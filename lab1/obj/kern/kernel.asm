
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
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

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
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 60 1a 10 f0 	movl   $0xf0101a60,(%esp)
f0100055:	e8 f4 09 00 00       	call   f0100a4e <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 24 07 00 00       	call   f01007ab <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 7c 1a 10 f0 	movl   $0xf0101a7c,(%esp)
f0100092:	e8 b7 09 00 00       	call   f0100a4e <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f01000a8:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 00 23 11 f0 	movl   $0xf0112300,(%esp)
f01000c0:	e8 f2 14 00 00       	call   f01015b7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 95 04 00 00       	call   f010055f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 97 1a 10 f0 	movl   $0xf0101a97,(%esp)
f01000d9:	e8 70 09 00 00       	call   f0100a4e <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 df 07 00 00       	call   f01008d5 <monitor>
f01000f6:	eb f2                	jmp    f01000ea <i386_init+0x4d>

f01000f8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f8:	55                   	push   %ebp
f01000f9:	89 e5                	mov    %esp,%ebp
f01000fb:	56                   	push   %esi
f01000fc:	53                   	push   %ebx
f01000fd:	83 ec 10             	sub    $0x10,%esp
f0100100:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100103:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f010010a:	75 3d                	jne    f0100149 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010010c:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100112:	fa                   	cli    
f0100113:	fc                   	cld    

	va_start(ap, fmt);
f0100114:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100117:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010011e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100121:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100125:	c7 04 24 b2 1a 10 f0 	movl   $0xf0101ab2,(%esp)
f010012c:	e8 1d 09 00 00       	call   f0100a4e <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 de 08 00 00       	call   f0100a1b <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 ee 1a 10 f0 	movl   $0xf0101aee,(%esp)
f0100144:	e8 05 09 00 00       	call   f0100a4e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 80 07 00 00       	call   f01008d5 <monitor>
f0100155:	eb f2                	jmp    f0100149 <_panic+0x51>

f0100157 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100157:	55                   	push   %ebp
f0100158:	89 e5                	mov    %esp,%ebp
f010015a:	53                   	push   %ebx
f010015b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010015e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100161:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100164:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100168:	8b 45 08             	mov    0x8(%ebp),%eax
f010016b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010016f:	c7 04 24 ca 1a 10 f0 	movl   $0xf0101aca,(%esp)
f0100176:	e8 d3 08 00 00       	call   f0100a4e <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 91 08 00 00       	call   f0100a1b <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 ee 1a 10 f0 	movl   $0xf0101aee,(%esp)
f0100191:	e8 b8 08 00 00       	call   f0100a4e <cprintf>
	va_end(ap);
}
f0100196:	83 c4 14             	add    $0x14,%esp
f0100199:	5b                   	pop    %ebx
f010019a:	5d                   	pop    %ebp
f010019b:	c3                   	ret    
f010019c:	66 90                	xchg   %ax,%ax
f010019e:	66 90                	xchg   %ax,%ax

f01001a0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001a8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001a9:	a8 01                	test   $0x1,%al
f01001ab:	74 08                	je     f01001b5 <serial_proc_data+0x15>
f01001ad:	b2 f8                	mov    $0xf8,%dl
f01001af:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001b0:	0f b6 c0             	movzbl %al,%eax
f01001b3:	eb 05                	jmp    f01001ba <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001bc:	55                   	push   %ebp
f01001bd:	89 e5                	mov    %esp,%ebp
f01001bf:	53                   	push   %ebx
f01001c0:	83 ec 04             	sub    $0x4,%esp
f01001c3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001c5:	eb 2a                	jmp    f01001f1 <cons_intr+0x35>
		if (c == 0)
f01001c7:	85 d2                	test   %edx,%edx
f01001c9:	74 26                	je     f01001f1 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001cb:	a1 24 25 11 f0       	mov    0xf0112524,%eax
f01001d0:	8d 48 01             	lea    0x1(%eax),%ecx
f01001d3:	89 0d 24 25 11 f0    	mov    %ecx,0xf0112524
f01001d9:	88 90 20 23 11 f0    	mov    %dl,-0xfeedce0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01001df:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001e5:	75 0a                	jne    f01001f1 <cons_intr+0x35>
			cons.wpos = 0;
f01001e7:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001ee:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d3                	call   *%ebx
f01001f3:	89 c2                	mov    %eax,%edx
f01001f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f8:	75 cd                	jne    f01001c7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001fa:	83 c4 04             	add    $0x4,%esp
f01001fd:	5b                   	pop    %ebx
f01001fe:	5d                   	pop    %ebp
f01001ff:	c3                   	ret    

f0100200 <kbd_proc_data>:
f0100200:	ba 64 00 00 00       	mov    $0x64,%edx
f0100205:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100206:	a8 01                	test   $0x1,%al
f0100208:	0f 84 ef 00 00 00    	je     f01002fd <kbd_proc_data+0xfd>
f010020e:	b2 60                	mov    $0x60,%dl
f0100210:	ec                   	in     (%dx),%al
f0100211:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100213:	3c e0                	cmp    $0xe0,%al
f0100215:	75 0d                	jne    f0100224 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100217:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f010021e:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100223:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100224:	55                   	push   %ebp
f0100225:	89 e5                	mov    %esp,%ebp
f0100227:	53                   	push   %ebx
f0100228:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010022b:	84 c0                	test   %al,%al
f010022d:	79 37                	jns    f0100266 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010022f:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100235:	89 cb                	mov    %ecx,%ebx
f0100237:	83 e3 40             	and    $0x40,%ebx
f010023a:	83 e0 7f             	and    $0x7f,%eax
f010023d:	85 db                	test   %ebx,%ebx
f010023f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100242:	0f b6 d2             	movzbl %dl,%edx
f0100245:	0f b6 82 40 1c 10 f0 	movzbl -0xfefe3c0(%edx),%eax
f010024c:	83 c8 40             	or     $0x40,%eax
f010024f:	0f b6 c0             	movzbl %al,%eax
f0100252:	f7 d0                	not    %eax
f0100254:	21 c1                	and    %eax,%ecx
f0100256:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
		return 0;
f010025c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100261:	e9 9d 00 00 00       	jmp    f0100303 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100266:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010026c:	f6 c1 40             	test   $0x40,%cl
f010026f:	74 0e                	je     f010027f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100271:	83 c8 80             	or     $0xffffff80,%eax
f0100274:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100276:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100279:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f010027f:	0f b6 d2             	movzbl %dl,%edx
f0100282:	0f b6 82 40 1c 10 f0 	movzbl -0xfefe3c0(%edx),%eax
f0100289:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f010028f:	0f b6 8a 40 1b 10 f0 	movzbl -0xfefe4c0(%edx),%ecx
f0100296:	31 c8                	xor    %ecx,%eax
f0100298:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f010029d:	89 c1                	mov    %eax,%ecx
f010029f:	83 e1 03             	and    $0x3,%ecx
f01002a2:	8b 0c 8d 20 1b 10 f0 	mov    -0xfefe4e0(,%ecx,4),%ecx
f01002a9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002ad:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002b0:	a8 08                	test   $0x8,%al
f01002b2:	74 1b                	je     f01002cf <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f01002b4:	89 da                	mov    %ebx,%edx
f01002b6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002b9:	83 f9 19             	cmp    $0x19,%ecx
f01002bc:	77 05                	ja     f01002c3 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f01002be:	83 eb 20             	sub    $0x20,%ebx
f01002c1:	eb 0c                	jmp    f01002cf <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f01002c3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002c6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002c9:	83 fa 19             	cmp    $0x19,%edx
f01002cc:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002cf:	f7 d0                	not    %eax
f01002d1:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d3:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002d5:	f6 c2 06             	test   $0x6,%dl
f01002d8:	75 29                	jne    f0100303 <kbd_proc_data+0x103>
f01002da:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002e0:	75 21                	jne    f0100303 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f01002e2:	c7 04 24 e4 1a 10 f0 	movl   $0xf0101ae4,(%esp)
f01002e9:	e8 60 07 00 00       	call   f0100a4e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ee:	ba 92 00 00 00       	mov    $0x92,%edx
f01002f3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002f8:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002f9:	89 d8                	mov    %ebx,%eax
f01002fb:	eb 06                	jmp    f0100303 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100302:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100303:	83 c4 14             	add    $0x14,%esp
f0100306:	5b                   	pop    %ebx
f0100307:	5d                   	pop    %ebp
f0100308:	c3                   	ret    

f0100309 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100309:	55                   	push   %ebp
f010030a:	89 e5                	mov    %esp,%ebp
f010030c:	57                   	push   %edi
f010030d:	56                   	push   %esi
f010030e:	53                   	push   %ebx
f010030f:	83 ec 1c             	sub    $0x1c,%esp
f0100312:	89 c7                	mov    %eax,%edi
f0100314:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100319:	be fd 03 00 00       	mov    $0x3fd,%esi
f010031e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100323:	eb 06                	jmp    f010032b <cons_putc+0x22>
f0100325:	89 ca                	mov    %ecx,%edx
f0100327:	ec                   	in     (%dx),%al
f0100328:	ec                   	in     (%dx),%al
f0100329:	ec                   	in     (%dx),%al
f010032a:	ec                   	in     (%dx),%al
f010032b:	89 f2                	mov    %esi,%edx
f010032d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010032e:	a8 20                	test   $0x20,%al
f0100330:	75 05                	jne    f0100337 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100332:	83 eb 01             	sub    $0x1,%ebx
f0100335:	75 ee                	jne    f0100325 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100337:	89 f8                	mov    %edi,%eax
f0100339:	0f b6 c0             	movzbl %al,%eax
f010033c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010033f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100344:	ee                   	out    %al,(%dx)
f0100345:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010034a:	be 79 03 00 00       	mov    $0x379,%esi
f010034f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100354:	eb 06                	jmp    f010035c <cons_putc+0x53>
f0100356:	89 ca                	mov    %ecx,%edx
f0100358:	ec                   	in     (%dx),%al
f0100359:	ec                   	in     (%dx),%al
f010035a:	ec                   	in     (%dx),%al
f010035b:	ec                   	in     (%dx),%al
f010035c:	89 f2                	mov    %esi,%edx
f010035e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010035f:	84 c0                	test   %al,%al
f0100361:	78 05                	js     f0100368 <cons_putc+0x5f>
f0100363:	83 eb 01             	sub    $0x1,%ebx
f0100366:	75 ee                	jne    f0100356 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100368:	ba 78 03 00 00       	mov    $0x378,%edx
f010036d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100371:	ee                   	out    %al,(%dx)
f0100372:	b2 7a                	mov    $0x7a,%dl
f0100374:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100379:	ee                   	out    %al,(%dx)
f010037a:	b8 08 00 00 00       	mov    $0x8,%eax
f010037f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100380:	89 fa                	mov    %edi,%edx
f0100382:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100388:	89 f8                	mov    %edi,%eax
f010038a:	80 cc 07             	or     $0x7,%ah
f010038d:	85 d2                	test   %edx,%edx
f010038f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100392:	89 f8                	mov    %edi,%eax
f0100394:	0f b6 c0             	movzbl %al,%eax
f0100397:	83 f8 09             	cmp    $0x9,%eax
f010039a:	74 76                	je     f0100412 <cons_putc+0x109>
f010039c:	83 f8 09             	cmp    $0x9,%eax
f010039f:	7f 0a                	jg     f01003ab <cons_putc+0xa2>
f01003a1:	83 f8 08             	cmp    $0x8,%eax
f01003a4:	74 16                	je     f01003bc <cons_putc+0xb3>
f01003a6:	e9 9b 00 00 00       	jmp    f0100446 <cons_putc+0x13d>
f01003ab:	83 f8 0a             	cmp    $0xa,%eax
f01003ae:	66 90                	xchg   %ax,%ax
f01003b0:	74 3a                	je     f01003ec <cons_putc+0xe3>
f01003b2:	83 f8 0d             	cmp    $0xd,%eax
f01003b5:	74 3d                	je     f01003f4 <cons_putc+0xeb>
f01003b7:	e9 8a 00 00 00       	jmp    f0100446 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f01003bc:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003c3:	66 85 c0             	test   %ax,%ax
f01003c6:	0f 84 e5 00 00 00    	je     f01004b1 <cons_putc+0x1a8>
			crt_pos--;
