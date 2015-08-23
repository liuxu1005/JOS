
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 80 19 10 f0       	push   $0xf0101980
f0100050:	e8 81 09 00 00       	call   f01009d6 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 ea 06 00 00       	call   f0100765 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 9c 19 10 f0       	push   $0xf010199c
f0100087:	e8 4a 09 00 00       	call   f01009d6 <cprintf>
f010008c:	83 c4 10             	add    $0x10,%esp
}
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 84 29 11 f0       	mov    $0xf0112984,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 11 14 00 00       	call   f01014c2 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 8c 04 00 00       	call   f0100542 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 b7 19 10 f0       	push   $0xf01019b7
f01000c3:	e8 0e 09 00 00       	call   f01009d6 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 87 07 00 00       	call   f0100868 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 80 29 11 f0 00 	cmpl   $0x0,0xf0112980
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 80 29 11 f0    	mov    %esi,0xf0112980

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 d2 19 10 f0       	push   $0xf01019d2
f0100110:	e8 c1 08 00 00       	call   f01009d6 <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 91 08 00 00       	call   f01009b0 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 0e 1a 10 f0 	movl   $0xf0101a0e,(%esp)
f0100126:	e8 ab 08 00 00       	call   f01009d6 <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 30 07 00 00       	call   f0100868 <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 ea 19 10 f0       	push   $0xf01019ea
f0100152:	e8 7f 08 00 00       	call   f01009d6 <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 4d 08 00 00       	call   f01009b0 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 0e 1a 10 f0 	movl   $0xf0101a0e,(%esp)
f010016a:	e8 67 08 00 00       	call   f01009d6 <cprintf>
	va_end(ap);
f010016f:	83 c4 10             	add    $0x10,%esp
}
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 08                	je     f010018c <serial_proc_data+0x15>
f0100184:	b2 f8                	mov    $0xf8,%dl
f0100186:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100187:	0f b6 c0             	movzbl %al,%eax
f010018a:	eb 05                	jmp    f0100191 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100191:	5d                   	pop    %ebp
f0100192:	c3                   	ret    

f0100193 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100193:	55                   	push   %ebp
f0100194:	89 e5                	mov    %esp,%ebp
f0100196:	53                   	push   %ebx
f0100197:	83 ec 04             	sub    $0x4,%esp
f010019a:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019c:	eb 2a                	jmp    f01001c8 <cons_intr+0x35>
		if (c == 0)
f010019e:	85 d2                	test   %edx,%edx
f01001a0:	74 26                	je     f01001c8 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a2:	a1 44 25 11 f0       	mov    0xf0112544,%eax
f01001a7:	8d 48 01             	lea    0x1(%eax),%ecx
f01001aa:	89 0d 44 25 11 f0    	mov    %ecx,0xf0112544
f01001b0:	88 90 40 23 11 f0    	mov    %dl,-0xfeedcc0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01001b6:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001bc:	75 0a                	jne    f01001c8 <cons_intr+0x35>
			cons.wpos = 0;
f01001be:	c7 05 44 25 11 f0 00 	movl   $0x0,0xf0112544
f01001c5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001c8:	ff d3                	call   *%ebx
f01001ca:	89 c2                	mov    %eax,%edx
f01001cc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001cf:	75 cd                	jne    f010019e <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d1:	83 c4 04             	add    $0x4,%esp
f01001d4:	5b                   	pop    %ebx
f01001d5:	5d                   	pop    %ebp
f01001d6:	c3                   	ret    

f01001d7 <kbd_proc_data>:
f01001d7:	ba 64 00 00 00       	mov    $0x64,%edx
f01001dc:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001dd:	a8 01                	test   $0x1,%al
f01001df:	0f 84 f0 00 00 00    	je     f01002d5 <kbd_proc_data+0xfe>
f01001e5:	b2 60                	mov    $0x60,%dl
f01001e7:	ec                   	in     (%dx),%al
f01001e8:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001ea:	3c e0                	cmp    $0xe0,%al
f01001ec:	75 0d                	jne    f01001fb <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001ee:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001f5:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001fa:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001fb:	55                   	push   %ebp
f01001fc:	89 e5                	mov    %esp,%ebp
f01001fe:	53                   	push   %ebx
f01001ff:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100202:	84 c0                	test   %al,%al
f0100204:	79 36                	jns    f010023c <kbd_proc_data+0x65>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100206:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010020c:	89 cb                	mov    %ecx,%ebx
f010020e:	83 e3 40             	and    $0x40,%ebx
f0100211:	83 e0 7f             	and    $0x7f,%eax
f0100214:	85 db                	test   %ebx,%ebx
f0100216:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100219:	0f b6 d2             	movzbl %dl,%edx
f010021c:	0f b6 82 80 1b 10 f0 	movzbl -0xfefe480(%edx),%eax
f0100223:	83 c8 40             	or     $0x40,%eax
f0100226:	0f b6 c0             	movzbl %al,%eax
f0100229:	f7 d0                	not    %eax
f010022b:	21 c8                	and    %ecx,%eax
f010022d:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f0100232:	b8 00 00 00 00       	mov    $0x0,%eax
f0100237:	e9 a1 00 00 00       	jmp    f01002dd <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010023c:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100242:	f6 c1 40             	test   $0x40,%cl
f0100245:	74 0e                	je     f0100255 <kbd_proc_data+0x7e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100247:	83 c8 80             	or     $0xffffff80,%eax
f010024a:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010024c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010024f:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100255:	0f b6 c2             	movzbl %dl,%eax
f0100258:	0f b6 90 80 1b 10 f0 	movzbl -0xfefe480(%eax),%edx
f010025f:	0b 15 00 23 11 f0    	or     0xf0112300,%edx
	shift ^= togglecode[data];
f0100265:	0f b6 88 80 1a 10 f0 	movzbl -0xfefe580(%eax),%ecx
f010026c:	31 ca                	xor    %ecx,%edx
f010026e:	89 15 00 23 11 f0    	mov    %edx,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100274:	89 d1                	mov    %edx,%ecx
f0100276:	83 e1 03             	and    $0x3,%ecx
f0100279:	8b 0c 8d 40 1a 10 f0 	mov    -0xfefe5c0(,%ecx,4),%ecx
f0100280:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f0100284:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f0100287:	f6 c2 08             	test   $0x8,%dl
f010028a:	74 1b                	je     f01002a7 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f010028c:	89 d8                	mov    %ebx,%eax
f010028e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100291:	83 f9 19             	cmp    $0x19,%ecx
f0100294:	77 05                	ja     f010029b <kbd_proc_data+0xc4>
			c += 'A' - 'a';
f0100296:	83 eb 20             	sub    $0x20,%ebx
f0100299:	eb 0c                	jmp    f01002a7 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f010029b:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f010029e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002a1:	83 f8 19             	cmp    $0x19,%eax
f01002a4:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002a7:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002ad:	75 2c                	jne    f01002db <kbd_proc_data+0x104>
f01002af:	f7 d2                	not    %edx
f01002b1:	f6 c2 06             	test   $0x6,%dl
f01002b4:	75 25                	jne    f01002db <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01002b6:	83 ec 0c             	sub    $0xc,%esp
f01002b9:	68 04 1a 10 f0       	push   $0xf0101a04
f01002be:	e8 13 07 00 00       	call   f01009d6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c3:	ba 92 00 00 00       	mov    $0x92,%edx
f01002c8:	b8 03 00 00 00       	mov    $0x3,%eax
f01002cd:	ee                   	out    %al,(%dx)
f01002ce:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d1:	89 d8                	mov    %ebx,%eax
f01002d3:	eb 08                	jmp    f01002dd <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002da:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002db:	89 d8                	mov    %ebx,%eax
}
f01002dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002e0:	c9                   	leave  
f01002e1:	c3                   	ret    

f01002e2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002e2:	55                   	push   %ebp
f01002e3:	89 e5                	mov    %esp,%ebp
f01002e5:	57                   	push   %edi
f01002e6:	56                   	push   %esi
f01002e7:	53                   	push   %ebx
f01002e8:	83 ec 1c             	sub    $0x1c,%esp
f01002eb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ed:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f2:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002f7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fc:	eb 09                	jmp    f0100307 <cons_putc+0x25>
f01002fe:	89 ca                	mov    %ecx,%edx
f0100300:	ec                   	in     (%dx),%al
f0100301:	ec                   	in     (%dx),%al
f0100302:	ec                   	in     (%dx),%al
f0100303:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100304:	83 c3 01             	add    $0x1,%ebx
f0100307:	89 f2                	mov    %esi,%edx
f0100309:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010030a:	a8 20                	test   $0x20,%al
f010030c:	75 08                	jne    f0100316 <cons_putc+0x34>
f010030e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100314:	7e e8                	jle    f01002fe <cons_putc+0x1c>
f0100316:	89 f8                	mov    %edi,%eax
f0100318:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100320:	89 f8                	mov    %edi,%eax
f0100322:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100323:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100328:	be 79 03 00 00       	mov    $0x379,%esi
f010032d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100332:	eb 09                	jmp    f010033d <cons_putc+0x5b>
f0100334:	89 ca                	mov    %ecx,%edx
f0100336:	ec                   	in     (%dx),%al
f0100337:	ec                   	in     (%dx),%al
f0100338:	ec                   	in     (%dx),%al
f0100339:	ec                   	in     (%dx),%al
f010033a:	83 c3 01             	add    $0x1,%ebx
f010033d:	89 f2                	mov    %esi,%edx
f010033f:	ec                   	in     (%dx),%al
f0100340:	84 c0                	test   %al,%al
f0100342:	78 08                	js     f010034c <cons_putc+0x6a>
f0100344:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010034a:	7e e8                	jle    f0100334 <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100351:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100355:	ee                   	out    %al,(%dx)
f0100356:	b2 7a                	mov    $0x7a,%dl
f0100358:	b8 0d 00 00 00       	mov    $0xd,%eax
f010035d:	ee                   	out    %al,(%dx)
f010035e:	b8 08 00 00 00       	mov    $0x8,%eax
f0100363:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100364:	89 fa                	mov    %edi,%edx
f0100366:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010036c:	89 f8                	mov    %edi,%eax
f010036e:	80 cc 07             	or     $0x7,%ah
f0100371:	85 d2                	test   %edx,%edx
f0100373:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100376:	89 f8                	mov    %edi,%eax
f0100378:	0f b6 c0             	movzbl %al,%eax
f010037b:	83 f8 09             	cmp    $0x9,%eax
f010037e:	74 74                	je     f01003f4 <cons_putc+0x112>
f0100380:	83 f8 09             	cmp    $0x9,%eax
f0100383:	7f 0a                	jg     f010038f <cons_putc+0xad>
f0100385:	83 f8 08             	cmp    $0x8,%eax
f0100388:	74 14                	je     f010039e <cons_putc+0xbc>
f010038a:	e9 99 00 00 00       	jmp    f0100428 <cons_putc+0x146>
f010038f:	83 f8 0a             	cmp    $0xa,%eax
f0100392:	74 3a                	je     f01003ce <cons_putc+0xec>
f0100394:	83 f8 0d             	cmp    $0xd,%eax
f0100397:	74 3d                	je     f01003d6 <cons_putc+0xf4>
f0100399:	e9 8a 00 00 00       	jmp    f0100428 <cons_putc+0x146>
	case '\b':
		if (crt_pos > 0) {
f010039e:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f01003a5:	66 85 c0             	test   %ax,%ax
f01003a8:	0f 84 e6 00 00 00    	je     f0100494 <cons_putc+0x1b2>
			crt_pos--;
f01003ae:	83 e8 01             	sub    $0x1,%eax
f01003b1:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003b7:	0f b7 c0             	movzwl %ax,%eax
f01003ba:	66 81 e7 00 ff       	and    $0xff00,%di
f01003bf:	83 cf 20             	or     $0x20,%edi
f01003c2:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f01003c8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003cc:	eb 78                	jmp    f0100446 <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ce:	66 83 05 48 25 11 f0 	addw   $0x50,0xf0112548
f01003d5:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003d6:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f01003dd:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e3:	c1 e8 16             	shr    $0x16,%eax
f01003e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e9:	c1 e0 04             	shl    $0x4,%eax
f01003ec:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
f01003f2:	eb 52                	jmp    f0100446 <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
f01003f4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f9:	e8 e4 fe ff ff       	call   f01002e2 <cons_putc>
		cons_putc(' ');
f01003fe:	b8 20 00 00 00       	mov    $0x20,%eax
f0100403:	e8 da fe ff ff       	call   f01002e2 <cons_putc>
		cons_putc(' ');
f0100408:	b8 20 00 00 00       	mov    $0x20,%eax
f010040d:	e8 d0 fe ff ff       	call   f01002e2 <cons_putc>
		cons_putc(' ');
f0100412:	b8 20 00 00 00       	mov    $0x20,%eax
f0100417:	e8 c6 fe ff ff       	call   f01002e2 <cons_putc>
		cons_putc(' ');
f010041c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100421:	e8 bc fe ff ff       	call   f01002e2 <cons_putc>
f0100426:	eb 1e                	jmp    f0100446 <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100428:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f010042f:	8d 50 01             	lea    0x1(%eax),%edx
f0100432:	66 89 15 48 25 11 f0 	mov    %dx,0xf0112548
f0100439:	0f b7 c0             	movzwl %ax,%eax
f010043c:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f0100442:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 3d 48 25 11 f0 	cmpw   $0x7cf,0xf0112548
f010044d:	cf 07 
f010044f:	76 43                	jbe    f0100494 <cons_putc+0x1b2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100451:	a1 4c 25 11 f0       	mov    0xf011254c,%eax
f0100456:	83 ec 04             	sub    $0x4,%esp
f0100459:	68 00 0f 00 00       	push   $0xf00
f010045e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100464:	52                   	push   %edx
f0100465:	50                   	push   %eax
f0100466:	e8 a4 10 00 00       	call   f010150f <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010046b:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f0100471:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100477:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010047d:	83 c4 10             	add    $0x10,%esp
f0100480:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100485:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100488:	39 d0                	cmp    %edx,%eax
f010048a:	75 f4                	jne    f0100480 <cons_putc+0x19e>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010048c:	66 83 2d 48 25 11 f0 	subw   $0x50,0xf0112548
f0100493:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100494:	8b 0d 50 25 11 f0    	mov    0xf0112550,%ecx
f010049a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010049f:	89 ca                	mov    %ecx,%edx
f01004a1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a2:	0f b7 1d 48 25 11 f0 	movzwl 0xf0112548,%ebx
f01004a9:	8d 71 01             	lea    0x1(%ecx),%esi
f01004ac:	89 d8                	mov    %ebx,%eax
f01004ae:	66 c1 e8 08          	shr    $0x8,%ax
f01004b2:	89 f2                	mov    %esi,%edx
f01004b4:	ee                   	out    %al,(%dx)
f01004b5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ba:	89 ca                	mov    %ecx,%edx
f01004bc:	ee                   	out    %al,(%dx)
f01004bd:	89 d8                	mov    %ebx,%eax
f01004bf:	89 f2                	mov    %esi,%edx
f01004c1:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004c5:	5b                   	pop    %ebx
f01004c6:	5e                   	pop    %esi
f01004c7:	5f                   	pop    %edi
f01004c8:	5d                   	pop    %ebp
f01004c9:	c3                   	ret    

f01004ca <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004ca:	80 3d 54 25 11 f0 00 	cmpb   $0x0,0xf0112554
f01004d1:	74 11                	je     f01004e4 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004d3:	55                   	push   %ebp
f01004d4:	89 e5                	mov    %esp,%ebp
f01004d6:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004d9:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004de:	e8 b0 fc ff ff       	call   f0100193 <cons_intr>
}
f01004e3:	c9                   	leave  
f01004e4:	f3 c3                	repz ret 