f01003cc:	83 e8 01             	sub    $0x1,%eax
f01003cf:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003d5:	0f b7 c0             	movzwl %ax,%eax
f01003d8:	66 81 e7 00 ff       	and    $0xff00,%di
f01003dd:	83 cf 20             	or     $0x20,%edi
f01003e0:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003e6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003ea:	eb 78                	jmp    f0100464 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ec:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003f3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003f4:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003fb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100401:	c1 e8 16             	shr    $0x16,%eax
f0100404:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100407:	c1 e0 04             	shl    $0x4,%eax
f010040a:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100410:	eb 52                	jmp    f0100464 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f0100412:	b8 20 00 00 00       	mov    $0x20,%eax
f0100417:	e8 ed fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f010041c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100421:	e8 e3 fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f0100426:	b8 20 00 00 00       	mov    $0x20,%eax
f010042b:	e8 d9 fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 cf fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 c5 fe ff ff       	call   f0100309 <cons_putc>
f0100444:	eb 1e                	jmp    f0100464 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100446:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010044d:	8d 50 01             	lea    0x1(%eax),%edx
f0100450:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100457:	0f b7 c0             	movzwl %ax,%eax
f010045a:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100460:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100464:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010046b:	cf 07 
f010046d:	76 42                	jbe    f01004b1 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010046f:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100474:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010047b:	00 
f010047c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100482:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100486:	89 04 24             	mov    %eax,(%esp)
f0100489:	e8 76 11 00 00       	call   f0101604 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010048e:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100494:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100499:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010049f:	83 c0 01             	add    $0x1,%eax
f01004a2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004a7:	75 f0                	jne    f0100499 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004a9:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004b0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004b1:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004b7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004bc:	89 ca                	mov    %ecx,%edx
f01004be:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004bf:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004c6:	8d 71 01             	lea    0x1(%ecx),%esi
f01004c9:	89 d8                	mov    %ebx,%eax
f01004cb:	66 c1 e8 08          	shr    $0x8,%ax
f01004cf:	89 f2                	mov    %esi,%edx
f01004d1:	ee                   	out    %al,(%dx)
f01004d2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004d7:	89 ca                	mov    %ecx,%edx
f01004d9:	ee                   	out    %al,(%dx)
f01004da:	89 d8                	mov    %ebx,%eax
f01004dc:	89 f2                	mov    %esi,%edx
f01004de:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004df:	83 c4 1c             	add    $0x1c,%esp
f01004e2:	5b                   	pop    %ebx
f01004e3:	5e                   	pop    %esi
f01004e4:	5f                   	pop    %edi
f01004e5:	5d                   	pop    %ebp
f01004e6:	c3                   	ret    

f01004e7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004e7:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004ee:	74 11                	je     f0100501 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004f0:	55                   	push   %ebp
f01004f1:	89 e5                	mov    %esp,%ebp
f01004f3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004f6:	b8 a0 01 10 f0       	mov    $0xf01001a0,%eax
f01004fb:	e8 bc fc ff ff       	call   f01001bc <cons_intr>
}
f0100500:	c9                   	leave  
f0100501:	f3 c3                	repz ret 

f0100503 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100503:	55                   	push   %ebp
f0100504:	89 e5                	mov    %esp,%ebp
f0100506:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100509:	b8 00 02 10 f0       	mov    $0xf0100200,%eax
f010050e:	e8 a9 fc ff ff       	call   f01001bc <cons_intr>
}
f0100513:	c9                   	leave  
f0100514:	c3                   	ret    

f0100515 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100515:	55                   	push   %ebp
f0100516:	89 e5                	mov    %esp,%ebp
f0100518:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010051b:	e8 c7 ff ff ff       	call   f01004e7 <serial_intr>
	kbd_intr();
f0100520:	e8 de ff ff ff       	call   f0100503 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100525:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010052a:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100530:	74 26                	je     f0100558 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100532:	8d 50 01             	lea    0x1(%eax),%edx
f0100535:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010053b:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100542:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100544:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010054a:	75 11                	jne    f010055d <cons_getc+0x48>
			cons.rpos = 0;
f010054c:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100553:	00 00 00 
f0100556:	eb 05                	jmp    f010055d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100558:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010055d:	c9                   	leave  
f010055e:	c3                   	ret    

f010055f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010055f:	55                   	push   %ebp
f0100560:	89 e5                	mov    %esp,%ebp
f0100562:	57                   	push   %edi
f0100563:	56                   	push   %esi
f0100564:	53                   	push   %ebx
f0100565:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100568:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010056f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100576:	5a a5 
	if (*cp != 0xA55A) {
f0100578:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010057f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100583:	74 11                	je     f0100596 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100585:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f010058c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010058f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100594:	eb 16                	jmp    f01005ac <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100596:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010059d:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f01005a4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005a7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005ac:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01005b2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b7:	89 ca                	mov    %ecx,%edx
f01005b9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ba:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005bd:	89 da                	mov    %ebx,%edx
f01005bf:	ec                   	in     (%dx),%al
f01005c0:	0f b6 f0             	movzbl %al,%esi
f01005c3:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005cb:	89 ca                	mov    %ecx,%edx
f01005cd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ce:	89 da                	mov    %ebx,%edx
f01005d0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005d1:	89 3d 2c 25 11 f0    	mov    %edi,0xf011252c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005d7:	0f b6 d8             	movzbl %al,%ebx
f01005da:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005dc:	66 89 35 28 25 11 f0 	mov    %si,0xf0112528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e3:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ed:	89 f2                	mov    %esi,%edx
f01005ef:	ee                   	out    %al,(%dx)
f01005f0:	b2 fb                	mov    $0xfb,%dl
f01005f2:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005f7:	ee                   	out    %al,(%dx)
f01005f8:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005fd:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100602:	89 da                	mov    %ebx,%edx
f0100604:	ee                   	out    %al,(%dx)
f0100605:	b2 f9                	mov    $0xf9,%dl
f0100607:	b8 00 00 00 00       	mov    $0x0,%eax
f010060c:	ee                   	out    %al,(%dx)
f010060d:	b2 fb                	mov    $0xfb,%dl
f010060f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100614:	ee                   	out    %al,(%dx)
f0100615:	b2 fc                	mov    $0xfc,%dl
f0100617:	b8 00 00 00 00       	mov    $0x0,%eax
f010061c:	ee                   	out    %al,(%dx)
f010061d:	b2 f9                	mov    $0xf9,%dl
f010061f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100624:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100625:	b2 fd                	mov    $0xfd,%dl
f0100627:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100628:	3c ff                	cmp    $0xff,%al
f010062a:	0f 95 c1             	setne  %cl
f010062d:	88 0d 34 25 11 f0    	mov    %cl,0xf0112534
f0100633:	89 f2                	mov    %esi,%edx
f0100635:	ec                   	in     (%dx),%al
f0100636:	89 da                	mov    %ebx,%edx
f0100638:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100639:	84 c9                	test   %cl,%cl
f010063b:	75 0c                	jne    f0100649 <cons_init+0xea>
		cprintf("Serial port does not exist!\n");
f010063d:	c7 04 24 f0 1a 10 f0 	movl   $0xf0101af0,(%esp)
f0100644:	e8 05 04 00 00       	call   f0100a4e <cprintf>
}
f0100649:	83 c4 1c             	add    $0x1c,%esp
f010064c:	5b                   	pop    %ebx
f010064d:	5e                   	pop    %esi
f010064e:	5f                   	pop    %edi
f010064f:	5d                   	pop    %ebp
f0100650:	c3                   	ret    

f0100651 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100651:	55                   	push   %ebp
f0100652:	89 e5                	mov    %esp,%ebp
f0100654:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100657:	8b 45 08             	mov    0x8(%ebp),%eax
f010065a:	e8 aa fc ff ff       	call   f0100309 <cons_putc>
}
f010065f:	c9                   	leave  
f0100660:	c3                   	ret    

f0100661 <getchar>:

int
getchar(void)
{
f0100661:	55                   	push   %ebp
f0100662:	89 e5                	mov    %esp,%ebp
f0100664:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100667:	e8 a9 fe ff ff       	call   f0100515 <cons_getc>
f010066c:	85 c0                	test   %eax,%eax
f010066e:	74 f7                	je     f0100667 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100670:	c9                   	leave  
f0100671:	c3                   	ret    

f0100672 <iscons>:

int
iscons(int fdnum)
{
f0100672:	55                   	push   %ebp
f0100673:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100675:	b8 01 00 00 00       	mov    $0x1,%eax
f010067a:	5d                   	pop    %ebp
f010067b:	c3                   	ret    
f010067c:	66 90                	xchg   %ax,%ax
f010067e:	66 90                	xchg   %ax,%ax

f0100680 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100680:	55                   	push   %ebp
f0100681:	89 e5                	mov    %esp,%ebp
f0100683:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100686:	c7 44 24 08 40 1d 10 	movl   $0xf0101d40,0x8(%esp)
f010068d:	f0 
f010068e:	c7 44 24 04 5e 1d 10 	movl   $0xf0101d5e,0x4(%esp)
f0100695:	f0 
f0100696:	c7 04 24 63 1d 10 f0 	movl   $0xf0101d63,(%esp)
f010069d:	e8 ac 03 00 00       	call   f0100a4e <cprintf>
f01006a2:	c7 44 24 08 14 1e 10 	movl   $0xf0101e14,0x8(%esp)
f01006a9:	f0 
f01006aa:	c7 44 24 04 6c 1d 10 	movl   $0xf0101d6c,0x4(%esp)
f01006b1:	f0 
f01006b2:	c7 04 24 63 1d 10 f0 	movl   $0xf0101d63,(%esp)
f01006b9:	e8 90 03 00 00       	call   f0100a4e <cprintf>
f01006be:	c7 44 24 08 75 1d 10 	movl   $0xf0101d75,0x8(%esp)
f01006c5:	f0 
f01006c6:	c7 44 24 04 88 1d 10 	movl   $0xf0101d88,0x4(%esp)
f01006cd:	f0 
f01006ce:	c7 04 24 63 1d 10 f0 	movl   $0xf0101d63,(%esp)
f01006d5:	e8 74 03 00 00       	call   f0100a4e <cprintf>
	return 0;
}
f01006da:	b8 00 00 00 00       	mov    $0x0,%eax
f01006df:	c9                   	leave  
f01006e0:	c3                   	ret    

f01006e1 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006e1:	55                   	push   %ebp
f01006e2:	89 e5                	mov    %esp,%ebp
f01006e4:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006e7:	c7 04 24 92 1d 10 f0 	movl   $0xf0101d92,(%esp)
f01006ee:	e8 5b 03 00 00       	call   f0100a4e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006f3:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01006fa:	00 
f01006fb:	c7 04 24 3c 1e 10 f0 	movl   $0xf0101e3c,(%esp)
f0100702:	e8 47 03 00 00       	call   f0100a4e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100707:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010070e:	00 
f010070f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100716:	f0 
f0100717:	c7 04 24 64 1e 10 f0 	movl   $0xf0101e64,(%esp)
f010071e:	e8 2b 03 00 00       	call   f0100a4e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100723:	c7 44 24 08 47 1a 10 	movl   $0x101a47,0x8(%esp)
f010072a:	00 
f010072b:	c7 44 24 04 47 1a 10 	movl   $0xf0101a47,0x4(%esp)
f0100732:	f0 
f0100733:	c7 04 24 88 1e 10 f0 	movl   $0xf0101e88,(%esp)
f010073a:	e8 0f 03 00 00       	call   f0100a4e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010073f:	c7 44 24 08 00 23 11 	movl   $0x112300,0x8(%esp)
f0100746:	00 
f0100747:	c7 44 24 04 00 23 11 	movl   $0xf0112300,0x4(%esp)
f010074e:	f0 
f010074f:	c7 04 24 ac 1e 10 f0 	movl   $0xf0101eac,(%esp)
f0100756:	e8 f3 02 00 00       	call   f0100a4e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010075b:	c7 44 24 08 44 29 11 	movl   $0x112944,0x8(%esp)
f0100762:	00 
f0100763:	c7 44 24 04 44 29 11 	movl   $0xf0112944,0x4(%esp)
f010076a:	f0 
f010076b:	c7 04 24 d0 1e 10 f0 	movl   $0xf0101ed0,(%esp)
f0100772:	e8 d7 02 00 00       	call   f0100a4e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100777:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f010077c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100781:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100786:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010078c:	85 c0                	test   %eax,%eax
f010078e:	0f 48 c2             	cmovs  %edx,%eax
f0100791:	c1 f8 0a             	sar    $0xa,%eax
f0100794:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100798:	c7 04 24 f4 1e 10 f0 	movl   $0xf0101ef4,(%esp)
f010079f:	e8 aa 02 00 00       	call   f0100a4e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01007a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a9:	c9                   	leave  
f01007aa:	c3                   	ret    

f01007ab <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01007ab:	55                   	push   %ebp
f01007ac:	89 e5                	mov    %esp,%ebp
f01007ae:	57                   	push   %edi
f01007af:	56                   	push   %esi
f01007b0:	53                   	push   %ebx
f01007b1:	81 ec bc 00 00 00    	sub    $0xbc,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01007b7:	89 e8                	mov    %ebp,%eax
	// Your code here.
        uint32_t *ebp;
        uint32_t eip;
        uint32_t arg0, arg1, arg2, arg3, arg4;
        ebp = (uint32_t *)read_ebp();
f01007b9:	89 c3                	mov    %eax,%ebx
        eip = ebp[1];
f01007bb:	8b 70 04             	mov    0x4(%eax),%esi
        arg0 = ebp[2];
f01007be:	8b 50 08             	mov    0x8(%eax),%edx
f01007c1:	89 95 64 ff ff ff    	mov    %edx,-0x9c(%ebp)
        arg1 = ebp[3];
f01007c7:	8b 48 0c             	mov    0xc(%eax),%ecx
f01007ca:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
        arg2 = ebp[4];
f01007d0:	8b 50 10             	mov    0x10(%eax),%edx
f01007d3:	89 95 5c ff ff ff    	mov    %edx,-0xa4(%ebp)
        arg3 = ebp[5];
f01007d9:	8b 78 14             	mov    0x14(%eax),%edi
f01007dc:	89 bd 58 ff ff ff    	mov    %edi,-0xa8(%ebp)
        arg4 = ebp[6];
f01007e2:	8b 78 18             	mov    0x18(%eax),%edi
        cprintf("Stack backtrace:\n");
f01007e5:	c7 04 24 ab 1d 10 f0 	movl   $0xf0101dab,(%esp)
f01007ec:	e8 5d 02 00 00       	call   f0100a4e <cprintf>
f01007f1:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
f01007f7:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
f01007fd:	8b 8d 58 ff ff ff    	mov    -0xa8(%ebp),%ecx
        while(ebp != 0) {
f0100803:	e9 b5 00 00 00       	jmp    f01008bd <mon_backtrace+0x112>
             
             char fn[100];
              
             cprintf("  ebp  %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
f0100808:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f010080c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0100810:	89 54 24 14          	mov    %edx,0x14(%esp)
f0100814:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100818:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f010081e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100822:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100826:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010082a:	c7 04 24 20 1f 10 f0 	movl   $0xf0101f20,(%esp)
f0100831:	e8 18 02 00 00       	call   f0100a4e <cprintf>
                                       ebp, eip, arg0, arg1, arg2, arg3, arg4);
             struct Eipdebuginfo info;
             debuginfo_eip(eip, &info);
f0100836:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f010083c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100840:	89 34 24             	mov    %esi,(%esp)
f0100843:	e8 fd 02 00 00       	call   f0100b45 <debuginfo_eip>
            
             snprintf(fn, info.eip_fn_namelen+1, "%s", info.eip_fn_name);
f0100848:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
f010084e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100852:	c7 44 24 08 bd 1d 10 	movl   $0xf0101dbd,0x8(%esp)
f0100859:	f0 
f010085a:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
f0100860:	83 c0 01             	add    $0x1,%eax
f0100863:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100867:	8d 45 84             	lea    -0x7c(%ebp),%eax
f010086a:	89 04 24             	mov    %eax,(%esp)
f010086d:	e8 b8 0a 00 00       	call   f010132a <snprintf>
            
             cprintf("         %s:%u: %s+%u\n", info.eip_file, info.eip_line, fn, eip - info.eip_fn_addr);
f0100872:	2b b5 7c ff ff ff    	sub    -0x84(%ebp),%esi
f0100878:	89 74 24 10          	mov    %esi,0x10(%esp)
f010087c:	8d 45 84             	lea    -0x7c(%ebp),%eax
f010087f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100883:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
f0100889:	89 44 24 08          	mov    %eax,0x8(%esp)
f010088d:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
f0100893:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100897:	c7 04 24 c0 1d 10 f0 	movl   $0xf0101dc0,(%esp)
f010089e:	e8 ab 01 00 00       	call   f0100a4e <cprintf>
             ebp = (uint32_t *)ebp[0];
f01008a3:	8b 1b                	mov    (%ebx),%ebx
             eip = ebp[1];
f01008a5:	8b 73 04             	mov    0x4(%ebx),%esi
             arg0 = ebp[2];
f01008a8:	8b 43 08             	mov    0x8(%ebx),%eax
f01008ab:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
             arg1 = ebp[3];
f01008b1:	8b 43 0c             	mov    0xc(%ebx),%eax
             arg2 = ebp[4];
f01008b4:	8b 53 10             	mov    0x10(%ebx),%edx
             arg3 = ebp[5];
f01008b7:	8b 4b 14             	mov    0x14(%ebx),%ecx
             arg4 = ebp[6];
f01008ba:	8b 7b 18             	mov    0x18(%ebx),%edi
        arg1 = ebp[3];
        arg2 = ebp[4];
        arg3 = ebp[5];
        arg4 = ebp[6];
        cprintf("Stack backtrace:\n");
        while(ebp != 0) {
f01008bd:	85 db                	test   %ebx,%ebx
f01008bf:	0f 85 43 ff ff ff    	jne    f0100808 <mon_backtrace+0x5d>
             arg2 = ebp[4];
             arg3 = ebp[5];
             arg4 = ebp[6];
        }
	return 0;
}
f01008c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ca:	81 c4 bc 00 00 00    	add    $0xbc,%esp
f01008d0:	5b                   	pop    %ebx
f01008d1:	5e                   	pop    %esi
f01008d2:	5f                   	pop    %edi
f01008d3:	5d                   	pop    %ebp
f01008d4:	c3                   	ret    

f01008d5 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008d5:	55                   	push   %ebp
f01008d6:	89 e5                	mov    %esp,%ebp
f01008d8:	57                   	push   %edi
f01008d9:	56                   	push   %esi
f01008da:	53                   	push   %ebx
f01008db:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008de:	c7 04 24 58 1f 10 f0 	movl   $0xf0101f58,(%esp)
f01008e5:	e8 64 01 00 00       	call   f0100a4e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008ea:	c7 04 24 7c 1f 10 f0 	movl   $0xf0101f7c,(%esp)
f01008f1:	e8 58 01 00 00       	call   f0100a4e <cprintf>


	while (1) {
		buf = readline("K> ");
f01008f6:	c7 04 24 d7 1d 10 f0 	movl   $0xf0101dd7,(%esp)
f01008fd:	e8 5e 0a 00 00       	call   f0101360 <readline>
f0100902:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100904:	85 c0                	test   %eax,%eax
f0100906:	74 ee                	je     f01008f6 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100908:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010090f:	be 00 00 00 00       	mov    $0x0,%esi
f0100914:	eb 0a                	jmp    f0100920 <monitor+0x4b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100916:	c6 03 00             	movb   $0x0,(%ebx)
f0100919:	89 f7                	mov    %esi,%edi
f010091b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010091e:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100920:	0f b6 03             	movzbl (%ebx),%eax
f0100923:	84 c0                	test   %al,%al
f0100925:	74 63                	je     f010098a <monitor+0xb5>
f0100927:	0f be c0             	movsbl %al,%eax
f010092a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010092e:	c7 04 24 db 1d 10 f0 	movl   $0xf0101ddb,(%esp)
f0100935:	e8 40 0c 00 00       	call   f010157a <strchr>
f010093a:	85 c0                	test   %eax,%eax
f010093c:	75 d8                	jne    f0100916 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f010093e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100941:	74 47                	je     f010098a <monitor+0xb5>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100943:	83 fe 0f             	cmp    $0xf,%esi
f0100946:	75 16                	jne    f010095e <monitor+0x89>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100948:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010094f:	00 
f0100950:	c7 04 24 e0 1d 10 f0 	movl   $0xf0101de0,(%esp)
f0100957:	e8 f2 00 00 00       	call   f0100a4e <cprintf>
f010095c:	eb 98                	jmp    f01008f6 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f010095e:	8d 7e 01             	lea    0x1(%esi),%edi
f0100961:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100965:	eb 03                	jmp    f010096a <monitor+0x95>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100967:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010096a:	0f b6 03             	movzbl (%ebx),%eax
f010096d:	84 c0                	test   %al,%al
f010096f:	74 ad                	je     f010091e <monitor+0x49>
f0100971:	0f be c0             	movsbl %al,%eax
f0100974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100978:	c7 04 24 db 1d 10 f0 	movl   $0xf0101ddb,(%esp)
f010097f:	e8 f6 0b 00 00       	call   f010157a <strchr>
f0100984:	85 c0                	test   %eax,%eax
f0100986:	74 df                	je     f0100967 <monitor+0x92>
f0100988:	eb 94                	jmp    f010091e <monitor+0x49>
			buf++;
	}
	argv[argc] = 0;
f010098a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100991:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100992:	85 f6                	test   %esi,%esi
f0100994:	0f 84 5c ff ff ff    	je     f01008f6 <monitor+0x21>
f010099a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010099f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009a2:	8b 04 85 c0 1f 10 f0 	mov    -0xfefe040(,%eax,4),%eax
f01009a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ad:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009b0:	89 04 24             	mov    %eax,(%esp)
f01009b3:	e8 64 0b 00 00       	call   f010151c <strcmp>
f01009b8:	85 c0                	test   %eax,%eax
f01009ba:	75 24                	jne    f01009e0 <monitor+0x10b>
			return commands[i].func(argc, argv, tf);
f01009bc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009bf:	8b 55 08             	mov    0x8(%ebp),%edx
f01009c2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01009c6:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01009c9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01009cd:	89 34 24             	mov    %esi,(%esp)
f01009d0:	ff 14 85 c8 1f 10 f0 	call   *-0xfefe038(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009d7:	85 c0                	test   %eax,%eax
f01009d9:	78 25                	js     f0100a00 <monitor+0x12b>
f01009db:	e9 16 ff ff ff       	jmp    f01008f6 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009e0:	83 c3 01             	add    $0x1,%ebx
f01009e3:	83 fb 03             	cmp    $0x3,%ebx
f01009e6:	75 b7                	jne    f010099f <monitor+0xca>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009e8:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ef:	c7 04 24 fd 1d 10 f0 	movl   $0xf0101dfd,(%esp)
f01009f6:	e8 53 00 00 00       	call   f0100a4e <cprintf>
f01009fb:	e9 f6 fe ff ff       	jmp    f01008f6 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a00:	83 c4 5c             	add    $0x5c,%esp
f0100a03:	5b                   	pop    %ebx
f0100a04:	5e                   	pop    %esi
f0100a05:	5f                   	pop    %edi
f0100a06:	5d                   	pop    %ebp
f0100a07:	c3                   	ret    

f0100a08 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a08:	55                   	push   %ebp
f0100a09:	89 e5                	mov    %esp,%ebp
f0100a0b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100a0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a11:	89 04 24             	mov    %eax,(%esp)
f0100a14:	e8 38 fc ff ff       	call   f0100651 <cputchar>
	*cnt++;
}
f0100a19:	c9                   	leave  
f0100a1a:	c3                   	ret    

f0100a1b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a1b:	55                   	push   %ebp
f0100a1c:	89 e5                	mov    %esp,%ebp
f0100a1e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100a21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a32:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a36:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a3d:	c7 04 24 08 0a 10 f0 	movl   $0xf0100a08,(%esp)
f0100a44:	e8 b5 04 00 00       	call   f0100efe <vprintfmt>
	return cnt;
}
f0100a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a4c:	c9                   	leave  
f0100a4d:	c3                   	ret    

f0100a4e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a4e:	55                   	push   %ebp
f0100a4f:	89 e5                	mov    %esp,%ebp
f0100a51:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a54:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a5e:	89 04 24             	mov    %eax,(%esp)
f0100a61:	e8 b5 ff ff ff       	call   f0100a1b <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a66:	c9                   	leave  
f0100a67:	c3                   	ret    

f0100a68 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a68:	55                   	push   %ebp
f0100a69:	89 e5                	mov    %esp,%ebp
f0100a6b:	57                   	push   %edi
f0100a6c:	56                   	push   %esi
f0100a6d:	53                   	push   %ebx
f0100a6e:	83 ec 10             	sub    $0x10,%esp
f0100a71:	89 c6                	mov    %eax,%esi
f0100a73:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100a76:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100a79:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a7c:	8b 1a                	mov    (%edx),%ebx
f0100a7e:	8b 01                	mov    (%ecx),%eax
f0100a80:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a83:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100a8a:	eb 77                	jmp    f0100b03 <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0100a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a8f:	01 d8                	add    %ebx,%eax
f0100a91:	b9 02 00 00 00       	mov    $0x2,%ecx
f0100a96:	99                   	cltd   
f0100a97:	f7 f9                	idiv   %ecx
f0100a99:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a9b:	eb 01                	jmp    f0100a9e <stab_binsearch+0x36>
			m--;
f0100a9d:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a9e:	39 d9                	cmp    %ebx,%ecx
f0100aa0:	7c 1d                	jl     f0100abf <stab_binsearch+0x57>
f0100aa2:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100aa5:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100aaa:	39 fa                	cmp    %edi,%edx
f0100aac:	75 ef                	jne    f0100a9d <stab_binsearch+0x35>
f0100aae:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100ab1:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100ab4:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0100ab8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100abb:	73 18                	jae    f0100ad5 <stab_binsearch+0x6d>
f0100abd:	eb 05                	jmp    f0100ac4 <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100abf:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0100ac2:	eb 3f                	jmp    f0100b03 <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100ac4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100ac7:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0100ac9:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100acc:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100ad3:	eb 2e                	jmp    f0100b03 <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100ad5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100ad8:	73 15                	jae    f0100aef <stab_binsearch+0x87>
			*region_right = m - 1;
f0100ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100add:	48                   	dec    %eax
f0100ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ae1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100ae4:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ae6:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100aed:	eb 14                	jmp    f0100b03 <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100aef:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100af2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0100af5:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0100af7:	ff 45 0c             	incl   0xc(%ebp)
f0100afa:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100afc:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100b03:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b06:	7e 84                	jle    f0100a8c <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100b08:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100b0c:	75 0d                	jne    f0100b1b <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0100b0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100b11:	8b 00                	mov    (%eax),%eax
f0100b13:	48                   	dec    %eax
f0100b14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b17:	89 07                	mov    %eax,(%edi)
f0100b19:	eb 22                	jmp    f0100b3d <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b1e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b20:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100b23:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b25:	eb 01                	jmp    f0100b28 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100b27:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b28:	39 c1                	cmp    %eax,%ecx
f0100b2a:	7d 0c                	jge    f0100b38 <stab_binsearch+0xd0>
f0100b2c:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0100b2f:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100b34:	39 fa                	cmp    %edi,%edx
f0100b36:	75 ef                	jne    f0100b27 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b38:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0100b3b:	89 07                	mov    %eax,(%edi)
	}
}
f0100b3d:	83 c4 10             	add    $0x10,%esp
f0100b40:	5b                   	pop    %ebx
f0100b41:	5e                   	pop    %esi
f0100b42:	5f                   	pop    %edi
f0100b43:	5d                   	pop    %ebp
f0100b44:	c3                   	ret    