f01004e6 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004e6:	55                   	push   %ebp
f01004e7:	89 e5                	mov    %esp,%ebp
f01004e9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004ec:	b8 d7 01 10 f0       	mov    $0xf01001d7,%eax
f01004f1:	e8 9d fc ff ff       	call   f0100193 <cons_intr>
}
f01004f6:	c9                   	leave  
f01004f7:	c3                   	ret    

f01004f8 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004f8:	55                   	push   %ebp
f01004f9:	89 e5                	mov    %esp,%ebp
f01004fb:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004fe:	e8 c7 ff ff ff       	call   f01004ca <serial_intr>
	kbd_intr();
f0100503:	e8 de ff ff ff       	call   f01004e6 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100508:	a1 40 25 11 f0       	mov    0xf0112540,%eax
f010050d:	3b 05 44 25 11 f0    	cmp    0xf0112544,%eax
f0100513:	74 26                	je     f010053b <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100515:	8d 50 01             	lea    0x1(%eax),%edx
f0100518:	89 15 40 25 11 f0    	mov    %edx,0xf0112540
f010051e:	0f b6 88 40 23 11 f0 	movzbl -0xfeedcc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100525:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100527:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010052d:	75 11                	jne    f0100540 <cons_getc+0x48>
			cons.rpos = 0;
f010052f:	c7 05 40 25 11 f0 00 	movl   $0x0,0xf0112540
f0100536:	00 00 00 
f0100539:	eb 05                	jmp    f0100540 <cons_getc+0x48>
		return c;
	}
	return 0;
f010053b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100540:	c9                   	leave  
f0100541:	c3                   	ret    

f0100542 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100542:	55                   	push   %ebp
f0100543:	89 e5                	mov    %esp,%ebp
f0100545:	57                   	push   %edi
f0100546:	56                   	push   %esi
f0100547:	53                   	push   %ebx
f0100548:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010054b:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100552:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100559:	5a a5 
	if (*cp != 0xA55A) {
f010055b:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100562:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100566:	74 11                	je     f0100579 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100568:	c7 05 50 25 11 f0 b4 	movl   $0x3b4,0xf0112550
f010056f:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100572:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100577:	eb 16                	jmp    f010058f <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100579:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100580:	c7 05 50 25 11 f0 d4 	movl   $0x3d4,0xf0112550
f0100587:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010058a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010058f:	8b 3d 50 25 11 f0    	mov    0xf0112550,%edi
f0100595:	b8 0e 00 00 00       	mov    $0xe,%eax
f010059a:	89 fa                	mov    %edi,%edx
f010059c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010059d:	8d 4f 01             	lea    0x1(%edi),%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a0:	89 ca                	mov    %ecx,%edx
f01005a2:	ec                   	in     (%dx),%al
f01005a3:	0f b6 c0             	movzbl %al,%eax
f01005a6:	c1 e0 08             	shl    $0x8,%eax
f01005a9:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ab:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b0:	89 fa                	mov    %edi,%edx
f01005b2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b3:	89 ca                	mov    %ecx,%edx
f01005b5:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005b6:	89 35 4c 25 11 f0    	mov    %esi,0xf011254c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005bc:	0f b6 c8             	movzbl %al,%ecx
f01005bf:	89 d8                	mov    %ebx,%eax
f01005c1:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005c3:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c9:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d3:	89 da                	mov    %ebx,%edx
f01005d5:	ee                   	out    %al,(%dx)
f01005d6:	b2 fb                	mov    $0xfb,%dl
f01005d8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005dd:	ee                   	out    %al,(%dx)
f01005de:	be f8 03 00 00       	mov    $0x3f8,%esi
f01005e3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005e8:	89 f2                	mov    %esi,%edx
f01005ea:	ee                   	out    %al,(%dx)
f01005eb:	b2 f9                	mov    $0xf9,%dl
f01005ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f2:	ee                   	out    %al,(%dx)
f01005f3:	b2 fb                	mov    $0xfb,%dl
f01005f5:	b8 03 00 00 00       	mov    $0x3,%eax
f01005fa:	ee                   	out    %al,(%dx)
f01005fb:	b2 fc                	mov    $0xfc,%dl
f01005fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100602:	ee                   	out    %al,(%dx)
f0100603:	b2 f9                	mov    $0xf9,%dl
f0100605:	b8 01 00 00 00       	mov    $0x1,%eax
f010060a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060b:	b2 fd                	mov    $0xfd,%dl
f010060d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010060e:	3c ff                	cmp    $0xff,%al
f0100610:	0f 95 c1             	setne  %cl
f0100613:	88 0d 54 25 11 f0    	mov    %cl,0xf0112554
f0100619:	89 da                	mov    %ebx,%edx
f010061b:	ec                   	in     (%dx),%al
f010061c:	89 f2                	mov    %esi,%edx
f010061e:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010061f:	84 c9                	test   %cl,%cl
f0100621:	75 10                	jne    f0100633 <cons_init+0xf1>
		cprintf("Serial port does not exist!\n");
f0100623:	83 ec 0c             	sub    $0xc,%esp
f0100626:	68 10 1a 10 f0       	push   $0xf0101a10
f010062b:	e8 a6 03 00 00       	call   f01009d6 <cprintf>
f0100630:	83 c4 10             	add    $0x10,%esp
}
f0100633:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100636:	5b                   	pop    %ebx
f0100637:	5e                   	pop    %esi
f0100638:	5f                   	pop    %edi
f0100639:	5d                   	pop    %ebp
f010063a:	c3                   	ret    

f010063b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010063b:	55                   	push   %ebp
f010063c:	89 e5                	mov    %esp,%ebp
f010063e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100641:	8b 45 08             	mov    0x8(%ebp),%eax
f0100644:	e8 99 fc ff ff       	call   f01002e2 <cons_putc>
}
f0100649:	c9                   	leave  
f010064a:	c3                   	ret    

f010064b <getchar>:

int
getchar(void)
{
f010064b:	55                   	push   %ebp
f010064c:	89 e5                	mov    %esp,%ebp
f010064e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100651:	e8 a2 fe ff ff       	call   f01004f8 <cons_getc>
f0100656:	85 c0                	test   %eax,%eax
f0100658:	74 f7                	je     f0100651 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010065a:	c9                   	leave  
f010065b:	c3                   	ret    

f010065c <iscons>:

int
iscons(int fdnum)
{
f010065c:	55                   	push   %ebp
f010065d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010065f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100664:	5d                   	pop    %ebp
f0100665:	c3                   	ret    

f0100666 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100666:	55                   	push   %ebp
f0100667:	89 e5                	mov    %esp,%ebp
f0100669:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010066c:	68 80 1c 10 f0       	push   $0xf0101c80
f0100671:	68 9e 1c 10 f0       	push   $0xf0101c9e
f0100676:	68 a3 1c 10 f0       	push   $0xf0101ca3
f010067b:	e8 56 03 00 00       	call   f01009d6 <cprintf>
f0100680:	83 c4 0c             	add    $0xc,%esp
f0100683:	68 54 1d 10 f0       	push   $0xf0101d54
f0100688:	68 ac 1c 10 f0       	push   $0xf0101cac
f010068d:	68 a3 1c 10 f0       	push   $0xf0101ca3
f0100692:	e8 3f 03 00 00       	call   f01009d6 <cprintf>
f0100697:	83 c4 0c             	add    $0xc,%esp
f010069a:	68 b5 1c 10 f0       	push   $0xf0101cb5
f010069f:	68 c8 1c 10 f0       	push   $0xf0101cc8
f01006a4:	68 a3 1c 10 f0       	push   $0xf0101ca3
f01006a9:	e8 28 03 00 00       	call   f01009d6 <cprintf>
	return 0;
}
f01006ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01006b3:	c9                   	leave  
f01006b4:	c3                   	ret    

f01006b5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006b5:	55                   	push   %ebp
f01006b6:	89 e5                	mov    %esp,%ebp
f01006b8:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006bb:	68 d2 1c 10 f0       	push   $0xf0101cd2
f01006c0:	e8 11 03 00 00       	call   f01009d6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006c5:	83 c4 08             	add    $0x8,%esp
f01006c8:	68 0c 00 10 00       	push   $0x10000c
f01006cd:	68 7c 1d 10 f0       	push   $0xf0101d7c
f01006d2:	e8 ff 02 00 00       	call   f01009d6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006d7:	83 c4 0c             	add    $0xc,%esp
f01006da:	68 0c 00 10 00       	push   $0x10000c
f01006df:	68 0c 00 10 f0       	push   $0xf010000c
f01006e4:	68 a4 1d 10 f0       	push   $0xf0101da4
f01006e9:	e8 e8 02 00 00       	call   f01009d6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006ee:	83 c4 0c             	add    $0xc,%esp
f01006f1:	68 75 19 10 00       	push   $0x101975
f01006f6:	68 75 19 10 f0       	push   $0xf0101975
f01006fb:	68 c8 1d 10 f0       	push   $0xf0101dc8
f0100700:	e8 d1 02 00 00       	call   f01009d6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100705:	83 c4 0c             	add    $0xc,%esp
f0100708:	68 00 23 11 00       	push   $0x112300
f010070d:	68 00 23 11 f0       	push   $0xf0112300
f0100712:	68 ec 1d 10 f0       	push   $0xf0101dec
f0100717:	e8 ba 02 00 00       	call   f01009d6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010071c:	83 c4 0c             	add    $0xc,%esp
f010071f:	68 84 29 11 00       	push   $0x112984
f0100724:	68 84 29 11 f0       	push   $0xf0112984
f0100729:	68 10 1e 10 f0       	push   $0xf0101e10
f010072e:	e8 a3 02 00 00       	call   f01009d6 <cprintf>
f0100733:	b8 83 2d 11 f0       	mov    $0xf0112d83,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100738:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010073d:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100740:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100745:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010074b:	85 c0                	test   %eax,%eax
f010074d:	0f 48 c2             	cmovs  %edx,%eax
f0100750:	c1 f8 0a             	sar    $0xa,%eax
f0100753:	50                   	push   %eax
f0100754:	68 34 1e 10 f0       	push   $0xf0101e34
f0100759:	e8 78 02 00 00       	call   f01009d6 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010075e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100763:	c9                   	leave  
f0100764:	c3                   	ret    

f0100765 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100765:	55                   	push   %ebp
f0100766:	89 e5                	mov    %esp,%ebp
f0100768:	57                   	push   %edi
f0100769:	56                   	push   %esi
f010076a:	53                   	push   %ebx
f010076b:	81 ec a8 00 00 00    	sub    $0xa8,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100771:	89 e8                	mov    %ebp,%eax
	// Your code here.
        uint32_t *ebp;
        uint32_t eip;
        uint32_t arg0, arg1, arg2, arg3, arg4;
        ebp = (uint32_t *)read_ebp();
f0100773:	89 c3                	mov    %eax,%ebx
        eip = ebp[1];
f0100775:	8b 70 04             	mov    0x4(%eax),%esi
        arg0 = ebp[2];
f0100778:	8b 50 08             	mov    0x8(%eax),%edx
f010077b:	89 d7                	mov    %edx,%edi
        arg1 = ebp[3];
f010077d:	8b 48 0c             	mov    0xc(%eax),%ecx
f0100780:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
        arg2 = ebp[4];
f0100786:	8b 50 10             	mov    0x10(%eax),%edx
f0100789:	89 95 58 ff ff ff    	mov    %edx,-0xa8(%ebp)
        arg3 = ebp[5];
f010078f:	8b 48 14             	mov    0x14(%eax),%ecx
f0100792:	89 8d 64 ff ff ff    	mov    %ecx,-0x9c(%ebp)
        arg4 = ebp[6];
f0100798:	8b 40 18             	mov    0x18(%eax),%eax
f010079b:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
        cprintf("Stack backtrace:\n");
f01007a1:	68 eb 1c 10 f0       	push   $0xf0101ceb
f01007a6:	e8 2b 02 00 00       	call   f01009d6 <cprintf>
        while(ebp != 0) {
f01007ab:	83 c4 10             	add    $0x10,%esp
f01007ae:	89 f8                	mov    %edi,%eax
f01007b0:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
f01007b6:	8b 8d 58 ff ff ff    	mov    -0xa8(%ebp),%ecx
f01007bc:	e9 92 00 00 00       	jmp    f0100853 <mon_backtrace+0xee>
             
             char fn[100];
              
             cprintf("  ebp  %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
f01007c1:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f01007c7:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
f01007cd:	51                   	push   %ecx
f01007ce:	52                   	push   %edx
f01007cf:	50                   	push   %eax
f01007d0:	56                   	push   %esi
f01007d1:	53                   	push   %ebx
f01007d2:	68 60 1e 10 f0       	push   $0xf0101e60
f01007d7:	e8 fa 01 00 00       	call   f01009d6 <cprintf>
                                       ebp, eip, arg0, arg1, arg2, arg3, arg4);
             struct Eipdebuginfo info;
             debuginfo_eip(eip, &info);
f01007dc:	83 c4 18             	add    $0x18,%esp
f01007df:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f01007e5:	50                   	push   %eax
f01007e6:	56                   	push   %esi
f01007e7:	e8 00 03 00 00       	call   f0100aec <debuginfo_eip>
            
             snprintf(fn, info.eip_fn_namelen+1, "%s", info.eip_fn_name);
f01007ec:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
f01007f2:	68 fd 1c 10 f0       	push   $0xf0101cfd
f01007f7:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
f01007fd:	83 c0 01             	add    $0x1,%eax
f0100800:	50                   	push   %eax
f0100801:	8d 45 84             	lea    -0x7c(%ebp),%eax
f0100804:	50                   	push   %eax
f0100805:	e8 47 0a 00 00       	call   f0101251 <snprintf>
            
             cprintf("         %s:%u: %s+%u\n", info.eip_file, info.eip_line, fn, eip - info.eip_fn_addr);
f010080a:	83 c4 14             	add    $0x14,%esp
f010080d:	89 f0                	mov    %esi,%eax
f010080f:	2b 85 7c ff ff ff    	sub    -0x84(%ebp),%eax
f0100815:	50                   	push   %eax
f0100816:	8d 45 84             	lea    -0x7c(%ebp),%eax
f0100819:	50                   	push   %eax
f010081a:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
f0100820:	ff b5 6c ff ff ff    	pushl  -0x94(%ebp)
f0100826:	68 00 1d 10 f0       	push   $0xf0101d00
f010082b:	e8 a6 01 00 00       	call   f01009d6 <cprintf>
             ebp = (uint32_t *)ebp[0];
f0100830:	8b 1b                	mov    (%ebx),%ebx
             eip = ebp[1];
f0100832:	8b 73 04             	mov    0x4(%ebx),%esi
             arg0 = ebp[2];
f0100835:	8b 43 08             	mov    0x8(%ebx),%eax
             arg1 = ebp[3];
f0100838:	8b 53 0c             	mov    0xc(%ebx),%edx
             arg2 = ebp[4];
f010083b:	8b 4b 10             	mov    0x10(%ebx),%ecx
             arg3 = ebp[5];
f010083e:	8b 7b 14             	mov    0x14(%ebx),%edi
f0100841:	89 bd 64 ff ff ff    	mov    %edi,-0x9c(%ebp)
             arg4 = ebp[6];
f0100847:	8b 7b 18             	mov    0x18(%ebx),%edi
f010084a:	89 bd 60 ff ff ff    	mov    %edi,-0xa0(%ebp)
f0100850:	83 c4 20             	add    $0x20,%esp
        arg1 = ebp[3];
        arg2 = ebp[4];
        arg3 = ebp[5];
        arg4 = ebp[6];
        cprintf("Stack backtrace:\n");
        while(ebp != 0) {
f0100853:	85 db                	test   %ebx,%ebx
f0100855:	0f 85 66 ff ff ff    	jne    f01007c1 <mon_backtrace+0x5c>
             arg2 = ebp[4];
             arg3 = ebp[5];
             arg4 = ebp[6];
        }
	return 0;
}
f010085b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100860:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100863:	5b                   	pop    %ebx
f0100864:	5e                   	pop    %esi
f0100865:	5f                   	pop    %edi
f0100866:	5d                   	pop    %ebp
f0100867:	c3                   	ret    

f0100868 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100868:	55                   	push   %ebp
f0100869:	89 e5                	mov    %esp,%ebp
f010086b:	57                   	push   %edi
f010086c:	56                   	push   %esi
f010086d:	53                   	push   %ebx
f010086e:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100871:	68 98 1e 10 f0       	push   $0xf0101e98
f0100876:	e8 5b 01 00 00       	call   f01009d6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010087b:	c7 04 24 bc 1e 10 f0 	movl   $0xf0101ebc,(%esp)
f0100882:	e8 4f 01 00 00       	call   f01009d6 <cprintf>
f0100887:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010088a:	83 ec 0c             	sub    $0xc,%esp
f010088d:	68 17 1d 10 f0       	push   $0xf0101d17
f0100892:	e8 d4 09 00 00       	call   f010126b <readline>
f0100897:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100899:	83 c4 10             	add    $0x10,%esp
f010089c:	85 c0                	test   %eax,%eax
f010089e:	74 ea                	je     f010088a <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008a0:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008a7:	be 00 00 00 00       	mov    $0x0,%esi
f01008ac:	eb 0a                	jmp    f01008b8 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008ae:	c6 03 00             	movb   $0x0,(%ebx)
f01008b1:	89 f7                	mov    %esi,%edi
f01008b3:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01008b6:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008b8:	0f b6 03             	movzbl (%ebx),%eax
f01008bb:	84 c0                	test   %al,%al
f01008bd:	74 63                	je     f0100922 <monitor+0xba>
f01008bf:	83 ec 08             	sub    $0x8,%esp
f01008c2:	0f be c0             	movsbl %al,%eax
f01008c5:	50                   	push   %eax
f01008c6:	68 1b 1d 10 f0       	push   $0xf0101d1b
f01008cb:	e8 b5 0b 00 00       	call   f0101485 <strchr>
f01008d0:	83 c4 10             	add    $0x10,%esp
f01008d3:	85 c0                	test   %eax,%eax
f01008d5:	75 d7                	jne    f01008ae <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008d7:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008da:	74 46                	je     f0100922 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008dc:	83 fe 0f             	cmp    $0xf,%esi
f01008df:	75 14                	jne    f01008f5 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008e1:	83 ec 08             	sub    $0x8,%esp
f01008e4:	6a 10                	push   $0x10
f01008e6:	68 20 1d 10 f0       	push   $0xf0101d20
f01008eb:	e8 e6 00 00 00       	call   f01009d6 <cprintf>
f01008f0:	83 c4 10             	add    $0x10,%esp
f01008f3:	eb 95                	jmp    f010088a <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008f5:	8d 7e 01             	lea    0x1(%esi),%edi
f01008f8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008fc:	eb 03                	jmp    f0100901 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008fe:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100901:	0f b6 03             	movzbl (%ebx),%eax
f0100904:	84 c0                	test   %al,%al
f0100906:	74 ae                	je     f01008b6 <monitor+0x4e>
f0100908:	83 ec 08             	sub    $0x8,%esp
f010090b:	0f be c0             	movsbl %al,%eax
f010090e:	50                   	push   %eax
f010090f:	68 1b 1d 10 f0       	push   $0xf0101d1b
f0100914:	e8 6c 0b 00 00       	call   f0101485 <strchr>
f0100919:	83 c4 10             	add    $0x10,%esp
f010091c:	85 c0                	test   %eax,%eax
f010091e:	74 de                	je     f01008fe <monitor+0x96>
f0100920:	eb 94                	jmp    f01008b6 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100922:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100929:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010092a:	85 f6                	test   %esi,%esi
f010092c:	0f 84 58 ff ff ff    	je     f010088a <monitor+0x22>
f0100932:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100937:	83 ec 08             	sub    $0x8,%esp
f010093a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010093d:	ff 34 85 00 1f 10 f0 	pushl  -0xfefe100(,%eax,4)
f0100944:	ff 75 a8             	pushl  -0x58(%ebp)
f0100947:	e8 db 0a 00 00       	call   f0101427 <strcmp>
f010094c:	83 c4 10             	add    $0x10,%esp
f010094f:	85 c0                	test   %eax,%eax
f0100951:	75 22                	jne    f0100975 <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100953:	83 ec 04             	sub    $0x4,%esp
f0100956:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100959:	ff 75 08             	pushl  0x8(%ebp)
f010095c:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010095f:	52                   	push   %edx
f0100960:	56                   	push   %esi
f0100961:	ff 14 85 08 1f 10 f0 	call   *-0xfefe0f8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100968:	83 c4 10             	add    $0x10,%esp
f010096b:	85 c0                	test   %eax,%eax
f010096d:	0f 89 17 ff ff ff    	jns    f010088a <monitor+0x22>
f0100973:	eb 20                	jmp    f0100995 <monitor+0x12d>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100975:	83 c3 01             	add    $0x1,%ebx
f0100978:	83 fb 03             	cmp    $0x3,%ebx
f010097b:	75 ba                	jne    f0100937 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010097d:	83 ec 08             	sub    $0x8,%esp
f0100980:	ff 75 a8             	pushl  -0x58(%ebp)
f0100983:	68 3d 1d 10 f0       	push   $0xf0101d3d
f0100988:	e8 49 00 00 00       	call   f01009d6 <cprintf>
f010098d:	83 c4 10             	add    $0x10,%esp
f0100990:	e9 f5 fe ff ff       	jmp    f010088a <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100995:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100998:	5b                   	pop    %ebx
f0100999:	5e                   	pop    %esi
f010099a:	5f                   	pop    %edi
f010099b:	5d                   	pop    %ebp
f010099c:	c3                   	ret    

f010099d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010099d:	55                   	push   %ebp
f010099e:	89 e5                	mov    %esp,%ebp
f01009a0:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01009a3:	ff 75 08             	pushl  0x8(%ebp)
f01009a6:	e8 90 fc ff ff       	call   f010063b <cputchar>
f01009ab:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01009ae:	c9                   	leave  
f01009af:	c3                   	ret    

f01009b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01009b0:	55                   	push   %ebp
f01009b1:	89 e5                	mov    %esp,%ebp
f01009b3:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01009b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009bd:	ff 75 0c             	pushl  0xc(%ebp)
f01009c0:	ff 75 08             	pushl  0x8(%ebp)
f01009c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009c6:	50                   	push   %eax
f01009c7:	68 9d 09 10 f0       	push   $0xf010099d
f01009cc:	e8 7e 04 00 00       	call   f0100e4f <vprintfmt>
	return cnt;
}
f01009d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009d4:	c9                   	leave  
f01009d5:	c3                   	ret    

f01009d6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009d6:	55                   	push   %ebp
f01009d7:	89 e5                	mov    %esp,%ebp
f01009d9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009df:	50                   	push   %eax
f01009e0:	ff 75 08             	pushl  0x8(%ebp)
f01009e3:	e8 c8 ff ff ff       	call   f01009b0 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009e8:	c9                   	leave  
f01009e9:	c3                   	ret    

f01009ea <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009ea:	55                   	push   %ebp
f01009eb:	89 e5                	mov    %esp,%ebp
f01009ed:	57                   	push   %edi
f01009ee:	56                   	push   %esi
f01009ef:	53                   	push   %ebx
f01009f0:	83 ec 14             	sub    $0x14,%esp
f01009f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009fc:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009ff:	8b 1a                	mov    (%edx),%ebx
f0100a01:	8b 01                	mov    (%ecx),%eax
f0100a03:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a06:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100a0d:	e9 88 00 00 00       	jmp    f0100a9a <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0100a12:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a15:	01 d8                	add    %ebx,%eax
f0100a17:	89 c6                	mov    %eax,%esi
f0100a19:	c1 ee 1f             	shr    $0x1f,%esi
f0100a1c:	01 c6                	add    %eax,%esi
f0100a1e:	d1 fe                	sar    %esi
f0100a20:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a23:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a26:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100a29:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a2b:	eb 03                	jmp    f0100a30 <stab_binsearch+0x46>
			m--;
f0100a2d:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a30:	39 c3                	cmp    %eax,%ebx
f0100a32:	7f 1f                	jg     f0100a53 <stab_binsearch+0x69>
f0100a34:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100a38:	83 ea 0c             	sub    $0xc,%edx
f0100a3b:	39 f9                	cmp    %edi,%ecx
f0100a3d:	75 ee                	jne    f0100a2d <stab_binsearch+0x43>
f0100a3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a42:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a45:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a48:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a4c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a4f:	76 18                	jbe    f0100a69 <stab_binsearch+0x7f>
f0100a51:	eb 05                	jmp    f0100a58 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a53:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100a56:	eb 42                	jmp    f0100a9a <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100a58:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a5b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a5d:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a60:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a67:	eb 31                	jmp    f0100a9a <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a69:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a6c:	73 17                	jae    f0100a85 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0100a6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100a71:	83 e8 01             	sub    $0x1,%eax
f0100a74:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a77:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a7a:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a7c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a83:	eb 15                	jmp    f0100a9a <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a85:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a88:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100a8b:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f0100a8d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a91:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a93:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a9a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a9d:	0f 8e 6f ff ff ff    	jle    f0100a12 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100aa3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100aa7:	75 0f                	jne    f0100ab8 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0100aa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100aac:	8b 00                	mov    (%eax),%eax
f0100aae:	83 e8 01             	sub    $0x1,%eax
f0100ab1:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100ab4:	89 06                	mov    %eax,(%esi)
f0100ab6:	eb 2c                	jmp    f0100ae4 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ab8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100abb:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100abd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ac0:	8b 0e                	mov    (%esi),%ecx
f0100ac2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ac5:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100ac8:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100acb:	eb 03                	jmp    f0100ad0 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100acd:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ad0:	39 c8                	cmp    %ecx,%eax
f0100ad2:	7e 0b                	jle    f0100adf <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0100ad4:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100ad8:	83 ea 0c             	sub    $0xc,%edx
f0100adb:	39 fb                	cmp    %edi,%ebx
f0100add:	75 ee                	jne    f0100acd <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100adf:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ae2:	89 06                	mov    %eax,(%esi)
	}
}
f0100ae4:	83 c4 14             	add    $0x14,%esp
f0100ae7:	5b                   	pop    %ebx
f0100ae8:	5e                   	pop    %esi
f0100ae9:	5f                   	pop    %edi
f0100aea:	5d                   	pop    %ebp
f0100aeb:	c3                   	ret    