f0100b45 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b45:	55                   	push   %ebp
f0100b46:	89 e5                	mov    %esp,%ebp
f0100b48:	57                   	push   %edi
f0100b49:	56                   	push   %esi
f0100b4a:	53                   	push   %ebx
f0100b4b:	83 ec 3c             	sub    $0x3c,%esp
f0100b4e:	8b 75 08             	mov    0x8(%ebp),%esi
f0100b51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b54:	c7 03 e4 1f 10 f0    	movl   $0xf0101fe4,(%ebx)
	info->eip_line = 0;
f0100b5a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100b61:	c7 43 08 e4 1f 10 f0 	movl   $0xf0101fe4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100b68:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100b6f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b72:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b79:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b7f:	76 12                	jbe    f0100b93 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b81:	b8 8b 75 10 f0       	mov    $0xf010758b,%eax
f0100b86:	3d 39 5c 10 f0       	cmp    $0xf0105c39,%eax
f0100b8b:	0f 86 cd 01 00 00    	jbe    f0100d5e <debuginfo_eip+0x219>
f0100b91:	eb 1c                	jmp    f0100baf <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b93:	c7 44 24 08 ee 1f 10 	movl   $0xf0101fee,0x8(%esp)
f0100b9a:	f0 
f0100b9b:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100ba2:	00 
f0100ba3:	c7 04 24 fb 1f 10 f0 	movl   $0xf0101ffb,(%esp)
f0100baa:	e8 49 f5 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100baf:	80 3d 8a 75 10 f0 00 	cmpb   $0x0,0xf010758a
f0100bb6:	0f 85 a9 01 00 00    	jne    f0100d65 <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100bbc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100bc3:	b8 38 5c 10 f0       	mov    $0xf0105c38,%eax
f0100bc8:	2d 30 22 10 f0       	sub    $0xf0102230,%eax
f0100bcd:	c1 f8 02             	sar    $0x2,%eax
f0100bd0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100bd6:	83 e8 01             	sub    $0x1,%eax
f0100bd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100bdc:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100be0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100be7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100bea:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100bed:	b8 30 22 10 f0       	mov    $0xf0102230,%eax
f0100bf2:	e8 71 fe ff ff       	call   f0100a68 <stab_binsearch>
	if (lfile == 0)
f0100bf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bfa:	85 c0                	test   %eax,%eax
f0100bfc:	0f 84 6a 01 00 00    	je     f0100d6c <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c02:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c05:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c08:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c0b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c0f:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100c16:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c19:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c1c:	b8 30 22 10 f0       	mov    $0xf0102230,%eax
f0100c21:	e8 42 fe ff ff       	call   f0100a68 <stab_binsearch>

	if (lfun <= rfun) {
f0100c26:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c29:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100c2c:	39 d0                	cmp    %edx,%eax
f0100c2e:	7f 3d                	jg     f0100c6d <debuginfo_eip+0x128>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c30:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0100c33:	8d b9 30 22 10 f0    	lea    -0xfefddd0(%ecx),%edi
f0100c39:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100c3c:	8b 89 30 22 10 f0    	mov    -0xfefddd0(%ecx),%ecx
f0100c42:	bf 8b 75 10 f0       	mov    $0xf010758b,%edi
f0100c47:	81 ef 39 5c 10 f0    	sub    $0xf0105c39,%edi
f0100c4d:	39 f9                	cmp    %edi,%ecx
f0100c4f:	73 09                	jae    f0100c5a <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c51:	81 c1 39 5c 10 f0    	add    $0xf0105c39,%ecx
f0100c57:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c5a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c5d:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100c60:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100c63:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100c65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100c68:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c6b:	eb 0f                	jmp    f0100c7c <debuginfo_eip+0x137>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c6d:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100c76:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c79:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c7c:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100c83:	00 
f0100c84:	8b 43 08             	mov    0x8(%ebx),%eax
f0100c87:	89 04 24             	mov    %eax,(%esp)
f0100c8a:	e8 0c 09 00 00       	call   f010159b <strfind>
f0100c8f:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c92:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100c95:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c99:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100ca0:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100ca3:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100ca6:	b8 30 22 10 f0       	mov    $0xf0102230,%eax
f0100cab:	e8 b8 fd ff ff       	call   f0100a68 <stab_binsearch>
        if(lline <= rline)
f0100cb0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cb3:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100cb6:	0f 8f b7 00 00 00    	jg     f0100d73 <debuginfo_eip+0x22e>
              info->eip_line = stabs[lline].n_desc;
f0100cbc:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100cbf:	0f b7 80 36 22 10 f0 	movzwl -0xfefddca(%eax),%eax
f0100cc6:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100cc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ccc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100ccf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cd2:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100cd5:	81 c2 30 22 10 f0    	add    $0xf0102230,%edx
f0100cdb:	eb 06                	jmp    f0100ce3 <debuginfo_eip+0x19e>
f0100cdd:	83 e8 01             	sub    $0x1,%eax
f0100ce0:	83 ea 0c             	sub    $0xc,%edx
f0100ce3:	89 c6                	mov    %eax,%esi
f0100ce5:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100ce8:	7f 33                	jg     f0100d1d <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f0100cea:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100cee:	80 f9 84             	cmp    $0x84,%cl
f0100cf1:	74 0b                	je     f0100cfe <debuginfo_eip+0x1b9>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100cf3:	80 f9 64             	cmp    $0x64,%cl
f0100cf6:	75 e5                	jne    f0100cdd <debuginfo_eip+0x198>
f0100cf8:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100cfc:	74 df                	je     f0100cdd <debuginfo_eip+0x198>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100cfe:	6b f6 0c             	imul   $0xc,%esi,%esi
f0100d01:	8b 86 30 22 10 f0    	mov    -0xfefddd0(%esi),%eax
f0100d07:	ba 8b 75 10 f0       	mov    $0xf010758b,%edx
f0100d0c:	81 ea 39 5c 10 f0    	sub    $0xf0105c39,%edx
f0100d12:	39 d0                	cmp    %edx,%eax
f0100d14:	73 07                	jae    f0100d1d <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100d16:	05 39 5c 10 f0       	add    $0xf0105c39,%eax
f0100d1b:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d1d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d20:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d23:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d28:	39 ca                	cmp    %ecx,%edx
f0100d2a:	7d 53                	jge    f0100d7f <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
f0100d2c:	8d 42 01             	lea    0x1(%edx),%eax
f0100d2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100d32:	89 c2                	mov    %eax,%edx
f0100d34:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100d37:	05 30 22 10 f0       	add    $0xf0102230,%eax
f0100d3c:	89 ce                	mov    %ecx,%esi
f0100d3e:	eb 04                	jmp    f0100d44 <debuginfo_eip+0x1ff>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100d40:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100d44:	39 d6                	cmp    %edx,%esi
f0100d46:	7e 32                	jle    f0100d7a <debuginfo_eip+0x235>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d48:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100d4c:	83 c2 01             	add    $0x1,%edx
f0100d4f:	83 c0 0c             	add    $0xc,%eax
f0100d52:	80 f9 a0             	cmp    $0xa0,%cl
f0100d55:	74 e9                	je     f0100d40 <debuginfo_eip+0x1fb>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d57:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d5c:	eb 21                	jmp    f0100d7f <debuginfo_eip+0x23a>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100d5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d63:	eb 1a                	jmp    f0100d7f <debuginfo_eip+0x23a>
f0100d65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d6a:	eb 13                	jmp    f0100d7f <debuginfo_eip+0x23a>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100d6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d71:	eb 0c                	jmp    f0100d7f <debuginfo_eip+0x23a>
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
        if(lline <= rline)
              info->eip_line = stabs[lline].n_desc;
        else
              return -1;
f0100d73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d78:	eb 05                	jmp    f0100d7f <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d7f:	83 c4 3c             	add    $0x3c,%esp
f0100d82:	5b                   	pop    %ebx
f0100d83:	5e                   	pop    %esi
f0100d84:	5f                   	pop    %edi
f0100d85:	5d                   	pop    %ebp
f0100d86:	c3                   	ret    
f0100d87:	66 90                	xchg   %ax,%ax
f0100d89:	66 90                	xchg   %ax,%ax
f0100d8b:	66 90                	xchg   %ax,%ax
f0100d8d:	66 90                	xchg   %ax,%ax
f0100d8f:	90                   	nop

f0100d90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d90:	55                   	push   %ebp
f0100d91:	89 e5                	mov    %esp,%ebp
f0100d93:	57                   	push   %edi
f0100d94:	56                   	push   %esi
f0100d95:	53                   	push   %ebx
f0100d96:	83 ec 3c             	sub    $0x3c,%esp
f0100d99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d9c:	89 d7                	mov    %edx,%edi
f0100d9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100da1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100da4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100da7:	89 c3                	mov    %eax,%ebx
f0100da9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100dac:	8b 45 10             	mov    0x10(%ebp),%eax
f0100daf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100db2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100db7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100dba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100dbd:	39 d9                	cmp    %ebx,%ecx
f0100dbf:	72 05                	jb     f0100dc6 <printnum+0x36>
f0100dc1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0100dc4:	77 69                	ja     f0100e2f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100dc6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0100dc9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100dcd:	83 ee 01             	sub    $0x1,%esi
f0100dd0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100dd4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100dd8:	8b 44 24 08          	mov    0x8(%esp),%eax
f0100ddc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0100de0:	89 c3                	mov    %eax,%ebx
f0100de2:	89 d6                	mov    %edx,%esi
f0100de4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100de7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100dea:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100dee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100df2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100df5:	89 04 24             	mov    %eax,(%esp)
f0100df8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dff:	e8 bc 09 00 00       	call   f01017c0 <__udivdi3>
f0100e04:	89 d9                	mov    %ebx,%ecx
f0100e06:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100e0a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100e0e:	89 04 24             	mov    %eax,(%esp)
f0100e11:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100e15:	89 fa                	mov    %edi,%edx
f0100e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e1a:	e8 71 ff ff ff       	call   f0100d90 <printnum>
f0100e1f:	eb 1b                	jmp    f0100e3c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100e21:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e25:	8b 45 18             	mov    0x18(%ebp),%eax
f0100e28:	89 04 24             	mov    %eax,(%esp)
f0100e2b:	ff d3                	call   *%ebx
f0100e2d:	eb 03                	jmp    f0100e32 <printnum+0xa2>
f0100e2f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100e32:	83 ee 01             	sub    $0x1,%esi
f0100e35:	85 f6                	test   %esi,%esi
f0100e37:	7f e8                	jg     f0100e21 <printnum+0x91>
f0100e39:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100e3c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e40:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100e44:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e47:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e4a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100e52:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e55:	89 04 24             	mov    %eax,(%esp)
f0100e58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e5f:	e8 8c 0a 00 00       	call   f01018f0 <__umoddi3>
f0100e64:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e68:	0f be 80 09 20 10 f0 	movsbl -0xfefdff7(%eax),%eax
f0100e6f:	89 04 24             	mov    %eax,(%esp)
f0100e72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e75:	ff d0                	call   *%eax
}
f0100e77:	83 c4 3c             	add    $0x3c,%esp
f0100e7a:	5b                   	pop    %ebx
f0100e7b:	5e                   	pop    %esi
f0100e7c:	5f                   	pop    %edi
f0100e7d:	5d                   	pop    %ebp
f0100e7e:	c3                   	ret    

f0100e7f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100e7f:	55                   	push   %ebp
f0100e80:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100e82:	83 fa 01             	cmp    $0x1,%edx
f0100e85:	7e 0e                	jle    f0100e95 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100e87:	8b 10                	mov    (%eax),%edx
f0100e89:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100e8c:	89 08                	mov    %ecx,(%eax)
f0100e8e:	8b 02                	mov    (%edx),%eax
f0100e90:	8b 52 04             	mov    0x4(%edx),%edx
f0100e93:	eb 22                	jmp    f0100eb7 <getuint+0x38>
	else if (lflag)
f0100e95:	85 d2                	test   %edx,%edx
f0100e97:	74 10                	je     f0100ea9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100e99:	8b 10                	mov    (%eax),%edx
f0100e9b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e9e:	89 08                	mov    %ecx,(%eax)
f0100ea0:	8b 02                	mov    (%edx),%eax
f0100ea2:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ea7:	eb 0e                	jmp    f0100eb7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100ea9:	8b 10                	mov    (%eax),%edx
f0100eab:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100eae:	89 08                	mov    %ecx,(%eax)
f0100eb0:	8b 02                	mov    (%edx),%eax
f0100eb2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100eb7:	5d                   	pop    %ebp
f0100eb8:	c3                   	ret    

f0100eb9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100eb9:	55                   	push   %ebp
f0100eba:	89 e5                	mov    %esp,%ebp
f0100ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ebf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100ec3:	8b 10                	mov    (%eax),%edx
f0100ec5:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ec8:	73 0a                	jae    f0100ed4 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100eca:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100ecd:	89 08                	mov    %ecx,(%eax)
f0100ecf:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ed2:	88 02                	mov    %al,(%edx)
}
f0100ed4:	5d                   	pop    %ebp
f0100ed5:	c3                   	ret    

f0100ed6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100ed6:	55                   	push   %ebp
f0100ed7:	89 e5                	mov    %esp,%ebp
f0100ed9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100edc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100edf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee3:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ee6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100eea:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100eed:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ef1:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ef4:	89 04 24             	mov    %eax,(%esp)
f0100ef7:	e8 02 00 00 00       	call   f0100efe <vprintfmt>
	va_end(ap);
}
f0100efc:	c9                   	leave  
f0100efd:	c3                   	ret    

f0100efe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100efe:	55                   	push   %ebp
f0100eff:	89 e5                	mov    %esp,%ebp
f0100f01:	57                   	push   %edi
f0100f02:	56                   	push   %esi
f0100f03:	53                   	push   %ebx
f0100f04:	83 ec 3c             	sub    $0x3c,%esp
f0100f07:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0100f0d:	eb 14                	jmp    f0100f23 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100f0f:	85 c0                	test   %eax,%eax
f0100f11:	0f 84 b3 03 00 00    	je     f01012ca <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
f0100f17:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f1b:	89 04 24             	mov    %eax,(%esp)
f0100f1e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100f21:	89 f3                	mov    %esi,%ebx
f0100f23:	8d 73 01             	lea    0x1(%ebx),%esi
f0100f26:	0f b6 03             	movzbl (%ebx),%eax
f0100f29:	83 f8 25             	cmp    $0x25,%eax
f0100f2c:	75 e1                	jne    f0100f0f <vprintfmt+0x11>
f0100f2e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100f32:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100f39:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0100f40:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0100f47:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f4c:	eb 1d                	jmp    f0100f6b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f4e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100f50:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100f54:	eb 15                	jmp    f0100f6b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f56:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100f58:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100f5c:	eb 0d                	jmp    f0100f6b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100f5e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f61:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100f64:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f6b:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100f6e:	0f b6 0e             	movzbl (%esi),%ecx
f0100f71:	0f b6 c1             	movzbl %cl,%eax
f0100f74:	83 e9 23             	sub    $0x23,%ecx
f0100f77:	80 f9 55             	cmp    $0x55,%cl
f0100f7a:	0f 87 2a 03 00 00    	ja     f01012aa <vprintfmt+0x3ac>
f0100f80:	0f b6 c9             	movzbl %cl,%ecx
f0100f83:	ff 24 8d a0 20 10 f0 	jmp    *-0xfefdf60(,%ecx,4)
f0100f8a:	89 de                	mov    %ebx,%esi
f0100f8c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100f91:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100f94:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0100f98:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100f9b:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0100f9e:	83 fb 09             	cmp    $0x9,%ebx
f0100fa1:	77 36                	ja     f0100fd9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100fa3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100fa6:	eb e9                	jmp    f0100f91 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100fa8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fab:	8d 48 04             	lea    0x4(%eax),%ecx
f0100fae:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100fb1:	8b 00                	mov    (%eax),%eax
f0100fb3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fb6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100fb8:	eb 22                	jmp    f0100fdc <vprintfmt+0xde>
f0100fba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100fbd:	85 c9                	test   %ecx,%ecx
f0100fbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fc4:	0f 49 c1             	cmovns %ecx,%eax
f0100fc7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fca:	89 de                	mov    %ebx,%esi
f0100fcc:	eb 9d                	jmp    f0100f6b <vprintfmt+0x6d>
f0100fce:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100fd0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0100fd7:	eb 92                	jmp    f0100f6b <vprintfmt+0x6d>
f0100fd9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f0100fdc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100fe0:	79 89                	jns    f0100f6b <vprintfmt+0x6d>
f0100fe2:	e9 77 ff ff ff       	jmp    f0100f5e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100fe7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fea:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100fec:	e9 7a ff ff ff       	jmp    f0100f6b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100ff1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff4:	8d 50 04             	lea    0x4(%eax),%edx
f0100ff7:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ffa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ffe:	8b 00                	mov    (%eax),%eax
f0101000:	89 04 24             	mov    %eax,(%esp)
f0101003:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101006:	e9 18 ff ff ff       	jmp    f0100f23 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010100b:	8b 45 14             	mov    0x14(%ebp),%eax
f010100e:	8d 50 04             	lea    0x4(%eax),%edx
f0101011:	89 55 14             	mov    %edx,0x14(%ebp)
f0101014:	8b 00                	mov    (%eax),%eax
f0101016:	99                   	cltd   
f0101017:	31 d0                	xor    %edx,%eax
f0101019:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010101b:	83 f8 07             	cmp    $0x7,%eax
f010101e:	7f 0b                	jg     f010102b <vprintfmt+0x12d>
f0101020:	8b 14 85 00 22 10 f0 	mov    -0xfefde00(,%eax,4),%edx
f0101027:	85 d2                	test   %edx,%edx
f0101029:	75 20                	jne    f010104b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f010102b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010102f:	c7 44 24 08 21 20 10 	movl   $0xf0102021,0x8(%esp)
f0101036:	f0 
f0101037:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010103b:	8b 45 08             	mov    0x8(%ebp),%eax
f010103e:	89 04 24             	mov    %eax,(%esp)
f0101041:	e8 90 fe ff ff       	call   f0100ed6 <printfmt>
f0101046:	e9 d8 fe ff ff       	jmp    f0100f23 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f010104b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010104f:	c7 44 24 08 bd 1d 10 	movl   $0xf0101dbd,0x8(%esp)
f0101056:	f0 
f0101057:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010105b:	8b 45 08             	mov    0x8(%ebp),%eax
f010105e:	89 04 24             	mov    %eax,(%esp)
f0101061:	e8 70 fe ff ff       	call   f0100ed6 <printfmt>
f0101066:	e9 b8 fe ff ff       	jmp    f0100f23 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010106b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010106e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101071:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101074:	8b 45 14             	mov    0x14(%ebp),%eax
f0101077:	8d 50 04             	lea    0x4(%eax),%edx
f010107a:	89 55 14             	mov    %edx,0x14(%ebp)
f010107d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f010107f:	85 f6                	test   %esi,%esi
f0101081:	b8 1a 20 10 f0       	mov    $0xf010201a,%eax
f0101086:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0101089:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f010108d:	0f 84 97 00 00 00    	je     f010112a <vprintfmt+0x22c>
f0101093:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0101097:	0f 8e 9b 00 00 00    	jle    f0101138 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f010109d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01010a1:	89 34 24             	mov    %esi,(%esp)
f01010a4:	e8 9f 03 00 00       	call   f0101448 <strnlen>
f01010a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01010ac:	29 c2                	sub    %eax,%edx
f01010ae:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f01010b1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01010b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01010b8:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01010bb:	8b 75 08             	mov    0x8(%ebp),%esi
f01010be:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01010c1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01010c3:	eb 0f                	jmp    f01010d4 <vprintfmt+0x1d6>
					putch(padc, putdat);
f01010c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01010cc:	89 04 24             	mov    %eax,(%esp)
f01010cf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01010d1:	83 eb 01             	sub    $0x1,%ebx
f01010d4:	85 db                	test   %ebx,%ebx
f01010d6:	7f ed                	jg     f01010c5 <vprintfmt+0x1c7>
f01010d8:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01010db:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01010de:	85 d2                	test   %edx,%edx
f01010e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e5:	0f 49 c2             	cmovns %edx,%eax
f01010e8:	29 c2                	sub    %eax,%edx
f01010ea:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01010ed:	89 d7                	mov    %edx,%edi
f01010ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01010f2:	eb 50                	jmp    f0101144 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01010f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01010f8:	74 1e                	je     f0101118 <vprintfmt+0x21a>
f01010fa:	0f be d2             	movsbl %dl,%edx
f01010fd:	83 ea 20             	sub    $0x20,%edx
f0101100:	83 fa 5e             	cmp    $0x5e,%edx
f0101103:	76 13                	jbe    f0101118 <vprintfmt+0x21a>
					putch('?', putdat);
f0101105:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101108:	89 44 24 04          	mov    %eax,0x4(%esp)
f010110c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101113:	ff 55 08             	call   *0x8(%ebp)
f0101116:	eb 0d                	jmp    f0101125 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0101118:	8b 55 0c             	mov    0xc(%ebp),%edx
f010111b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010111f:	89 04 24             	mov    %eax,(%esp)
f0101122:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101125:	83 ef 01             	sub    $0x1,%edi
f0101128:	eb 1a                	jmp    f0101144 <vprintfmt+0x246>
f010112a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010112d:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101130:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101133:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101136:	eb 0c                	jmp    f0101144 <vprintfmt+0x246>
f0101138:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010113b:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010113e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101141:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101144:	83 c6 01             	add    $0x1,%esi
f0101147:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f010114b:	0f be c2             	movsbl %dl,%eax
f010114e:	85 c0                	test   %eax,%eax
f0101150:	74 27                	je     f0101179 <vprintfmt+0x27b>
f0101152:	85 db                	test   %ebx,%ebx
f0101154:	78 9e                	js     f01010f4 <vprintfmt+0x1f6>
f0101156:	83 eb 01             	sub    $0x1,%ebx
f0101159:	79 99                	jns    f01010f4 <vprintfmt+0x1f6>
f010115b:	89 f8                	mov    %edi,%eax
f010115d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101160:	8b 75 08             	mov    0x8(%ebp),%esi
f0101163:	89 c3                	mov    %eax,%ebx
f0101165:	eb 1a                	jmp    f0101181 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101167:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010116b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101172:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101174:	83 eb 01             	sub    $0x1,%ebx
f0101177:	eb 08                	jmp    f0101181 <vprintfmt+0x283>
f0101179:	89 fb                	mov    %edi,%ebx
f010117b:	8b 75 08             	mov    0x8(%ebp),%esi
f010117e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101181:	85 db                	test   %ebx,%ebx
f0101183:	7f e2                	jg     f0101167 <vprintfmt+0x269>
f0101185:	89 75 08             	mov    %esi,0x8(%ebp)
f0101188:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010118b:	e9 93 fd ff ff       	jmp    f0100f23 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101190:	83 fa 01             	cmp    $0x1,%edx
f0101193:	7e 16                	jle    f01011ab <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f0101195:	8b 45 14             	mov    0x14(%ebp),%eax
f0101198:	8d 50 08             	lea    0x8(%eax),%edx
f010119b:	89 55 14             	mov    %edx,0x14(%ebp)
f010119e:	8b 50 04             	mov    0x4(%eax),%edx
f01011a1:	8b 00                	mov    (%eax),%eax
f01011a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01011a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01011a9:	eb 32                	jmp    f01011dd <vprintfmt+0x2df>
	else if (lflag)
f01011ab:	85 d2                	test   %edx,%edx
f01011ad:	74 18                	je     f01011c7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f01011af:	8b 45 14             	mov    0x14(%ebp),%eax
f01011b2:	8d 50 04             	lea    0x4(%eax),%edx
f01011b5:	89 55 14             	mov    %edx,0x14(%ebp)
f01011b8:	8b 30                	mov    (%eax),%esi
f01011ba:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01011bd:	89 f0                	mov    %esi,%eax
f01011bf:	c1 f8 1f             	sar    $0x1f,%eax
f01011c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01011c5:	eb 16                	jmp    f01011dd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
f01011c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ca:	8d 50 04             	lea    0x4(%eax),%edx
f01011cd:	89 55 14             	mov    %edx,0x14(%ebp)
f01011d0:	8b 30                	mov    (%eax),%esi
f01011d2:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01011d5:	89 f0                	mov    %esi,%eax
f01011d7:	c1 f8 1f             	sar    $0x1f,%eax
f01011da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01011dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01011e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01011e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01011ec:	0f 89 80 00 00 00    	jns    f0101272 <vprintfmt+0x374>
				putch('-', putdat);
f01011f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01011fd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101200:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101203:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101206:	f7 d8                	neg    %eax
f0101208:	83 d2 00             	adc    $0x0,%edx
f010120b:	f7 da                	neg    %edx
			}
			base = 10;
f010120d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101212:	eb 5e                	jmp    f0101272 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101214:	8d 45 14             	lea    0x14(%ebp),%eax
f0101217:	e8 63 fc ff ff       	call   f0100e7f <getuint>
			base = 10;
f010121c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101221:	eb 4f                	jmp    f0101272 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0101223:	8d 45 14             	lea    0x14(%ebp),%eax
f0101226:	e8 54 fc ff ff       	call   f0100e7f <getuint>
                        base = 8;
f010122b:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0101230:	eb 40                	jmp    f0101272 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
f0101232:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101236:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010123d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101240:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101244:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010124b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010124e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101251:	8d 50 04             	lea    0x4(%eax),%edx
f0101254:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101257:	8b 00                	mov    (%eax),%eax
f0101259:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010125e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101263:	eb 0d                	jmp    f0101272 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101265:	8d 45 14             	lea    0x14(%ebp),%eax
f0101268:	e8 12 fc ff ff       	call   f0100e7f <getuint>
			base = 16;
f010126d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101272:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0101276:	89 74 24 10          	mov    %esi,0x10(%esp)
f010127a:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010127d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101281:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101285:	89 04 24             	mov    %eax,(%esp)
f0101288:	89 54 24 04          	mov    %edx,0x4(%esp)
f010128c:	89 fa                	mov    %edi,%edx
f010128e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101291:	e8 fa fa ff ff       	call   f0100d90 <printnum>
			break;
f0101296:	e9 88 fc ff ff       	jmp    f0100f23 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010129b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010129f:	89 04 24             	mov    %eax,(%esp)
f01012a2:	ff 55 08             	call   *0x8(%ebp)
			break;