f0100aec <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100aec:	55                   	push   %ebp
f0100aed:	89 e5                	mov    %esp,%ebp
f0100aef:	57                   	push   %edi
f0100af0:	56                   	push   %esi
f0100af1:	53                   	push   %ebx
f0100af2:	83 ec 3c             	sub    $0x3c,%esp
f0100af5:	8b 75 08             	mov    0x8(%ebp),%esi
f0100af8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100afb:	c7 03 24 1f 10 f0    	movl   $0xf0101f24,(%ebx)
	info->eip_line = 0;
f0100b01:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100b08:	c7 43 08 24 1f 10 f0 	movl   $0xf0101f24,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100b0f:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100b16:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b19:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b20:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b26:	76 11                	jbe    f0100b39 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b28:	b8 6c 74 10 f0       	mov    $0xf010746c,%eax
f0100b2d:	3d 55 5b 10 f0       	cmp    $0xf0105b55,%eax
f0100b32:	77 19                	ja     f0100b4d <debuginfo_eip+0x61>
f0100b34:	e9 a9 01 00 00       	jmp    f0100ce2 <debuginfo_eip+0x1f6>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b39:	83 ec 04             	sub    $0x4,%esp
f0100b3c:	68 2e 1f 10 f0       	push   $0xf0101f2e
f0100b41:	6a 7f                	push   $0x7f
f0100b43:	68 3b 1f 10 f0       	push   $0xf0101f3b
f0100b48:	e8 99 f5 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b4d:	80 3d 6b 74 10 f0 00 	cmpb   $0x0,0xf010746b
f0100b54:	0f 85 8f 01 00 00    	jne    f0100ce9 <debuginfo_eip+0x1fd>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b5a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b61:	b8 54 5b 10 f0       	mov    $0xf0105b54,%eax
f0100b66:	2d 70 21 10 f0       	sub    $0xf0102170,%eax
f0100b6b:	c1 f8 02             	sar    $0x2,%eax
f0100b6e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b74:	83 e8 01             	sub    $0x1,%eax
f0100b77:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b7a:	83 ec 08             	sub    $0x8,%esp
f0100b7d:	56                   	push   %esi
f0100b7e:	6a 64                	push   $0x64
f0100b80:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b83:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b86:	b8 70 21 10 f0       	mov    $0xf0102170,%eax
f0100b8b:	e8 5a fe ff ff       	call   f01009ea <stab_binsearch>
	if (lfile == 0)
f0100b90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b93:	83 c4 10             	add    $0x10,%esp
f0100b96:	85 c0                	test   %eax,%eax
f0100b98:	0f 84 52 01 00 00    	je     f0100cf0 <debuginfo_eip+0x204>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b9e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ba1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ba7:	83 ec 08             	sub    $0x8,%esp
f0100baa:	56                   	push   %esi
f0100bab:	6a 24                	push   $0x24
f0100bad:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100bb0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bb3:	b8 70 21 10 f0       	mov    $0xf0102170,%eax
f0100bb8:	e8 2d fe ff ff       	call   f01009ea <stab_binsearch>

	if (lfun <= rfun) {
f0100bbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100bc0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100bc3:	83 c4 10             	add    $0x10,%esp
f0100bc6:	39 d0                	cmp    %edx,%eax
f0100bc8:	7f 40                	jg     f0100c0a <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100bca:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100bcd:	c1 e1 02             	shl    $0x2,%ecx
f0100bd0:	8d b9 70 21 10 f0    	lea    -0xfefde90(%ecx),%edi
f0100bd6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100bd9:	8b b9 70 21 10 f0    	mov    -0xfefde90(%ecx),%edi
f0100bdf:	b9 6c 74 10 f0       	mov    $0xf010746c,%ecx
f0100be4:	81 e9 55 5b 10 f0    	sub    $0xf0105b55,%ecx
f0100bea:	39 cf                	cmp    %ecx,%edi
f0100bec:	73 09                	jae    f0100bf7 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100bee:	81 c7 55 5b 10 f0    	add    $0xf0105b55,%edi
f0100bf4:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100bf7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100bfa:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100bfd:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100c00:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100c02:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100c05:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c08:	eb 0f                	jmp    f0100c19 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c0a:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c10:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100c13:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c16:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c19:	83 ec 08             	sub    $0x8,%esp
f0100c1c:	6a 3a                	push   $0x3a
f0100c1e:	ff 73 08             	pushl  0x8(%ebx)
f0100c21:	e8 80 08 00 00       	call   f01014a6 <strfind>
f0100c26:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c29:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100c2c:	83 c4 08             	add    $0x8,%esp
f0100c2f:	56                   	push   %esi
f0100c30:	6a 44                	push   $0x44
f0100c32:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100c35:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100c38:	b8 70 21 10 f0       	mov    $0xf0102170,%eax
f0100c3d:	e8 a8 fd ff ff       	call   f01009ea <stab_binsearch>
        if(lline <= rline)
f0100c42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c45:	83 c4 10             	add    $0x10,%esp
f0100c48:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100c4b:	0f 8f a6 00 00 00    	jg     f0100cf7 <debuginfo_eip+0x20b>
              info->eip_line = stabs[lline].n_desc;
f0100c51:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100c54:	0f b7 04 85 76 21 10 	movzwl -0xfefde8a(,%eax,4),%eax
f0100c5b:	f0 
f0100c5c:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c65:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c68:	8d 14 95 70 21 10 f0 	lea    -0xfefde90(,%edx,4),%edx
f0100c6f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100c72:	eb 06                	jmp    f0100c7a <debuginfo_eip+0x18e>
f0100c74:	83 e8 01             	sub    $0x1,%eax
f0100c77:	83 ea 0c             	sub    $0xc,%edx
f0100c7a:	39 c7                	cmp    %eax,%edi
f0100c7c:	7f 23                	jg     f0100ca1 <debuginfo_eip+0x1b5>
	       && stabs[lline].n_type != N_SOL
f0100c7e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c82:	80 f9 84             	cmp    $0x84,%cl
f0100c85:	74 7e                	je     f0100d05 <debuginfo_eip+0x219>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c87:	80 f9 64             	cmp    $0x64,%cl
f0100c8a:	75 e8                	jne    f0100c74 <debuginfo_eip+0x188>
f0100c8c:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100c90:	74 e2                	je     f0100c74 <debuginfo_eip+0x188>
f0100c92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100c95:	eb 71                	jmp    f0100d08 <debuginfo_eip+0x21c>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c97:	81 c2 55 5b 10 f0    	add    $0xf0105b55,%edx
f0100c9d:	89 13                	mov    %edx,(%ebx)
f0100c9f:	eb 03                	jmp    f0100ca4 <debuginfo_eip+0x1b8>
f0100ca1:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100ca4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ca7:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100caa:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100caf:	39 f2                	cmp    %esi,%edx
f0100cb1:	7d 76                	jge    f0100d29 <debuginfo_eip+0x23d>
		for (lline = lfun + 1;
f0100cb3:	83 c2 01             	add    $0x1,%edx
f0100cb6:	89 d0                	mov    %edx,%eax
f0100cb8:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100cbb:	8d 14 95 70 21 10 f0 	lea    -0xfefde90(,%edx,4),%edx
f0100cc2:	eb 04                	jmp    f0100cc8 <debuginfo_eip+0x1dc>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100cc4:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100cc8:	39 c6                	cmp    %eax,%esi
f0100cca:	7e 32                	jle    f0100cfe <debuginfo_eip+0x212>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ccc:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100cd0:	83 c0 01             	add    $0x1,%eax
f0100cd3:	83 c2 0c             	add    $0xc,%edx
f0100cd6:	80 f9 a0             	cmp    $0xa0,%cl
f0100cd9:	74 e9                	je     f0100cc4 <debuginfo_eip+0x1d8>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cdb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ce0:	eb 47                	jmp    f0100d29 <debuginfo_eip+0x23d>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100ce2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ce7:	eb 40                	jmp    f0100d29 <debuginfo_eip+0x23d>
f0100ce9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cee:	eb 39                	jmp    f0100d29 <debuginfo_eip+0x23d>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100cf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cf5:	eb 32                	jmp    f0100d29 <debuginfo_eip+0x23d>
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
        if(lline <= rline)
              info->eip_line = stabs[lline].n_desc;
        else
              return -1;
f0100cf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cfc:	eb 2b                	jmp    f0100d29 <debuginfo_eip+0x23d>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cfe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d03:	eb 24                	jmp    f0100d29 <debuginfo_eip+0x23d>
f0100d05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100d08:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100d0b:	8b 14 85 70 21 10 f0 	mov    -0xfefde90(,%eax,4),%edx
f0100d12:	b8 6c 74 10 f0       	mov    $0xf010746c,%eax
f0100d17:	2d 55 5b 10 f0       	sub    $0xf0105b55,%eax
f0100d1c:	39 c2                	cmp    %eax,%edx
f0100d1e:	0f 82 73 ff ff ff    	jb     f0100c97 <debuginfo_eip+0x1ab>
f0100d24:	e9 7b ff ff ff       	jmp    f0100ca4 <debuginfo_eip+0x1b8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0100d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d2c:	5b                   	pop    %ebx
f0100d2d:	5e                   	pop    %esi
f0100d2e:	5f                   	pop    %edi
f0100d2f:	5d                   	pop    %ebp
f0100d30:	c3                   	ret    

f0100d31 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d31:	55                   	push   %ebp
f0100d32:	89 e5                	mov    %esp,%ebp
f0100d34:	57                   	push   %edi
f0100d35:	56                   	push   %esi
f0100d36:	53                   	push   %ebx
f0100d37:	83 ec 1c             	sub    $0x1c,%esp
f0100d3a:	89 c7                	mov    %eax,%edi
f0100d3c:	89 d6                	mov    %edx,%esi
f0100d3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d41:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d44:	89 d1                	mov    %edx,%ecx
f0100d46:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d49:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100d4c:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d4f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d52:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d55:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100d5c:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0100d5f:	72 05                	jb     f0100d66 <printnum+0x35>
f0100d61:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100d64:	77 3e                	ja     f0100da4 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d66:	83 ec 0c             	sub    $0xc,%esp
f0100d69:	ff 75 18             	pushl  0x18(%ebp)
f0100d6c:	83 eb 01             	sub    $0x1,%ebx
f0100d6f:	53                   	push   %ebx
f0100d70:	50                   	push   %eax
f0100d71:	83 ec 08             	sub    $0x8,%esp
f0100d74:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d77:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d7a:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d7d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d80:	e8 4b 09 00 00       	call   f01016d0 <__udivdi3>
f0100d85:	83 c4 18             	add    $0x18,%esp
f0100d88:	52                   	push   %edx
f0100d89:	50                   	push   %eax
f0100d8a:	89 f2                	mov    %esi,%edx
f0100d8c:	89 f8                	mov    %edi,%eax
f0100d8e:	e8 9e ff ff ff       	call   f0100d31 <printnum>
f0100d93:	83 c4 20             	add    $0x20,%esp
f0100d96:	eb 13                	jmp    f0100dab <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d98:	83 ec 08             	sub    $0x8,%esp
f0100d9b:	56                   	push   %esi
f0100d9c:	ff 75 18             	pushl  0x18(%ebp)
f0100d9f:	ff d7                	call   *%edi
f0100da1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100da4:	83 eb 01             	sub    $0x1,%ebx
f0100da7:	85 db                	test   %ebx,%ebx
f0100da9:	7f ed                	jg     f0100d98 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100dab:	83 ec 08             	sub    $0x8,%esp
f0100dae:	56                   	push   %esi
f0100daf:	83 ec 04             	sub    $0x4,%esp
f0100db2:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100db5:	ff 75 e0             	pushl  -0x20(%ebp)
f0100db8:	ff 75 dc             	pushl  -0x24(%ebp)
f0100dbb:	ff 75 d8             	pushl  -0x28(%ebp)
f0100dbe:	e8 3d 0a 00 00       	call   f0101800 <__umoddi3>
f0100dc3:	83 c4 14             	add    $0x14,%esp
f0100dc6:	0f be 80 49 1f 10 f0 	movsbl -0xfefe0b7(%eax),%eax
f0100dcd:	50                   	push   %eax
f0100dce:	ff d7                	call   *%edi
f0100dd0:	83 c4 10             	add    $0x10,%esp
}
f0100dd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dd6:	5b                   	pop    %ebx
f0100dd7:	5e                   	pop    %esi
f0100dd8:	5f                   	pop    %edi
f0100dd9:	5d                   	pop    %ebp
f0100dda:	c3                   	ret    

f0100ddb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100ddb:	55                   	push   %ebp
f0100ddc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100dde:	83 fa 01             	cmp    $0x1,%edx
f0100de1:	7e 0e                	jle    f0100df1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100de3:	8b 10                	mov    (%eax),%edx
f0100de5:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100de8:	89 08                	mov    %ecx,(%eax)
f0100dea:	8b 02                	mov    (%edx),%eax
f0100dec:	8b 52 04             	mov    0x4(%edx),%edx
f0100def:	eb 22                	jmp    f0100e13 <getuint+0x38>
	else if (lflag)
f0100df1:	85 d2                	test   %edx,%edx
f0100df3:	74 10                	je     f0100e05 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100df5:	8b 10                	mov    (%eax),%edx
f0100df7:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100dfa:	89 08                	mov    %ecx,(%eax)
f0100dfc:	8b 02                	mov    (%edx),%eax
f0100dfe:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e03:	eb 0e                	jmp    f0100e13 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100e05:	8b 10                	mov    (%eax),%edx
f0100e07:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e0a:	89 08                	mov    %ecx,(%eax)
f0100e0c:	8b 02                	mov    (%edx),%eax
f0100e0e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100e13:	5d                   	pop    %ebp
f0100e14:	c3                   	ret    

f0100e15 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e15:	55                   	push   %ebp
f0100e16:	89 e5                	mov    %esp,%ebp
f0100e18:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e1b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e1f:	8b 10                	mov    (%eax),%edx
f0100e21:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e24:	73 0a                	jae    f0100e30 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100e26:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e29:	89 08                	mov    %ecx,(%eax)
f0100e2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e2e:	88 02                	mov    %al,(%edx)
}
f0100e30:	5d                   	pop    %ebp
f0100e31:	c3                   	ret    

f0100e32 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100e32:	55                   	push   %ebp
f0100e33:	89 e5                	mov    %esp,%ebp
f0100e35:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100e38:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e3b:	50                   	push   %eax
f0100e3c:	ff 75 10             	pushl  0x10(%ebp)
f0100e3f:	ff 75 0c             	pushl  0xc(%ebp)
f0100e42:	ff 75 08             	pushl  0x8(%ebp)
f0100e45:	e8 05 00 00 00       	call   f0100e4f <vprintfmt>
	va_end(ap);
f0100e4a:	83 c4 10             	add    $0x10,%esp
}
f0100e4d:	c9                   	leave  
f0100e4e:	c3                   	ret    

f0100e4f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100e4f:	55                   	push   %ebp
f0100e50:	89 e5                	mov    %esp,%ebp
f0100e52:	57                   	push   %edi
f0100e53:	56                   	push   %esi
f0100e54:	53                   	push   %ebx
f0100e55:	83 ec 2c             	sub    $0x2c,%esp
f0100e58:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e5e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e61:	eb 12                	jmp    f0100e75 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e63:	85 c0                	test   %eax,%eax
f0100e65:	0f 84 90 03 00 00    	je     f01011fb <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0100e6b:	83 ec 08             	sub    $0x8,%esp
f0100e6e:	53                   	push   %ebx
f0100e6f:	50                   	push   %eax
f0100e70:	ff d6                	call   *%esi
f0100e72:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e75:	83 c7 01             	add    $0x1,%edi
f0100e78:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100e7c:	83 f8 25             	cmp    $0x25,%eax
f0100e7f:	75 e2                	jne    f0100e63 <vprintfmt+0x14>
f0100e81:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e8c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e93:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e9a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e9f:	eb 07                	jmp    f0100ea8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ea1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100ea4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ea8:	8d 47 01             	lea    0x1(%edi),%eax
f0100eab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100eae:	0f b6 07             	movzbl (%edi),%eax
f0100eb1:	0f b6 c8             	movzbl %al,%ecx
f0100eb4:	83 e8 23             	sub    $0x23,%eax
f0100eb7:	3c 55                	cmp    $0x55,%al
f0100eb9:	0f 87 21 03 00 00    	ja     f01011e0 <vprintfmt+0x391>
f0100ebf:	0f b6 c0             	movzbl %al,%eax
f0100ec2:	ff 24 85 e0 1f 10 f0 	jmp    *-0xfefe020(,%eax,4)
f0100ec9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100ecc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100ed0:	eb d6                	jmp    f0100ea8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ed2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ed5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eda:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100edd:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100ee0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100ee4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100ee7:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100eea:	83 fa 09             	cmp    $0x9,%edx
f0100eed:	77 39                	ja     f0100f28 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100eef:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100ef2:	eb e9                	jmp    f0100edd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100ef4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef7:	8d 48 04             	lea    0x4(%eax),%ecx
f0100efa:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100efd:	8b 00                	mov    (%eax),%eax
f0100eff:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100f05:	eb 27                	jmp    f0100f2e <vprintfmt+0xdf>
f0100f07:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f0a:	85 c0                	test   %eax,%eax
f0100f0c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f11:	0f 49 c8             	cmovns %eax,%ecx
f0100f14:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f1a:	eb 8c                	jmp    f0100ea8 <vprintfmt+0x59>
f0100f1c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100f1f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100f26:	eb 80                	jmp    f0100ea8 <vprintfmt+0x59>
f0100f28:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f2b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100f2e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f32:	0f 89 70 ff ff ff    	jns    f0100ea8 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100f38:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100f3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f3e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100f45:	e9 5e ff ff ff       	jmp    f0100ea8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f4a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100f50:	e9 53 ff ff ff       	jmp    f0100ea8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f55:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f58:	8d 50 04             	lea    0x4(%eax),%edx
f0100f5b:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f5e:	83 ec 08             	sub    $0x8,%esp
f0100f61:	53                   	push   %ebx
f0100f62:	ff 30                	pushl  (%eax)
f0100f64:	ff d6                	call   *%esi
			break;
f0100f66:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100f6c:	e9 04 ff ff ff       	jmp    f0100e75 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f71:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f74:	8d 50 04             	lea    0x4(%eax),%edx
f0100f77:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f7a:	8b 00                	mov    (%eax),%eax
f0100f7c:	99                   	cltd   
f0100f7d:	31 d0                	xor    %edx,%eax
f0100f7f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f81:	83 f8 07             	cmp    $0x7,%eax
f0100f84:	7f 0b                	jg     f0100f91 <vprintfmt+0x142>
f0100f86:	8b 14 85 40 21 10 f0 	mov    -0xfefdec0(,%eax,4),%edx
f0100f8d:	85 d2                	test   %edx,%edx
f0100f8f:	75 18                	jne    f0100fa9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f91:	50                   	push   %eax
f0100f92:	68 61 1f 10 f0       	push   $0xf0101f61
f0100f97:	53                   	push   %ebx
f0100f98:	56                   	push   %esi
f0100f99:	e8 94 fe ff ff       	call   f0100e32 <printfmt>
f0100f9e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fa1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100fa4:	e9 cc fe ff ff       	jmp    f0100e75 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100fa9:	52                   	push   %edx
f0100faa:	68 fd 1c 10 f0       	push   $0xf0101cfd
f0100faf:	53                   	push   %ebx
f0100fb0:	56                   	push   %esi
f0100fb1:	e8 7c fe ff ff       	call   f0100e32 <printfmt>
f0100fb6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fb9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fbc:	e9 b4 fe ff ff       	jmp    f0100e75 <vprintfmt+0x26>
f0100fc1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100fc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fc7:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100fca:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fcd:	8d 50 04             	lea    0x4(%eax),%edx
f0100fd0:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fd3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100fd5:	85 ff                	test   %edi,%edi
f0100fd7:	ba 5a 1f 10 f0       	mov    $0xf0101f5a,%edx
f0100fdc:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
f0100fdf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100fe3:	0f 84 92 00 00 00    	je     f010107b <vprintfmt+0x22c>
f0100fe9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0100fed:	0f 8e 96 00 00 00    	jle    f0101089 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ff3:	83 ec 08             	sub    $0x8,%esp
f0100ff6:	51                   	push   %ecx
f0100ff7:	57                   	push   %edi
f0100ff8:	e8 5f 03 00 00       	call   f010135c <strnlen>
f0100ffd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101000:	29 c1                	sub    %eax,%ecx
f0101002:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101005:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101008:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010100c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010100f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101012:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101014:	eb 0f                	jmp    f0101025 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0101016:	83 ec 08             	sub    $0x8,%esp
f0101019:	53                   	push   %ebx
f010101a:	ff 75 e0             	pushl  -0x20(%ebp)
f010101d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010101f:	83 ef 01             	sub    $0x1,%edi
f0101022:	83 c4 10             	add    $0x10,%esp
f0101025:	85 ff                	test   %edi,%edi
f0101027:	7f ed                	jg     f0101016 <vprintfmt+0x1c7>
f0101029:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010102c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010102f:	85 c9                	test   %ecx,%ecx
f0101031:	b8 00 00 00 00       	mov    $0x0,%eax
f0101036:	0f 49 c1             	cmovns %ecx,%eax
f0101039:	29 c1                	sub    %eax,%ecx
f010103b:	89 75 08             	mov    %esi,0x8(%ebp)
f010103e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101041:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101044:	89 cb                	mov    %ecx,%ebx
f0101046:	eb 4d                	jmp    f0101095 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101048:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010104c:	74 1b                	je     f0101069 <vprintfmt+0x21a>
f010104e:	0f be c0             	movsbl %al,%eax
f0101051:	83 e8 20             	sub    $0x20,%eax
f0101054:	83 f8 5e             	cmp    $0x5e,%eax
f0101057:	76 10                	jbe    f0101069 <vprintfmt+0x21a>
					putch('?', putdat);
f0101059:	83 ec 08             	sub    $0x8,%esp
f010105c:	ff 75 0c             	pushl  0xc(%ebp)
f010105f:	6a 3f                	push   $0x3f
f0101061:	ff 55 08             	call   *0x8(%ebp)
f0101064:	83 c4 10             	add    $0x10,%esp
f0101067:	eb 0d                	jmp    f0101076 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0101069:	83 ec 08             	sub    $0x8,%esp
f010106c:	ff 75 0c             	pushl  0xc(%ebp)
f010106f:	52                   	push   %edx
f0101070:	ff 55 08             	call   *0x8(%ebp)
f0101073:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101076:	83 eb 01             	sub    $0x1,%ebx
f0101079:	eb 1a                	jmp    f0101095 <vprintfmt+0x246>
f010107b:	89 75 08             	mov    %esi,0x8(%ebp)
f010107e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101081:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101084:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101087:	eb 0c                	jmp    f0101095 <vprintfmt+0x246>
f0101089:	89 75 08             	mov    %esi,0x8(%ebp)
f010108c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010108f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101092:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101095:	83 c7 01             	add    $0x1,%edi
f0101098:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010109c:	0f be d0             	movsbl %al,%edx
f010109f:	85 d2                	test   %edx,%edx
f01010a1:	74 23                	je     f01010c6 <vprintfmt+0x277>
f01010a3:	85 f6                	test   %esi,%esi
f01010a5:	78 a1                	js     f0101048 <vprintfmt+0x1f9>
f01010a7:	83 ee 01             	sub    $0x1,%esi
f01010aa:	79 9c                	jns    f0101048 <vprintfmt+0x1f9>
f01010ac:	89 df                	mov    %ebx,%edi
f01010ae:	8b 75 08             	mov    0x8(%ebp),%esi
f01010b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010b4:	eb 18                	jmp    f01010ce <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01010b6:	83 ec 08             	sub    $0x8,%esp
f01010b9:	53                   	push   %ebx
f01010ba:	6a 20                	push   $0x20
f01010bc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01010be:	83 ef 01             	sub    $0x1,%edi
f01010c1:	83 c4 10             	add    $0x10,%esp
f01010c4:	eb 08                	jmp    f01010ce <vprintfmt+0x27f>
f01010c6:	89 df                	mov    %ebx,%edi
f01010c8:	8b 75 08             	mov    0x8(%ebp),%esi
f01010cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010ce:	85 ff                	test   %edi,%edi
f01010d0:	7f e4                	jg     f01010b6 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010d5:	e9 9b fd ff ff       	jmp    f0100e75 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01010da:	83 fa 01             	cmp    $0x1,%edx
f01010dd:	7e 16                	jle    f01010f5 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f01010df:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e2:	8d 50 08             	lea    0x8(%eax),%edx
f01010e5:	89 55 14             	mov    %edx,0x14(%ebp)
f01010e8:	8b 50 04             	mov    0x4(%eax),%edx
f01010eb:	8b 00                	mov    (%eax),%eax
f01010ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010f3:	eb 32                	jmp    f0101127 <vprintfmt+0x2d8>
	else if (lflag)
f01010f5:	85 d2                	test   %edx,%edx
f01010f7:	74 18                	je     f0101111 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f01010f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01010fc:	8d 50 04             	lea    0x4(%eax),%edx
f01010ff:	89 55 14             	mov    %edx,0x14(%ebp)
f0101102:	8b 00                	mov    (%eax),%eax
f0101104:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101107:	89 c1                	mov    %eax,%ecx
f0101109:	c1 f9 1f             	sar    $0x1f,%ecx
f010110c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010110f:	eb 16                	jmp    f0101127 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f0101111:	8b 45 14             	mov    0x14(%ebp),%eax
f0101114:	8d 50 04             	lea    0x4(%eax),%edx
f0101117:	89 55 14             	mov    %edx,0x14(%ebp)
f010111a:	8b 00                	mov    (%eax),%eax
f010111c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010111f:	89 c1                	mov    %eax,%ecx
f0101121:	c1 f9 1f             	sar    $0x1f,%ecx
f0101124:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101127:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010112a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010112d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101132:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101136:	79 74                	jns    f01011ac <vprintfmt+0x35d>
				putch('-', putdat);
f0101138:	83 ec 08             	sub    $0x8,%esp
f010113b:	53                   	push   %ebx
f010113c:	6a 2d                	push   $0x2d
f010113e:	ff d6                	call   *%esi
				num = -(long long) num;
f0101140:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101143:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101146:	f7 d8                	neg    %eax
f0101148:	83 d2 00             	adc    $0x0,%edx
f010114b:	f7 da                	neg    %edx
f010114d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0101150:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101155:	eb 55                	jmp    f01011ac <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101157:	8d 45 14             	lea    0x14(%ebp),%eax
f010115a:	e8 7c fc ff ff       	call   f0100ddb <getuint>
			base = 10;
f010115f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101164:	eb 46                	jmp    f01011ac <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0101166:	8d 45 14             	lea    0x14(%ebp),%eax
f0101169:	e8 6d fc ff ff       	call   f0100ddb <getuint>
                        base = 8;
f010116e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0101173:	eb 37                	jmp    f01011ac <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
f0101175:	83 ec 08             	sub    $0x8,%esp
f0101178:	53                   	push   %ebx
f0101179:	6a 30                	push   $0x30
f010117b:	ff d6                	call   *%esi
			putch('x', putdat);
f010117d:	83 c4 08             	add    $0x8,%esp
f0101180:	53                   	push   %ebx
f0101181:	6a 78                	push   $0x78
f0101183:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101185:	8b 45 14             	mov    0x14(%ebp),%eax
f0101188:	8d 50 04             	lea    0x4(%eax),%edx
f010118b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010118e:	8b 00                	mov    (%eax),%eax
f0101190:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101195:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101198:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010119d:	eb 0d                	jmp    f01011ac <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010119f:	8d 45 14             	lea    0x14(%ebp),%eax
f01011a2:	e8 34 fc ff ff       	call   f0100ddb <getuint>
			base = 16;