f01012a5:	e9 79 fc ff ff       	jmp    f0100f23 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01012aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01012b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01012b8:	89 f3                	mov    %esi,%ebx
f01012ba:	eb 03                	jmp    f01012bf <vprintfmt+0x3c1>
f01012bc:	83 eb 01             	sub    $0x1,%ebx
f01012bf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01012c3:	75 f7                	jne    f01012bc <vprintfmt+0x3be>
f01012c5:	e9 59 fc ff ff       	jmp    f0100f23 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f01012ca:	83 c4 3c             	add    $0x3c,%esp
f01012cd:	5b                   	pop    %ebx
f01012ce:	5e                   	pop    %esi
f01012cf:	5f                   	pop    %edi
f01012d0:	5d                   	pop    %ebp
f01012d1:	c3                   	ret    

f01012d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01012d2:	55                   	push   %ebp
f01012d3:	89 e5                	mov    %esp,%ebp
f01012d5:	83 ec 28             	sub    $0x28,%esp
f01012d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01012db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01012de:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01012e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01012e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01012e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01012ef:	85 c0                	test   %eax,%eax
f01012f1:	74 30                	je     f0101323 <vsnprintf+0x51>
f01012f3:	85 d2                	test   %edx,%edx
f01012f5:	7e 2c                	jle    f0101323 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01012f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012fe:	8b 45 10             	mov    0x10(%ebp),%eax
f0101301:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101305:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101308:	89 44 24 04          	mov    %eax,0x4(%esp)
f010130c:	c7 04 24 b9 0e 10 f0 	movl   $0xf0100eb9,(%esp)
f0101313:	e8 e6 fb ff ff       	call   f0100efe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101318:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010131b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010131e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101321:	eb 05                	jmp    f0101328 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101323:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101328:	c9                   	leave  
f0101329:	c3                   	ret    

f010132a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010132a:	55                   	push   %ebp
f010132b:	89 e5                	mov    %esp,%ebp
f010132d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101330:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101333:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101337:	8b 45 10             	mov    0x10(%ebp),%eax
f010133a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010133e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101341:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101345:	8b 45 08             	mov    0x8(%ebp),%eax
f0101348:	89 04 24             	mov    %eax,(%esp)
f010134b:	e8 82 ff ff ff       	call   f01012d2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101350:	c9                   	leave  
f0101351:	c3                   	ret    
f0101352:	66 90                	xchg   %ax,%ax
f0101354:	66 90                	xchg   %ax,%ax
f0101356:	66 90                	xchg   %ax,%ax
f0101358:	66 90                	xchg   %ax,%ax
f010135a:	66 90                	xchg   %ax,%ax
f010135c:	66 90                	xchg   %ax,%ax
f010135e:	66 90                	xchg   %ax,%ax

f0101360 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101360:	55                   	push   %ebp
f0101361:	89 e5                	mov    %esp,%ebp
f0101363:	57                   	push   %edi
f0101364:	56                   	push   %esi
f0101365:	53                   	push   %ebx
f0101366:	83 ec 1c             	sub    $0x1c,%esp
f0101369:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010136c:	85 c0                	test   %eax,%eax
f010136e:	74 10                	je     f0101380 <readline+0x20>
		cprintf("%s", prompt);
f0101370:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101374:	c7 04 24 bd 1d 10 f0 	movl   $0xf0101dbd,(%esp)
f010137b:	e8 ce f6 ff ff       	call   f0100a4e <cprintf>

	i = 0;
	echoing = iscons(0);
f0101380:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101387:	e8 e6 f2 ff ff       	call   f0100672 <iscons>
f010138c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010138e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101393:	e8 c9 f2 ff ff       	call   f0100661 <getchar>
f0101398:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010139a:	85 c0                	test   %eax,%eax
f010139c:	79 17                	jns    f01013b5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010139e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013a2:	c7 04 24 20 22 10 f0 	movl   $0xf0102220,(%esp)
f01013a9:	e8 a0 f6 ff ff       	call   f0100a4e <cprintf>
			return NULL;
f01013ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01013b3:	eb 6d                	jmp    f0101422 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01013b5:	83 f8 7f             	cmp    $0x7f,%eax
f01013b8:	74 05                	je     f01013bf <readline+0x5f>
f01013ba:	83 f8 08             	cmp    $0x8,%eax
f01013bd:	75 19                	jne    f01013d8 <readline+0x78>
f01013bf:	85 f6                	test   %esi,%esi
f01013c1:	7e 15                	jle    f01013d8 <readline+0x78>
			if (echoing)
f01013c3:	85 ff                	test   %edi,%edi
f01013c5:	74 0c                	je     f01013d3 <readline+0x73>
				cputchar('\b');
f01013c7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01013ce:	e8 7e f2 ff ff       	call   f0100651 <cputchar>
			i--;
f01013d3:	83 ee 01             	sub    $0x1,%esi
f01013d6:	eb bb                	jmp    f0101393 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01013d8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01013de:	7f 1c                	jg     f01013fc <readline+0x9c>
f01013e0:	83 fb 1f             	cmp    $0x1f,%ebx
f01013e3:	7e 17                	jle    f01013fc <readline+0x9c>
			if (echoing)
f01013e5:	85 ff                	test   %edi,%edi
f01013e7:	74 08                	je     f01013f1 <readline+0x91>
				cputchar(c);
f01013e9:	89 1c 24             	mov    %ebx,(%esp)
f01013ec:	e8 60 f2 ff ff       	call   f0100651 <cputchar>
			buf[i++] = c;
f01013f1:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01013f7:	8d 76 01             	lea    0x1(%esi),%esi
f01013fa:	eb 97                	jmp    f0101393 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01013fc:	83 fb 0d             	cmp    $0xd,%ebx
f01013ff:	74 05                	je     f0101406 <readline+0xa6>
f0101401:	83 fb 0a             	cmp    $0xa,%ebx
f0101404:	75 8d                	jne    f0101393 <readline+0x33>
			if (echoing)
f0101406:	85 ff                	test   %edi,%edi
f0101408:	74 0c                	je     f0101416 <readline+0xb6>
				cputchar('\n');
f010140a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101411:	e8 3b f2 ff ff       	call   f0100651 <cputchar>
			buf[i] = 0;
f0101416:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f010141d:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f0101422:	83 c4 1c             	add    $0x1c,%esp
f0101425:	5b                   	pop    %ebx
f0101426:	5e                   	pop    %esi
f0101427:	5f                   	pop    %edi
f0101428:	5d                   	pop    %ebp
f0101429:	c3                   	ret    
f010142a:	66 90                	xchg   %ax,%ax
f010142c:	66 90                	xchg   %ax,%ax
f010142e:	66 90                	xchg   %ax,%ax

f0101430 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101430:	55                   	push   %ebp
f0101431:	89 e5                	mov    %esp,%ebp
f0101433:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101436:	b8 00 00 00 00       	mov    $0x0,%eax
f010143b:	eb 03                	jmp    f0101440 <strlen+0x10>
		n++;
f010143d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101440:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101444:	75 f7                	jne    f010143d <strlen+0xd>
		n++;
	return n;
}
f0101446:	5d                   	pop    %ebp
f0101447:	c3                   	ret    

f0101448 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101448:	55                   	push   %ebp
f0101449:	89 e5                	mov    %esp,%ebp
f010144b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010144e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101451:	b8 00 00 00 00       	mov    $0x0,%eax
f0101456:	eb 03                	jmp    f010145b <strnlen+0x13>
		n++;
f0101458:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010145b:	39 d0                	cmp    %edx,%eax
f010145d:	74 06                	je     f0101465 <strnlen+0x1d>
f010145f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101463:	75 f3                	jne    f0101458 <strnlen+0x10>
		n++;
	return n;
}
f0101465:	5d                   	pop    %ebp
f0101466:	c3                   	ret    

f0101467 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101467:	55                   	push   %ebp
f0101468:	89 e5                	mov    %esp,%ebp
f010146a:	53                   	push   %ebx
f010146b:	8b 45 08             	mov    0x8(%ebp),%eax
f010146e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101471:	89 c2                	mov    %eax,%edx
f0101473:	83 c2 01             	add    $0x1,%edx
f0101476:	83 c1 01             	add    $0x1,%ecx
f0101479:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010147d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101480:	84 db                	test   %bl,%bl
f0101482:	75 ef                	jne    f0101473 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101484:	5b                   	pop    %ebx
f0101485:	5d                   	pop    %ebp
f0101486:	c3                   	ret    

f0101487 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101487:	55                   	push   %ebp
f0101488:	89 e5                	mov    %esp,%ebp
f010148a:	53                   	push   %ebx
f010148b:	83 ec 08             	sub    $0x8,%esp
f010148e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101491:	89 1c 24             	mov    %ebx,(%esp)
f0101494:	e8 97 ff ff ff       	call   f0101430 <strlen>
	strcpy(dst + len, src);
f0101499:	8b 55 0c             	mov    0xc(%ebp),%edx
f010149c:	89 54 24 04          	mov    %edx,0x4(%esp)
f01014a0:	01 d8                	add    %ebx,%eax
f01014a2:	89 04 24             	mov    %eax,(%esp)
f01014a5:	e8 bd ff ff ff       	call   f0101467 <strcpy>
	return dst;
}
f01014aa:	89 d8                	mov    %ebx,%eax
f01014ac:	83 c4 08             	add    $0x8,%esp
f01014af:	5b                   	pop    %ebx
f01014b0:	5d                   	pop    %ebp
f01014b1:	c3                   	ret    

f01014b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01014b2:	55                   	push   %ebp
f01014b3:	89 e5                	mov    %esp,%ebp
f01014b5:	56                   	push   %esi
f01014b6:	53                   	push   %ebx
f01014b7:	8b 75 08             	mov    0x8(%ebp),%esi
f01014ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014bd:	89 f3                	mov    %esi,%ebx
f01014bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014c2:	89 f2                	mov    %esi,%edx
f01014c4:	eb 0f                	jmp    f01014d5 <strncpy+0x23>
		*dst++ = *src;
f01014c6:	83 c2 01             	add    $0x1,%edx
f01014c9:	0f b6 01             	movzbl (%ecx),%eax
f01014cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01014cf:	80 39 01             	cmpb   $0x1,(%ecx)
f01014d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014d5:	39 da                	cmp    %ebx,%edx
f01014d7:	75 ed                	jne    f01014c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01014d9:	89 f0                	mov    %esi,%eax
f01014db:	5b                   	pop    %ebx
f01014dc:	5e                   	pop    %esi
f01014dd:	5d                   	pop    %ebp
f01014de:	c3                   	ret    

f01014df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01014df:	55                   	push   %ebp
f01014e0:	89 e5                	mov    %esp,%ebp
f01014e2:	56                   	push   %esi
f01014e3:	53                   	push   %ebx
f01014e4:	8b 75 08             	mov    0x8(%ebp),%esi
f01014e7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01014ed:	89 f0                	mov    %esi,%eax
f01014ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01014f3:	85 c9                	test   %ecx,%ecx
f01014f5:	75 0b                	jne    f0101502 <strlcpy+0x23>
f01014f7:	eb 1d                	jmp    f0101516 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01014f9:	83 c0 01             	add    $0x1,%eax
f01014fc:	83 c2 01             	add    $0x1,%edx
f01014ff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101502:	39 d8                	cmp    %ebx,%eax
f0101504:	74 0b                	je     f0101511 <strlcpy+0x32>
f0101506:	0f b6 0a             	movzbl (%edx),%ecx
f0101509:	84 c9                	test   %cl,%cl
f010150b:	75 ec                	jne    f01014f9 <strlcpy+0x1a>
f010150d:	89 c2                	mov    %eax,%edx
f010150f:	eb 02                	jmp    f0101513 <strlcpy+0x34>
f0101511:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0101513:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0101516:	29 f0                	sub    %esi,%eax
}
f0101518:	5b                   	pop    %ebx
f0101519:	5e                   	pop    %esi
f010151a:	5d                   	pop    %ebp
f010151b:	c3                   	ret    

f010151c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010151c:	55                   	push   %ebp
f010151d:	89 e5                	mov    %esp,%ebp
f010151f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101522:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101525:	eb 06                	jmp    f010152d <strcmp+0x11>
		p++, q++;
f0101527:	83 c1 01             	add    $0x1,%ecx
f010152a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010152d:	0f b6 01             	movzbl (%ecx),%eax
f0101530:	84 c0                	test   %al,%al
f0101532:	74 04                	je     f0101538 <strcmp+0x1c>
f0101534:	3a 02                	cmp    (%edx),%al
f0101536:	74 ef                	je     f0101527 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101538:	0f b6 c0             	movzbl %al,%eax
f010153b:	0f b6 12             	movzbl (%edx),%edx
f010153e:	29 d0                	sub    %edx,%eax
}
f0101540:	5d                   	pop    %ebp
f0101541:	c3                   	ret    

f0101542 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101542:	55                   	push   %ebp
f0101543:	89 e5                	mov    %esp,%ebp
f0101545:	53                   	push   %ebx
f0101546:	8b 45 08             	mov    0x8(%ebp),%eax
f0101549:	8b 55 0c             	mov    0xc(%ebp),%edx
f010154c:	89 c3                	mov    %eax,%ebx
f010154e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101551:	eb 06                	jmp    f0101559 <strncmp+0x17>
		n--, p++, q++;