f01011a7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01011ac:	83 ec 0c             	sub    $0xc,%esp
f01011af:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01011b3:	57                   	push   %edi
f01011b4:	ff 75 e0             	pushl  -0x20(%ebp)
f01011b7:	51                   	push   %ecx
f01011b8:	52                   	push   %edx
f01011b9:	50                   	push   %eax
f01011ba:	89 da                	mov    %ebx,%edx
f01011bc:	89 f0                	mov    %esi,%eax
f01011be:	e8 6e fb ff ff       	call   f0100d31 <printnum>
			break;
f01011c3:	83 c4 20             	add    $0x20,%esp
f01011c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01011c9:	e9 a7 fc ff ff       	jmp    f0100e75 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01011ce:	83 ec 08             	sub    $0x8,%esp
f01011d1:	53                   	push   %ebx
f01011d2:	51                   	push   %ecx
f01011d3:	ff d6                	call   *%esi
			break;
f01011d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01011db:	e9 95 fc ff ff       	jmp    f0100e75 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01011e0:	83 ec 08             	sub    $0x8,%esp
f01011e3:	53                   	push   %ebx
f01011e4:	6a 25                	push   $0x25
f01011e6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011e8:	83 c4 10             	add    $0x10,%esp
f01011eb:	eb 03                	jmp    f01011f0 <vprintfmt+0x3a1>
f01011ed:	83 ef 01             	sub    $0x1,%edi
f01011f0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01011f4:	75 f7                	jne    f01011ed <vprintfmt+0x39e>
f01011f6:	e9 7a fc ff ff       	jmp    f0100e75 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01011fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011fe:	5b                   	pop    %ebx
f01011ff:	5e                   	pop    %esi
f0101200:	5f                   	pop    %edi
f0101201:	5d                   	pop    %ebp
f0101202:	c3                   	ret    

f0101203 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101203:	55                   	push   %ebp
f0101204:	89 e5                	mov    %esp,%ebp
f0101206:	83 ec 18             	sub    $0x18,%esp
f0101209:	8b 45 08             	mov    0x8(%ebp),%eax
f010120c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010120f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101212:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101216:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101219:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101220:	85 c0                	test   %eax,%eax
f0101222:	74 26                	je     f010124a <vsnprintf+0x47>
f0101224:	85 d2                	test   %edx,%edx
f0101226:	7e 22                	jle    f010124a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101228:	ff 75 14             	pushl  0x14(%ebp)
f010122b:	ff 75 10             	pushl  0x10(%ebp)
f010122e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101231:	50                   	push   %eax
f0101232:	68 15 0e 10 f0       	push   $0xf0100e15
f0101237:	e8 13 fc ff ff       	call   f0100e4f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010123c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010123f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101242:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101245:	83 c4 10             	add    $0x10,%esp
f0101248:	eb 05                	jmp    f010124f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010124a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010124f:	c9                   	leave  
f0101250:	c3                   	ret    

f0101251 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101251:	55                   	push   %ebp
f0101252:	89 e5                	mov    %esp,%ebp
f0101254:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101257:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010125a:	50                   	push   %eax
f010125b:	ff 75 10             	pushl  0x10(%ebp)
f010125e:	ff 75 0c             	pushl  0xc(%ebp)
f0101261:	ff 75 08             	pushl  0x8(%ebp)
f0101264:	e8 9a ff ff ff       	call   f0101203 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101269:	c9                   	leave  
f010126a:	c3                   	ret    

f010126b <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010126b:	55                   	push   %ebp
f010126c:	89 e5                	mov    %esp,%ebp
f010126e:	57                   	push   %edi
f010126f:	56                   	push   %esi
f0101270:	53                   	push   %ebx
f0101271:	83 ec 0c             	sub    $0xc,%esp
f0101274:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101277:	85 c0                	test   %eax,%eax
f0101279:	74 11                	je     f010128c <readline+0x21>
		cprintf("%s", prompt);
f010127b:	83 ec 08             	sub    $0x8,%esp
f010127e:	50                   	push   %eax
f010127f:	68 fd 1c 10 f0       	push   $0xf0101cfd
f0101284:	e8 4d f7 ff ff       	call   f01009d6 <cprintf>
f0101289:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010128c:	83 ec 0c             	sub    $0xc,%esp
f010128f:	6a 00                	push   $0x0
f0101291:	e8 c6 f3 ff ff       	call   f010065c <iscons>
f0101296:	89 c7                	mov    %eax,%edi
f0101298:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010129b:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01012a0:	e8 a6 f3 ff ff       	call   f010064b <getchar>
f01012a5:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01012a7:	85 c0                	test   %eax,%eax
f01012a9:	79 18                	jns    f01012c3 <readline+0x58>
			cprintf("read error: %e\n", c);
f01012ab:	83 ec 08             	sub    $0x8,%esp
f01012ae:	50                   	push   %eax
f01012af:	68 60 21 10 f0       	push   $0xf0102160
f01012b4:	e8 1d f7 ff ff       	call   f01009d6 <cprintf>
			return NULL;
f01012b9:	83 c4 10             	add    $0x10,%esp
f01012bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01012c1:	eb 79                	jmp    f010133c <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012c3:	83 f8 7f             	cmp    $0x7f,%eax
f01012c6:	0f 94 c2             	sete   %dl
f01012c9:	83 f8 08             	cmp    $0x8,%eax
f01012cc:	0f 94 c0             	sete   %al
f01012cf:	08 c2                	or     %al,%dl
f01012d1:	74 1a                	je     f01012ed <readline+0x82>
f01012d3:	85 f6                	test   %esi,%esi
f01012d5:	7e 16                	jle    f01012ed <readline+0x82>
			if (echoing)
f01012d7:	85 ff                	test   %edi,%edi
f01012d9:	74 0d                	je     f01012e8 <readline+0x7d>
				cputchar('\b');
f01012db:	83 ec 0c             	sub    $0xc,%esp
f01012de:	6a 08                	push   $0x8
f01012e0:	e8 56 f3 ff ff       	call   f010063b <cputchar>
f01012e5:	83 c4 10             	add    $0x10,%esp
			i--;
f01012e8:	83 ee 01             	sub    $0x1,%esi
f01012eb:	eb b3                	jmp    f01012a0 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01012ed:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01012f3:	7f 20                	jg     f0101315 <readline+0xaa>
f01012f5:	83 fb 1f             	cmp    $0x1f,%ebx
f01012f8:	7e 1b                	jle    f0101315 <readline+0xaa>
			if (echoing)
f01012fa:	85 ff                	test   %edi,%edi
f01012fc:	74 0c                	je     f010130a <readline+0x9f>
				cputchar(c);
f01012fe:	83 ec 0c             	sub    $0xc,%esp
f0101301:	53                   	push   %ebx
f0101302:	e8 34 f3 ff ff       	call   f010063b <cputchar>
f0101307:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010130a:	88 9e 80 25 11 f0    	mov    %bl,-0xfeeda80(%esi)
f0101310:	8d 76 01             	lea    0x1(%esi),%esi
f0101313:	eb 8b                	jmp    f01012a0 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101315:	83 fb 0d             	cmp    $0xd,%ebx
f0101318:	74 05                	je     f010131f <readline+0xb4>
f010131a:	83 fb 0a             	cmp    $0xa,%ebx
f010131d:	75 81                	jne    f01012a0 <readline+0x35>
			if (echoing)
f010131f:	85 ff                	test   %edi,%edi
f0101321:	74 0d                	je     f0101330 <readline+0xc5>
				cputchar('\n');
f0101323:	83 ec 0c             	sub    $0xc,%esp
f0101326:	6a 0a                	push   $0xa
f0101328:	e8 0e f3 ff ff       	call   f010063b <cputchar>
f010132d:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0101330:	c6 86 80 25 11 f0 00 	movb   $0x0,-0xfeeda80(%esi)
			return buf;
f0101337:	b8 80 25 11 f0       	mov    $0xf0112580,%eax
		}
	}
}
f010133c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010133f:	5b                   	pop    %ebx
f0101340:	5e                   	pop    %esi
f0101341:	5f                   	pop    %edi
f0101342:	5d                   	pop    %ebp
f0101343:	c3                   	ret    

f0101344 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101344:	55                   	push   %ebp
f0101345:	89 e5                	mov    %esp,%ebp
f0101347:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010134a:	b8 00 00 00 00       	mov    $0x0,%eax
f010134f:	eb 03                	jmp    f0101354 <strlen+0x10>
		n++;
f0101351:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101354:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101358:	75 f7                	jne    f0101351 <strlen+0xd>
		n++;
	return n;
}
f010135a:	5d                   	pop    %ebp
f010135b:	c3                   	ret    

f010135c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010135c:	55                   	push   %ebp
f010135d:	89 e5                	mov    %esp,%ebp
f010135f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101362:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101365:	ba 00 00 00 00       	mov    $0x0,%edx
f010136a:	eb 03                	jmp    f010136f <strnlen+0x13>
		n++;
f010136c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010136f:	39 c2                	cmp    %eax,%edx
f0101371:	74 08                	je     f010137b <strnlen+0x1f>
f0101373:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101377:	75 f3                	jne    f010136c <strnlen+0x10>
f0101379:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010137b:	5d                   	pop    %ebp
f010137c:	c3                   	ret    

f010137d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010137d:	55                   	push   %ebp
f010137e:	89 e5                	mov    %esp,%ebp
f0101380:	53                   	push   %ebx
f0101381:	8b 45 08             	mov    0x8(%ebp),%eax
f0101384:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101387:	89 c2                	mov    %eax,%edx
f0101389:	83 c2 01             	add    $0x1,%edx
f010138c:	83 c1 01             	add    $0x1,%ecx
f010138f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101393:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101396:	84 db                	test   %bl,%bl
f0101398:	75 ef                	jne    f0101389 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010139a:	5b                   	pop    %ebx
f010139b:	5d                   	pop    %ebp
f010139c:	c3                   	ret    

f010139d <strcat>:

char *
strcat(char *dst, const char *src)
{
f010139d:	55                   	push   %ebp
f010139e:	89 e5                	mov    %esp,%ebp
f01013a0:	53                   	push   %ebx
f01013a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01013a4:	53                   	push   %ebx
f01013a5:	e8 9a ff ff ff       	call   f0101344 <strlen>
f01013aa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01013ad:	ff 75 0c             	pushl  0xc(%ebp)
f01013b0:	01 d8                	add    %ebx,%eax
f01013b2:	50                   	push   %eax
f01013b3:	e8 c5 ff ff ff       	call   f010137d <strcpy>
	return dst;
}
f01013b8:	89 d8                	mov    %ebx,%eax
f01013ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013bd:	c9                   	leave  
f01013be:	c3                   	ret    

f01013bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01013bf:	55                   	push   %ebp
f01013c0:	89 e5                	mov    %esp,%ebp
f01013c2:	56                   	push   %esi
f01013c3:	53                   	push   %ebx
f01013c4:	8b 75 08             	mov    0x8(%ebp),%esi
f01013c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013ca:	89 f3                	mov    %esi,%ebx
f01013cc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013cf:	89 f2                	mov    %esi,%edx
f01013d1:	eb 0f                	jmp    f01013e2 <strncpy+0x23>
		*dst++ = *src;
f01013d3:	83 c2 01             	add    $0x1,%edx
f01013d6:	0f b6 01             	movzbl (%ecx),%eax
f01013d9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01013dc:	80 39 01             	cmpb   $0x1,(%ecx)
f01013df:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013e2:	39 da                	cmp    %ebx,%edx
f01013e4:	75 ed                	jne    f01013d3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01013e6:	89 f0                	mov    %esi,%eax
f01013e8:	5b                   	pop    %ebx
f01013e9:	5e                   	pop    %esi
f01013ea:	5d                   	pop    %ebp
f01013eb:	c3                   	ret    

f01013ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01013ec:	55                   	push   %ebp
f01013ed:	89 e5                	mov    %esp,%ebp
f01013ef:	56                   	push   %esi
f01013f0:	53                   	push   %ebx
f01013f1:	8b 75 08             	mov    0x8(%ebp),%esi
f01013f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013f7:	8b 55 10             	mov    0x10(%ebp),%edx
f01013fa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01013fc:	85 d2                	test   %edx,%edx
f01013fe:	74 21                	je     f0101421 <strlcpy+0x35>
f0101400:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101404:	89 f2                	mov    %esi,%edx
f0101406:	eb 09                	jmp    f0101411 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101408:	83 c2 01             	add    $0x1,%edx
f010140b:	83 c1 01             	add    $0x1,%ecx
f010140e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101411:	39 c2                	cmp    %eax,%edx
f0101413:	74 09                	je     f010141e <strlcpy+0x32>
f0101415:	0f b6 19             	movzbl (%ecx),%ebx
f0101418:	84 db                	test   %bl,%bl
f010141a:	75 ec                	jne    f0101408 <strlcpy+0x1c>
f010141c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010141e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101421:	29 f0                	sub    %esi,%eax
}
f0101423:	5b                   	pop    %ebx
f0101424:	5e                   	pop    %esi
f0101425:	5d                   	pop    %ebp
f0101426:	c3                   	ret    

f0101427 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101427:	55                   	push   %ebp
f0101428:	89 e5                	mov    %esp,%ebp
f010142a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010142d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101430:	eb 06                	jmp    f0101438 <strcmp+0x11>
		p++, q++;
f0101432:	83 c1 01             	add    $0x1,%ecx
f0101435:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101438:	0f b6 01             	movzbl (%ecx),%eax
f010143b:	84 c0                	test   %al,%al
f010143d:	74 04                	je     f0101443 <strcmp+0x1c>
f010143f:	3a 02                	cmp    (%edx),%al
f0101441:	74 ef                	je     f0101432 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101443:	0f b6 c0             	movzbl %al,%eax
f0101446:	0f b6 12             	movzbl (%edx),%edx
f0101449:	29 d0                	sub    %edx,%eax
}
f010144b:	5d                   	pop    %ebp
f010144c:	c3                   	ret    

f010144d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010144d:	55                   	push   %ebp
f010144e:	89 e5                	mov    %esp,%ebp
f0101450:	53                   	push   %ebx
f0101451:	8b 45 08             	mov    0x8(%ebp),%eax
f0101454:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101457:	89 c3                	mov    %eax,%ebx
f0101459:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010145c:	eb 06                	jmp    f0101464 <strncmp+0x17>
		n--, p++, q++;
f010145e:	83 c0 01             	add    $0x1,%eax
f0101461:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101464:	39 d8                	cmp    %ebx,%eax
f0101466:	74 15                	je     f010147d <strncmp+0x30>
f0101468:	0f b6 08             	movzbl (%eax),%ecx
f010146b:	84 c9                	test   %cl,%cl
f010146d:	74 04                	je     f0101473 <strncmp+0x26>
f010146f:	3a 0a                	cmp    (%edx),%cl
f0101471:	74 eb                	je     f010145e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101473:	0f b6 00             	movzbl (%eax),%eax
f0101476:	0f b6 12             	movzbl (%edx),%edx
f0101479:	29 d0                	sub    %edx,%eax
f010147b:	eb 05                	jmp    f0101482 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010147d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101482:	5b                   	pop    %ebx
f0101483:	5d                   	pop    %ebp
f0101484:	c3                   	ret    

f0101485 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101485:	55                   	push   %ebp
f0101486:	89 e5                	mov    %esp,%ebp
f0101488:	8b 45 08             	mov    0x8(%ebp),%eax
f010148b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010148f:	eb 07                	jmp    f0101498 <strchr+0x13>
		if (*s == c)
f0101491:	38 ca                	cmp    %cl,%dl
f0101493:	74 0f                	je     f01014a4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101495:	83 c0 01             	add    $0x1,%eax
f0101498:	0f b6 10             	movzbl (%eax),%edx
f010149b:	84 d2                	test   %dl,%dl
f010149d:	75 f2                	jne    f0101491 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010149f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014a4:	5d                   	pop    %ebp
f01014a5:	c3                   	ret    

f01014a6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01014a6:	55                   	push   %ebp
f01014a7:	89 e5                	mov    %esp,%ebp
f01014a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01014b0:	eb 03                	jmp    f01014b5 <strfind+0xf>
f01014b2:	83 c0 01             	add    $0x1,%eax
f01014b5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01014b8:	84 d2                	test   %dl,%dl
f01014ba:	74 04                	je     f01014c0 <strfind+0x1a>
f01014bc:	38 ca                	cmp    %cl,%dl
f01014be:	75 f2                	jne    f01014b2 <strfind+0xc>
			break;
	return (char *) s;
}
f01014c0:	5d                   	pop    %ebp
f01014c1:	c3                   	ret    

f01014c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01014c2:	55                   	push   %ebp
f01014c3:	89 e5                	mov    %esp,%ebp
f01014c5:	57                   	push   %edi
f01014c6:	56                   	push   %esi
f01014c7:	53                   	push   %ebx
f01014c8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01014ce:	85 c9                	test   %ecx,%ecx
f01014d0:	74 36                	je     f0101508 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01014d2:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01014d8:	75 28                	jne    f0101502 <memset+0x40>
f01014da:	f6 c1 03             	test   $0x3,%cl
f01014dd:	75 23                	jne    f0101502 <memset+0x40>
		c &= 0xFF;
f01014df:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01014e3:	89 d3                	mov    %edx,%ebx
f01014e5:	c1 e3 08             	shl    $0x8,%ebx
f01014e8:	89 d6                	mov    %edx,%esi
f01014ea:	c1 e6 18             	shl    $0x18,%esi
f01014ed:	89 d0                	mov    %edx,%eax
f01014ef:	c1 e0 10             	shl    $0x10,%eax
f01014f2:	09 f0                	or     %esi,%eax
f01014f4:	09 c2                	or     %eax,%edx
f01014f6:	89 d0                	mov    %edx,%eax
f01014f8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01014fa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01014fd:	fc                   	cld    
f01014fe:	f3 ab                	rep stos %eax,%es:(%edi)
f0101500:	eb 06                	jmp    f0101508 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101502:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101505:	fc                   	cld    
f0101506:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101508:	89 f8                	mov    %edi,%eax
f010150a:	5b                   	pop    %ebx
f010150b:	5e                   	pop    %esi
f010150c:	5f                   	pop    %edi
f010150d:	5d                   	pop    %ebp
f010150e:	c3                   	ret    

f010150f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010150f:	55                   	push   %ebp
f0101510:	89 e5                	mov    %esp,%ebp
f0101512:	57                   	push   %edi
f0101513:	56                   	push   %esi
f0101514:	8b 45 08             	mov    0x8(%ebp),%eax
f0101517:	8b 75 0c             	mov    0xc(%ebp),%esi
f010151a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010151d:	39 c6                	cmp    %eax,%esi
f010151f:	73 35                	jae    f0101556 <memmove+0x47>
f0101521:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101524:	39 d0                	cmp    %edx,%eax
f0101526:	73 2e                	jae    f0101556 <memmove+0x47>
		s += n;
		d += n;
f0101528:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f010152b:	89 d6                	mov    %edx,%esi
f010152d:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010152f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101535:	75 13                	jne    f010154a <memmove+0x3b>
f0101537:	f6 c1 03             	test   $0x3,%cl
f010153a:	75 0e                	jne    f010154a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010153c:	83 ef 04             	sub    $0x4,%edi
f010153f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101542:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0101545:	fd                   	std    
f0101546:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101548:	eb 09                	jmp    f0101553 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010154a:	83 ef 01             	sub    $0x1,%edi
f010154d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101550:	fd                   	std    
f0101551:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101553:	fc                   	cld    
f0101554:	eb 1d                	jmp    f0101573 <memmove+0x64>
f0101556:	89 f2                	mov    %esi,%edx
f0101558:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010155a:	f6 c2 03             	test   $0x3,%dl
f010155d:	75 0f                	jne    f010156e <memmove+0x5f>
f010155f:	f6 c1 03             	test   $0x3,%cl
f0101562:	75 0a                	jne    f010156e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101564:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0101567:	89 c7                	mov    %eax,%edi
f0101569:	fc                   	cld    
f010156a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010156c:	eb 05                	jmp    f0101573 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010156e:	89 c7                	mov    %eax,%edi
f0101570:	fc                   	cld    
f0101571:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101573:	5e                   	pop    %esi
f0101574:	5f                   	pop    %edi
f0101575:	5d                   	pop    %ebp
f0101576:	c3                   	ret    

f0101577 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101577:	55                   	push   %ebp
f0101578:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010157a:	ff 75 10             	pushl  0x10(%ebp)
f010157d:	ff 75 0c             	pushl  0xc(%ebp)
f0101580:	ff 75 08             	pushl  0x8(%ebp)
f0101583:	e8 87 ff ff ff       	call   f010150f <memmove>
}
f0101588:	c9                   	leave  
f0101589:	c3                   	ret    

f010158a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010158a:	55                   	push   %ebp
f010158b:	89 e5                	mov    %esp,%ebp
f010158d:	56                   	push   %esi
f010158e:	53                   	push   %ebx
f010158f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101592:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101595:	89 c6                	mov    %eax,%esi
f0101597:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010159a:	eb 1a                	jmp    f01015b6 <memcmp+0x2c>
		if (*s1 != *s2)
f010159c:	0f b6 08             	movzbl (%eax),%ecx
f010159f:	0f b6 1a             	movzbl (%edx),%ebx
f01015a2:	38 d9                	cmp    %bl,%cl
f01015a4:	74 0a                	je     f01015b0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01015a6:	0f b6 c1             	movzbl %cl,%eax
f01015a9:	0f b6 db             	movzbl %bl,%ebx
f01015ac:	29 d8                	sub    %ebx,%eax
f01015ae:	eb 0f                	jmp    f01015bf <memcmp+0x35>
		s1++, s2++;
f01015b0:	83 c0 01             	add    $0x1,%eax
f01015b3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015b6:	39 f0                	cmp    %esi,%eax
f01015b8:	75 e2                	jne    f010159c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01015ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015bf:	5b                   	pop    %ebx
f01015c0:	5e                   	pop    %esi
f01015c1:	5d                   	pop    %ebp
f01015c2:	c3                   	ret    

f01015c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01015c3:	55                   	push   %ebp
f01015c4:	89 e5                	mov    %esp,%ebp
f01015c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01015c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01015cc:	89 c2                	mov    %eax,%edx
f01015ce:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01015d1:	eb 07                	jmp    f01015da <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01015d3:	38 08                	cmp    %cl,(%eax)
f01015d5:	74 07                	je     f01015de <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015d7:	83 c0 01             	add    $0x1,%eax
f01015da:	39 d0                	cmp    %edx,%eax
f01015dc:	72 f5                	jb     f01015d3 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01015de:	5d                   	pop    %ebp
f01015df:	c3                   	ret    

f01015e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01015e0:	55                   	push   %ebp
f01015e1:	89 e5                	mov    %esp,%ebp
f01015e3:	57                   	push   %edi
f01015e4:	56                   	push   %esi
f01015e5:	53                   	push   %ebx
f01015e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015ec:	eb 03                	jmp    f01015f1 <strtol+0x11>
		s++;
f01015ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015f1:	0f b6 01             	movzbl (%ecx),%eax
f01015f4:	3c 09                	cmp    $0x9,%al
f01015f6:	74 f6                	je     f01015ee <strtol+0xe>
f01015f8:	3c 20                	cmp    $0x20,%al
f01015fa:	74 f2                	je     f01015ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01015fc:	3c 2b                	cmp    $0x2b,%al
f01015fe:	75 0a                	jne    f010160a <strtol+0x2a>
		s++;
f0101600:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101603:	bf 00 00 00 00       	mov    $0x0,%edi
f0101608:	eb 10                	jmp    f010161a <strtol+0x3a>
f010160a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010160f:	3c 2d                	cmp    $0x2d,%al
f0101611:	75 07                	jne    f010161a <strtol+0x3a>
		s++, neg = 1;
f0101613:	8d 49 01             	lea    0x1(%ecx),%ecx
f0101616:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010161a:	85 db                	test   %ebx,%ebx
f010161c:	0f 94 c0             	sete   %al
f010161f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101625:	75 19                	jne    f0101640 <strtol+0x60>
f0101627:	80 39 30             	cmpb   $0x30,(%ecx)
f010162a:	75 14                	jne    f0101640 <strtol+0x60>
f010162c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101630:	0f 85 82 00 00 00    	jne    f01016b8 <strtol+0xd8>
		s += 2, base = 16;
f0101636:	83 c1 02             	add    $0x2,%ecx
f0101639:	bb 10 00 00 00       	mov    $0x10,%ebx
f010163e:	eb 16                	jmp    f0101656 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0101640:	84 c0                	test   %al,%al
f0101642:	74 12                	je     f0101656 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101644:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101649:	80 39 30             	cmpb   $0x30,(%ecx)
f010164c:	75 08                	jne    f0101656 <strtol+0x76>
		s++, base = 8;
f010164e:	83 c1 01             	add    $0x1,%ecx
f0101651:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101656:	b8 00 00 00 00       	mov    $0x0,%eax
f010165b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010165e:	0f b6 11             	movzbl (%ecx),%edx
f0101661:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101664:	89 f3                	mov    %esi,%ebx
f0101666:	80 fb 09             	cmp    $0x9,%bl
f0101669:	77 08                	ja     f0101673 <strtol+0x93>
			dig = *s - '0';
f010166b:	0f be d2             	movsbl %dl,%edx
f010166e:	83 ea 30             	sub    $0x30,%edx
f0101671:	eb 22                	jmp    f0101695 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f0101673:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101676:	89 f3                	mov    %esi,%ebx
f0101678:	80 fb 19             	cmp    $0x19,%bl
f010167b:	77 08                	ja     f0101685 <strtol+0xa5>
			dig = *s - 'a' + 10;
f010167d:	0f be d2             	movsbl %dl,%edx
f0101680:	83 ea 57             	sub    $0x57,%edx
f0101683:	eb 10                	jmp    f0101695 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f0101685:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101688:	89 f3                	mov    %esi,%ebx
f010168a:	80 fb 19             	cmp    $0x19,%bl
f010168d:	77 16                	ja     f01016a5 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010168f:	0f be d2             	movsbl %dl,%edx
f0101692:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101695:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101698:	7d 0f                	jge    f01016a9 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f010169a:	83 c1 01             	add    $0x1,%ecx
f010169d:	0f af 45 10          	imul   0x10(%ebp),%eax
f01016a1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01016a3:	eb b9                	jmp    f010165e <strtol+0x7e>
f01016a5:	89 c2                	mov    %eax,%edx
f01016a7:	eb 02                	jmp    f01016ab <strtol+0xcb>
f01016a9:	89 c2                	mov    %eax,%edx

	if (endptr)
f01016ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01016af:	74 0d                	je     f01016be <strtol+0xde>
		*endptr = (char *) s;
f01016b1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016b4:	89 0e                	mov    %ecx,(%esi)
f01016b6:	eb 06                	jmp    f01016be <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01016b8:	84 c0                	test   %al,%al
f01016ba:	75 92                	jne    f010164e <strtol+0x6e>
f01016bc:	eb 98                	jmp    f0101656 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01016be:	f7 da                	neg    %edx
f01016c0:	85 ff                	test   %edi,%edi
f01016c2:	0f 45 c2             	cmovne %edx,%eax
}
f01016c5:	5b                   	pop    %ebx
f01016c6:	5e                   	pop    %esi
f01016c7:	5f                   	pop    %edi
f01016c8:	5d                   	pop    %ebp
f01016c9:	c3                   	ret    
f01016ca:	66 90                	xchg   %ax,%ax
f01016cc:	66 90                	xchg   %ax,%ax
f01016ce:	66 90                	xchg   %ax,%ax