f0101553:	83 c0 01             	add    $0x1,%eax
f0101556:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101559:	39 d8                	cmp    %ebx,%eax
f010155b:	74 15                	je     f0101572 <strncmp+0x30>
f010155d:	0f b6 08             	movzbl (%eax),%ecx
f0101560:	84 c9                	test   %cl,%cl
f0101562:	74 04                	je     f0101568 <strncmp+0x26>
f0101564:	3a 0a                	cmp    (%edx),%cl
f0101566:	74 eb                	je     f0101553 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101568:	0f b6 00             	movzbl (%eax),%eax
f010156b:	0f b6 12             	movzbl (%edx),%edx
f010156e:	29 d0                	sub    %edx,%eax
f0101570:	eb 05                	jmp    f0101577 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101572:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101577:	5b                   	pop    %ebx
f0101578:	5d                   	pop    %ebp
f0101579:	c3                   	ret    

f010157a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010157a:	55                   	push   %ebp
f010157b:	89 e5                	mov    %esp,%ebp
f010157d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101580:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101584:	eb 07                	jmp    f010158d <strchr+0x13>
		if (*s == c)
f0101586:	38 ca                	cmp    %cl,%dl
f0101588:	74 0f                	je     f0101599 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010158a:	83 c0 01             	add    $0x1,%eax
f010158d:	0f b6 10             	movzbl (%eax),%edx
f0101590:	84 d2                	test   %dl,%dl
f0101592:	75 f2                	jne    f0101586 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101594:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101599:	5d                   	pop    %ebp
f010159a:	c3                   	ret    

f010159b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010159b:	55                   	push   %ebp
f010159c:	89 e5                	mov    %esp,%ebp
f010159e:	8b 45 08             	mov    0x8(%ebp),%eax
f01015a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015a5:	eb 07                	jmp    f01015ae <strfind+0x13>
		if (*s == c)
f01015a7:	38 ca                	cmp    %cl,%dl
f01015a9:	74 0a                	je     f01015b5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01015ab:	83 c0 01             	add    $0x1,%eax
f01015ae:	0f b6 10             	movzbl (%eax),%edx
f01015b1:	84 d2                	test   %dl,%dl
f01015b3:	75 f2                	jne    f01015a7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01015b5:	5d                   	pop    %ebp
f01015b6:	c3                   	ret    

f01015b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01015b7:	55                   	push   %ebp
f01015b8:	89 e5                	mov    %esp,%ebp
f01015ba:	57                   	push   %edi
f01015bb:	56                   	push   %esi
f01015bc:	53                   	push   %ebx
f01015bd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01015c3:	85 c9                	test   %ecx,%ecx
f01015c5:	74 36                	je     f01015fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01015c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01015cd:	75 28                	jne    f01015f7 <memset+0x40>
f01015cf:	f6 c1 03             	test   $0x3,%cl
f01015d2:	75 23                	jne    f01015f7 <memset+0x40>
		c &= 0xFF;
f01015d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01015d8:	89 d3                	mov    %edx,%ebx
f01015da:	c1 e3 08             	shl    $0x8,%ebx
f01015dd:	89 d6                	mov    %edx,%esi
f01015df:	c1 e6 18             	shl    $0x18,%esi
f01015e2:	89 d0                	mov    %edx,%eax
f01015e4:	c1 e0 10             	shl    $0x10,%eax
f01015e7:	09 f0                	or     %esi,%eax
f01015e9:	09 c2                	or     %eax,%edx
f01015eb:	89 d0                	mov    %edx,%eax
f01015ed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01015ef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01015f2:	fc                   	cld    
f01015f3:	f3 ab                	rep stos %eax,%es:(%edi)
f01015f5:	eb 06                	jmp    f01015fd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01015f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015fa:	fc                   	cld    
f01015fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01015fd:	89 f8                	mov    %edi,%eax
f01015ff:	5b                   	pop    %ebx
f0101600:	5e                   	pop    %esi
f0101601:	5f                   	pop    %edi
f0101602:	5d                   	pop    %ebp
f0101603:	c3                   	ret    

f0101604 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101604:	55                   	push   %ebp
f0101605:	89 e5                	mov    %esp,%ebp
f0101607:	57                   	push   %edi
f0101608:	56                   	push   %esi
f0101609:	8b 45 08             	mov    0x8(%ebp),%eax
f010160c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010160f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101612:	39 c6                	cmp    %eax,%esi
f0101614:	73 35                	jae    f010164b <memmove+0x47>
f0101616:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101619:	39 d0                	cmp    %edx,%eax
f010161b:	73 2e                	jae    f010164b <memmove+0x47>
		s += n;
		d += n;
f010161d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0101620:	89 d6                	mov    %edx,%esi
f0101622:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101624:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010162a:	75 13                	jne    f010163f <memmove+0x3b>
f010162c:	f6 c1 03             	test   $0x3,%cl
f010162f:	75 0e                	jne    f010163f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101631:	83 ef 04             	sub    $0x4,%edi
f0101634:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101637:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010163a:	fd                   	std    
f010163b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010163d:	eb 09                	jmp    f0101648 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010163f:	83 ef 01             	sub    $0x1,%edi
f0101642:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101645:	fd                   	std    
f0101646:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101648:	fc                   	cld    
f0101649:	eb 1d                	jmp    f0101668 <memmove+0x64>
f010164b:	89 f2                	mov    %esi,%edx
f010164d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010164f:	f6 c2 03             	test   $0x3,%dl
f0101652:	75 0f                	jne    f0101663 <memmove+0x5f>
f0101654:	f6 c1 03             	test   $0x3,%cl
f0101657:	75 0a                	jne    f0101663 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101659:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010165c:	89 c7                	mov    %eax,%edi
f010165e:	fc                   	cld    
f010165f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101661:	eb 05                	jmp    f0101668 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101663:	89 c7                	mov    %eax,%edi
f0101665:	fc                   	cld    
f0101666:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101668:	5e                   	pop    %esi
f0101669:	5f                   	pop    %edi
f010166a:	5d                   	pop    %ebp
f010166b:	c3                   	ret    

f010166c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010166c:	55                   	push   %ebp
f010166d:	89 e5                	mov    %esp,%ebp
f010166f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101672:	8b 45 10             	mov    0x10(%ebp),%eax
f0101675:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101679:	8b 45 0c             	mov    0xc(%ebp),%eax
f010167c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101680:	8b 45 08             	mov    0x8(%ebp),%eax
f0101683:	89 04 24             	mov    %eax,(%esp)
f0101686:	e8 79 ff ff ff       	call   f0101604 <memmove>
}
f010168b:	c9                   	leave  
f010168c:	c3                   	ret    

f010168d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010168d:	55                   	push   %ebp
f010168e:	89 e5                	mov    %esp,%ebp
f0101690:	56                   	push   %esi
f0101691:	53                   	push   %ebx
f0101692:	8b 55 08             	mov    0x8(%ebp),%edx
f0101695:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101698:	89 d6                	mov    %edx,%esi
f010169a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010169d:	eb 1a                	jmp    f01016b9 <memcmp+0x2c>
		if (*s1 != *s2)
f010169f:	0f b6 02             	movzbl (%edx),%eax
f01016a2:	0f b6 19             	movzbl (%ecx),%ebx
f01016a5:	38 d8                	cmp    %bl,%al
f01016a7:	74 0a                	je     f01016b3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01016a9:	0f b6 c0             	movzbl %al,%eax
f01016ac:	0f b6 db             	movzbl %bl,%ebx
f01016af:	29 d8                	sub    %ebx,%eax
f01016b1:	eb 0f                	jmp    f01016c2 <memcmp+0x35>
		s1++, s2++;
f01016b3:	83 c2 01             	add    $0x1,%edx
f01016b6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016b9:	39 f2                	cmp    %esi,%edx
f01016bb:	75 e2                	jne    f010169f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01016bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016c2:	5b                   	pop    %ebx
f01016c3:	5e                   	pop    %esi
f01016c4:	5d                   	pop    %ebp
f01016c5:	c3                   	ret    

f01016c6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01016c6:	55                   	push   %ebp
f01016c7:	89 e5                	mov    %esp,%ebp
f01016c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01016cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01016cf:	89 c2                	mov    %eax,%edx
f01016d1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01016d4:	eb 07                	jmp    f01016dd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01016d6:	38 08                	cmp    %cl,(%eax)
f01016d8:	74 07                	je     f01016e1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01016da:	83 c0 01             	add    $0x1,%eax
f01016dd:	39 d0                	cmp    %edx,%eax
f01016df:	72 f5                	jb     f01016d6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01016e1:	5d                   	pop    %ebp
f01016e2:	c3                   	ret    

f01016e3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01016e3:	55                   	push   %ebp
f01016e4:	89 e5                	mov    %esp,%ebp
f01016e6:	57                   	push   %edi
f01016e7:	56                   	push   %esi
f01016e8:	53                   	push   %ebx
f01016e9:	8b 55 08             	mov    0x8(%ebp),%edx
f01016ec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01016ef:	eb 03                	jmp    f01016f4 <strtol+0x11>
		s++;
f01016f1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01016f4:	0f b6 0a             	movzbl (%edx),%ecx
f01016f7:	80 f9 09             	cmp    $0x9,%cl
f01016fa:	74 f5                	je     f01016f1 <strtol+0xe>
f01016fc:	80 f9 20             	cmp    $0x20,%cl
f01016ff:	74 f0                	je     f01016f1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101701:	80 f9 2b             	cmp    $0x2b,%cl
f0101704:	75 0a                	jne    f0101710 <strtol+0x2d>
		s++;
f0101706:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101709:	bf 00 00 00 00       	mov    $0x0,%edi
f010170e:	eb 11                	jmp    f0101721 <strtol+0x3e>
f0101710:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101715:	80 f9 2d             	cmp    $0x2d,%cl
f0101718:	75 07                	jne    f0101721 <strtol+0x3e>
		s++, neg = 1;
f010171a:	8d 52 01             	lea    0x1(%edx),%edx
f010171d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101721:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0101726:	75 15                	jne    f010173d <strtol+0x5a>
f0101728:	80 3a 30             	cmpb   $0x30,(%edx)
f010172b:	75 10                	jne    f010173d <strtol+0x5a>
f010172d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101731:	75 0a                	jne    f010173d <strtol+0x5a>
		s += 2, base = 16;
f0101733:	83 c2 02             	add    $0x2,%edx
f0101736:	b8 10 00 00 00       	mov    $0x10,%eax
f010173b:	eb 10                	jmp    f010174d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010173d:	85 c0                	test   %eax,%eax
f010173f:	75 0c                	jne    f010174d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101741:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101743:	80 3a 30             	cmpb   $0x30,(%edx)
f0101746:	75 05                	jne    f010174d <strtol+0x6a>
		s++, base = 8;
f0101748:	83 c2 01             	add    $0x1,%edx
f010174b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010174d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101752:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101755:	0f b6 0a             	movzbl (%edx),%ecx
f0101758:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010175b:	89 f0                	mov    %esi,%eax
f010175d:	3c 09                	cmp    $0x9,%al
f010175f:	77 08                	ja     f0101769 <strtol+0x86>
			dig = *s - '0';
f0101761:	0f be c9             	movsbl %cl,%ecx
f0101764:	83 e9 30             	sub    $0x30,%ecx
f0101767:	eb 20                	jmp    f0101789 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0101769:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010176c:	89 f0                	mov    %esi,%eax
f010176e:	3c 19                	cmp    $0x19,%al
f0101770:	77 08                	ja     f010177a <strtol+0x97>
			dig = *s - 'a' + 10;
f0101772:	0f be c9             	movsbl %cl,%ecx
f0101775:	83 e9 57             	sub    $0x57,%ecx
f0101778:	eb 0f                	jmp    f0101789 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010177a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010177d:	89 f0                	mov    %esi,%eax
f010177f:	3c 19                	cmp    $0x19,%al
f0101781:	77 16                	ja     f0101799 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0101783:	0f be c9             	movsbl %cl,%ecx
f0101786:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101789:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010178c:	7d 0f                	jge    f010179d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f010178e:	83 c2 01             	add    $0x1,%edx
f0101791:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0101795:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0101797:	eb bc                	jmp    f0101755 <strtol+0x72>
f0101799:	89 d8                	mov    %ebx,%eax
f010179b:	eb 02                	jmp    f010179f <strtol+0xbc>
f010179d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f010179f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01017a3:	74 05                	je     f01017aa <strtol+0xc7>
		*endptr = (char *) s;
f01017a5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017a8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01017aa:	f7 d8                	neg    %eax
f01017ac:	85 ff                	test   %edi,%edi
f01017ae:	0f 44 c3             	cmove  %ebx,%eax
}
f01017b1:	5b                   	pop    %ebx
f01017b2:	5e                   	pop    %esi
f01017b3:	5f                   	pop    %edi
f01017b4:	5d                   	pop    %ebp
f01017b5:	c3                   	ret    
f01017b6:	66 90                	xchg   %ax,%ax
f01017b8:	66 90                	xchg   %ax,%ax
f01017ba:	66 90                	xchg   %ax,%ax
f01017bc:	66 90                	xchg   %ax,%ax
f01017be:	66 90                	xchg   %ax,%ax