f01016d0 <__udivdi3>:
f01016d0:	55                   	push   %ebp
f01016d1:	57                   	push   %edi
f01016d2:	56                   	push   %esi
f01016d3:	83 ec 10             	sub    $0x10,%esp
f01016d6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f01016da:	8b 7c 24 20          	mov    0x20(%esp),%edi
f01016de:	8b 74 24 24          	mov    0x24(%esp),%esi
f01016e2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01016e6:	85 d2                	test   %edx,%edx
f01016e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016ec:	89 34 24             	mov    %esi,(%esp)
f01016ef:	89 c8                	mov    %ecx,%eax
f01016f1:	75 35                	jne    f0101728 <__udivdi3+0x58>
f01016f3:	39 f1                	cmp    %esi,%ecx
f01016f5:	0f 87 bd 00 00 00    	ja     f01017b8 <__udivdi3+0xe8>
f01016fb:	85 c9                	test   %ecx,%ecx
f01016fd:	89 cd                	mov    %ecx,%ebp
f01016ff:	75 0b                	jne    f010170c <__udivdi3+0x3c>
f0101701:	b8 01 00 00 00       	mov    $0x1,%eax
f0101706:	31 d2                	xor    %edx,%edx
f0101708:	f7 f1                	div    %ecx
f010170a:	89 c5                	mov    %eax,%ebp
f010170c:	89 f0                	mov    %esi,%eax
f010170e:	31 d2                	xor    %edx,%edx
f0101710:	f7 f5                	div    %ebp
f0101712:	89 c6                	mov    %eax,%esi
f0101714:	89 f8                	mov    %edi,%eax
f0101716:	f7 f5                	div    %ebp
f0101718:	89 f2                	mov    %esi,%edx
f010171a:	83 c4 10             	add    $0x10,%esp
f010171d:	5e                   	pop    %esi
f010171e:	5f                   	pop    %edi
f010171f:	5d                   	pop    %ebp
f0101720:	c3                   	ret    
f0101721:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101728:	3b 14 24             	cmp    (%esp),%edx
f010172b:	77 7b                	ja     f01017a8 <__udivdi3+0xd8>
f010172d:	0f bd f2             	bsr    %edx,%esi
f0101730:	83 f6 1f             	xor    $0x1f,%esi
f0101733:	0f 84 97 00 00 00    	je     f01017d0 <__udivdi3+0x100>
f0101739:	bd 20 00 00 00       	mov    $0x20,%ebp
f010173e:	89 d7                	mov    %edx,%edi
f0101740:	89 f1                	mov    %esi,%ecx
f0101742:	29 f5                	sub    %esi,%ebp
f0101744:	d3 e7                	shl    %cl,%edi
f0101746:	89 c2                	mov    %eax,%edx
f0101748:	89 e9                	mov    %ebp,%ecx
f010174a:	d3 ea                	shr    %cl,%edx
f010174c:	89 f1                	mov    %esi,%ecx
f010174e:	09 fa                	or     %edi,%edx
f0101750:	8b 3c 24             	mov    (%esp),%edi
f0101753:	d3 e0                	shl    %cl,%eax
f0101755:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101759:	89 e9                	mov    %ebp,%ecx
f010175b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010175f:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101763:	89 fa                	mov    %edi,%edx
f0101765:	d3 ea                	shr    %cl,%edx
f0101767:	89 f1                	mov    %esi,%ecx
f0101769:	d3 e7                	shl    %cl,%edi
f010176b:	89 e9                	mov    %ebp,%ecx
f010176d:	d3 e8                	shr    %cl,%eax
f010176f:	09 c7                	or     %eax,%edi
f0101771:	89 f8                	mov    %edi,%eax
f0101773:	f7 74 24 08          	divl   0x8(%esp)
f0101777:	89 d5                	mov    %edx,%ebp
f0101779:	89 c7                	mov    %eax,%edi
f010177b:	f7 64 24 0c          	mull   0xc(%esp)
f010177f:	39 d5                	cmp    %edx,%ebp
f0101781:	89 14 24             	mov    %edx,(%esp)
f0101784:	72 11                	jb     f0101797 <__udivdi3+0xc7>
f0101786:	8b 54 24 04          	mov    0x4(%esp),%edx
f010178a:	89 f1                	mov    %esi,%ecx
f010178c:	d3 e2                	shl    %cl,%edx
f010178e:	39 c2                	cmp    %eax,%edx
f0101790:	73 5e                	jae    f01017f0 <__udivdi3+0x120>
f0101792:	3b 2c 24             	cmp    (%esp),%ebp
f0101795:	75 59                	jne    f01017f0 <__udivdi3+0x120>
f0101797:	8d 47 ff             	lea    -0x1(%edi),%eax
f010179a:	31 f6                	xor    %esi,%esi
f010179c:	89 f2                	mov    %esi,%edx
f010179e:	83 c4 10             	add    $0x10,%esp
f01017a1:	5e                   	pop    %esi
f01017a2:	5f                   	pop    %edi
f01017a3:	5d                   	pop    %ebp
f01017a4:	c3                   	ret    
f01017a5:	8d 76 00             	lea    0x0(%esi),%esi
f01017a8:	31 f6                	xor    %esi,%esi
f01017aa:	31 c0                	xor    %eax,%eax
f01017ac:	89 f2                	mov    %esi,%edx
f01017ae:	83 c4 10             	add    $0x10,%esp
f01017b1:	5e                   	pop    %esi
f01017b2:	5f                   	pop    %edi
f01017b3:	5d                   	pop    %ebp
f01017b4:	c3                   	ret    
f01017b5:	8d 76 00             	lea    0x0(%esi),%esi
f01017b8:	89 f2                	mov    %esi,%edx
f01017ba:	31 f6                	xor    %esi,%esi
f01017bc:	89 f8                	mov    %edi,%eax
f01017be:	f7 f1                	div    %ecx
f01017c0:	89 f2                	mov    %esi,%edx
f01017c2:	83 c4 10             	add    $0x10,%esp
f01017c5:	5e                   	pop    %esi
f01017c6:	5f                   	pop    %edi
f01017c7:	5d                   	pop    %ebp
f01017c8:	c3                   	ret    
f01017c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017d0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01017d4:	76 0b                	jbe    f01017e1 <__udivdi3+0x111>
f01017d6:	31 c0                	xor    %eax,%eax
f01017d8:	3b 14 24             	cmp    (%esp),%edx
f01017db:	0f 83 37 ff ff ff    	jae    f0101718 <__udivdi3+0x48>
f01017e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01017e6:	e9 2d ff ff ff       	jmp    f0101718 <__udivdi3+0x48>
f01017eb:	90                   	nop
f01017ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017f0:	89 f8                	mov    %edi,%eax
f01017f2:	31 f6                	xor    %esi,%esi
f01017f4:	e9 1f ff ff ff       	jmp    f0101718 <__udivdi3+0x48>
f01017f9:	66 90                	xchg   %ax,%ax
f01017fb:	66 90                	xchg   %ax,%ax
f01017fd:	66 90                	xchg   %ax,%ax
f01017ff:	90                   	nop

f0101800 <__umoddi3>:
f0101800:	55                   	push   %ebp
f0101801:	57                   	push   %edi
f0101802:	56                   	push   %esi
f0101803:	83 ec 20             	sub    $0x20,%esp
f0101806:	8b 44 24 34          	mov    0x34(%esp),%eax
f010180a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010180e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101812:	89 c6                	mov    %eax,%esi
f0101814:	89 44 24 10          	mov    %eax,0x10(%esp)
f0101818:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010181c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0101820:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101824:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0101828:	89 74 24 18          	mov    %esi,0x18(%esp)
f010182c:	85 c0                	test   %eax,%eax
f010182e:	89 c2                	mov    %eax,%edx
f0101830:	75 1e                	jne    f0101850 <__umoddi3+0x50>
f0101832:	39 f7                	cmp    %esi,%edi
f0101834:	76 52                	jbe    f0101888 <__umoddi3+0x88>
f0101836:	89 c8                	mov    %ecx,%eax
f0101838:	89 f2                	mov    %esi,%edx
f010183a:	f7 f7                	div    %edi
f010183c:	89 d0                	mov    %edx,%eax
f010183e:	31 d2                	xor    %edx,%edx
f0101840:	83 c4 20             	add    $0x20,%esp
f0101843:	5e                   	pop    %esi
f0101844:	5f                   	pop    %edi
f0101845:	5d                   	pop    %ebp
f0101846:	c3                   	ret    
f0101847:	89 f6                	mov    %esi,%esi
f0101849:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101850:	39 f0                	cmp    %esi,%eax
f0101852:	77 5c                	ja     f01018b0 <__umoddi3+0xb0>
f0101854:	0f bd e8             	bsr    %eax,%ebp
f0101857:	83 f5 1f             	xor    $0x1f,%ebp
f010185a:	75 64                	jne    f01018c0 <__umoddi3+0xc0>
f010185c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f0101860:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f0101864:	0f 86 f6 00 00 00    	jbe    f0101960 <__umoddi3+0x160>
f010186a:	3b 44 24 18          	cmp    0x18(%esp),%eax
f010186e:	0f 82 ec 00 00 00    	jb     f0101960 <__umoddi3+0x160>
f0101874:	8b 44 24 14          	mov    0x14(%esp),%eax
f0101878:	8b 54 24 18          	mov    0x18(%esp),%edx
f010187c:	83 c4 20             	add    $0x20,%esp
f010187f:	5e                   	pop    %esi
f0101880:	5f                   	pop    %edi
f0101881:	5d                   	pop    %ebp
f0101882:	c3                   	ret    
f0101883:	90                   	nop
f0101884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101888:	85 ff                	test   %edi,%edi
f010188a:	89 fd                	mov    %edi,%ebp
f010188c:	75 0b                	jne    f0101899 <__umoddi3+0x99>
f010188e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101893:	31 d2                	xor    %edx,%edx
f0101895:	f7 f7                	div    %edi
f0101897:	89 c5                	mov    %eax,%ebp
f0101899:	8b 44 24 10          	mov    0x10(%esp),%eax
f010189d:	31 d2                	xor    %edx,%edx
f010189f:	f7 f5                	div    %ebp
f01018a1:	89 c8                	mov    %ecx,%eax
f01018a3:	f7 f5                	div    %ebp
f01018a5:	eb 95                	jmp    f010183c <__umoddi3+0x3c>
f01018a7:	89 f6                	mov    %esi,%esi
f01018a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01018b0:	89 c8                	mov    %ecx,%eax
f01018b2:	89 f2                	mov    %esi,%edx
f01018b4:	83 c4 20             	add    $0x20,%esp
f01018b7:	5e                   	pop    %esi
f01018b8:	5f                   	pop    %edi
f01018b9:	5d                   	pop    %ebp
f01018ba:	c3                   	ret    
f01018bb:	90                   	nop
f01018bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018c0:	b8 20 00 00 00       	mov    $0x20,%eax
f01018c5:	89 e9                	mov    %ebp,%ecx
f01018c7:	29 e8                	sub    %ebp,%eax
f01018c9:	d3 e2                	shl    %cl,%edx
f01018cb:	89 c7                	mov    %eax,%edi
f01018cd:	89 44 24 18          	mov    %eax,0x18(%esp)
f01018d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01018d5:	89 f9                	mov    %edi,%ecx
f01018d7:	d3 e8                	shr    %cl,%eax
f01018d9:	89 c1                	mov    %eax,%ecx
f01018db:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01018df:	09 d1                	or     %edx,%ecx
f01018e1:	89 fa                	mov    %edi,%edx
f01018e3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01018e7:	89 e9                	mov    %ebp,%ecx
f01018e9:	d3 e0                	shl    %cl,%eax
f01018eb:	89 f9                	mov    %edi,%ecx
f01018ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018f1:	89 f0                	mov    %esi,%eax
f01018f3:	d3 e8                	shr    %cl,%eax
f01018f5:	89 e9                	mov    %ebp,%ecx
f01018f7:	89 c7                	mov    %eax,%edi
f01018f9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01018fd:	d3 e6                	shl    %cl,%esi
f01018ff:	89 d1                	mov    %edx,%ecx
f0101901:	89 fa                	mov    %edi,%edx
f0101903:	d3 e8                	shr    %cl,%eax
f0101905:	89 e9                	mov    %ebp,%ecx
f0101907:	09 f0                	or     %esi,%eax
f0101909:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f010190d:	f7 74 24 10          	divl   0x10(%esp)
f0101911:	d3 e6                	shl    %cl,%esi
f0101913:	89 d1                	mov    %edx,%ecx
f0101915:	f7 64 24 0c          	mull   0xc(%esp)
f0101919:	39 d1                	cmp    %edx,%ecx
f010191b:	89 74 24 14          	mov    %esi,0x14(%esp)
f010191f:	89 d7                	mov    %edx,%edi
f0101921:	89 c6                	mov    %eax,%esi
f0101923:	72 0a                	jb     f010192f <__umoddi3+0x12f>
f0101925:	39 44 24 14          	cmp    %eax,0x14(%esp)
f0101929:	73 10                	jae    f010193b <__umoddi3+0x13b>
f010192b:	39 d1                	cmp    %edx,%ecx
f010192d:	75 0c                	jne    f010193b <__umoddi3+0x13b>
f010192f:	89 d7                	mov    %edx,%edi
f0101931:	89 c6                	mov    %eax,%esi
f0101933:	2b 74 24 0c          	sub    0xc(%esp),%esi
f0101937:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f010193b:	89 ca                	mov    %ecx,%edx
f010193d:	89 e9                	mov    %ebp,%ecx
f010193f:	8b 44 24 14          	mov    0x14(%esp),%eax
f0101943:	29 f0                	sub    %esi,%eax
f0101945:	19 fa                	sbb    %edi,%edx
f0101947:	d3 e8                	shr    %cl,%eax
f0101949:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f010194e:	89 d7                	mov    %edx,%edi
f0101950:	d3 e7                	shl    %cl,%edi
f0101952:	89 e9                	mov    %ebp,%ecx
f0101954:	09 f8                	or     %edi,%eax
f0101956:	d3 ea                	shr    %cl,%edx
f0101958:	83 c4 20             	add    $0x20,%esp
f010195b:	5e                   	pop    %esi
f010195c:	5f                   	pop    %edi
f010195d:	5d                   	pop    %ebp
f010195e:	c3                   	ret    
f010195f:	90                   	nop
f0101960:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101964:	29 f9                	sub    %edi,%ecx
f0101966:	19 c6                	sbb    %eax,%esi
f0101968:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f010196c:	89 74 24 18          	mov    %esi,0x18(%esp)
f0101970:	e9 ff fe ff ff       	jmp    f0101874 <__umoddi3+0x74>