f01017c0 <__udivdi3>:
f01017c0:	55                   	push   %ebp
f01017c1:	57                   	push   %edi
f01017c2:	56                   	push   %esi
f01017c3:	83 ec 0c             	sub    $0xc,%esp
f01017c6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01017ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01017ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f01017d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01017d6:	85 c0                	test   %eax,%eax
f01017d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01017dc:	89 ea                	mov    %ebp,%edx
f01017de:	89 0c 24             	mov    %ecx,(%esp)
f01017e1:	75 2d                	jne    f0101810 <__udivdi3+0x50>
f01017e3:	39 e9                	cmp    %ebp,%ecx
f01017e5:	77 61                	ja     f0101848 <__udivdi3+0x88>
f01017e7:	85 c9                	test   %ecx,%ecx
f01017e9:	89 ce                	mov    %ecx,%esi
f01017eb:	75 0b                	jne    f01017f8 <__udivdi3+0x38>
f01017ed:	b8 01 00 00 00       	mov    $0x1,%eax
f01017f2:	31 d2                	xor    %edx,%edx
f01017f4:	f7 f1                	div    %ecx
f01017f6:	89 c6                	mov    %eax,%esi
f01017f8:	31 d2                	xor    %edx,%edx
f01017fa:	89 e8                	mov    %ebp,%eax
f01017fc:	f7 f6                	div    %esi
f01017fe:	89 c5                	mov    %eax,%ebp
f0101800:	89 f8                	mov    %edi,%eax
f0101802:	f7 f6                	div    %esi
f0101804:	89 ea                	mov    %ebp,%edx
f0101806:	83 c4 0c             	add    $0xc,%esp
f0101809:	5e                   	pop    %esi
f010180a:	5f                   	pop    %edi
f010180b:	5d                   	pop    %ebp
f010180c:	c3                   	ret    
f010180d:	8d 76 00             	lea    0x0(%esi),%esi
f0101810:	39 e8                	cmp    %ebp,%eax
f0101812:	77 24                	ja     f0101838 <__udivdi3+0x78>
f0101814:	0f bd e8             	bsr    %eax,%ebp
f0101817:	83 f5 1f             	xor    $0x1f,%ebp
f010181a:	75 3c                	jne    f0101858 <__udivdi3+0x98>
f010181c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101820:	39 34 24             	cmp    %esi,(%esp)
f0101823:	0f 86 9f 00 00 00    	jbe    f01018c8 <__udivdi3+0x108>
f0101829:	39 d0                	cmp    %edx,%eax
f010182b:	0f 82 97 00 00 00    	jb     f01018c8 <__udivdi3+0x108>
f0101831:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101838:	31 d2                	xor    %edx,%edx
f010183a:	31 c0                	xor    %eax,%eax
f010183c:	83 c4 0c             	add    $0xc,%esp
f010183f:	5e                   	pop    %esi
f0101840:	5f                   	pop    %edi
f0101841:	5d                   	pop    %ebp
f0101842:	c3                   	ret    
f0101843:	90                   	nop
f0101844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101848:	89 f8                	mov    %edi,%eax
f010184a:	f7 f1                	div    %ecx
f010184c:	31 d2                	xor    %edx,%edx
f010184e:	83 c4 0c             	add    $0xc,%esp
f0101851:	5e                   	pop    %esi
f0101852:	5f                   	pop    %edi
f0101853:	5d                   	pop    %ebp
f0101854:	c3                   	ret    
f0101855:	8d 76 00             	lea    0x0(%esi),%esi
f0101858:	89 e9                	mov    %ebp,%ecx
f010185a:	8b 3c 24             	mov    (%esp),%edi
f010185d:	d3 e0                	shl    %cl,%eax
f010185f:	89 c6                	mov    %eax,%esi
f0101861:	b8 20 00 00 00       	mov    $0x20,%eax
f0101866:	29 e8                	sub    %ebp,%eax
f0101868:	89 c1                	mov    %eax,%ecx
f010186a:	d3 ef                	shr    %cl,%edi
f010186c:	89 e9                	mov    %ebp,%ecx
f010186e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101872:	8b 3c 24             	mov    (%esp),%edi
f0101875:	09 74 24 08          	or     %esi,0x8(%esp)
f0101879:	89 d6                	mov    %edx,%esi
f010187b:	d3 e7                	shl    %cl,%edi
f010187d:	89 c1                	mov    %eax,%ecx
f010187f:	89 3c 24             	mov    %edi,(%esp)
f0101882:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101886:	d3 ee                	shr    %cl,%esi
f0101888:	89 e9                	mov    %ebp,%ecx
f010188a:	d3 e2                	shl    %cl,%edx
f010188c:	89 c1                	mov    %eax,%ecx
f010188e:	d3 ef                	shr    %cl,%edi
f0101890:	09 d7                	or     %edx,%edi
f0101892:	89 f2                	mov    %esi,%edx
f0101894:	89 f8                	mov    %edi,%eax
f0101896:	f7 74 24 08          	divl   0x8(%esp)
f010189a:	89 d6                	mov    %edx,%esi
f010189c:	89 c7                	mov    %eax,%edi
f010189e:	f7 24 24             	mull   (%esp)
f01018a1:	39 d6                	cmp    %edx,%esi
f01018a3:	89 14 24             	mov    %edx,(%esp)
f01018a6:	72 30                	jb     f01018d8 <__udivdi3+0x118>
f01018a8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01018ac:	89 e9                	mov    %ebp,%ecx
f01018ae:	d3 e2                	shl    %cl,%edx
f01018b0:	39 c2                	cmp    %eax,%edx
f01018b2:	73 05                	jae    f01018b9 <__udivdi3+0xf9>
f01018b4:	3b 34 24             	cmp    (%esp),%esi
f01018b7:	74 1f                	je     f01018d8 <__udivdi3+0x118>
f01018b9:	89 f8                	mov    %edi,%eax
f01018bb:	31 d2                	xor    %edx,%edx
f01018bd:	e9 7a ff ff ff       	jmp    f010183c <__udivdi3+0x7c>
f01018c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018c8:	31 d2                	xor    %edx,%edx
f01018ca:	b8 01 00 00 00       	mov    $0x1,%eax
f01018cf:	e9 68 ff ff ff       	jmp    f010183c <__udivdi3+0x7c>
f01018d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018d8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01018db:	31 d2                	xor    %edx,%edx
f01018dd:	83 c4 0c             	add    $0xc,%esp
f01018e0:	5e                   	pop    %esi
f01018e1:	5f                   	pop    %edi
f01018e2:	5d                   	pop    %ebp
f01018e3:	c3                   	ret    
f01018e4:	66 90                	xchg   %ax,%ax
f01018e6:	66 90                	xchg   %ax,%ax
f01018e8:	66 90                	xchg   %ax,%ax
f01018ea:	66 90                	xchg   %ax,%ax
f01018ec:	66 90                	xchg   %ax,%ax
f01018ee:	66 90                	xchg   %ax,%ax

f01018f0 <__umoddi3>:
f01018f0:	55                   	push   %ebp
f01018f1:	57                   	push   %edi
f01018f2:	56                   	push   %esi
f01018f3:	83 ec 14             	sub    $0x14,%esp
f01018f6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01018fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01018fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0101902:	89 c7                	mov    %eax,%edi
f0101904:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101908:	8b 44 24 30          	mov    0x30(%esp),%eax
f010190c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101910:	89 34 24             	mov    %esi,(%esp)
f0101913:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101917:	85 c0                	test   %eax,%eax
f0101919:	89 c2                	mov    %eax,%edx
f010191b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010191f:	75 17                	jne    f0101938 <__umoddi3+0x48>
f0101921:	39 fe                	cmp    %edi,%esi
f0101923:	76 4b                	jbe    f0101970 <__umoddi3+0x80>
f0101925:	89 c8                	mov    %ecx,%eax
f0101927:	89 fa                	mov    %edi,%edx
f0101929:	f7 f6                	div    %esi
f010192b:	89 d0                	mov    %edx,%eax
f010192d:	31 d2                	xor    %edx,%edx
f010192f:	83 c4 14             	add    $0x14,%esp
f0101932:	5e                   	pop    %esi
f0101933:	5f                   	pop    %edi
f0101934:	5d                   	pop    %ebp
f0101935:	c3                   	ret    
f0101936:	66 90                	xchg   %ax,%ax
f0101938:	39 f8                	cmp    %edi,%eax
f010193a:	77 54                	ja     f0101990 <__umoddi3+0xa0>
f010193c:	0f bd e8             	bsr    %eax,%ebp
f010193f:	83 f5 1f             	xor    $0x1f,%ebp
f0101942:	75 5c                	jne    f01019a0 <__umoddi3+0xb0>
f0101944:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101948:	39 3c 24             	cmp    %edi,(%esp)
f010194b:	0f 87 e7 00 00 00    	ja     f0101a38 <__umoddi3+0x148>
f0101951:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101955:	29 f1                	sub    %esi,%ecx
f0101957:	19 c7                	sbb    %eax,%edi
f0101959:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010195d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101961:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101965:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101969:	83 c4 14             	add    $0x14,%esp
f010196c:	5e                   	pop    %esi
f010196d:	5f                   	pop    %edi
f010196e:	5d                   	pop    %ebp
f010196f:	c3                   	ret    
f0101970:	85 f6                	test   %esi,%esi
f0101972:	89 f5                	mov    %esi,%ebp
f0101974:	75 0b                	jne    f0101981 <__umoddi3+0x91>
f0101976:	b8 01 00 00 00       	mov    $0x1,%eax
f010197b:	31 d2                	xor    %edx,%edx
f010197d:	f7 f6                	div    %esi
f010197f:	89 c5                	mov    %eax,%ebp
f0101981:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101985:	31 d2                	xor    %edx,%edx
f0101987:	f7 f5                	div    %ebp
f0101989:	89 c8                	mov    %ecx,%eax
f010198b:	f7 f5                	div    %ebp
f010198d:	eb 9c                	jmp    f010192b <__umoddi3+0x3b>
f010198f:	90                   	nop
f0101990:	89 c8                	mov    %ecx,%eax
f0101992:	89 fa                	mov    %edi,%edx
f0101994:	83 c4 14             	add    $0x14,%esp
f0101997:	5e                   	pop    %esi
f0101998:	5f                   	pop    %edi
f0101999:	5d                   	pop    %ebp
f010199a:	c3                   	ret    
f010199b:	90                   	nop
f010199c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019a0:	8b 04 24             	mov    (%esp),%eax
f01019a3:	be 20 00 00 00       	mov    $0x20,%esi
f01019a8:	89 e9                	mov    %ebp,%ecx
f01019aa:	29 ee                	sub    %ebp,%esi
f01019ac:	d3 e2                	shl    %cl,%edx
f01019ae:	89 f1                	mov    %esi,%ecx
f01019b0:	d3 e8                	shr    %cl,%eax
f01019b2:	89 e9                	mov    %ebp,%ecx
f01019b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019b8:	8b 04 24             	mov    (%esp),%eax
f01019bb:	09 54 24 04          	or     %edx,0x4(%esp)
f01019bf:	89 fa                	mov    %edi,%edx
f01019c1:	d3 e0                	shl    %cl,%eax
f01019c3:	89 f1                	mov    %esi,%ecx
f01019c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019c9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01019cd:	d3 ea                	shr    %cl,%edx
f01019cf:	89 e9                	mov    %ebp,%ecx
f01019d1:	d3 e7                	shl    %cl,%edi
f01019d3:	89 f1                	mov    %esi,%ecx
f01019d5:	d3 e8                	shr    %cl,%eax
f01019d7:	89 e9                	mov    %ebp,%ecx
f01019d9:	09 f8                	or     %edi,%eax
f01019db:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01019df:	f7 74 24 04          	divl   0x4(%esp)
f01019e3:	d3 e7                	shl    %cl,%edi
f01019e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01019e9:	89 d7                	mov    %edx,%edi
f01019eb:	f7 64 24 08          	mull   0x8(%esp)
f01019ef:	39 d7                	cmp    %edx,%edi
f01019f1:	89 c1                	mov    %eax,%ecx
f01019f3:	89 14 24             	mov    %edx,(%esp)
f01019f6:	72 2c                	jb     f0101a24 <__umoddi3+0x134>
f01019f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f01019fc:	72 22                	jb     f0101a20 <__umoddi3+0x130>
f01019fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101a02:	29 c8                	sub    %ecx,%eax
f0101a04:	19 d7                	sbb    %edx,%edi
f0101a06:	89 e9                	mov    %ebp,%ecx
f0101a08:	89 fa                	mov    %edi,%edx
f0101a0a:	d3 e8                	shr    %cl,%eax
f0101a0c:	89 f1                	mov    %esi,%ecx
f0101a0e:	d3 e2                	shl    %cl,%edx
f0101a10:	89 e9                	mov    %ebp,%ecx
f0101a12:	d3 ef                	shr    %cl,%edi
f0101a14:	09 d0                	or     %edx,%eax
f0101a16:	89 fa                	mov    %edi,%edx
f0101a18:	83 c4 14             	add    $0x14,%esp
f0101a1b:	5e                   	pop    %esi
f0101a1c:	5f                   	pop    %edi
f0101a1d:	5d                   	pop    %ebp
f0101a1e:	c3                   	ret    
f0101a1f:	90                   	nop
f0101a20:	39 d7                	cmp    %edx,%edi
f0101a22:	75 da                	jne    f01019fe <__umoddi3+0x10e>
f0101a24:	8b 14 24             	mov    (%esp),%edx
f0101a27:	89 c1                	mov    %eax,%ecx
f0101a29:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0101a2d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0101a31:	eb cb                	jmp    f01019fe <__umoddi3+0x10e>
f0101a33:	90                   	nop
f0101a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0101a3c:	0f 82 0f ff ff ff    	jb     f0101951 <__umoddi3+0x61>
f0101a42:	e9 1a ff ff ff       	jmp    f0101961 <__umoddi3+0x71>
