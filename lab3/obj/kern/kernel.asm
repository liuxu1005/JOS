
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
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


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
f0100046:	b8 50 de 17 f0       	mov    $0xf017de50,%eax
f010004b:	2d e2 ce 17 f0       	sub    $0xf017cee2,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 e2 ce 17 f0       	push   $0xf017cee2
f0100058:	e8 d6 43 00 00       	call   f0104433 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 9a 04 00 00       	call   f01004fc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 00 49 10 f0       	push   $0xf0104900
f010006f:	e8 95 2f 00 00       	call   f0103009 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 c4 10 00 00       	call   f010113d <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 fc 29 00 00       	call   f0102a7a <env_init>
	trap_init();
f010007e:	e8 f7 2f 00 00       	call   f010307a <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 2e 1c 13 f0       	push   $0xf0131c2e
f010008d:	e8 99 2b 00 00       	call   f0102c2b <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 6c d1 17 f0    	pushl  0xf017d16c
f010009b:	e8 b2 2e 00 00       	call   f0102f52 <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 40 de 17 f0 00 	cmpl   $0x0,0xf017de40
f01000af:	75 37                	jne    f01000e8 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 40 de 17 f0    	mov    %esi,0xf017de40

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000bc:	83 ec 04             	sub    $0x4,%esp
f01000bf:	ff 75 0c             	pushl  0xc(%ebp)
f01000c2:	ff 75 08             	pushl  0x8(%ebp)
f01000c5:	68 1b 49 10 f0       	push   $0xf010491b
f01000ca:	e8 3a 2f 00 00       	call   f0103009 <cprintf>
	vcprintf(fmt, ap);
f01000cf:	83 c4 08             	add    $0x8,%esp
f01000d2:	53                   	push   %ebx
f01000d3:	56                   	push   %esi
f01000d4:	e8 0a 2f 00 00       	call   f0102fe3 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 44 51 10 f0 	movl   $0xf0105144,(%esp)
f01000e0:	e8 24 2f 00 00       	call   f0103009 <cprintf>
	va_end(ap);
f01000e5:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	83 ec 0c             	sub    $0xc,%esp
f01000eb:	6a 00                	push   $0x0
f01000ed:	e8 30 07 00 00       	call   f0100822 <monitor>
f01000f2:	83 c4 10             	add    $0x10,%esp
f01000f5:	eb f1                	jmp    f01000e8 <_panic+0x48>

f01000f7 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f7:	55                   	push   %ebp
f01000f8:	89 e5                	mov    %esp,%ebp
f01000fa:	53                   	push   %ebx
f01000fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fe:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100101:	ff 75 0c             	pushl  0xc(%ebp)
f0100104:	ff 75 08             	pushl  0x8(%ebp)
f0100107:	68 33 49 10 f0       	push   $0xf0104933
f010010c:	e8 f8 2e 00 00       	call   f0103009 <cprintf>
	vcprintf(fmt, ap);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	53                   	push   %ebx
f0100115:	ff 75 10             	pushl  0x10(%ebp)
f0100118:	e8 c6 2e 00 00       	call   f0102fe3 <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 44 51 10 f0 	movl   $0xf0105144,(%esp)
f0100124:	e8 e0 2e 00 00       	call   f0103009 <cprintf>
	va_end(ap);
f0100129:	83 c4 10             	add    $0x10,%esp
}
f010012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010012f:	c9                   	leave  
f0100130:	c3                   	ret    

f0100131 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100131:	55                   	push   %ebp
f0100132:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100134:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100139:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013a:	a8 01                	test   $0x1,%al
f010013c:	74 08                	je     f0100146 <serial_proc_data+0x15>
f010013e:	b2 f8                	mov    $0xf8,%dl
f0100140:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100141:	0f b6 c0             	movzbl %al,%eax
f0100144:	eb 05                	jmp    f010014b <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100146:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010014b:	5d                   	pop    %ebp
f010014c:	c3                   	ret    

f010014d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010014d:	55                   	push   %ebp
f010014e:	89 e5                	mov    %esp,%ebp
f0100150:	53                   	push   %ebx
f0100151:	83 ec 04             	sub    $0x4,%esp
f0100154:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100156:	eb 2a                	jmp    f0100182 <cons_intr+0x35>
		if (c == 0)
f0100158:	85 d2                	test   %edx,%edx
f010015a:	74 26                	je     f0100182 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010015c:	a1 44 d1 17 f0       	mov    0xf017d144,%eax
f0100161:	8d 48 01             	lea    0x1(%eax),%ecx
f0100164:	89 0d 44 d1 17 f0    	mov    %ecx,0xf017d144
f010016a:	88 90 40 cf 17 f0    	mov    %dl,-0xfe830c0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f0100170:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100176:	75 0a                	jne    f0100182 <cons_intr+0x35>
			cons.wpos = 0;
f0100178:	c7 05 44 d1 17 f0 00 	movl   $0x0,0xf017d144
f010017f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100182:	ff d3                	call   *%ebx
f0100184:	89 c2                	mov    %eax,%edx
f0100186:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100189:	75 cd                	jne    f0100158 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010018b:	83 c4 04             	add    $0x4,%esp
f010018e:	5b                   	pop    %ebx
f010018f:	5d                   	pop    %ebp
f0100190:	c3                   	ret    

f0100191 <kbd_proc_data>:
f0100191:	ba 64 00 00 00       	mov    $0x64,%edx
f0100196:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100197:	a8 01                	test   $0x1,%al
f0100199:	0f 84 f0 00 00 00    	je     f010028f <kbd_proc_data+0xfe>
f010019f:	b2 60                	mov    $0x60,%dl
f01001a1:	ec                   	in     (%dx),%al
f01001a2:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001a4:	3c e0                	cmp    $0xe0,%al
f01001a6:	75 0d                	jne    f01001b5 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001a8:	83 0d 00 cf 17 f0 40 	orl    $0x40,0xf017cf00
		return 0;
f01001af:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001b4:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001b5:	55                   	push   %ebp
f01001b6:	89 e5                	mov    %esp,%ebp
f01001b8:	53                   	push   %ebx
f01001b9:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001bc:	84 c0                	test   %al,%al
f01001be:	79 36                	jns    f01001f6 <kbd_proc_data+0x65>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001c0:	8b 0d 00 cf 17 f0    	mov    0xf017cf00,%ecx
f01001c6:	89 cb                	mov    %ecx,%ebx
f01001c8:	83 e3 40             	and    $0x40,%ebx
f01001cb:	83 e0 7f             	and    $0x7f,%eax
f01001ce:	85 db                	test   %ebx,%ebx
f01001d0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001d3:	0f b6 d2             	movzbl %dl,%edx
f01001d6:	0f b6 82 c0 4a 10 f0 	movzbl -0xfefb540(%edx),%eax
f01001dd:	83 c8 40             	or     $0x40,%eax
f01001e0:	0f b6 c0             	movzbl %al,%eax
f01001e3:	f7 d0                	not    %eax
f01001e5:	21 c8                	and    %ecx,%eax
f01001e7:	a3 00 cf 17 f0       	mov    %eax,0xf017cf00
		return 0;
f01001ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01001f1:	e9 a1 00 00 00       	jmp    f0100297 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001f6:	8b 0d 00 cf 17 f0    	mov    0xf017cf00,%ecx
f01001fc:	f6 c1 40             	test   $0x40,%cl
f01001ff:	74 0e                	je     f010020f <kbd_proc_data+0x7e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100201:	83 c8 80             	or     $0xffffff80,%eax
f0100204:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100206:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100209:	89 0d 00 cf 17 f0    	mov    %ecx,0xf017cf00
	}

	shift |= shiftcode[data];
f010020f:	0f b6 c2             	movzbl %dl,%eax
f0100212:	0f b6 90 c0 4a 10 f0 	movzbl -0xfefb540(%eax),%edx
f0100219:	0b 15 00 cf 17 f0    	or     0xf017cf00,%edx
	shift ^= togglecode[data];
f010021f:	0f b6 88 c0 49 10 f0 	movzbl -0xfefb640(%eax),%ecx
f0100226:	31 ca                	xor    %ecx,%edx
f0100228:	89 15 00 cf 17 f0    	mov    %edx,0xf017cf00

	c = charcode[shift & (CTL | SHIFT)][data];
f010022e:	89 d1                	mov    %edx,%ecx
f0100230:	83 e1 03             	and    $0x3,%ecx
f0100233:	8b 0c 8d 80 49 10 f0 	mov    -0xfefb680(,%ecx,4),%ecx
f010023a:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f010023e:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f0100241:	f6 c2 08             	test   $0x8,%dl
f0100244:	74 1b                	je     f0100261 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f0100246:	89 d8                	mov    %ebx,%eax
f0100248:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010024b:	83 f9 19             	cmp    $0x19,%ecx
f010024e:	77 05                	ja     f0100255 <kbd_proc_data+0xc4>
			c += 'A' - 'a';
f0100250:	83 eb 20             	sub    $0x20,%ebx
f0100253:	eb 0c                	jmp    f0100261 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f0100255:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f0100258:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010025b:	83 f8 19             	cmp    $0x19,%eax
f010025e:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100261:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100267:	75 2c                	jne    f0100295 <kbd_proc_data+0x104>
f0100269:	f7 d2                	not    %edx
f010026b:	f6 c2 06             	test   $0x6,%dl
f010026e:	75 25                	jne    f0100295 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100270:	83 ec 0c             	sub    $0xc,%esp
f0100273:	68 4d 49 10 f0       	push   $0xf010494d
f0100278:	e8 8c 2d 00 00       	call   f0103009 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010027d:	ba 92 00 00 00       	mov    $0x92,%edx
f0100282:	b8 03 00 00 00       	mov    $0x3,%eax
f0100287:	ee                   	out    %al,(%dx)
f0100288:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010028b:	89 d8                	mov    %ebx,%eax
f010028d:	eb 08                	jmp    f0100297 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010028f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100294:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100295:	89 d8                	mov    %ebx,%eax
}
f0100297:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010029a:	c9                   	leave  
f010029b:	c3                   	ret    

f010029c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010029c:	55                   	push   %ebp
f010029d:	89 e5                	mov    %esp,%ebp
f010029f:	57                   	push   %edi
f01002a0:	56                   	push   %esi
f01002a1:	53                   	push   %ebx
f01002a2:	83 ec 1c             	sub    $0x1c,%esp
f01002a5:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a7:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ac:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002b1:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b6:	eb 09                	jmp    f01002c1 <cons_putc+0x25>
f01002b8:	89 ca                	mov    %ecx,%edx
f01002ba:	ec                   	in     (%dx),%al
f01002bb:	ec                   	in     (%dx),%al
f01002bc:	ec                   	in     (%dx),%al
f01002bd:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002be:	83 c3 01             	add    $0x1,%ebx
f01002c1:	89 f2                	mov    %esi,%edx
f01002c3:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002c4:	a8 20                	test   $0x20,%al
f01002c6:	75 08                	jne    f01002d0 <cons_putc+0x34>
f01002c8:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002ce:	7e e8                	jle    f01002b8 <cons_putc+0x1c>
f01002d0:	89 f8                	mov    %edi,%eax
f01002d2:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002da:	89 f8                	mov    %edi,%eax
f01002dc:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002dd:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e2:	be 79 03 00 00       	mov    $0x379,%esi
f01002e7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002ec:	eb 09                	jmp    f01002f7 <cons_putc+0x5b>
f01002ee:	89 ca                	mov    %ecx,%edx
f01002f0:	ec                   	in     (%dx),%al
f01002f1:	ec                   	in     (%dx),%al
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	ec                   	in     (%dx),%al
f01002f4:	83 c3 01             	add    $0x1,%ebx
f01002f7:	89 f2                	mov    %esi,%edx
f01002f9:	ec                   	in     (%dx),%al
f01002fa:	84 c0                	test   %al,%al
f01002fc:	78 08                	js     f0100306 <cons_putc+0x6a>
f01002fe:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100304:	7e e8                	jle    f01002ee <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100306:	ba 78 03 00 00       	mov    $0x378,%edx
f010030b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010030f:	ee                   	out    %al,(%dx)
f0100310:	b2 7a                	mov    $0x7a,%dl
f0100312:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100317:	ee                   	out    %al,(%dx)
f0100318:	b8 08 00 00 00       	mov    $0x8,%eax
f010031d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010031e:	89 fa                	mov    %edi,%edx
f0100320:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	80 cc 07             	or     $0x7,%ah
f010032b:	85 d2                	test   %edx,%edx
f010032d:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100330:	89 f8                	mov    %edi,%eax
f0100332:	0f b6 c0             	movzbl %al,%eax
f0100335:	83 f8 09             	cmp    $0x9,%eax
f0100338:	74 74                	je     f01003ae <cons_putc+0x112>
f010033a:	83 f8 09             	cmp    $0x9,%eax
f010033d:	7f 0a                	jg     f0100349 <cons_putc+0xad>
f010033f:	83 f8 08             	cmp    $0x8,%eax
f0100342:	74 14                	je     f0100358 <cons_putc+0xbc>
f0100344:	e9 99 00 00 00       	jmp    f01003e2 <cons_putc+0x146>
f0100349:	83 f8 0a             	cmp    $0xa,%eax
f010034c:	74 3a                	je     f0100388 <cons_putc+0xec>
f010034e:	83 f8 0d             	cmp    $0xd,%eax
f0100351:	74 3d                	je     f0100390 <cons_putc+0xf4>
f0100353:	e9 8a 00 00 00       	jmp    f01003e2 <cons_putc+0x146>
	case '\b':
		if (crt_pos > 0) {
f0100358:	0f b7 05 48 d1 17 f0 	movzwl 0xf017d148,%eax
f010035f:	66 85 c0             	test   %ax,%ax
f0100362:	0f 84 e6 00 00 00    	je     f010044e <cons_putc+0x1b2>
			crt_pos--;
f0100368:	83 e8 01             	sub    $0x1,%eax
f010036b:	66 a3 48 d1 17 f0    	mov    %ax,0xf017d148
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100371:	0f b7 c0             	movzwl %ax,%eax
f0100374:	66 81 e7 00 ff       	and    $0xff00,%di
f0100379:	83 cf 20             	or     $0x20,%edi
f010037c:	8b 15 4c d1 17 f0    	mov    0xf017d14c,%edx
f0100382:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100386:	eb 78                	jmp    f0100400 <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100388:	66 83 05 48 d1 17 f0 	addw   $0x50,0xf017d148
f010038f:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100390:	0f b7 05 48 d1 17 f0 	movzwl 0xf017d148,%eax
f0100397:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010039d:	c1 e8 16             	shr    $0x16,%eax
f01003a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a3:	c1 e0 04             	shl    $0x4,%eax
f01003a6:	66 a3 48 d1 17 f0    	mov    %ax,0xf017d148
f01003ac:	eb 52                	jmp    f0100400 <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
f01003ae:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b3:	e8 e4 fe ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f01003b8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003bd:	e8 da fe ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f01003c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c7:	e8 d0 fe ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f01003cc:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d1:	e8 c6 fe ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f01003d6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003db:	e8 bc fe ff ff       	call   f010029c <cons_putc>
f01003e0:	eb 1e                	jmp    f0100400 <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003e2:	0f b7 05 48 d1 17 f0 	movzwl 0xf017d148,%eax
f01003e9:	8d 50 01             	lea    0x1(%eax),%edx
f01003ec:	66 89 15 48 d1 17 f0 	mov    %dx,0xf017d148
f01003f3:	0f b7 c0             	movzwl %ax,%eax
f01003f6:	8b 15 4c d1 17 f0    	mov    0xf017d14c,%edx
f01003fc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100400:	66 81 3d 48 d1 17 f0 	cmpw   $0x7cf,0xf017d148
f0100407:	cf 07 
f0100409:	76 43                	jbe    f010044e <cons_putc+0x1b2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010040b:	a1 4c d1 17 f0       	mov    0xf017d14c,%eax
f0100410:	83 ec 04             	sub    $0x4,%esp
f0100413:	68 00 0f 00 00       	push   $0xf00
f0100418:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041e:	52                   	push   %edx
f010041f:	50                   	push   %eax
f0100420:	e8 5b 40 00 00       	call   f0104480 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100425:	8b 15 4c d1 17 f0    	mov    0xf017d14c,%edx
f010042b:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100431:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100437:	83 c4 10             	add    $0x10,%esp
f010043a:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010043f:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100442:	39 d0                	cmp    %edx,%eax
f0100444:	75 f4                	jne    f010043a <cons_putc+0x19e>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100446:	66 83 2d 48 d1 17 f0 	subw   $0x50,0xf017d148
f010044d:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044e:	8b 0d 50 d1 17 f0    	mov    0xf017d150,%ecx
f0100454:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100459:	89 ca                	mov    %ecx,%edx
f010045b:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045c:	0f b7 1d 48 d1 17 f0 	movzwl 0xf017d148,%ebx
f0100463:	8d 71 01             	lea    0x1(%ecx),%esi
f0100466:	89 d8                	mov    %ebx,%eax
f0100468:	66 c1 e8 08          	shr    $0x8,%ax
f010046c:	89 f2                	mov    %esi,%edx
f010046e:	ee                   	out    %al,(%dx)
f010046f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100474:	89 ca                	mov    %ecx,%edx
f0100476:	ee                   	out    %al,(%dx)
f0100477:	89 d8                	mov    %ebx,%eax
f0100479:	89 f2                	mov    %esi,%edx
f010047b:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010047c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010047f:	5b                   	pop    %ebx
f0100480:	5e                   	pop    %esi
f0100481:	5f                   	pop    %edi
f0100482:	5d                   	pop    %ebp
f0100483:	c3                   	ret    

f0100484 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100484:	80 3d 54 d1 17 f0 00 	cmpb   $0x0,0xf017d154
f010048b:	74 11                	je     f010049e <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010048d:	55                   	push   %ebp
f010048e:	89 e5                	mov    %esp,%ebp
f0100490:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100493:	b8 31 01 10 f0       	mov    $0xf0100131,%eax
f0100498:	e8 b0 fc ff ff       	call   f010014d <cons_intr>
}
f010049d:	c9                   	leave  
f010049e:	f3 c3                	repz ret 

f01004a0 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a0:	55                   	push   %ebp
f01004a1:	89 e5                	mov    %esp,%ebp
f01004a3:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a6:	b8 91 01 10 f0       	mov    $0xf0100191,%eax
f01004ab:	e8 9d fc ff ff       	call   f010014d <cons_intr>
}
f01004b0:	c9                   	leave  
f01004b1:	c3                   	ret    

f01004b2 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b2:	55                   	push   %ebp
f01004b3:	89 e5                	mov    %esp,%ebp
f01004b5:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b8:	e8 c7 ff ff ff       	call   f0100484 <serial_intr>
	kbd_intr();
f01004bd:	e8 de ff ff ff       	call   f01004a0 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c2:	a1 40 d1 17 f0       	mov    0xf017d140,%eax
f01004c7:	3b 05 44 d1 17 f0    	cmp    0xf017d144,%eax
f01004cd:	74 26                	je     f01004f5 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cf:	8d 50 01             	lea    0x1(%eax),%edx
f01004d2:	89 15 40 d1 17 f0    	mov    %edx,0xf017d140
f01004d8:	0f b6 88 40 cf 17 f0 	movzbl -0xfe830c0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004df:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004e1:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e7:	75 11                	jne    f01004fa <cons_getc+0x48>
			cons.rpos = 0;
f01004e9:	c7 05 40 d1 17 f0 00 	movl   $0x0,0xf017d140
f01004f0:	00 00 00 
f01004f3:	eb 05                	jmp    f01004fa <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004fa:	c9                   	leave  
f01004fb:	c3                   	ret    

f01004fc <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004fc:	55                   	push   %ebp
f01004fd:	89 e5                	mov    %esp,%ebp
f01004ff:	57                   	push   %edi
f0100500:	56                   	push   %esi
f0100501:	53                   	push   %ebx
f0100502:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100505:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010050c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100513:	5a a5 
	if (*cp != 0xA55A) {
f0100515:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010051c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100520:	74 11                	je     f0100533 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100522:	c7 05 50 d1 17 f0 b4 	movl   $0x3b4,0xf017d150
f0100529:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100531:	eb 16                	jmp    f0100549 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100533:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010053a:	c7 05 50 d1 17 f0 d4 	movl   $0x3d4,0xf017d150
f0100541:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100544:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100549:	8b 3d 50 d1 17 f0    	mov    0xf017d150,%edi
f010054f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100554:	89 fa                	mov    %edi,%edx
f0100556:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100557:	8d 4f 01             	lea    0x1(%edi),%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055a:	89 ca                	mov    %ecx,%edx
f010055c:	ec                   	in     (%dx),%al
f010055d:	0f b6 c0             	movzbl %al,%eax
f0100560:	c1 e0 08             	shl    $0x8,%eax
f0100563:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100565:	b8 0f 00 00 00       	mov    $0xf,%eax
f010056a:	89 fa                	mov    %edi,%edx
f010056c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056d:	89 ca                	mov    %ecx,%edx
f010056f:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100570:	89 35 4c d1 17 f0    	mov    %esi,0xf017d14c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100576:	0f b6 c8             	movzbl %al,%ecx
f0100579:	89 d8                	mov    %ebx,%eax
f010057b:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010057d:	66 a3 48 d1 17 f0    	mov    %ax,0xf017d148
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100583:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100588:	b8 00 00 00 00       	mov    $0x0,%eax
f010058d:	89 da                	mov    %ebx,%edx
f010058f:	ee                   	out    %al,(%dx)
f0100590:	b2 fb                	mov    $0xfb,%dl
f0100592:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100597:	ee                   	out    %al,(%dx)
f0100598:	be f8 03 00 00       	mov    $0x3f8,%esi
f010059d:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a2:	89 f2                	mov    %esi,%edx
f01005a4:	ee                   	out    %al,(%dx)
f01005a5:	b2 f9                	mov    $0xf9,%dl
f01005a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ac:	ee                   	out    %al,(%dx)
f01005ad:	b2 fb                	mov    $0xfb,%dl
f01005af:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b4:	ee                   	out    %al,(%dx)
f01005b5:	b2 fc                	mov    $0xfc,%dl
f01005b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005bc:	ee                   	out    %al,(%dx)
f01005bd:	b2 f9                	mov    $0xf9,%dl
f01005bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01005c4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c5:	b2 fd                	mov    $0xfd,%dl
f01005c7:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005c8:	3c ff                	cmp    $0xff,%al
f01005ca:	0f 95 c1             	setne  %cl
f01005cd:	88 0d 54 d1 17 f0    	mov    %cl,0xf017d154
f01005d3:	89 da                	mov    %ebx,%edx
f01005d5:	ec                   	in     (%dx),%al
f01005d6:	89 f2                	mov    %esi,%edx
f01005d8:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d9:	84 c9                	test   %cl,%cl
f01005db:	75 10                	jne    f01005ed <cons_init+0xf1>
		cprintf("Serial port does not exist!\n");
f01005dd:	83 ec 0c             	sub    $0xc,%esp
f01005e0:	68 59 49 10 f0       	push   $0xf0104959
f01005e5:	e8 1f 2a 00 00       	call   f0103009 <cprintf>
f01005ea:	83 c4 10             	add    $0x10,%esp
}
f01005ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005f0:	5b                   	pop    %ebx
f01005f1:	5e                   	pop    %esi
f01005f2:	5f                   	pop    %edi
f01005f3:	5d                   	pop    %ebp
f01005f4:	c3                   	ret    

f01005f5 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f5:	55                   	push   %ebp
f01005f6:	89 e5                	mov    %esp,%ebp
f01005f8:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01005fe:	e8 99 fc ff ff       	call   f010029c <cons_putc>
}
f0100603:	c9                   	leave  
f0100604:	c3                   	ret    

f0100605 <getchar>:

int
getchar(void)
{
f0100605:	55                   	push   %ebp
f0100606:	89 e5                	mov    %esp,%ebp
f0100608:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010060b:	e8 a2 fe ff ff       	call   f01004b2 <cons_getc>
f0100610:	85 c0                	test   %eax,%eax
f0100612:	74 f7                	je     f010060b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100614:	c9                   	leave  
f0100615:	c3                   	ret    

f0100616 <iscons>:

int
iscons(int fdnum)
{
f0100616:	55                   	push   %ebp
f0100617:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100619:	b8 01 00 00 00       	mov    $0x1,%eax
f010061e:	5d                   	pop    %ebp
f010061f:	c3                   	ret    

f0100620 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100626:	68 c0 4b 10 f0       	push   $0xf0104bc0
f010062b:	68 de 4b 10 f0       	push   $0xf0104bde
f0100630:	68 e3 4b 10 f0       	push   $0xf0104be3
f0100635:	e8 cf 29 00 00       	call   f0103009 <cprintf>
f010063a:	83 c4 0c             	add    $0xc,%esp
f010063d:	68 90 4c 10 f0       	push   $0xf0104c90
f0100642:	68 ec 4b 10 f0       	push   $0xf0104bec
f0100647:	68 e3 4b 10 f0       	push   $0xf0104be3
f010064c:	e8 b8 29 00 00       	call   f0103009 <cprintf>
f0100651:	83 c4 0c             	add    $0xc,%esp
f0100654:	68 f5 4b 10 f0       	push   $0xf0104bf5
f0100659:	68 08 4c 10 f0       	push   $0xf0104c08
f010065e:	68 e3 4b 10 f0       	push   $0xf0104be3
f0100663:	e8 a1 29 00 00       	call   f0103009 <cprintf>
	return 0;
}
f0100668:	b8 00 00 00 00       	mov    $0x0,%eax
f010066d:	c9                   	leave  
f010066e:	c3                   	ret    

f010066f <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010066f:	55                   	push   %ebp
f0100670:	89 e5                	mov    %esp,%ebp
f0100672:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100675:	68 12 4c 10 f0       	push   $0xf0104c12
f010067a:	e8 8a 29 00 00       	call   f0103009 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010067f:	83 c4 08             	add    $0x8,%esp
f0100682:	68 0c 00 10 00       	push   $0x10000c
f0100687:	68 b8 4c 10 f0       	push   $0xf0104cb8
f010068c:	e8 78 29 00 00       	call   f0103009 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100691:	83 c4 0c             	add    $0xc,%esp
f0100694:	68 0c 00 10 00       	push   $0x10000c
f0100699:	68 0c 00 10 f0       	push   $0xf010000c
f010069e:	68 e0 4c 10 f0       	push   $0xf0104ce0
f01006a3:	e8 61 29 00 00       	call   f0103009 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a8:	83 c4 0c             	add    $0xc,%esp
f01006ab:	68 e5 48 10 00       	push   $0x1048e5
f01006b0:	68 e5 48 10 f0       	push   $0xf01048e5
f01006b5:	68 04 4d 10 f0       	push   $0xf0104d04
f01006ba:	e8 4a 29 00 00       	call   f0103009 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006bf:	83 c4 0c             	add    $0xc,%esp
f01006c2:	68 e2 ce 17 00       	push   $0x17cee2
f01006c7:	68 e2 ce 17 f0       	push   $0xf017cee2
f01006cc:	68 28 4d 10 f0       	push   $0xf0104d28
f01006d1:	e8 33 29 00 00       	call   f0103009 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006d6:	83 c4 0c             	add    $0xc,%esp
f01006d9:	68 50 de 17 00       	push   $0x17de50
f01006de:	68 50 de 17 f0       	push   $0xf017de50
f01006e3:	68 4c 4d 10 f0       	push   $0xf0104d4c
f01006e8:	e8 1c 29 00 00       	call   f0103009 <cprintf>
f01006ed:	b8 4f e2 17 f0       	mov    $0xf017e24f,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006f2:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006f7:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006fa:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006ff:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100705:	85 c0                	test   %eax,%eax
f0100707:	0f 48 c2             	cmovs  %edx,%eax
f010070a:	c1 f8 0a             	sar    $0xa,%eax
f010070d:	50                   	push   %eax
f010070e:	68 70 4d 10 f0       	push   $0xf0104d70
f0100713:	e8 f1 28 00 00       	call   f0103009 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100718:	b8 00 00 00 00       	mov    $0x0,%eax
f010071d:	c9                   	leave  
f010071e:	c3                   	ret    

f010071f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010071f:	55                   	push   %ebp
f0100720:	89 e5                	mov    %esp,%ebp
f0100722:	57                   	push   %edi
f0100723:	56                   	push   %esi
f0100724:	53                   	push   %ebx
f0100725:	81 ec a8 00 00 00    	sub    $0xa8,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010072b:	89 e8                	mov    %ebp,%eax
	// Your code here.
        uint32_t *ebp;
        uint32_t eip;
        uint32_t arg0, arg1, arg2, arg3, arg4;
        ebp = (uint32_t *)read_ebp();
f010072d:	89 c3                	mov    %eax,%ebx
        eip = ebp[1];
f010072f:	8b 70 04             	mov    0x4(%eax),%esi
        arg0 = ebp[2];
f0100732:	8b 50 08             	mov    0x8(%eax),%edx
f0100735:	89 d7                	mov    %edx,%edi
        arg1 = ebp[3];
f0100737:	8b 48 0c             	mov    0xc(%eax),%ecx
f010073a:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
        arg2 = ebp[4];
f0100740:	8b 50 10             	mov    0x10(%eax),%edx
f0100743:	89 95 58 ff ff ff    	mov    %edx,-0xa8(%ebp)
        arg3 = ebp[5];
f0100749:	8b 48 14             	mov    0x14(%eax),%ecx
f010074c:	89 8d 64 ff ff ff    	mov    %ecx,-0x9c(%ebp)
        arg4 = ebp[6];
f0100752:	8b 40 18             	mov    0x18(%eax),%eax
f0100755:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
        cprintf("Stack backtrace:\n");
f010075b:	68 2b 4c 10 f0       	push   $0xf0104c2b
f0100760:	e8 a4 28 00 00       	call   f0103009 <cprintf>
        while(ebp != 0) {
f0100765:	83 c4 10             	add    $0x10,%esp
f0100768:	89 f8                	mov    %edi,%eax
f010076a:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
f0100770:	8b 8d 58 ff ff ff    	mov    -0xa8(%ebp),%ecx
f0100776:	e9 92 00 00 00       	jmp    f010080d <mon_backtrace+0xee>
             
             char fn[100];
              
             cprintf("  ebp  %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
f010077b:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f0100781:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
f0100787:	51                   	push   %ecx
f0100788:	52                   	push   %edx
f0100789:	50                   	push   %eax
f010078a:	56                   	push   %esi
f010078b:	53                   	push   %ebx
f010078c:	68 9c 4d 10 f0       	push   $0xf0104d9c
f0100791:	e8 73 28 00 00       	call   f0103009 <cprintf>
                                       ebp, eip, arg0, arg1, arg2, arg3, arg4);
             struct Eipdebuginfo info;
             debuginfo_eip(eip, &info);
f0100796:	83 c4 18             	add    $0x18,%esp
f0100799:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 3a 32 00 00       	call   f01039e0 <debuginfo_eip>
            
             snprintf(fn, info.eip_fn_namelen+1, "%s", info.eip_fn_name);
f01007a6:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
f01007ac:	68 96 4e 10 f0       	push   $0xf0104e96
f01007b1:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
f01007b7:	83 c0 01             	add    $0x1,%eax
f01007ba:	50                   	push   %eax
f01007bb:	8d 45 84             	lea    -0x7c(%ebp),%eax
f01007be:	50                   	push   %eax
f01007bf:	e8 fe 39 00 00       	call   f01041c2 <snprintf>
            
             cprintf("         %s:%u: %s+%u\n", info.eip_file, info.eip_line, fn, eip - info.eip_fn_addr);
f01007c4:	83 c4 14             	add    $0x14,%esp
f01007c7:	89 f0                	mov    %esi,%eax
f01007c9:	2b 85 7c ff ff ff    	sub    -0x84(%ebp),%eax
f01007cf:	50                   	push   %eax
f01007d0:	8d 45 84             	lea    -0x7c(%ebp),%eax
f01007d3:	50                   	push   %eax
f01007d4:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
f01007da:	ff b5 6c ff ff ff    	pushl  -0x94(%ebp)
f01007e0:	68 3d 4c 10 f0       	push   $0xf0104c3d
f01007e5:	e8 1f 28 00 00       	call   f0103009 <cprintf>
             ebp = (uint32_t *)ebp[0];
f01007ea:	8b 1b                	mov    (%ebx),%ebx
             eip = ebp[1];
f01007ec:	8b 73 04             	mov    0x4(%ebx),%esi
             arg0 = ebp[2];
f01007ef:	8b 43 08             	mov    0x8(%ebx),%eax
             arg1 = ebp[3];
f01007f2:	8b 53 0c             	mov    0xc(%ebx),%edx
             arg2 = ebp[4];
f01007f5:	8b 4b 10             	mov    0x10(%ebx),%ecx
             arg3 = ebp[5];
f01007f8:	8b 7b 14             	mov    0x14(%ebx),%edi
f01007fb:	89 bd 64 ff ff ff    	mov    %edi,-0x9c(%ebp)
             arg4 = ebp[6];
f0100801:	8b 7b 18             	mov    0x18(%ebx),%edi
f0100804:	89 bd 60 ff ff ff    	mov    %edi,-0xa0(%ebp)
f010080a:	83 c4 20             	add    $0x20,%esp
        arg1 = ebp[3];
        arg2 = ebp[4];
        arg3 = ebp[5];
        arg4 = ebp[6];
        cprintf("Stack backtrace:\n");
        while(ebp != 0) {
f010080d:	85 db                	test   %ebx,%ebx
f010080f:	0f 85 66 ff ff ff    	jne    f010077b <mon_backtrace+0x5c>
             arg2 = ebp[4];
             arg3 = ebp[5];
             arg4 = ebp[6];
        }
	return 0;
}
f0100815:	b8 00 00 00 00       	mov    $0x0,%eax
f010081a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010081d:	5b                   	pop    %ebx
f010081e:	5e                   	pop    %esi
f010081f:	5f                   	pop    %edi
f0100820:	5d                   	pop    %ebp
f0100821:	c3                   	ret    

f0100822 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100822:	55                   	push   %ebp
f0100823:	89 e5                	mov    %esp,%ebp
f0100825:	57                   	push   %edi
f0100826:	56                   	push   %esi
f0100827:	53                   	push   %ebx
f0100828:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010082b:	68 d4 4d 10 f0       	push   $0xf0104dd4
f0100830:	e8 d4 27 00 00       	call   f0103009 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100835:	c7 04 24 f8 4d 10 f0 	movl   $0xf0104df8,(%esp)
f010083c:	e8 c8 27 00 00       	call   f0103009 <cprintf>

	if (tf != NULL)
f0100841:	83 c4 10             	add    $0x10,%esp
f0100844:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100848:	74 0e                	je     f0100858 <monitor+0x36>
		print_trapframe(tf);
f010084a:	83 ec 0c             	sub    $0xc,%esp
f010084d:	ff 75 08             	pushl  0x8(%ebp)
f0100850:	e8 19 2c 00 00       	call   f010346e <print_trapframe>
f0100855:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100858:	83 ec 0c             	sub    $0xc,%esp
f010085b:	68 54 4c 10 f0       	push   $0xf0104c54
f0100860:	e8 77 39 00 00       	call   f01041dc <readline>
f0100865:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100867:	83 c4 10             	add    $0x10,%esp
f010086a:	85 c0                	test   %eax,%eax
f010086c:	74 ea                	je     f0100858 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010086e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100875:	be 00 00 00 00       	mov    $0x0,%esi
f010087a:	eb 0a                	jmp    f0100886 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010087c:	c6 03 00             	movb   $0x0,(%ebx)
f010087f:	89 f7                	mov    %esi,%edi
f0100881:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100884:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100886:	0f b6 03             	movzbl (%ebx),%eax
f0100889:	84 c0                	test   %al,%al
f010088b:	74 63                	je     f01008f0 <monitor+0xce>
f010088d:	83 ec 08             	sub    $0x8,%esp
f0100890:	0f be c0             	movsbl %al,%eax
f0100893:	50                   	push   %eax
f0100894:	68 58 4c 10 f0       	push   $0xf0104c58
f0100899:	e8 58 3b 00 00       	call   f01043f6 <strchr>
f010089e:	83 c4 10             	add    $0x10,%esp
f01008a1:	85 c0                	test   %eax,%eax
f01008a3:	75 d7                	jne    f010087c <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01008a5:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008a8:	74 46                	je     f01008f0 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008aa:	83 fe 0f             	cmp    $0xf,%esi
f01008ad:	75 14                	jne    f01008c3 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008af:	83 ec 08             	sub    $0x8,%esp
f01008b2:	6a 10                	push   $0x10
f01008b4:	68 5d 4c 10 f0       	push   $0xf0104c5d
f01008b9:	e8 4b 27 00 00       	call   f0103009 <cprintf>
f01008be:	83 c4 10             	add    $0x10,%esp
f01008c1:	eb 95                	jmp    f0100858 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01008c3:	8d 7e 01             	lea    0x1(%esi),%edi
f01008c6:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008ca:	eb 03                	jmp    f01008cf <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008cc:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008cf:	0f b6 03             	movzbl (%ebx),%eax
f01008d2:	84 c0                	test   %al,%al
f01008d4:	74 ae                	je     f0100884 <monitor+0x62>
f01008d6:	83 ec 08             	sub    $0x8,%esp
f01008d9:	0f be c0             	movsbl %al,%eax
f01008dc:	50                   	push   %eax
f01008dd:	68 58 4c 10 f0       	push   $0xf0104c58
f01008e2:	e8 0f 3b 00 00       	call   f01043f6 <strchr>
f01008e7:	83 c4 10             	add    $0x10,%esp
f01008ea:	85 c0                	test   %eax,%eax
f01008ec:	74 de                	je     f01008cc <monitor+0xaa>
f01008ee:	eb 94                	jmp    f0100884 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01008f0:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008f7:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008f8:	85 f6                	test   %esi,%esi
f01008fa:	0f 84 58 ff ff ff    	je     f0100858 <monitor+0x36>
f0100900:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100905:	83 ec 08             	sub    $0x8,%esp
f0100908:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010090b:	ff 34 85 20 4e 10 f0 	pushl  -0xfefb1e0(,%eax,4)
f0100912:	ff 75 a8             	pushl  -0x58(%ebp)
f0100915:	e8 7e 3a 00 00       	call   f0104398 <strcmp>
f010091a:	83 c4 10             	add    $0x10,%esp
f010091d:	85 c0                	test   %eax,%eax
f010091f:	75 22                	jne    f0100943 <monitor+0x121>
			return commands[i].func(argc, argv, tf);
f0100921:	83 ec 04             	sub    $0x4,%esp
f0100924:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100927:	ff 75 08             	pushl  0x8(%ebp)
f010092a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010092d:	52                   	push   %edx
f010092e:	56                   	push   %esi
f010092f:	ff 14 85 28 4e 10 f0 	call   *-0xfefb1d8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100936:	83 c4 10             	add    $0x10,%esp
f0100939:	85 c0                	test   %eax,%eax
f010093b:	0f 89 17 ff ff ff    	jns    f0100858 <monitor+0x36>
f0100941:	eb 20                	jmp    f0100963 <monitor+0x141>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100943:	83 c3 01             	add    $0x1,%ebx
f0100946:	83 fb 03             	cmp    $0x3,%ebx
f0100949:	75 ba                	jne    f0100905 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010094b:	83 ec 08             	sub    $0x8,%esp
f010094e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100951:	68 7a 4c 10 f0       	push   $0xf0104c7a
f0100956:	e8 ae 26 00 00       	call   f0103009 <cprintf>
f010095b:	83 c4 10             	add    $0x10,%esp
f010095e:	e9 f5 fe ff ff       	jmp    f0100858 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100963:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100966:	5b                   	pop    %ebx
f0100967:	5e                   	pop    %esi
f0100968:	5f                   	pop    %edi
f0100969:	5d                   	pop    %ebp
f010096a:	c3                   	ret    

f010096b <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010096b:	83 3d 58 d1 17 f0 00 	cmpl   $0x0,0xf017d158
f0100972:	75 11                	jne    f0100985 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100974:	ba 4f ee 17 f0       	mov    $0xf017ee4f,%edx
f0100979:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010097f:	89 15 58 d1 17 f0    	mov    %edx,0xf017d158
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n > 0) {
f0100985:	85 c0                	test   %eax,%eax
f0100987:	74 3d                	je     f01009c6 <boot_alloc+0x5b>
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100989:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx

		result = nextfree;
f010098f:	a1 58 d1 17 f0       	mov    0xf017d158,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n > 0) {
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100994:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx

		result = nextfree;
		nextfree += alloc_size;
f010099a:	01 c2                	add    %eax,%edx
f010099c:	89 15 58 d1 17 f0    	mov    %edx,0xf017d158

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
f01009a2:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f01009a8:	76 21                	jbe    f01009cb <boot_alloc+0x60>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01009aa:	55                   	push   %ebp
f01009ab:	89 e5                	mov    %esp,%ebp
f01009ad:	83 ec 0c             	sub    $0xc,%esp

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
		     nextfree = result;
f01009b0:	a3 58 d1 17 f0       	mov    %eax,0xf017d158
                     result = NULL;
                     panic("boot_alloc: out of memory");
f01009b5:	68 44 4e 10 f0       	push   $0xf0104e44
f01009ba:	6a 73                	push   $0x73
f01009bc:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01009c1:	e8 da f6 ff ff       	call   f01000a0 <_panic>
                }

        
	} else {
		result = nextfree;
f01009c6:	a1 58 d1 17 f0       	mov    0xf017d158,%eax
	}
	return result;
	
}
f01009cb:	f3 c3                	repz ret 

f01009cd <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009cd:	89 d1                	mov    %edx,%ecx
f01009cf:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009d2:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009d5:	a8 01                	test   $0x1,%al
f01009d7:	74 52                	je     f0100a2b <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009de:	89 c1                	mov    %eax,%ecx
f01009e0:	c1 e9 0c             	shr    $0xc,%ecx
f01009e3:	3b 0d 44 de 17 f0    	cmp    0xf017de44,%ecx
f01009e9:	72 1b                	jb     f0100a06 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009eb:	55                   	push   %ebp
f01009ec:	89 e5                	mov    %esp,%ebp
f01009ee:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009f1:	50                   	push   %eax
f01009f2:	68 78 51 10 f0       	push   $0xf0105178
f01009f7:	68 3f 03 00 00       	push   $0x33f
f01009fc:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100a01:	e8 9a f6 ff ff       	call   f01000a0 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a06:	c1 ea 0c             	shr    $0xc,%edx
f0100a09:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a0f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a16:	89 c2                	mov    %eax,%edx
f0100a18:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a20:	85 d2                	test   %edx,%edx
f0100a22:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a27:	0f 44 c2             	cmove  %edx,%eax
f0100a2a:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a30:	c3                   	ret    

f0100a31 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a31:	55                   	push   %ebp
f0100a32:	89 e5                	mov    %esp,%ebp
f0100a34:	57                   	push   %edi
f0100a35:	56                   	push   %esi
f0100a36:	53                   	push   %ebx
f0100a37:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a3a:	84 c0                	test   %al,%al
f0100a3c:	0f 85 7a 02 00 00    	jne    f0100cbc <check_page_free_list+0x28b>
f0100a42:	e9 87 02 00 00       	jmp    f0100cce <check_page_free_list+0x29d>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a47:	83 ec 04             	sub    $0x4,%esp
f0100a4a:	68 9c 51 10 f0       	push   $0xf010519c
f0100a4f:	68 7d 02 00 00       	push   $0x27d
f0100a54:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100a59:	e8 42 f6 ff ff       	call   f01000a0 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a5e:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a61:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a64:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a67:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a6a:	89 c2                	mov    %eax,%edx
f0100a6c:	2b 15 4c de 17 f0    	sub    0xf017de4c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a72:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a78:	0f 95 c2             	setne  %dl
f0100a7b:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a7e:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a82:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a84:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a88:	8b 00                	mov    (%eax),%eax
f0100a8a:	85 c0                	test   %eax,%eax
f0100a8c:	75 dc                	jne    f0100a6a <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a91:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a97:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a9a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a9d:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a9f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100aa2:	a3 60 d1 17 f0       	mov    %eax,0xf017d160
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100aa7:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100aac:	8b 1d 60 d1 17 f0    	mov    0xf017d160,%ebx
f0100ab2:	eb 53                	jmp    f0100b07 <check_page_free_list+0xd6>
f0100ab4:	89 d8                	mov    %ebx,%eax
f0100ab6:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f0100abc:	c1 f8 03             	sar    $0x3,%eax
f0100abf:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ac2:	89 c2                	mov    %eax,%edx
f0100ac4:	c1 ea 16             	shr    $0x16,%edx
f0100ac7:	39 f2                	cmp    %esi,%edx
f0100ac9:	73 3a                	jae    f0100b05 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100acb:	89 c2                	mov    %eax,%edx
f0100acd:	c1 ea 0c             	shr    $0xc,%edx
f0100ad0:	3b 15 44 de 17 f0    	cmp    0xf017de44,%edx
f0100ad6:	72 12                	jb     f0100aea <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ad8:	50                   	push   %eax
f0100ad9:	68 78 51 10 f0       	push   $0xf0105178
f0100ade:	6a 56                	push   $0x56
f0100ae0:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0100ae5:	e8 b6 f5 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100aea:	83 ec 04             	sub    $0x4,%esp
f0100aed:	68 80 00 00 00       	push   $0x80
f0100af2:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100af7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100afc:	50                   	push   %eax
f0100afd:	e8 31 39 00 00       	call   f0104433 <memset>
f0100b02:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b05:	8b 1b                	mov    (%ebx),%ebx
f0100b07:	85 db                	test   %ebx,%ebx
f0100b09:	75 a9                	jne    f0100ab4 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b0b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b10:	e8 56 fe ff ff       	call   f010096b <boot_alloc>
f0100b15:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b18:	8b 15 60 d1 17 f0    	mov    0xf017d160,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b1e:	8b 0d 4c de 17 f0    	mov    0xf017de4c,%ecx
		assert(pp < pages + npages);
f0100b24:	a1 44 de 17 f0       	mov    0xf017de44,%eax
f0100b29:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100b2c:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b2f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b32:	be 00 00 00 00       	mov    $0x0,%esi
f0100b37:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b3c:	89 75 cc             	mov    %esi,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b3f:	e9 33 01 00 00       	jmp    f0100c77 <check_page_free_list+0x246>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b44:	39 ca                	cmp    %ecx,%edx
f0100b46:	73 19                	jae    f0100b61 <check_page_free_list+0x130>
f0100b48:	68 78 4e 10 f0       	push   $0xf0104e78
f0100b4d:	68 84 4e 10 f0       	push   $0xf0104e84
f0100b52:	68 97 02 00 00       	push   $0x297
f0100b57:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100b5c:	e8 3f f5 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100b61:	39 da                	cmp    %ebx,%edx
f0100b63:	72 19                	jb     f0100b7e <check_page_free_list+0x14d>
f0100b65:	68 99 4e 10 f0       	push   $0xf0104e99
f0100b6a:	68 84 4e 10 f0       	push   $0xf0104e84
f0100b6f:	68 98 02 00 00       	push   $0x298
f0100b74:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100b79:	e8 22 f5 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b7e:	89 d0                	mov    %edx,%eax
f0100b80:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b83:	a8 07                	test   $0x7,%al
f0100b85:	74 19                	je     f0100ba0 <check_page_free_list+0x16f>
f0100b87:	68 c0 51 10 f0       	push   $0xf01051c0
f0100b8c:	68 84 4e 10 f0       	push   $0xf0104e84
f0100b91:	68 99 02 00 00       	push   $0x299
f0100b96:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100b9b:	e8 00 f5 ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ba0:	c1 f8 03             	sar    $0x3,%eax
f0100ba3:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ba6:	85 c0                	test   %eax,%eax
f0100ba8:	75 19                	jne    f0100bc3 <check_page_free_list+0x192>
f0100baa:	68 ad 4e 10 f0       	push   $0xf0104ead
f0100baf:	68 84 4e 10 f0       	push   $0xf0104e84
f0100bb4:	68 9c 02 00 00       	push   $0x29c
f0100bb9:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100bbe:	e8 dd f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bc3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bc8:	75 19                	jne    f0100be3 <check_page_free_list+0x1b2>
f0100bca:	68 be 4e 10 f0       	push   $0xf0104ebe
f0100bcf:	68 84 4e 10 f0       	push   $0xf0104e84
f0100bd4:	68 9d 02 00 00       	push   $0x29d
f0100bd9:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100bde:	e8 bd f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100be3:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100be8:	75 19                	jne    f0100c03 <check_page_free_list+0x1d2>
f0100bea:	68 f4 51 10 f0       	push   $0xf01051f4
f0100bef:	68 84 4e 10 f0       	push   $0xf0104e84
f0100bf4:	68 9e 02 00 00       	push   $0x29e
f0100bf9:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100bfe:	e8 9d f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c03:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c08:	75 19                	jne    f0100c23 <check_page_free_list+0x1f2>
f0100c0a:	68 d7 4e 10 f0       	push   $0xf0104ed7
f0100c0f:	68 84 4e 10 f0       	push   $0xf0104e84
f0100c14:	68 9f 02 00 00       	push   $0x29f
f0100c19:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100c1e:	e8 7d f4 ff ff       	call   f01000a0 <_panic>
f0100c23:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c26:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c2b:	76 3f                	jbe    f0100c6c <check_page_free_list+0x23b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c2d:	89 c6                	mov    %eax,%esi
f0100c2f:	c1 ee 0c             	shr    $0xc,%esi
f0100c32:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0100c35:	77 12                	ja     f0100c49 <check_page_free_list+0x218>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c37:	50                   	push   %eax
f0100c38:	68 78 51 10 f0       	push   $0xf0105178
f0100c3d:	6a 56                	push   $0x56
f0100c3f:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0100c44:	e8 57 f4 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0100c49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c4e:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c51:	76 1e                	jbe    f0100c71 <check_page_free_list+0x240>
f0100c53:	68 18 52 10 f0       	push   $0xf0105218
f0100c58:	68 84 4e 10 f0       	push   $0xf0104e84
f0100c5d:	68 a0 02 00 00       	push   $0x2a0
f0100c62:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100c67:	e8 34 f4 ff ff       	call   f01000a0 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c6c:	83 c7 01             	add    $0x1,%edi
f0100c6f:	eb 04                	jmp    f0100c75 <check_page_free_list+0x244>
		else
			++nfree_extmem;
f0100c71:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c75:	8b 12                	mov    (%edx),%edx
f0100c77:	85 d2                	test   %edx,%edx
f0100c79:	0f 85 c5 fe ff ff    	jne    f0100b44 <check_page_free_list+0x113>
f0100c7f:	8b 75 cc             	mov    -0x34(%ebp),%esi
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c82:	85 ff                	test   %edi,%edi
f0100c84:	7f 19                	jg     f0100c9f <check_page_free_list+0x26e>
f0100c86:	68 f1 4e 10 f0       	push   $0xf0104ef1
f0100c8b:	68 84 4e 10 f0       	push   $0xf0104e84
f0100c90:	68 a8 02 00 00       	push   $0x2a8
f0100c95:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100c9a:	e8 01 f4 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100c9f:	85 f6                	test   %esi,%esi
f0100ca1:	7f 42                	jg     f0100ce5 <check_page_free_list+0x2b4>
f0100ca3:	68 03 4f 10 f0       	push   $0xf0104f03
f0100ca8:	68 84 4e 10 f0       	push   $0xf0104e84
f0100cad:	68 a9 02 00 00       	push   $0x2a9
f0100cb2:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100cb7:	e8 e4 f3 ff ff       	call   f01000a0 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cbc:	a1 60 d1 17 f0       	mov    0xf017d160,%eax
f0100cc1:	85 c0                	test   %eax,%eax
f0100cc3:	0f 85 95 fd ff ff    	jne    f0100a5e <check_page_free_list+0x2d>
f0100cc9:	e9 79 fd ff ff       	jmp    f0100a47 <check_page_free_list+0x16>
f0100cce:	83 3d 60 d1 17 f0 00 	cmpl   $0x0,0xf017d160
f0100cd5:	0f 84 6c fd ff ff    	je     f0100a47 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cdb:	be 00 04 00 00       	mov    $0x400,%esi
f0100ce0:	e9 c7 fd ff ff       	jmp    f0100aac <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ce8:	5b                   	pop    %ebx
f0100ce9:	5e                   	pop    %esi
f0100cea:	5f                   	pop    %edi
f0100ceb:	5d                   	pop    %ebp
f0100cec:	c3                   	ret    

f0100ced <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ced:	55                   	push   %ebp
f0100cee:	89 e5                	mov    %esp,%ebp
f0100cf0:	56                   	push   %esi
f0100cf1:	53                   	push   %ebx
f0100cf2:	8b 1d 60 d1 17 f0    	mov    0xf017d160,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100cf8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cfd:	eb 22                	jmp    f0100d21 <page_init+0x34>
f0100cff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100d06:	89 d1                	mov    %edx,%ecx
f0100d08:	03 0d 4c de 17 f0    	add    0xf017de4c,%ecx
f0100d0e:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100d14:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100d16:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100d19:	89 d3                	mov    %edx,%ebx
f0100d1b:	03 1d 4c de 17 f0    	add    0xf017de4c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100d21:	3b 05 44 de 17 f0    	cmp    0xf017de44,%eax
f0100d27:	72 d6                	jb     f0100cff <page_init+0x12>
f0100d29:	89 1d 60 d1 17 f0    	mov    %ebx,0xf017d160
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
        pages[0].pp_ref = 1;
f0100d2f:	a1 4c de 17 f0       	mov    0xf017de4c,%eax
f0100d34:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
  
        pages[1].pp_link = pages[0].pp_link;
f0100d3a:	8b 10                	mov    (%eax),%edx
f0100d3c:	89 50 08             	mov    %edx,0x8(%eax)
        //potential problem?
        uint32_t nextfreepa = PADDR(boot_alloc(0)); 
f0100d3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d44:	e8 22 fc ff ff       	call   f010096b <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d49:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d4e:	77 15                	ja     f0100d65 <page_init+0x78>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d50:	50                   	push   %eax
f0100d51:	68 60 52 10 f0       	push   $0xf0105260
f0100d56:	68 27 01 00 00       	push   $0x127
f0100d5b:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100d60:	e8 3b f3 ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d65:	05 00 00 00 10       	add    $0x10000000,%eax
        
        void *p = pages[IOPHYSMEM/PGSIZE].pp_link;
f0100d6a:	8b 15 4c de 17 f0    	mov    0xf017de4c,%edx
f0100d70:	8b b2 00 05 00 00    	mov    0x500(%edx),%esi
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
f0100d76:	ba 00 00 0a 00       	mov    $0xa0000,%edx
f0100d7b:	eb 20                	jmp    f0100d9d <page_init+0xb0>
              pages[i/PGSIZE].pp_ref = 1;  
f0100d7d:	89 d3                	mov    %edx,%ebx
f0100d7f:	c1 eb 0c             	shr    $0xc,%ebx
f0100d82:	8b 0d 4c de 17 f0    	mov    0xf017de4c,%ecx
f0100d88:	8d 0c d9             	lea    (%ecx,%ebx,8),%ecx
f0100d8b:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
              pages[i/PGSIZE].pp_link = NULL;     
f0100d91:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
        pages[1].pp_link = pages[0].pp_link;
        //potential problem?
        uint32_t nextfreepa = PADDR(boot_alloc(0)); 
        
        void *p = pages[IOPHYSMEM/PGSIZE].pp_link;
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
f0100d97:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0100d9d:	39 c2                	cmp    %eax,%edx
f0100d9f:	72 dc                	jb     f0100d7d <page_init+0x90>
              pages[i/PGSIZE].pp_ref = 1;  
              pages[i/PGSIZE].pp_link = NULL;     
        }      
        pages[i/PGSIZE].pp_link = p;
f0100da1:	c1 ea 0c             	shr    $0xc,%edx
f0100da4:	a1 4c de 17 f0       	mov    0xf017de4c,%eax
f0100da9:	89 34 d0             	mov    %esi,(%eax,%edx,8)
}
f0100dac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100daf:	5b                   	pop    %ebx
f0100db0:	5e                   	pop    %esi
f0100db1:	5d                   	pop    %ebp
f0100db2:	c3                   	ret    

f0100db3 <page_alloc>:
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
       if ( page_free_list ) {
f0100db3:	a1 60 d1 17 f0       	mov    0xf017d160,%eax
f0100db8:	85 c0                	test   %eax,%eax
f0100dba:	74 63                	je     f0100e1f <page_alloc+0x6c>
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100dbc:	55                   	push   %ebp
f0100dbd:	89 e5                	mov    %esp,%ebp
f0100dbf:	83 ec 08             	sub    $0x8,%esp
	// Fill this function in
       if ( page_free_list ) {
            if(alloc_flags & ALLOC_ZERO) 
f0100dc2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100dc6:	74 43                	je     f0100e0b <page_alloc+0x58>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dc8:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f0100dce:	c1 f8 03             	sar    $0x3,%eax
f0100dd1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dd4:	89 c2                	mov    %eax,%edx
f0100dd6:	c1 ea 0c             	shr    $0xc,%edx
f0100dd9:	3b 15 44 de 17 f0    	cmp    0xf017de44,%edx
f0100ddf:	72 12                	jb     f0100df3 <page_alloc+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100de1:	50                   	push   %eax
f0100de2:	68 78 51 10 f0       	push   $0xf0105178
f0100de7:	6a 56                	push   $0x56
f0100de9:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0100dee:	e8 ad f2 ff ff       	call   f01000a0 <_panic>
                memset(page2kva(page_free_list), 0, PGSIZE);
f0100df3:	83 ec 04             	sub    $0x4,%esp
f0100df6:	68 00 10 00 00       	push   $0x1000
f0100dfb:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100dfd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e02:	50                   	push   %eax
f0100e03:	e8 2b 36 00 00       	call   f0104433 <memset>
f0100e08:	83 c4 10             	add    $0x10,%esp
               
                struct PageInfo *tmp = page_free_list;
f0100e0b:	a1 60 d1 17 f0       	mov    0xf017d160,%eax
                 
                page_free_list = page_free_list->pp_link;
f0100e10:	8b 10                	mov    (%eax),%edx
f0100e12:	89 15 60 d1 17 f0    	mov    %edx,0xf017d160
                tmp->pp_link = NULL;
f0100e18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                      
                return tmp; 
            
        }
	return NULL;
}
f0100e1e:	c9                   	leave  
f0100e1f:	f3 c3                	repz ret 

f0100e21 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e21:	55                   	push   %ebp
f0100e22:	89 e5                	mov    %esp,%ebp
f0100e24:	83 ec 08             	sub    $0x8,%esp
f0100e27:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.    
        if(pp == NULL) return;
f0100e2a:	85 c0                	test   %eax,%eax
f0100e2c:	74 30                	je     f0100e5e <page_free+0x3d>
        if (pp->pp_ref != 0 || pp->pp_link != NULL)
f0100e2e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e33:	75 05                	jne    f0100e3a <page_free+0x19>
f0100e35:	83 38 00             	cmpl   $0x0,(%eax)
f0100e38:	74 17                	je     f0100e51 <page_free+0x30>
            panic("page_free: invalid page free\n");
f0100e3a:	83 ec 04             	sub    $0x4,%esp
f0100e3d:	68 14 4f 10 f0       	push   $0xf0104f14
f0100e42:	68 5c 01 00 00       	push   $0x15c
f0100e47:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100e4c:	e8 4f f2 ff ff       	call   f01000a0 <_panic>
        else {
            pp->pp_link = page_free_list;
f0100e51:	8b 15 60 d1 17 f0    	mov    0xf017d160,%edx
f0100e57:	89 10                	mov    %edx,(%eax)
            page_free_list = pp;
f0100e59:	a3 60 d1 17 f0       	mov    %eax,0xf017d160
        }
}
f0100e5e:	c9                   	leave  
f0100e5f:	c3                   	ret    

f0100e60 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e60:	55                   	push   %ebp
f0100e61:	89 e5                	mov    %esp,%ebp
f0100e63:	83 ec 08             	sub    $0x8,%esp
f0100e66:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e69:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e6d:	83 e8 01             	sub    $0x1,%eax
f0100e70:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e74:	66 85 c0             	test   %ax,%ax
f0100e77:	75 0c                	jne    f0100e85 <page_decref+0x25>
		page_free(pp);
f0100e79:	83 ec 0c             	sub    $0xc,%esp
f0100e7c:	52                   	push   %edx
f0100e7d:	e8 9f ff ff ff       	call   f0100e21 <page_free>
f0100e82:	83 c4 10             	add    $0x10,%esp
}
f0100e85:	c9                   	leave  
f0100e86:	c3                   	ret    

f0100e87 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e87:	55                   	push   %ebp
f0100e88:	89 e5                	mov    %esp,%ebp
f0100e8a:	56                   	push   %esi
f0100e8b:	53                   	push   %ebx
f0100e8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        pte_t * pte;
        if ((pgdir[PDX(va)] & PTE_P) != 0) {
f0100e8f:	89 de                	mov    %ebx,%esi
f0100e91:	c1 ee 16             	shr    $0x16,%esi
f0100e94:	c1 e6 02             	shl    $0x2,%esi
f0100e97:	03 75 08             	add    0x8(%ebp),%esi
f0100e9a:	8b 06                	mov    (%esi),%eax
f0100e9c:	a8 01                	test   $0x1,%al
f0100e9e:	74 3c                	je     f0100edc <pgdir_walk+0x55>
                pte =(pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0100ea0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ea5:	89 c2                	mov    %eax,%edx
f0100ea7:	c1 ea 0c             	shr    $0xc,%edx
f0100eaa:	3b 15 44 de 17 f0    	cmp    0xf017de44,%edx
f0100eb0:	72 15                	jb     f0100ec7 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eb2:	50                   	push   %eax
f0100eb3:	68 78 51 10 f0       	push   $0xf0105178
f0100eb8:	68 8a 01 00 00       	push   $0x18a
f0100ebd:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100ec2:	e8 d9 f1 ff ff       	call   f01000a0 <_panic>
                return pte + PTX(va);  
f0100ec7:	c1 eb 0a             	shr    $0xa,%ebx
f0100eca:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100ed0:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100ed7:	e9 81 00 00 00       	jmp    f0100f5d <pgdir_walk+0xd6>

 
        } 
        
        if(create != 0) {
f0100edc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100ee0:	74 6f                	je     f0100f51 <pgdir_walk+0xca>
               struct PageInfo *tmp;
               tmp = page_alloc(1);
f0100ee2:	83 ec 0c             	sub    $0xc,%esp
f0100ee5:	6a 01                	push   $0x1
f0100ee7:	e8 c7 fe ff ff       	call   f0100db3 <page_alloc>
       
               if(tmp != NULL) {
f0100eec:	83 c4 10             	add    $0x10,%esp
f0100eef:	85 c0                	test   %eax,%eax
f0100ef1:	74 65                	je     f0100f58 <pgdir_walk+0xd1>
                       
                        
                       tmp->pp_ref += 1;
f0100ef3:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
                       tmp->pp_link = NULL;
f0100ef8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100efe:	89 c2                	mov    %eax,%edx
f0100f00:	2b 15 4c de 17 f0    	sub    0xf017de4c,%edx
f0100f06:	c1 fa 03             	sar    $0x3,%edx
f0100f09:	c1 e2 0c             	shl    $0xc,%edx
                       pgdir[PDX(va)] = page2pa(tmp) | PTE_U | PTE_W | PTE_P;
f0100f0c:	83 ca 07             	or     $0x7,%edx
f0100f0f:	89 16                	mov    %edx,(%esi)
f0100f11:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f0100f17:	c1 f8 03             	sar    $0x3,%eax
f0100f1a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f1d:	89 c2                	mov    %eax,%edx
f0100f1f:	c1 ea 0c             	shr    $0xc,%edx
f0100f22:	3b 15 44 de 17 f0    	cmp    0xf017de44,%edx
f0100f28:	72 15                	jb     f0100f3f <pgdir_walk+0xb8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f2a:	50                   	push   %eax
f0100f2b:	68 78 51 10 f0       	push   $0xf0105178
f0100f30:	68 9a 01 00 00       	push   $0x19a
f0100f35:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100f3a:	e8 61 f1 ff ff       	call   f01000a0 <_panic>
                       pte = (pte_t *)KADDR(page2pa(tmp));
                  
                       return pte+PTX(va); 
f0100f3f:	c1 eb 0a             	shr    $0xa,%ebx
f0100f42:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f48:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100f4f:	eb 0c                	jmp    f0100f5d <pgdir_walk+0xd6>

               }
               
        }

	return NULL;
f0100f51:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f56:	eb 05                	jmp    f0100f5d <pgdir_walk+0xd6>
f0100f58:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f60:	5b                   	pop    %ebx
f0100f61:	5e                   	pop    %esi
f0100f62:	5d                   	pop    %ebp
f0100f63:	c3                   	ret    

f0100f64 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f64:	55                   	push   %ebp
f0100f65:	89 e5                	mov    %esp,%ebp
f0100f67:	57                   	push   %edi
f0100f68:	56                   	push   %esi
f0100f69:	53                   	push   %ebx
f0100f6a:	83 ec 1c             	sub    $0x1c,%esp
f0100f6d:	89 c7                	mov    %eax,%edi
f0100f6f:	89 55 e0             	mov    %edx,-0x20(%ebp)
	// Fill this function in
        size = ROUNDUP(size, PGSIZE);
f0100f72:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100f78:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100f7e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
        pte_t *tmp;
        int i ;
        for( i = 0; i < size; i += PGSIZE) { 
f0100f81:	be 00 00 00 00       	mov    $0x0,%esi
f0100f86:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f89:	83 c8 01             	or     $0x1,%eax
f0100f8c:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100f8f:	eb 3d                	jmp    f0100fce <boot_map_region+0x6a>
              tmp = pgdir_walk(pgdir, (void *)(va + i), 1);  
f0100f91:	83 ec 04             	sub    $0x4,%esp
f0100f94:	6a 01                	push   $0x1
f0100f96:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f99:	01 f0                	add    %esi,%eax
f0100f9b:	50                   	push   %eax
f0100f9c:	57                   	push   %edi
f0100f9d:	e8 e5 fe ff ff       	call   f0100e87 <pgdir_walk>
              if ( tmp == NULL ) {
f0100fa2:	83 c4 10             	add    $0x10,%esp
f0100fa5:	85 c0                	test   %eax,%eax
f0100fa7:	75 17                	jne    f0100fc0 <boot_map_region+0x5c>
                     panic("boot_map_region: fail\n");
f0100fa9:	83 ec 04             	sub    $0x4,%esp
f0100fac:	68 32 4f 10 f0       	push   $0xf0104f32
f0100fb1:	68 ba 01 00 00       	push   $0x1ba
f0100fb6:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100fbb:	e8 e0 f0 ff ff       	call   f01000a0 <_panic>
f0100fc0:	03 5d 08             	add    0x8(%ebp),%ebx
                     return;
              }
              *tmp = (pa + i) | perm | PTE_P; 
f0100fc3:	0b 5d dc             	or     -0x24(%ebp),%ebx
f0100fc6:	89 18                	mov    %ebx,(%eax)
{
	// Fill this function in
        size = ROUNDUP(size, PGSIZE);
        pte_t *tmp;
        int i ;
        for( i = 0; i < size; i += PGSIZE) { 
f0100fc8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100fce:	89 f3                	mov    %esi,%ebx
f0100fd0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0100fd3:	77 bc                	ja     f0100f91 <boot_map_region+0x2d>
                     return;
              }
              *tmp = (pa + i) | perm | PTE_P; 
 
        }
}
f0100fd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fd8:	5b                   	pop    %ebx
f0100fd9:	5e                   	pop    %esi
f0100fda:	5f                   	pop    %edi
f0100fdb:	5d                   	pop    %ebp
f0100fdc:	c3                   	ret    

f0100fdd <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fdd:	55                   	push   %ebp
f0100fde:	89 e5                	mov    %esp,%ebp
f0100fe0:	53                   	push   %ebx
f0100fe1:	83 ec 08             	sub    $0x8,%esp
f0100fe4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 0);
f0100fe7:	6a 00                	push   $0x0
f0100fe9:	ff 75 0c             	pushl  0xc(%ebp)
f0100fec:	ff 75 08             	pushl  0x8(%ebp)
f0100fef:	e8 93 fe ff ff       	call   f0100e87 <pgdir_walk>
        if ( tmp != NULL && (*tmp & PTE_P)) {
f0100ff4:	83 c4 10             	add    $0x10,%esp
f0100ff7:	85 c0                	test   %eax,%eax
f0100ff9:	74 37                	je     f0101032 <page_lookup+0x55>
f0100ffb:	f6 00 01             	testb  $0x1,(%eax)
f0100ffe:	74 39                	je     f0101039 <page_lookup+0x5c>
                if(pte_store != NULL) 
f0101000:	85 db                	test   %ebx,%ebx
f0101002:	74 02                	je     f0101006 <page_lookup+0x29>
                        *pte_store = tmp;
f0101004:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101006:	8b 00                	mov    (%eax),%eax
f0101008:	c1 e8 0c             	shr    $0xc,%eax
f010100b:	3b 05 44 de 17 f0    	cmp    0xf017de44,%eax
f0101011:	72 14                	jb     f0101027 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101013:	83 ec 04             	sub    $0x4,%esp
f0101016:	68 84 52 10 f0       	push   $0xf0105284
f010101b:	6a 4f                	push   $0x4f
f010101d:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101022:	e8 79 f0 ff ff       	call   f01000a0 <_panic>
	return &pages[PGNUM(pa)];
f0101027:	8b 15 4c de 17 f0    	mov    0xf017de4c,%edx
f010102d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
                return (struct PageInfo *)pa2page(*tmp);
f0101030:	eb 0c                	jmp    f010103e <page_lookup+0x61>

        }
	return NULL;
f0101032:	b8 00 00 00 00       	mov    $0x0,%eax
f0101037:	eb 05                	jmp    f010103e <page_lookup+0x61>
f0101039:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010103e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101041:	c9                   	leave  
f0101042:	c3                   	ret    

f0101043 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101043:	55                   	push   %ebp
f0101044:	89 e5                	mov    %esp,%ebp
f0101046:	53                   	push   %ebx
f0101047:	83 ec 18             	sub    $0x18,%esp
f010104a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
        pte_t *tmppte;
        struct PageInfo *tmp = page_lookup(pgdir, va, &tmppte);
f010104d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101050:	50                   	push   %eax
f0101051:	53                   	push   %ebx
f0101052:	ff 75 08             	pushl  0x8(%ebp)
f0101055:	e8 83 ff ff ff       	call   f0100fdd <page_lookup>
        if( tmp != NULL) {
f010105a:	83 c4 10             	add    $0x10,%esp
f010105d:	85 c0                	test   %eax,%eax
f010105f:	74 15                	je     f0101076 <tlb_invalidate+0x33>
                page_decref(tmp);
f0101061:	83 ec 0c             	sub    $0xc,%esp
f0101064:	50                   	push   %eax
f0101065:	e8 f6 fd ff ff       	call   f0100e60 <page_decref>
                *tmppte = 0;
f010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010106d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101073:	83 c4 10             	add    $0x10,%esp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101076:	0f 01 3b             	invlpg (%ebx)
        }
	invlpg(va);
}
f0101079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010107c:	c9                   	leave  
f010107d:	c3                   	ret    

f010107e <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010107e:	55                   	push   %ebp
f010107f:	89 e5                	mov    %esp,%ebp
f0101081:	56                   	push   %esi
f0101082:	53                   	push   %ebx
f0101083:	83 ec 14             	sub    $0x14,%esp
f0101086:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101089:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
        pte_t *tmppte;
        struct PageInfo *tmp = page_lookup(pgdir, va, &tmppte);
f010108c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010108f:	50                   	push   %eax
f0101090:	56                   	push   %esi
f0101091:	53                   	push   %ebx
f0101092:	e8 46 ff ff ff       	call   f0100fdd <page_lookup>
        if( tmp != NULL && (*tmppte & PTE_P)) {
f0101097:	83 c4 10             	add    $0x10,%esp
f010109a:	85 c0                	test   %eax,%eax
f010109c:	74 1d                	je     f01010bb <page_remove+0x3d>
f010109e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01010a1:	f6 02 01             	testb  $0x1,(%edx)
f01010a4:	74 15                	je     f01010bb <page_remove+0x3d>
                page_decref(tmp);
f01010a6:	83 ec 0c             	sub    $0xc,%esp
f01010a9:	50                   	push   %eax
f01010aa:	e8 b1 fd ff ff       	call   f0100e60 <page_decref>
                *tmppte = 0;
f01010af:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01010b8:	83 c4 10             	add    $0x10,%esp
        }
        tlb_invalidate(pgdir, va);
f01010bb:	83 ec 08             	sub    $0x8,%esp
f01010be:	56                   	push   %esi
f01010bf:	53                   	push   %ebx
f01010c0:	e8 7e ff ff ff       	call   f0101043 <tlb_invalidate>
f01010c5:	83 c4 10             	add    $0x10,%esp
}
f01010c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010cb:	5b                   	pop    %ebx
f01010cc:	5e                   	pop    %esi
f01010cd:	5d                   	pop    %ebp
f01010ce:	c3                   	ret    

f01010cf <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01010cf:	55                   	push   %ebp
f01010d0:	89 e5                	mov    %esp,%ebp
f01010d2:	57                   	push   %edi
f01010d3:	56                   	push   %esi
f01010d4:	53                   	push   %ebx
f01010d5:	83 ec 10             	sub    $0x10,%esp
f01010d8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01010db:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 1);
f01010de:	6a 01                	push   $0x1
f01010e0:	57                   	push   %edi
f01010e1:	ff 75 08             	pushl  0x8(%ebp)
f01010e4:	e8 9e fd ff ff       	call   f0100e87 <pgdir_walk>
f01010e9:	89 c3                	mov    %eax,%ebx
         
        if( tmp == NULL )
f01010eb:	83 c4 10             	add    $0x10,%esp
f01010ee:	85 c0                	test   %eax,%eax
f01010f0:	74 3e                	je     f0101130 <page_insert+0x61>
                return -E_NO_MEM;

        pp->pp_ref += 1;
f01010f2:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
        if( (*tmp & PTE_P) != 0 )
f01010f7:	f6 00 01             	testb  $0x1,(%eax)
f01010fa:	74 0f                	je     f010110b <page_insert+0x3c>
                page_remove(pgdir, va);
f01010fc:	83 ec 08             	sub    $0x8,%esp
f01010ff:	57                   	push   %edi
f0101100:	ff 75 08             	pushl  0x8(%ebp)
f0101103:	e8 76 ff ff ff       	call   f010107e <page_remove>
f0101108:	83 c4 10             	add    $0x10,%esp
f010110b:	8b 55 14             	mov    0x14(%ebp),%edx
f010110e:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101111:	89 f0                	mov    %esi,%eax
f0101113:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f0101119:	c1 f8 03             	sar    $0x3,%eax
f010111c:	c1 e0 0c             	shl    $0xc,%eax
         
        *tmp = page2pa(pp) | perm | PTE_P;
f010111f:	09 d0                	or     %edx,%eax
f0101121:	89 03                	mov    %eax,(%ebx)
        pp->pp_link = NULL;
f0101123:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	return 0;
f0101129:	b8 00 00 00 00       	mov    $0x0,%eax
f010112e:	eb 05                	jmp    f0101135 <page_insert+0x66>
{
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 1);
         
        if( tmp == NULL )
                return -E_NO_MEM;
f0101130:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
                page_remove(pgdir, va);
         
        *tmp = page2pa(pp) | perm | PTE_P;
        pp->pp_link = NULL;
	return 0;
}
f0101135:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101138:	5b                   	pop    %ebx
f0101139:	5e                   	pop    %esi
f010113a:	5f                   	pop    %edi
f010113b:	5d                   	pop    %ebp
f010113c:	c3                   	ret    

f010113d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010113d:	55                   	push   %ebp
f010113e:	89 e5                	mov    %esp,%ebp
f0101140:	57                   	push   %edi
f0101141:	56                   	push   %esi
f0101142:	53                   	push   %ebx
f0101143:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101146:	6a 15                	push   $0x15
f0101148:	e8 5b 1e 00 00       	call   f0102fa8 <mc146818_read>
f010114d:	89 c3                	mov    %eax,%ebx
f010114f:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101156:	e8 4d 1e 00 00       	call   f0102fa8 <mc146818_read>
f010115b:	c1 e0 08             	shl    $0x8,%eax
f010115e:	09 d8                	or     %ebx,%eax
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101160:	c1 e0 0a             	shl    $0xa,%eax
f0101163:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101169:	85 c0                	test   %eax,%eax
f010116b:	0f 48 c2             	cmovs  %edx,%eax
f010116e:	c1 f8 0c             	sar    $0xc,%eax
f0101171:	a3 64 d1 17 f0       	mov    %eax,0xf017d164
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101176:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010117d:	e8 26 1e 00 00       	call   f0102fa8 <mc146818_read>
f0101182:	89 c3                	mov    %eax,%ebx
f0101184:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010118b:	e8 18 1e 00 00       	call   f0102fa8 <mc146818_read>
f0101190:	c1 e0 08             	shl    $0x8,%eax
f0101193:	09 d8                	or     %ebx,%eax
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101195:	c1 e0 0a             	shl    $0xa,%eax
f0101198:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010119e:	83 c4 10             	add    $0x10,%esp
f01011a1:	85 c0                	test   %eax,%eax
f01011a3:	0f 48 c2             	cmovs  %edx,%eax
f01011a6:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01011a9:	85 c0                	test   %eax,%eax
f01011ab:	74 0e                	je     f01011bb <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01011ad:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01011b3:	89 15 44 de 17 f0    	mov    %edx,0xf017de44
f01011b9:	eb 0c                	jmp    f01011c7 <mem_init+0x8a>
	else
		npages = npages_basemem;
f01011bb:	8b 15 64 d1 17 f0    	mov    0xf017d164,%edx
f01011c1:	89 15 44 de 17 f0    	mov    %edx,0xf017de44

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01011c7:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011ca:	c1 e8 0a             	shr    $0xa,%eax
f01011cd:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01011ce:	a1 64 d1 17 f0       	mov    0xf017d164,%eax
f01011d3:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011d6:	c1 e8 0a             	shr    $0xa,%eax
f01011d9:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01011da:	a1 44 de 17 f0       	mov    0xf017de44,%eax
f01011df:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011e2:	c1 e8 0a             	shr    $0xa,%eax
f01011e5:	50                   	push   %eax
f01011e6:	68 a4 52 10 f0       	push   $0xf01052a4
f01011eb:	e8 19 1e 00 00       	call   f0103009 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011f0:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011f5:	e8 71 f7 ff ff       	call   f010096b <boot_alloc>
f01011fa:	a3 48 de 17 f0       	mov    %eax,0xf017de48
	memset(kern_pgdir, 0, PGSIZE);
f01011ff:	83 c4 0c             	add    $0xc,%esp
f0101202:	68 00 10 00 00       	push   $0x1000
f0101207:	6a 00                	push   $0x0
f0101209:	50                   	push   %eax
f010120a:	e8 24 32 00 00       	call   f0104433 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010120f:	a1 48 de 17 f0       	mov    0xf017de48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101214:	83 c4 10             	add    $0x10,%esp
f0101217:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010121c:	77 15                	ja     f0101233 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010121e:	50                   	push   %eax
f010121f:	68 60 52 10 f0       	push   $0xf0105260
f0101224:	68 9f 00 00 00       	push   $0x9f
f0101229:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010122e:	e8 6d ee ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101233:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101239:	83 ca 05             	or     $0x5,%edx
f010123c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
        pages = boot_alloc(npages * sizeof(struct PageInfo));
f0101242:	a1 44 de 17 f0       	mov    0xf017de44,%eax
f0101247:	c1 e0 03             	shl    $0x3,%eax
f010124a:	e8 1c f7 ff ff       	call   f010096b <boot_alloc>
f010124f:	a3 4c de 17 f0       	mov    %eax,0xf017de4c
        memset(pages, 0, npages * sizeof(struct PageInfo));
f0101254:	83 ec 04             	sub    $0x4,%esp
f0101257:	8b 3d 44 de 17 f0    	mov    0xf017de44,%edi
f010125d:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101264:	52                   	push   %edx
f0101265:	6a 00                	push   $0x0
f0101267:	50                   	push   %eax
f0101268:	e8 c6 31 00 00       	call   f0104433 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
        envs = boot_alloc(NENV * sizeof(struct Env));
f010126d:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101272:	e8 f4 f6 ff ff       	call   f010096b <boot_alloc>
f0101277:	a3 6c d1 17 f0       	mov    %eax,0xf017d16c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010127c:	e8 6c fa ff ff       	call   f0100ced <page_init>

	check_page_free_list(1);
f0101281:	b8 01 00 00 00       	mov    $0x1,%eax
f0101286:	e8 a6 f7 ff ff       	call   f0100a31 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010128b:	83 c4 10             	add    $0x10,%esp
f010128e:	83 3d 4c de 17 f0 00 	cmpl   $0x0,0xf017de4c
f0101295:	75 17                	jne    f01012ae <mem_init+0x171>
		panic("'pages' is a null pointer!");
f0101297:	83 ec 04             	sub    $0x4,%esp
f010129a:	68 49 4f 10 f0       	push   $0xf0104f49
f010129f:	68 ba 02 00 00       	push   $0x2ba
f01012a4:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01012a9:	e8 f2 ed ff ff       	call   f01000a0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012ae:	a1 60 d1 17 f0       	mov    0xf017d160,%eax
f01012b3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012b8:	eb 05                	jmp    f01012bf <mem_init+0x182>
		++nfree;
f01012ba:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012bd:	8b 00                	mov    (%eax),%eax
f01012bf:	85 c0                	test   %eax,%eax
f01012c1:	75 f7                	jne    f01012ba <mem_init+0x17d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012c3:	83 ec 0c             	sub    $0xc,%esp
f01012c6:	6a 00                	push   $0x0
f01012c8:	e8 e6 fa ff ff       	call   f0100db3 <page_alloc>
f01012cd:	89 c7                	mov    %eax,%edi
f01012cf:	83 c4 10             	add    $0x10,%esp
f01012d2:	85 c0                	test   %eax,%eax
f01012d4:	75 19                	jne    f01012ef <mem_init+0x1b2>
f01012d6:	68 64 4f 10 f0       	push   $0xf0104f64
f01012db:	68 84 4e 10 f0       	push   $0xf0104e84
f01012e0:	68 c2 02 00 00       	push   $0x2c2
f01012e5:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01012ea:	e8 b1 ed ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01012ef:	83 ec 0c             	sub    $0xc,%esp
f01012f2:	6a 00                	push   $0x0
f01012f4:	e8 ba fa ff ff       	call   f0100db3 <page_alloc>
f01012f9:	89 c6                	mov    %eax,%esi
f01012fb:	83 c4 10             	add    $0x10,%esp
f01012fe:	85 c0                	test   %eax,%eax
f0101300:	75 19                	jne    f010131b <mem_init+0x1de>
f0101302:	68 7a 4f 10 f0       	push   $0xf0104f7a
f0101307:	68 84 4e 10 f0       	push   $0xf0104e84
f010130c:	68 c3 02 00 00       	push   $0x2c3
f0101311:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101316:	e8 85 ed ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010131b:	83 ec 0c             	sub    $0xc,%esp
f010131e:	6a 00                	push   $0x0
f0101320:	e8 8e fa ff ff       	call   f0100db3 <page_alloc>
f0101325:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101328:	83 c4 10             	add    $0x10,%esp
f010132b:	85 c0                	test   %eax,%eax
f010132d:	75 19                	jne    f0101348 <mem_init+0x20b>
f010132f:	68 90 4f 10 f0       	push   $0xf0104f90
f0101334:	68 84 4e 10 f0       	push   $0xf0104e84
f0101339:	68 c4 02 00 00       	push   $0x2c4
f010133e:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101343:	e8 58 ed ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101348:	39 f7                	cmp    %esi,%edi
f010134a:	75 19                	jne    f0101365 <mem_init+0x228>
f010134c:	68 a6 4f 10 f0       	push   $0xf0104fa6
f0101351:	68 84 4e 10 f0       	push   $0xf0104e84
f0101356:	68 c7 02 00 00       	push   $0x2c7
f010135b:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101360:	e8 3b ed ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101365:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101368:	39 c7                	cmp    %eax,%edi
f010136a:	74 04                	je     f0101370 <mem_init+0x233>
f010136c:	39 c6                	cmp    %eax,%esi
f010136e:	75 19                	jne    f0101389 <mem_init+0x24c>
f0101370:	68 e0 52 10 f0       	push   $0xf01052e0
f0101375:	68 84 4e 10 f0       	push   $0xf0104e84
f010137a:	68 c8 02 00 00       	push   $0x2c8
f010137f:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101384:	e8 17 ed ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101389:	8b 0d 4c de 17 f0    	mov    0xf017de4c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010138f:	8b 15 44 de 17 f0    	mov    0xf017de44,%edx
f0101395:	c1 e2 0c             	shl    $0xc,%edx
f0101398:	89 f8                	mov    %edi,%eax
f010139a:	29 c8                	sub    %ecx,%eax
f010139c:	c1 f8 03             	sar    $0x3,%eax
f010139f:	c1 e0 0c             	shl    $0xc,%eax
f01013a2:	39 d0                	cmp    %edx,%eax
f01013a4:	72 19                	jb     f01013bf <mem_init+0x282>
f01013a6:	68 b8 4f 10 f0       	push   $0xf0104fb8
f01013ab:	68 84 4e 10 f0       	push   $0xf0104e84
f01013b0:	68 c9 02 00 00       	push   $0x2c9
f01013b5:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01013ba:	e8 e1 ec ff ff       	call   f01000a0 <_panic>
f01013bf:	89 f0                	mov    %esi,%eax
f01013c1:	29 c8                	sub    %ecx,%eax
f01013c3:	c1 f8 03             	sar    $0x3,%eax
f01013c6:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01013c9:	39 c2                	cmp    %eax,%edx
f01013cb:	77 19                	ja     f01013e6 <mem_init+0x2a9>
f01013cd:	68 d5 4f 10 f0       	push   $0xf0104fd5
f01013d2:	68 84 4e 10 f0       	push   $0xf0104e84
f01013d7:	68 ca 02 00 00       	push   $0x2ca
f01013dc:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01013e1:	e8 ba ec ff ff       	call   f01000a0 <_panic>
f01013e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013e9:	29 c8                	sub    %ecx,%eax
f01013eb:	c1 f8 03             	sar    $0x3,%eax
f01013ee:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01013f1:	39 c2                	cmp    %eax,%edx
f01013f3:	77 19                	ja     f010140e <mem_init+0x2d1>
f01013f5:	68 f2 4f 10 f0       	push   $0xf0104ff2
f01013fa:	68 84 4e 10 f0       	push   $0xf0104e84
f01013ff:	68 cb 02 00 00       	push   $0x2cb
f0101404:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101409:	e8 92 ec ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010140e:	a1 60 d1 17 f0       	mov    0xf017d160,%eax
f0101413:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101416:	c7 05 60 d1 17 f0 00 	movl   $0x0,0xf017d160
f010141d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101420:	83 ec 0c             	sub    $0xc,%esp
f0101423:	6a 00                	push   $0x0
f0101425:	e8 89 f9 ff ff       	call   f0100db3 <page_alloc>
f010142a:	83 c4 10             	add    $0x10,%esp
f010142d:	85 c0                	test   %eax,%eax
f010142f:	74 19                	je     f010144a <mem_init+0x30d>
f0101431:	68 0f 50 10 f0       	push   $0xf010500f
f0101436:	68 84 4e 10 f0       	push   $0xf0104e84
f010143b:	68 d2 02 00 00       	push   $0x2d2
f0101440:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101445:	e8 56 ec ff ff       	call   f01000a0 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010144a:	83 ec 0c             	sub    $0xc,%esp
f010144d:	57                   	push   %edi
f010144e:	e8 ce f9 ff ff       	call   f0100e21 <page_free>
	page_free(pp1);
f0101453:	89 34 24             	mov    %esi,(%esp)
f0101456:	e8 c6 f9 ff ff       	call   f0100e21 <page_free>
	page_free(pp2);
f010145b:	83 c4 04             	add    $0x4,%esp
f010145e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101461:	e8 bb f9 ff ff       	call   f0100e21 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101466:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010146d:	e8 41 f9 ff ff       	call   f0100db3 <page_alloc>
f0101472:	89 c6                	mov    %eax,%esi
f0101474:	83 c4 10             	add    $0x10,%esp
f0101477:	85 c0                	test   %eax,%eax
f0101479:	75 19                	jne    f0101494 <mem_init+0x357>
f010147b:	68 64 4f 10 f0       	push   $0xf0104f64
f0101480:	68 84 4e 10 f0       	push   $0xf0104e84
f0101485:	68 d9 02 00 00       	push   $0x2d9
f010148a:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010148f:	e8 0c ec ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101494:	83 ec 0c             	sub    $0xc,%esp
f0101497:	6a 00                	push   $0x0
f0101499:	e8 15 f9 ff ff       	call   f0100db3 <page_alloc>
f010149e:	89 c7                	mov    %eax,%edi
f01014a0:	83 c4 10             	add    $0x10,%esp
f01014a3:	85 c0                	test   %eax,%eax
f01014a5:	75 19                	jne    f01014c0 <mem_init+0x383>
f01014a7:	68 7a 4f 10 f0       	push   $0xf0104f7a
f01014ac:	68 84 4e 10 f0       	push   $0xf0104e84
f01014b1:	68 da 02 00 00       	push   $0x2da
f01014b6:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01014bb:	e8 e0 eb ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01014c0:	83 ec 0c             	sub    $0xc,%esp
f01014c3:	6a 00                	push   $0x0
f01014c5:	e8 e9 f8 ff ff       	call   f0100db3 <page_alloc>
f01014ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014cd:	83 c4 10             	add    $0x10,%esp
f01014d0:	85 c0                	test   %eax,%eax
f01014d2:	75 19                	jne    f01014ed <mem_init+0x3b0>
f01014d4:	68 90 4f 10 f0       	push   $0xf0104f90
f01014d9:	68 84 4e 10 f0       	push   $0xf0104e84
f01014de:	68 db 02 00 00       	push   $0x2db
f01014e3:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01014e8:	e8 b3 eb ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014ed:	39 fe                	cmp    %edi,%esi
f01014ef:	75 19                	jne    f010150a <mem_init+0x3cd>
f01014f1:	68 a6 4f 10 f0       	push   $0xf0104fa6
f01014f6:	68 84 4e 10 f0       	push   $0xf0104e84
f01014fb:	68 dd 02 00 00       	push   $0x2dd
f0101500:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101505:	e8 96 eb ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010150a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010150d:	39 c6                	cmp    %eax,%esi
f010150f:	74 04                	je     f0101515 <mem_init+0x3d8>
f0101511:	39 c7                	cmp    %eax,%edi
f0101513:	75 19                	jne    f010152e <mem_init+0x3f1>
f0101515:	68 e0 52 10 f0       	push   $0xf01052e0
f010151a:	68 84 4e 10 f0       	push   $0xf0104e84
f010151f:	68 de 02 00 00       	push   $0x2de
f0101524:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101529:	e8 72 eb ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f010152e:	83 ec 0c             	sub    $0xc,%esp
f0101531:	6a 00                	push   $0x0
f0101533:	e8 7b f8 ff ff       	call   f0100db3 <page_alloc>
f0101538:	83 c4 10             	add    $0x10,%esp
f010153b:	85 c0                	test   %eax,%eax
f010153d:	74 19                	je     f0101558 <mem_init+0x41b>
f010153f:	68 0f 50 10 f0       	push   $0xf010500f
f0101544:	68 84 4e 10 f0       	push   $0xf0104e84
f0101549:	68 df 02 00 00       	push   $0x2df
f010154e:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101553:	e8 48 eb ff ff       	call   f01000a0 <_panic>
f0101558:	89 f0                	mov    %esi,%eax
f010155a:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f0101560:	c1 f8 03             	sar    $0x3,%eax
f0101563:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101566:	89 c2                	mov    %eax,%edx
f0101568:	c1 ea 0c             	shr    $0xc,%edx
f010156b:	3b 15 44 de 17 f0    	cmp    0xf017de44,%edx
f0101571:	72 12                	jb     f0101585 <mem_init+0x448>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101573:	50                   	push   %eax
f0101574:	68 78 51 10 f0       	push   $0xf0105178
f0101579:	6a 56                	push   $0x56
f010157b:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101580:	e8 1b eb ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101585:	83 ec 04             	sub    $0x4,%esp
f0101588:	68 00 10 00 00       	push   $0x1000
f010158d:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010158f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101594:	50                   	push   %eax
f0101595:	e8 99 2e 00 00       	call   f0104433 <memset>
	page_free(pp0);
f010159a:	89 34 24             	mov    %esi,(%esp)
f010159d:	e8 7f f8 ff ff       	call   f0100e21 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015a9:	e8 05 f8 ff ff       	call   f0100db3 <page_alloc>
f01015ae:	83 c4 10             	add    $0x10,%esp
f01015b1:	85 c0                	test   %eax,%eax
f01015b3:	75 19                	jne    f01015ce <mem_init+0x491>
f01015b5:	68 1e 50 10 f0       	push   $0xf010501e
f01015ba:	68 84 4e 10 f0       	push   $0xf0104e84
f01015bf:	68 e4 02 00 00       	push   $0x2e4
f01015c4:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01015c9:	e8 d2 ea ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f01015ce:	39 c6                	cmp    %eax,%esi
f01015d0:	74 19                	je     f01015eb <mem_init+0x4ae>
f01015d2:	68 3c 50 10 f0       	push   $0xf010503c
f01015d7:	68 84 4e 10 f0       	push   $0xf0104e84
f01015dc:	68 e5 02 00 00       	push   $0x2e5
f01015e1:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01015e6:	e8 b5 ea ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015eb:	89 f0                	mov    %esi,%eax
f01015ed:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f01015f3:	c1 f8 03             	sar    $0x3,%eax
f01015f6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015f9:	89 c2                	mov    %eax,%edx
f01015fb:	c1 ea 0c             	shr    $0xc,%edx
f01015fe:	3b 15 44 de 17 f0    	cmp    0xf017de44,%edx
f0101604:	72 12                	jb     f0101618 <mem_init+0x4db>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101606:	50                   	push   %eax
f0101607:	68 78 51 10 f0       	push   $0xf0105178
f010160c:	6a 56                	push   $0x56
f010160e:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101613:	e8 88 ea ff ff       	call   f01000a0 <_panic>
f0101618:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010161e:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101624:	80 38 00             	cmpb   $0x0,(%eax)
f0101627:	74 19                	je     f0101642 <mem_init+0x505>
f0101629:	68 4c 50 10 f0       	push   $0xf010504c
f010162e:	68 84 4e 10 f0       	push   $0xf0104e84
f0101633:	68 e8 02 00 00       	push   $0x2e8
f0101638:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010163d:	e8 5e ea ff ff       	call   f01000a0 <_panic>
f0101642:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101645:	39 d0                	cmp    %edx,%eax
f0101647:	75 db                	jne    f0101624 <mem_init+0x4e7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101649:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010164c:	a3 60 d1 17 f0       	mov    %eax,0xf017d160

	// free the pages we took
	page_free(pp0);
f0101651:	83 ec 0c             	sub    $0xc,%esp
f0101654:	56                   	push   %esi
f0101655:	e8 c7 f7 ff ff       	call   f0100e21 <page_free>
	page_free(pp1);
f010165a:	89 3c 24             	mov    %edi,(%esp)
f010165d:	e8 bf f7 ff ff       	call   f0100e21 <page_free>
	page_free(pp2);
f0101662:	83 c4 04             	add    $0x4,%esp
f0101665:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101668:	e8 b4 f7 ff ff       	call   f0100e21 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010166d:	a1 60 d1 17 f0       	mov    0xf017d160,%eax
f0101672:	83 c4 10             	add    $0x10,%esp
f0101675:	eb 05                	jmp    f010167c <mem_init+0x53f>
		--nfree;
f0101677:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010167a:	8b 00                	mov    (%eax),%eax
f010167c:	85 c0                	test   %eax,%eax
f010167e:	75 f7                	jne    f0101677 <mem_init+0x53a>
		--nfree;
	assert(nfree == 0);
f0101680:	85 db                	test   %ebx,%ebx
f0101682:	74 19                	je     f010169d <mem_init+0x560>
f0101684:	68 56 50 10 f0       	push   $0xf0105056
f0101689:	68 84 4e 10 f0       	push   $0xf0104e84
f010168e:	68 f5 02 00 00       	push   $0x2f5
f0101693:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101698:	e8 03 ea ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010169d:	83 ec 0c             	sub    $0xc,%esp
f01016a0:	68 00 53 10 f0       	push   $0xf0105300
f01016a5:	e8 5f 19 00 00       	call   f0103009 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016b1:	e8 fd f6 ff ff       	call   f0100db3 <page_alloc>
f01016b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016b9:	83 c4 10             	add    $0x10,%esp
f01016bc:	85 c0                	test   %eax,%eax
f01016be:	75 19                	jne    f01016d9 <mem_init+0x59c>
f01016c0:	68 64 4f 10 f0       	push   $0xf0104f64
f01016c5:	68 84 4e 10 f0       	push   $0xf0104e84
f01016ca:	68 53 03 00 00       	push   $0x353
f01016cf:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01016d4:	e8 c7 e9 ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01016d9:	83 ec 0c             	sub    $0xc,%esp
f01016dc:	6a 00                	push   $0x0
f01016de:	e8 d0 f6 ff ff       	call   f0100db3 <page_alloc>
f01016e3:	89 c3                	mov    %eax,%ebx
f01016e5:	83 c4 10             	add    $0x10,%esp
f01016e8:	85 c0                	test   %eax,%eax
f01016ea:	75 19                	jne    f0101705 <mem_init+0x5c8>
f01016ec:	68 7a 4f 10 f0       	push   $0xf0104f7a
f01016f1:	68 84 4e 10 f0       	push   $0xf0104e84
f01016f6:	68 54 03 00 00       	push   $0x354
f01016fb:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101700:	e8 9b e9 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101705:	83 ec 0c             	sub    $0xc,%esp
f0101708:	6a 00                	push   $0x0
f010170a:	e8 a4 f6 ff ff       	call   f0100db3 <page_alloc>
f010170f:	89 c6                	mov    %eax,%esi
f0101711:	83 c4 10             	add    $0x10,%esp
f0101714:	85 c0                	test   %eax,%eax
f0101716:	75 19                	jne    f0101731 <mem_init+0x5f4>
f0101718:	68 90 4f 10 f0       	push   $0xf0104f90
f010171d:	68 84 4e 10 f0       	push   $0xf0104e84
f0101722:	68 55 03 00 00       	push   $0x355
f0101727:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010172c:	e8 6f e9 ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101731:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101734:	75 19                	jne    f010174f <mem_init+0x612>
f0101736:	68 a6 4f 10 f0       	push   $0xf0104fa6
f010173b:	68 84 4e 10 f0       	push   $0xf0104e84
f0101740:	68 58 03 00 00       	push   $0x358
f0101745:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010174a:	e8 51 e9 ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010174f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101752:	74 04                	je     f0101758 <mem_init+0x61b>
f0101754:	39 c3                	cmp    %eax,%ebx
f0101756:	75 19                	jne    f0101771 <mem_init+0x634>
f0101758:	68 e0 52 10 f0       	push   $0xf01052e0
f010175d:	68 84 4e 10 f0       	push   $0xf0104e84
f0101762:	68 59 03 00 00       	push   $0x359
f0101767:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010176c:	e8 2f e9 ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101771:	a1 60 d1 17 f0       	mov    0xf017d160,%eax
f0101776:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101779:	c7 05 60 d1 17 f0 00 	movl   $0x0,0xf017d160
f0101780:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101783:	83 ec 0c             	sub    $0xc,%esp
f0101786:	6a 00                	push   $0x0
f0101788:	e8 26 f6 ff ff       	call   f0100db3 <page_alloc>
f010178d:	83 c4 10             	add    $0x10,%esp
f0101790:	85 c0                	test   %eax,%eax
f0101792:	74 19                	je     f01017ad <mem_init+0x670>
f0101794:	68 0f 50 10 f0       	push   $0xf010500f
f0101799:	68 84 4e 10 f0       	push   $0xf0104e84
f010179e:	68 60 03 00 00       	push   $0x360
f01017a3:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01017a8:	e8 f3 e8 ff ff       	call   f01000a0 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01017ad:	83 ec 04             	sub    $0x4,%esp
f01017b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01017b3:	50                   	push   %eax
f01017b4:	6a 00                	push   $0x0
f01017b6:	ff 35 48 de 17 f0    	pushl  0xf017de48
f01017bc:	e8 1c f8 ff ff       	call   f0100fdd <page_lookup>
f01017c1:	83 c4 10             	add    $0x10,%esp
f01017c4:	85 c0                	test   %eax,%eax
f01017c6:	74 19                	je     f01017e1 <mem_init+0x6a4>
f01017c8:	68 20 53 10 f0       	push   $0xf0105320
f01017cd:	68 84 4e 10 f0       	push   $0xf0104e84
f01017d2:	68 63 03 00 00       	push   $0x363
f01017d7:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01017dc:	e8 bf e8 ff ff       	call   f01000a0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01017e1:	6a 02                	push   $0x2
f01017e3:	6a 00                	push   $0x0
f01017e5:	53                   	push   %ebx
f01017e6:	ff 35 48 de 17 f0    	pushl  0xf017de48
f01017ec:	e8 de f8 ff ff       	call   f01010cf <page_insert>
f01017f1:	83 c4 10             	add    $0x10,%esp
f01017f4:	85 c0                	test   %eax,%eax
f01017f6:	78 19                	js     f0101811 <mem_init+0x6d4>
f01017f8:	68 58 53 10 f0       	push   $0xf0105358
f01017fd:	68 84 4e 10 f0       	push   $0xf0104e84
f0101802:	68 66 03 00 00       	push   $0x366
f0101807:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010180c:	e8 8f e8 ff ff       	call   f01000a0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101811:	83 ec 0c             	sub    $0xc,%esp
f0101814:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101817:	e8 05 f6 ff ff       	call   f0100e21 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010181c:	6a 02                	push   $0x2
f010181e:	6a 00                	push   $0x0
f0101820:	53                   	push   %ebx
f0101821:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0101827:	e8 a3 f8 ff ff       	call   f01010cf <page_insert>
f010182c:	83 c4 20             	add    $0x20,%esp
f010182f:	85 c0                	test   %eax,%eax
f0101831:	74 19                	je     f010184c <mem_init+0x70f>
f0101833:	68 88 53 10 f0       	push   $0xf0105388
f0101838:	68 84 4e 10 f0       	push   $0xf0104e84
f010183d:	68 6a 03 00 00       	push   $0x36a
f0101842:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101847:	e8 54 e8 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010184c:	8b 3d 48 de 17 f0    	mov    0xf017de48,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101852:	a1 4c de 17 f0       	mov    0xf017de4c,%eax
f0101857:	89 c1                	mov    %eax,%ecx
f0101859:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010185c:	8b 17                	mov    (%edi),%edx
f010185e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101864:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101867:	29 c8                	sub    %ecx,%eax
f0101869:	c1 f8 03             	sar    $0x3,%eax
f010186c:	c1 e0 0c             	shl    $0xc,%eax
f010186f:	39 c2                	cmp    %eax,%edx
f0101871:	74 19                	je     f010188c <mem_init+0x74f>
f0101873:	68 b8 53 10 f0       	push   $0xf01053b8
f0101878:	68 84 4e 10 f0       	push   $0xf0104e84
f010187d:	68 6b 03 00 00       	push   $0x36b
f0101882:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101887:	e8 14 e8 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010188c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101891:	89 f8                	mov    %edi,%eax
f0101893:	e8 35 f1 ff ff       	call   f01009cd <check_va2pa>
f0101898:	89 da                	mov    %ebx,%edx
f010189a:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010189d:	c1 fa 03             	sar    $0x3,%edx
f01018a0:	c1 e2 0c             	shl    $0xc,%edx
f01018a3:	39 d0                	cmp    %edx,%eax
f01018a5:	74 19                	je     f01018c0 <mem_init+0x783>
f01018a7:	68 e0 53 10 f0       	push   $0xf01053e0
f01018ac:	68 84 4e 10 f0       	push   $0xf0104e84
f01018b1:	68 6c 03 00 00       	push   $0x36c
f01018b6:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01018bb:	e8 e0 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f01018c0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018c5:	74 19                	je     f01018e0 <mem_init+0x7a3>
f01018c7:	68 61 50 10 f0       	push   $0xf0105061
f01018cc:	68 84 4e 10 f0       	push   $0xf0104e84
f01018d1:	68 6d 03 00 00       	push   $0x36d
f01018d6:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01018db:	e8 c0 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f01018e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018e3:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01018e8:	74 19                	je     f0101903 <mem_init+0x7c6>
f01018ea:	68 72 50 10 f0       	push   $0xf0105072
f01018ef:	68 84 4e 10 f0       	push   $0xf0104e84
f01018f4:	68 6e 03 00 00       	push   $0x36e
f01018f9:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01018fe:	e8 9d e7 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101903:	6a 02                	push   $0x2
f0101905:	68 00 10 00 00       	push   $0x1000
f010190a:	56                   	push   %esi
f010190b:	57                   	push   %edi
f010190c:	e8 be f7 ff ff       	call   f01010cf <page_insert>
f0101911:	83 c4 10             	add    $0x10,%esp
f0101914:	85 c0                	test   %eax,%eax
f0101916:	74 19                	je     f0101931 <mem_init+0x7f4>
f0101918:	68 10 54 10 f0       	push   $0xf0105410
f010191d:	68 84 4e 10 f0       	push   $0xf0104e84
f0101922:	68 71 03 00 00       	push   $0x371
f0101927:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010192c:	e8 6f e7 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101931:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101936:	a1 48 de 17 f0       	mov    0xf017de48,%eax
f010193b:	e8 8d f0 ff ff       	call   f01009cd <check_va2pa>
f0101940:	89 f2                	mov    %esi,%edx
f0101942:	2b 15 4c de 17 f0    	sub    0xf017de4c,%edx
f0101948:	c1 fa 03             	sar    $0x3,%edx
f010194b:	c1 e2 0c             	shl    $0xc,%edx
f010194e:	39 d0                	cmp    %edx,%eax
f0101950:	74 19                	je     f010196b <mem_init+0x82e>
f0101952:	68 4c 54 10 f0       	push   $0xf010544c
f0101957:	68 84 4e 10 f0       	push   $0xf0104e84
f010195c:	68 72 03 00 00       	push   $0x372
f0101961:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101966:	e8 35 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f010196b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101970:	74 19                	je     f010198b <mem_init+0x84e>
f0101972:	68 83 50 10 f0       	push   $0xf0105083
f0101977:	68 84 4e 10 f0       	push   $0xf0104e84
f010197c:	68 73 03 00 00       	push   $0x373
f0101981:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101986:	e8 15 e7 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010198b:	83 ec 0c             	sub    $0xc,%esp
f010198e:	6a 00                	push   $0x0
f0101990:	e8 1e f4 ff ff       	call   f0100db3 <page_alloc>
f0101995:	83 c4 10             	add    $0x10,%esp
f0101998:	85 c0                	test   %eax,%eax
f010199a:	74 19                	je     f01019b5 <mem_init+0x878>
f010199c:	68 0f 50 10 f0       	push   $0xf010500f
f01019a1:	68 84 4e 10 f0       	push   $0xf0104e84
f01019a6:	68 76 03 00 00       	push   $0x376
f01019ab:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01019b0:	e8 eb e6 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019b5:	6a 02                	push   $0x2
f01019b7:	68 00 10 00 00       	push   $0x1000
f01019bc:	56                   	push   %esi
f01019bd:	ff 35 48 de 17 f0    	pushl  0xf017de48
f01019c3:	e8 07 f7 ff ff       	call   f01010cf <page_insert>
f01019c8:	83 c4 10             	add    $0x10,%esp
f01019cb:	85 c0                	test   %eax,%eax
f01019cd:	74 19                	je     f01019e8 <mem_init+0x8ab>
f01019cf:	68 10 54 10 f0       	push   $0xf0105410
f01019d4:	68 84 4e 10 f0       	push   $0xf0104e84
f01019d9:	68 79 03 00 00       	push   $0x379
f01019de:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01019e3:	e8 b8 e6 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019e8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019ed:	a1 48 de 17 f0       	mov    0xf017de48,%eax
f01019f2:	e8 d6 ef ff ff       	call   f01009cd <check_va2pa>
f01019f7:	89 f2                	mov    %esi,%edx
f01019f9:	2b 15 4c de 17 f0    	sub    0xf017de4c,%edx
f01019ff:	c1 fa 03             	sar    $0x3,%edx
f0101a02:	c1 e2 0c             	shl    $0xc,%edx
f0101a05:	39 d0                	cmp    %edx,%eax
f0101a07:	74 19                	je     f0101a22 <mem_init+0x8e5>
f0101a09:	68 4c 54 10 f0       	push   $0xf010544c
f0101a0e:	68 84 4e 10 f0       	push   $0xf0104e84
f0101a13:	68 7a 03 00 00       	push   $0x37a
f0101a18:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101a1d:	e8 7e e6 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101a22:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a27:	74 19                	je     f0101a42 <mem_init+0x905>
f0101a29:	68 83 50 10 f0       	push   $0xf0105083
f0101a2e:	68 84 4e 10 f0       	push   $0xf0104e84
f0101a33:	68 7b 03 00 00       	push   $0x37b
f0101a38:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101a3d:	e8 5e e6 ff ff       	call   f01000a0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a42:	83 ec 0c             	sub    $0xc,%esp
f0101a45:	6a 00                	push   $0x0
f0101a47:	e8 67 f3 ff ff       	call   f0100db3 <page_alloc>
f0101a4c:	83 c4 10             	add    $0x10,%esp
f0101a4f:	85 c0                	test   %eax,%eax
f0101a51:	74 19                	je     f0101a6c <mem_init+0x92f>
f0101a53:	68 0f 50 10 f0       	push   $0xf010500f
f0101a58:	68 84 4e 10 f0       	push   $0xf0104e84
f0101a5d:	68 7f 03 00 00       	push   $0x37f
f0101a62:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101a67:	e8 34 e6 ff ff       	call   f01000a0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a6c:	8b 15 48 de 17 f0    	mov    0xf017de48,%edx
f0101a72:	8b 02                	mov    (%edx),%eax
f0101a74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a79:	89 c1                	mov    %eax,%ecx
f0101a7b:	c1 e9 0c             	shr    $0xc,%ecx
f0101a7e:	3b 0d 44 de 17 f0    	cmp    0xf017de44,%ecx
f0101a84:	72 15                	jb     f0101a9b <mem_init+0x95e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a86:	50                   	push   %eax
f0101a87:	68 78 51 10 f0       	push   $0xf0105178
f0101a8c:	68 82 03 00 00       	push   $0x382
f0101a91:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101a96:	e8 05 e6 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0101a9b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101aa0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101aa3:	83 ec 04             	sub    $0x4,%esp
f0101aa6:	6a 00                	push   $0x0
f0101aa8:	68 00 10 00 00       	push   $0x1000
f0101aad:	52                   	push   %edx
f0101aae:	e8 d4 f3 ff ff       	call   f0100e87 <pgdir_walk>
f0101ab3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101ab6:	8d 57 04             	lea    0x4(%edi),%edx
f0101ab9:	83 c4 10             	add    $0x10,%esp
f0101abc:	39 d0                	cmp    %edx,%eax
f0101abe:	74 19                	je     f0101ad9 <mem_init+0x99c>
f0101ac0:	68 7c 54 10 f0       	push   $0xf010547c
f0101ac5:	68 84 4e 10 f0       	push   $0xf0104e84
f0101aca:	68 83 03 00 00       	push   $0x383
f0101acf:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101ad4:	e8 c7 e5 ff ff       	call   f01000a0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ad9:	6a 06                	push   $0x6
f0101adb:	68 00 10 00 00       	push   $0x1000
f0101ae0:	56                   	push   %esi
f0101ae1:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0101ae7:	e8 e3 f5 ff ff       	call   f01010cf <page_insert>
f0101aec:	83 c4 10             	add    $0x10,%esp
f0101aef:	85 c0                	test   %eax,%eax
f0101af1:	74 19                	je     f0101b0c <mem_init+0x9cf>
f0101af3:	68 bc 54 10 f0       	push   $0xf01054bc
f0101af8:	68 84 4e 10 f0       	push   $0xf0104e84
f0101afd:	68 86 03 00 00       	push   $0x386
f0101b02:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101b07:	e8 94 e5 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b0c:	8b 3d 48 de 17 f0    	mov    0xf017de48,%edi
f0101b12:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b17:	89 f8                	mov    %edi,%eax
f0101b19:	e8 af ee ff ff       	call   f01009cd <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b1e:	89 f2                	mov    %esi,%edx
f0101b20:	2b 15 4c de 17 f0    	sub    0xf017de4c,%edx
f0101b26:	c1 fa 03             	sar    $0x3,%edx
f0101b29:	c1 e2 0c             	shl    $0xc,%edx
f0101b2c:	39 d0                	cmp    %edx,%eax
f0101b2e:	74 19                	je     f0101b49 <mem_init+0xa0c>
f0101b30:	68 4c 54 10 f0       	push   $0xf010544c
f0101b35:	68 84 4e 10 f0       	push   $0xf0104e84
f0101b3a:	68 87 03 00 00       	push   $0x387
f0101b3f:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101b44:	e8 57 e5 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101b49:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b4e:	74 19                	je     f0101b69 <mem_init+0xa2c>
f0101b50:	68 83 50 10 f0       	push   $0xf0105083
f0101b55:	68 84 4e 10 f0       	push   $0xf0104e84
f0101b5a:	68 88 03 00 00       	push   $0x388
f0101b5f:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101b64:	e8 37 e5 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b69:	83 ec 04             	sub    $0x4,%esp
f0101b6c:	6a 00                	push   $0x0
f0101b6e:	68 00 10 00 00       	push   $0x1000
f0101b73:	57                   	push   %edi
f0101b74:	e8 0e f3 ff ff       	call   f0100e87 <pgdir_walk>
f0101b79:	83 c4 10             	add    $0x10,%esp
f0101b7c:	f6 00 04             	testb  $0x4,(%eax)
f0101b7f:	75 19                	jne    f0101b9a <mem_init+0xa5d>
f0101b81:	68 fc 54 10 f0       	push   $0xf01054fc
f0101b86:	68 84 4e 10 f0       	push   $0xf0104e84
f0101b8b:	68 89 03 00 00       	push   $0x389
f0101b90:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101b95:	e8 06 e5 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b9a:	a1 48 de 17 f0       	mov    0xf017de48,%eax
f0101b9f:	f6 00 04             	testb  $0x4,(%eax)
f0101ba2:	75 19                	jne    f0101bbd <mem_init+0xa80>
f0101ba4:	68 94 50 10 f0       	push   $0xf0105094
f0101ba9:	68 84 4e 10 f0       	push   $0xf0104e84
f0101bae:	68 8a 03 00 00       	push   $0x38a
f0101bb3:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101bb8:	e8 e3 e4 ff ff       	call   f01000a0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bbd:	6a 02                	push   $0x2
f0101bbf:	68 00 10 00 00       	push   $0x1000
f0101bc4:	56                   	push   %esi
f0101bc5:	50                   	push   %eax
f0101bc6:	e8 04 f5 ff ff       	call   f01010cf <page_insert>
f0101bcb:	83 c4 10             	add    $0x10,%esp
f0101bce:	85 c0                	test   %eax,%eax
f0101bd0:	74 19                	je     f0101beb <mem_init+0xaae>
f0101bd2:	68 10 54 10 f0       	push   $0xf0105410
f0101bd7:	68 84 4e 10 f0       	push   $0xf0104e84
f0101bdc:	68 8d 03 00 00       	push   $0x38d
f0101be1:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101be6:	e8 b5 e4 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101beb:	83 ec 04             	sub    $0x4,%esp
f0101bee:	6a 00                	push   $0x0
f0101bf0:	68 00 10 00 00       	push   $0x1000
f0101bf5:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0101bfb:	e8 87 f2 ff ff       	call   f0100e87 <pgdir_walk>
f0101c00:	83 c4 10             	add    $0x10,%esp
f0101c03:	f6 00 02             	testb  $0x2,(%eax)
f0101c06:	75 19                	jne    f0101c21 <mem_init+0xae4>
f0101c08:	68 30 55 10 f0       	push   $0xf0105530
f0101c0d:	68 84 4e 10 f0       	push   $0xf0104e84
f0101c12:	68 8e 03 00 00       	push   $0x38e
f0101c17:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101c1c:	e8 7f e4 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c21:	83 ec 04             	sub    $0x4,%esp
f0101c24:	6a 00                	push   $0x0
f0101c26:	68 00 10 00 00       	push   $0x1000
f0101c2b:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0101c31:	e8 51 f2 ff ff       	call   f0100e87 <pgdir_walk>
f0101c36:	83 c4 10             	add    $0x10,%esp
f0101c39:	f6 00 04             	testb  $0x4,(%eax)
f0101c3c:	74 19                	je     f0101c57 <mem_init+0xb1a>
f0101c3e:	68 64 55 10 f0       	push   $0xf0105564
f0101c43:	68 84 4e 10 f0       	push   $0xf0104e84
f0101c48:	68 8f 03 00 00       	push   $0x38f
f0101c4d:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101c52:	e8 49 e4 ff ff       	call   f01000a0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c57:	6a 02                	push   $0x2
f0101c59:	68 00 00 40 00       	push   $0x400000
f0101c5e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c61:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0101c67:	e8 63 f4 ff ff       	call   f01010cf <page_insert>
f0101c6c:	83 c4 10             	add    $0x10,%esp
f0101c6f:	85 c0                	test   %eax,%eax
f0101c71:	78 19                	js     f0101c8c <mem_init+0xb4f>
f0101c73:	68 9c 55 10 f0       	push   $0xf010559c
f0101c78:	68 84 4e 10 f0       	push   $0xf0104e84
f0101c7d:	68 92 03 00 00       	push   $0x392
f0101c82:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101c87:	e8 14 e4 ff ff       	call   f01000a0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c8c:	6a 02                	push   $0x2
f0101c8e:	68 00 10 00 00       	push   $0x1000
f0101c93:	53                   	push   %ebx
f0101c94:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0101c9a:	e8 30 f4 ff ff       	call   f01010cf <page_insert>
f0101c9f:	83 c4 10             	add    $0x10,%esp
f0101ca2:	85 c0                	test   %eax,%eax
f0101ca4:	74 19                	je     f0101cbf <mem_init+0xb82>
f0101ca6:	68 d4 55 10 f0       	push   $0xf01055d4
f0101cab:	68 84 4e 10 f0       	push   $0xf0104e84
f0101cb0:	68 95 03 00 00       	push   $0x395
f0101cb5:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101cba:	e8 e1 e3 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cbf:	83 ec 04             	sub    $0x4,%esp
f0101cc2:	6a 00                	push   $0x0
f0101cc4:	68 00 10 00 00       	push   $0x1000
f0101cc9:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0101ccf:	e8 b3 f1 ff ff       	call   f0100e87 <pgdir_walk>
f0101cd4:	83 c4 10             	add    $0x10,%esp
f0101cd7:	f6 00 04             	testb  $0x4,(%eax)
f0101cda:	74 19                	je     f0101cf5 <mem_init+0xbb8>
f0101cdc:	68 64 55 10 f0       	push   $0xf0105564
f0101ce1:	68 84 4e 10 f0       	push   $0xf0104e84
f0101ce6:	68 96 03 00 00       	push   $0x396
f0101ceb:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101cf0:	e8 ab e3 ff ff       	call   f01000a0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cf5:	8b 3d 48 de 17 f0    	mov    0xf017de48,%edi
f0101cfb:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d00:	89 f8                	mov    %edi,%eax
f0101d02:	e8 c6 ec ff ff       	call   f01009cd <check_va2pa>
f0101d07:	89 c1                	mov    %eax,%ecx
f0101d09:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d0c:	89 d8                	mov    %ebx,%eax
f0101d0e:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f0101d14:	c1 f8 03             	sar    $0x3,%eax
f0101d17:	c1 e0 0c             	shl    $0xc,%eax
f0101d1a:	39 c1                	cmp    %eax,%ecx
f0101d1c:	74 19                	je     f0101d37 <mem_init+0xbfa>
f0101d1e:	68 10 56 10 f0       	push   $0xf0105610
f0101d23:	68 84 4e 10 f0       	push   $0xf0104e84
f0101d28:	68 99 03 00 00       	push   $0x399
f0101d2d:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101d32:	e8 69 e3 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d37:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d3c:	89 f8                	mov    %edi,%eax
f0101d3e:	e8 8a ec ff ff       	call   f01009cd <check_va2pa>
f0101d43:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101d46:	74 19                	je     f0101d61 <mem_init+0xc24>
f0101d48:	68 3c 56 10 f0       	push   $0xf010563c
f0101d4d:	68 84 4e 10 f0       	push   $0xf0104e84
f0101d52:	68 9a 03 00 00       	push   $0x39a
f0101d57:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101d5c:	e8 3f e3 ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d61:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101d66:	74 19                	je     f0101d81 <mem_init+0xc44>
f0101d68:	68 aa 50 10 f0       	push   $0xf01050aa
f0101d6d:	68 84 4e 10 f0       	push   $0xf0104e84
f0101d72:	68 9c 03 00 00       	push   $0x39c
f0101d77:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101d7c:	e8 1f e3 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101d81:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d86:	74 19                	je     f0101da1 <mem_init+0xc64>
f0101d88:	68 bb 50 10 f0       	push   $0xf01050bb
f0101d8d:	68 84 4e 10 f0       	push   $0xf0104e84
f0101d92:	68 9d 03 00 00       	push   $0x39d
f0101d97:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101d9c:	e8 ff e2 ff ff       	call   f01000a0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101da1:	83 ec 0c             	sub    $0xc,%esp
f0101da4:	6a 00                	push   $0x0
f0101da6:	e8 08 f0 ff ff       	call   f0100db3 <page_alloc>
f0101dab:	83 c4 10             	add    $0x10,%esp
f0101dae:	85 c0                	test   %eax,%eax
f0101db0:	74 04                	je     f0101db6 <mem_init+0xc79>
f0101db2:	39 c6                	cmp    %eax,%esi
f0101db4:	74 19                	je     f0101dcf <mem_init+0xc92>
f0101db6:	68 6c 56 10 f0       	push   $0xf010566c
f0101dbb:	68 84 4e 10 f0       	push   $0xf0104e84
f0101dc0:	68 a0 03 00 00       	push   $0x3a0
f0101dc5:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101dca:	e8 d1 e2 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101dcf:	83 ec 08             	sub    $0x8,%esp
f0101dd2:	6a 00                	push   $0x0
f0101dd4:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0101dda:	e8 9f f2 ff ff       	call   f010107e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ddf:	8b 3d 48 de 17 f0    	mov    0xf017de48,%edi
f0101de5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dea:	89 f8                	mov    %edi,%eax
f0101dec:	e8 dc eb ff ff       	call   f01009cd <check_va2pa>
f0101df1:	83 c4 10             	add    $0x10,%esp
f0101df4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101df7:	74 19                	je     f0101e12 <mem_init+0xcd5>
f0101df9:	68 90 56 10 f0       	push   $0xf0105690
f0101dfe:	68 84 4e 10 f0       	push   $0xf0104e84
f0101e03:	68 a4 03 00 00       	push   $0x3a4
f0101e08:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101e0d:	e8 8e e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e12:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e17:	89 f8                	mov    %edi,%eax
f0101e19:	e8 af eb ff ff       	call   f01009cd <check_va2pa>
f0101e1e:	89 da                	mov    %ebx,%edx
f0101e20:	2b 15 4c de 17 f0    	sub    0xf017de4c,%edx
f0101e26:	c1 fa 03             	sar    $0x3,%edx
f0101e29:	c1 e2 0c             	shl    $0xc,%edx
f0101e2c:	39 d0                	cmp    %edx,%eax
f0101e2e:	74 19                	je     f0101e49 <mem_init+0xd0c>
f0101e30:	68 3c 56 10 f0       	push   $0xf010563c
f0101e35:	68 84 4e 10 f0       	push   $0xf0104e84
f0101e3a:	68 a5 03 00 00       	push   $0x3a5
f0101e3f:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101e44:	e8 57 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101e49:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e4e:	74 19                	je     f0101e69 <mem_init+0xd2c>
f0101e50:	68 61 50 10 f0       	push   $0xf0105061
f0101e55:	68 84 4e 10 f0       	push   $0xf0104e84
f0101e5a:	68 a6 03 00 00       	push   $0x3a6
f0101e5f:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101e64:	e8 37 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101e69:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e6e:	74 19                	je     f0101e89 <mem_init+0xd4c>
f0101e70:	68 bb 50 10 f0       	push   $0xf01050bb
f0101e75:	68 84 4e 10 f0       	push   $0xf0104e84
f0101e7a:	68 a7 03 00 00       	push   $0x3a7
f0101e7f:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101e84:	e8 17 e2 ff ff       	call   f01000a0 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e89:	6a 00                	push   $0x0
f0101e8b:	68 00 10 00 00       	push   $0x1000
f0101e90:	53                   	push   %ebx
f0101e91:	57                   	push   %edi
f0101e92:	e8 38 f2 ff ff       	call   f01010cf <page_insert>
f0101e97:	83 c4 10             	add    $0x10,%esp
f0101e9a:	85 c0                	test   %eax,%eax
f0101e9c:	74 19                	je     f0101eb7 <mem_init+0xd7a>
f0101e9e:	68 b4 56 10 f0       	push   $0xf01056b4
f0101ea3:	68 84 4e 10 f0       	push   $0xf0104e84
f0101ea8:	68 aa 03 00 00       	push   $0x3aa
f0101ead:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101eb2:	e8 e9 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f0101eb7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ebc:	75 19                	jne    f0101ed7 <mem_init+0xd9a>
f0101ebe:	68 cc 50 10 f0       	push   $0xf01050cc
f0101ec3:	68 84 4e 10 f0       	push   $0xf0104e84
f0101ec8:	68 ab 03 00 00       	push   $0x3ab
f0101ecd:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101ed2:	e8 c9 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f0101ed7:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101eda:	74 19                	je     f0101ef5 <mem_init+0xdb8>
f0101edc:	68 d8 50 10 f0       	push   $0xf01050d8
f0101ee1:	68 84 4e 10 f0       	push   $0xf0104e84
f0101ee6:	68 ac 03 00 00       	push   $0x3ac
f0101eeb:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101ef0:	e8 ab e1 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101ef5:	83 ec 08             	sub    $0x8,%esp
f0101ef8:	68 00 10 00 00       	push   $0x1000
f0101efd:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0101f03:	e8 76 f1 ff ff       	call   f010107e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f08:	8b 3d 48 de 17 f0    	mov    0xf017de48,%edi
f0101f0e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f13:	89 f8                	mov    %edi,%eax
f0101f15:	e8 b3 ea ff ff       	call   f01009cd <check_va2pa>
f0101f1a:	83 c4 10             	add    $0x10,%esp
f0101f1d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f20:	74 19                	je     f0101f3b <mem_init+0xdfe>
f0101f22:	68 90 56 10 f0       	push   $0xf0105690
f0101f27:	68 84 4e 10 f0       	push   $0xf0104e84
f0101f2c:	68 b0 03 00 00       	push   $0x3b0
f0101f31:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101f36:	e8 65 e1 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f3b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f40:	89 f8                	mov    %edi,%eax
f0101f42:	e8 86 ea ff ff       	call   f01009cd <check_va2pa>
f0101f47:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f4a:	74 19                	je     f0101f65 <mem_init+0xe28>
f0101f4c:	68 ec 56 10 f0       	push   $0xf01056ec
f0101f51:	68 84 4e 10 f0       	push   $0xf0104e84
f0101f56:	68 b1 03 00 00       	push   $0x3b1
f0101f5b:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101f60:	e8 3b e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0101f65:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f6a:	74 19                	je     f0101f85 <mem_init+0xe48>
f0101f6c:	68 ed 50 10 f0       	push   $0xf01050ed
f0101f71:	68 84 4e 10 f0       	push   $0xf0104e84
f0101f76:	68 b2 03 00 00       	push   $0x3b2
f0101f7b:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101f80:	e8 1b e1 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101f85:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f8a:	74 19                	je     f0101fa5 <mem_init+0xe68>
f0101f8c:	68 bb 50 10 f0       	push   $0xf01050bb
f0101f91:	68 84 4e 10 f0       	push   $0xf0104e84
f0101f96:	68 b3 03 00 00       	push   $0x3b3
f0101f9b:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101fa0:	e8 fb e0 ff ff       	call   f01000a0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101fa5:	83 ec 0c             	sub    $0xc,%esp
f0101fa8:	6a 00                	push   $0x0
f0101faa:	e8 04 ee ff ff       	call   f0100db3 <page_alloc>
f0101faf:	83 c4 10             	add    $0x10,%esp
f0101fb2:	85 c0                	test   %eax,%eax
f0101fb4:	74 04                	je     f0101fba <mem_init+0xe7d>
f0101fb6:	39 c3                	cmp    %eax,%ebx
f0101fb8:	74 19                	je     f0101fd3 <mem_init+0xe96>
f0101fba:	68 14 57 10 f0       	push   $0xf0105714
f0101fbf:	68 84 4e 10 f0       	push   $0xf0104e84
f0101fc4:	68 b6 03 00 00       	push   $0x3b6
f0101fc9:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101fce:	e8 cd e0 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101fd3:	83 ec 0c             	sub    $0xc,%esp
f0101fd6:	6a 00                	push   $0x0
f0101fd8:	e8 d6 ed ff ff       	call   f0100db3 <page_alloc>
f0101fdd:	83 c4 10             	add    $0x10,%esp
f0101fe0:	85 c0                	test   %eax,%eax
f0101fe2:	74 19                	je     f0101ffd <mem_init+0xec0>
f0101fe4:	68 0f 50 10 f0       	push   $0xf010500f
f0101fe9:	68 84 4e 10 f0       	push   $0xf0104e84
f0101fee:	68 b9 03 00 00       	push   $0x3b9
f0101ff3:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101ff8:	e8 a3 e0 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ffd:	8b 0d 48 de 17 f0    	mov    0xf017de48,%ecx
f0102003:	8b 11                	mov    (%ecx),%edx
f0102005:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010200b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010200e:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f0102014:	c1 f8 03             	sar    $0x3,%eax
f0102017:	c1 e0 0c             	shl    $0xc,%eax
f010201a:	39 c2                	cmp    %eax,%edx
f010201c:	74 19                	je     f0102037 <mem_init+0xefa>
f010201e:	68 b8 53 10 f0       	push   $0xf01053b8
f0102023:	68 84 4e 10 f0       	push   $0xf0104e84
f0102028:	68 bc 03 00 00       	push   $0x3bc
f010202d:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102032:	e8 69 e0 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0102037:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010203d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102040:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102045:	74 19                	je     f0102060 <mem_init+0xf23>
f0102047:	68 72 50 10 f0       	push   $0xf0105072
f010204c:	68 84 4e 10 f0       	push   $0xf0104e84
f0102051:	68 be 03 00 00       	push   $0x3be
f0102056:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010205b:	e8 40 e0 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0102060:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102063:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102069:	83 ec 0c             	sub    $0xc,%esp
f010206c:	50                   	push   %eax
f010206d:	e8 af ed ff ff       	call   f0100e21 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102072:	83 c4 0c             	add    $0xc,%esp
f0102075:	6a 01                	push   $0x1
f0102077:	68 00 10 40 00       	push   $0x401000
f010207c:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0102082:	e8 00 ee ff ff       	call   f0100e87 <pgdir_walk>
f0102087:	89 c7                	mov    %eax,%edi
f0102089:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010208c:	a1 48 de 17 f0       	mov    0xf017de48,%eax
f0102091:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102094:	8b 40 04             	mov    0x4(%eax),%eax
f0102097:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010209c:	8b 0d 44 de 17 f0    	mov    0xf017de44,%ecx
f01020a2:	89 c2                	mov    %eax,%edx
f01020a4:	c1 ea 0c             	shr    $0xc,%edx
f01020a7:	83 c4 10             	add    $0x10,%esp
f01020aa:	39 ca                	cmp    %ecx,%edx
f01020ac:	72 15                	jb     f01020c3 <mem_init+0xf86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020ae:	50                   	push   %eax
f01020af:	68 78 51 10 f0       	push   $0xf0105178
f01020b4:	68 c5 03 00 00       	push   $0x3c5
f01020b9:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01020be:	e8 dd df ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01020c3:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01020c8:	39 c7                	cmp    %eax,%edi
f01020ca:	74 19                	je     f01020e5 <mem_init+0xfa8>
f01020cc:	68 fe 50 10 f0       	push   $0xf01050fe
f01020d1:	68 84 4e 10 f0       	push   $0xf0104e84
f01020d6:	68 c6 03 00 00       	push   $0x3c6
f01020db:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01020e0:	e8 bb df ff ff       	call   f01000a0 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01020e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01020e8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01020ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020f2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020f8:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f01020fe:	c1 f8 03             	sar    $0x3,%eax
f0102101:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102104:	89 c2                	mov    %eax,%edx
f0102106:	c1 ea 0c             	shr    $0xc,%edx
f0102109:	39 d1                	cmp    %edx,%ecx
f010210b:	77 12                	ja     f010211f <mem_init+0xfe2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010210d:	50                   	push   %eax
f010210e:	68 78 51 10 f0       	push   $0xf0105178
f0102113:	6a 56                	push   $0x56
f0102115:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010211a:	e8 81 df ff ff       	call   f01000a0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010211f:	83 ec 04             	sub    $0x4,%esp
f0102122:	68 00 10 00 00       	push   $0x1000
f0102127:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010212c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102131:	50                   	push   %eax
f0102132:	e8 fc 22 00 00       	call   f0104433 <memset>
	page_free(pp0);
f0102137:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010213a:	89 3c 24             	mov    %edi,(%esp)
f010213d:	e8 df ec ff ff       	call   f0100e21 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102142:	83 c4 0c             	add    $0xc,%esp
f0102145:	6a 01                	push   $0x1
f0102147:	6a 00                	push   $0x0
f0102149:	ff 35 48 de 17 f0    	pushl  0xf017de48
f010214f:	e8 33 ed ff ff       	call   f0100e87 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102154:	89 fa                	mov    %edi,%edx
f0102156:	2b 15 4c de 17 f0    	sub    0xf017de4c,%edx
f010215c:	c1 fa 03             	sar    $0x3,%edx
f010215f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102162:	89 d0                	mov    %edx,%eax
f0102164:	c1 e8 0c             	shr    $0xc,%eax
f0102167:	83 c4 10             	add    $0x10,%esp
f010216a:	3b 05 44 de 17 f0    	cmp    0xf017de44,%eax
f0102170:	72 12                	jb     f0102184 <mem_init+0x1047>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102172:	52                   	push   %edx
f0102173:	68 78 51 10 f0       	push   $0xf0105178
f0102178:	6a 56                	push   $0x56
f010217a:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010217f:	e8 1c df ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0102184:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010218a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010218d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102193:	f6 00 01             	testb  $0x1,(%eax)
f0102196:	74 19                	je     f01021b1 <mem_init+0x1074>
f0102198:	68 16 51 10 f0       	push   $0xf0105116
f010219d:	68 84 4e 10 f0       	push   $0xf0104e84
f01021a2:	68 d0 03 00 00       	push   $0x3d0
f01021a7:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01021ac:	e8 ef de ff ff       	call   f01000a0 <_panic>
f01021b1:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01021b4:	39 d0                	cmp    %edx,%eax
f01021b6:	75 db                	jne    f0102193 <mem_init+0x1056>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01021b8:	a1 48 de 17 f0       	mov    0xf017de48,%eax
f01021bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01021c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021c6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01021cc:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01021cf:	89 3d 60 d1 17 f0    	mov    %edi,0xf017d160

	// free the pages we took
	page_free(pp0);
f01021d5:	83 ec 0c             	sub    $0xc,%esp
f01021d8:	50                   	push   %eax
f01021d9:	e8 43 ec ff ff       	call   f0100e21 <page_free>
	page_free(pp1);
f01021de:	89 1c 24             	mov    %ebx,(%esp)
f01021e1:	e8 3b ec ff ff       	call   f0100e21 <page_free>
	page_free(pp2);
f01021e6:	89 34 24             	mov    %esi,(%esp)
f01021e9:	e8 33 ec ff ff       	call   f0100e21 <page_free>

	cprintf("check_page() succeeded!\n");
f01021ee:	c7 04 24 2d 51 10 f0 	movl   $0xf010512d,(%esp)
f01021f5:	e8 0f 0e 00 00       	call   f0103009 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f01021fa:	a1 4c de 17 f0       	mov    0xf017de4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021ff:	83 c4 10             	add    $0x10,%esp
f0102202:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102207:	77 15                	ja     f010221e <mem_init+0x10e1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102209:	50                   	push   %eax
f010220a:	68 60 52 10 f0       	push   $0xf0105260
f010220f:	68 c6 00 00 00       	push   $0xc6
f0102214:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102219:	e8 82 de ff ff       	call   f01000a0 <_panic>
f010221e:	83 ec 08             	sub    $0x8,%esp
f0102221:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102223:	05 00 00 00 10       	add    $0x10000000,%eax
f0102228:	50                   	push   %eax
f0102229:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010222e:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102233:	a1 48 de 17 f0       	mov    0xf017de48,%eax
f0102238:	e8 27 ed ff ff       	call   f0100f64 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f010223d:	a1 6c d1 17 f0       	mov    0xf017d16c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102242:	83 c4 10             	add    $0x10,%esp
f0102245:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010224a:	77 15                	ja     f0102261 <mem_init+0x1124>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010224c:	50                   	push   %eax
f010224d:	68 60 52 10 f0       	push   $0xf0105260
f0102252:	68 ce 00 00 00       	push   $0xce
f0102257:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010225c:	e8 3f de ff ff       	call   f01000a0 <_panic>
f0102261:	83 ec 08             	sub    $0x8,%esp
f0102264:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102266:	05 00 00 00 10       	add    $0x10000000,%eax
f010226b:	50                   	push   %eax
f010226c:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102271:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102276:	a1 48 de 17 f0       	mov    0xf017de48,%eax
f010227b:	e8 e4 ec ff ff       	call   f0100f64 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102280:	83 c4 10             	add    $0x10,%esp
f0102283:	b8 00 10 11 f0       	mov    $0xf0111000,%eax
f0102288:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010228d:	77 15                	ja     f01022a4 <mem_init+0x1167>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010228f:	50                   	push   %eax
f0102290:	68 60 52 10 f0       	push   $0xf0105260
f0102295:	68 da 00 00 00       	push   $0xda
f010229a:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010229f:	e8 fc dd ff ff       	call   f01000a0 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01022a4:	83 ec 08             	sub    $0x8,%esp
f01022a7:	6a 02                	push   $0x2
f01022a9:	68 00 10 11 00       	push   $0x111000
f01022ae:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01022b3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01022b8:	a1 48 de 17 f0       	mov    0xf017de48,%eax
f01022bd:	e8 a2 ec ff ff       	call   f0100f64 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f01022c2:	83 c4 08             	add    $0x8,%esp
f01022c5:	6a 02                	push   $0x2
f01022c7:	6a 00                	push   $0x0
f01022c9:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01022ce:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01022d3:	a1 48 de 17 f0       	mov    0xf017de48,%eax
f01022d8:	e8 87 ec ff ff       	call   f0100f64 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01022dd:	8b 1d 48 de 17 f0    	mov    0xf017de48,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01022e3:	a1 44 de 17 f0       	mov    0xf017de44,%eax
f01022e8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01022eb:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01022f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022fa:	8b 3d 4c de 17 f0    	mov    0xf017de4c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102300:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102303:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102306:	be 00 00 00 00       	mov    $0x0,%esi
f010230b:	eb 55                	jmp    f0102362 <mem_init+0x1225>
f010230d:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102313:	89 d8                	mov    %ebx,%eax
f0102315:	e8 b3 e6 ff ff       	call   f01009cd <check_va2pa>
f010231a:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102321:	77 15                	ja     f0102338 <mem_init+0x11fb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102323:	57                   	push   %edi
f0102324:	68 60 52 10 f0       	push   $0xf0105260
f0102329:	68 0d 03 00 00       	push   $0x30d
f010232e:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102333:	e8 68 dd ff ff       	call   f01000a0 <_panic>
f0102338:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f010233f:	39 c2                	cmp    %eax,%edx
f0102341:	74 19                	je     f010235c <mem_init+0x121f>
f0102343:	68 38 57 10 f0       	push   $0xf0105738
f0102348:	68 84 4e 10 f0       	push   $0xf0104e84
f010234d:	68 0d 03 00 00       	push   $0x30d
f0102352:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102357:	e8 44 dd ff ff       	call   f01000a0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010235c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102362:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102365:	77 a6                	ja     f010230d <mem_init+0x11d0>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102367:	8b 3d 6c d1 17 f0    	mov    0xf017d16c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010236d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102370:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102375:	89 f2                	mov    %esi,%edx
f0102377:	89 d8                	mov    %ebx,%eax
f0102379:	e8 4f e6 ff ff       	call   f01009cd <check_va2pa>
f010237e:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102385:	77 15                	ja     f010239c <mem_init+0x125f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102387:	57                   	push   %edi
f0102388:	68 60 52 10 f0       	push   $0xf0105260
f010238d:	68 12 03 00 00       	push   $0x312
f0102392:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102397:	e8 04 dd ff ff       	call   f01000a0 <_panic>
f010239c:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f01023a3:	39 c2                	cmp    %eax,%edx
f01023a5:	74 19                	je     f01023c0 <mem_init+0x1283>
f01023a7:	68 6c 57 10 f0       	push   $0xf010576c
f01023ac:	68 84 4e 10 f0       	push   $0xf0104e84
f01023b1:	68 12 03 00 00       	push   $0x312
f01023b6:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01023bb:	e8 e0 dc ff ff       	call   f01000a0 <_panic>
f01023c0:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01023c6:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f01023cc:	75 a7                	jne    f0102375 <mem_init+0x1238>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01023ce:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01023d1:	c1 e7 0c             	shl    $0xc,%edi
f01023d4:	be 00 00 00 00       	mov    $0x0,%esi
f01023d9:	eb 30                	jmp    f010240b <mem_init+0x12ce>
f01023db:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01023e1:	89 d8                	mov    %ebx,%eax
f01023e3:	e8 e5 e5 ff ff       	call   f01009cd <check_va2pa>
f01023e8:	39 c6                	cmp    %eax,%esi
f01023ea:	74 19                	je     f0102405 <mem_init+0x12c8>
f01023ec:	68 a0 57 10 f0       	push   $0xf01057a0
f01023f1:	68 84 4e 10 f0       	push   $0xf0104e84
f01023f6:	68 16 03 00 00       	push   $0x316
f01023fb:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102400:	e8 9b dc ff ff       	call   f01000a0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102405:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010240b:	39 fe                	cmp    %edi,%esi
f010240d:	72 cc                	jb     f01023db <mem_init+0x129e>
f010240f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102414:	89 f2                	mov    %esi,%edx
f0102416:	89 d8                	mov    %ebx,%eax
f0102418:	e8 b0 e5 ff ff       	call   f01009cd <check_va2pa>
f010241d:	8d 96 00 90 11 10    	lea    0x10119000(%esi),%edx
f0102423:	39 c2                	cmp    %eax,%edx
f0102425:	74 19                	je     f0102440 <mem_init+0x1303>
f0102427:	68 c8 57 10 f0       	push   $0xf01057c8
f010242c:	68 84 4e 10 f0       	push   $0xf0104e84
f0102431:	68 1a 03 00 00       	push   $0x31a
f0102436:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010243b:	e8 60 dc ff ff       	call   f01000a0 <_panic>
f0102440:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102446:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010244c:	75 c6                	jne    f0102414 <mem_init+0x12d7>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010244e:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102453:	89 d8                	mov    %ebx,%eax
f0102455:	e8 73 e5 ff ff       	call   f01009cd <check_va2pa>
f010245a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010245d:	74 51                	je     f01024b0 <mem_init+0x1373>
f010245f:	68 10 58 10 f0       	push   $0xf0105810
f0102464:	68 84 4e 10 f0       	push   $0xf0104e84
f0102469:	68 1b 03 00 00       	push   $0x31b
f010246e:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102473:	e8 28 dc ff ff       	call   f01000a0 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102478:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010247d:	72 36                	jb     f01024b5 <mem_init+0x1378>
f010247f:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102484:	76 07                	jbe    f010248d <mem_init+0x1350>
f0102486:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010248b:	75 28                	jne    f01024b5 <mem_init+0x1378>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010248d:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102491:	0f 85 83 00 00 00    	jne    f010251a <mem_init+0x13dd>
f0102497:	68 46 51 10 f0       	push   $0xf0105146
f010249c:	68 84 4e 10 f0       	push   $0xf0104e84
f01024a1:	68 24 03 00 00       	push   $0x324
f01024a6:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01024ab:	e8 f0 db ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01024b0:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01024b5:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01024ba:	76 3f                	jbe    f01024fb <mem_init+0x13be>
				assert(pgdir[i] & PTE_P);
f01024bc:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01024bf:	f6 c2 01             	test   $0x1,%dl
f01024c2:	75 19                	jne    f01024dd <mem_init+0x13a0>
f01024c4:	68 46 51 10 f0       	push   $0xf0105146
f01024c9:	68 84 4e 10 f0       	push   $0xf0104e84
f01024ce:	68 28 03 00 00       	push   $0x328
f01024d3:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01024d8:	e8 c3 db ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_W);
f01024dd:	f6 c2 02             	test   $0x2,%dl
f01024e0:	75 38                	jne    f010251a <mem_init+0x13dd>
f01024e2:	68 57 51 10 f0       	push   $0xf0105157
f01024e7:	68 84 4e 10 f0       	push   $0xf0104e84
f01024ec:	68 29 03 00 00       	push   $0x329
f01024f1:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01024f6:	e8 a5 db ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
f01024fb:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01024ff:	74 19                	je     f010251a <mem_init+0x13dd>
f0102501:	68 68 51 10 f0       	push   $0xf0105168
f0102506:	68 84 4e 10 f0       	push   $0xf0104e84
f010250b:	68 2b 03 00 00       	push   $0x32b
f0102510:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102515:	e8 86 db ff ff       	call   f01000a0 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010251a:	83 c0 01             	add    $0x1,%eax
f010251d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102522:	0f 86 50 ff ff ff    	jbe    f0102478 <mem_init+0x133b>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102528:	83 ec 0c             	sub    $0xc,%esp
f010252b:	68 40 58 10 f0       	push   $0xf0105840
f0102530:	e8 d4 0a 00 00       	call   f0103009 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102535:	a1 48 de 17 f0       	mov    0xf017de48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010253a:	83 c4 10             	add    $0x10,%esp
f010253d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102542:	77 15                	ja     f0102559 <mem_init+0x141c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102544:	50                   	push   %eax
f0102545:	68 60 52 10 f0       	push   $0xf0105260
f010254a:	68 ee 00 00 00       	push   $0xee
f010254f:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102554:	e8 47 db ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102559:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010255e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102561:	b8 00 00 00 00       	mov    $0x0,%eax
f0102566:	e8 c6 e4 ff ff       	call   f0100a31 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010256b:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f010256e:	83 e0 f3             	and    $0xfffffff3,%eax
f0102571:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102576:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102579:	83 ec 0c             	sub    $0xc,%esp
f010257c:	6a 00                	push   $0x0
f010257e:	e8 30 e8 ff ff       	call   f0100db3 <page_alloc>
f0102583:	89 c3                	mov    %eax,%ebx
f0102585:	83 c4 10             	add    $0x10,%esp
f0102588:	85 c0                	test   %eax,%eax
f010258a:	75 19                	jne    f01025a5 <mem_init+0x1468>
f010258c:	68 64 4f 10 f0       	push   $0xf0104f64
f0102591:	68 84 4e 10 f0       	push   $0xf0104e84
f0102596:	68 eb 03 00 00       	push   $0x3eb
f010259b:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01025a0:	e8 fb da ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01025a5:	83 ec 0c             	sub    $0xc,%esp
f01025a8:	6a 00                	push   $0x0
f01025aa:	e8 04 e8 ff ff       	call   f0100db3 <page_alloc>
f01025af:	89 c7                	mov    %eax,%edi
f01025b1:	83 c4 10             	add    $0x10,%esp
f01025b4:	85 c0                	test   %eax,%eax
f01025b6:	75 19                	jne    f01025d1 <mem_init+0x1494>
f01025b8:	68 7a 4f 10 f0       	push   $0xf0104f7a
f01025bd:	68 84 4e 10 f0       	push   $0xf0104e84
f01025c2:	68 ec 03 00 00       	push   $0x3ec
f01025c7:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01025cc:	e8 cf da ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01025d1:	83 ec 0c             	sub    $0xc,%esp
f01025d4:	6a 00                	push   $0x0
f01025d6:	e8 d8 e7 ff ff       	call   f0100db3 <page_alloc>
f01025db:	89 c6                	mov    %eax,%esi
f01025dd:	83 c4 10             	add    $0x10,%esp
f01025e0:	85 c0                	test   %eax,%eax
f01025e2:	75 19                	jne    f01025fd <mem_init+0x14c0>
f01025e4:	68 90 4f 10 f0       	push   $0xf0104f90
f01025e9:	68 84 4e 10 f0       	push   $0xf0104e84
f01025ee:	68 ed 03 00 00       	push   $0x3ed
f01025f3:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01025f8:	e8 a3 da ff ff       	call   f01000a0 <_panic>
	page_free(pp0);
f01025fd:	83 ec 0c             	sub    $0xc,%esp
f0102600:	53                   	push   %ebx
f0102601:	e8 1b e8 ff ff       	call   f0100e21 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102606:	89 f8                	mov    %edi,%eax
f0102608:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f010260e:	c1 f8 03             	sar    $0x3,%eax
f0102611:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102614:	89 c2                	mov    %eax,%edx
f0102616:	c1 ea 0c             	shr    $0xc,%edx
f0102619:	83 c4 10             	add    $0x10,%esp
f010261c:	3b 15 44 de 17 f0    	cmp    0xf017de44,%edx
f0102622:	72 12                	jb     f0102636 <mem_init+0x14f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102624:	50                   	push   %eax
f0102625:	68 78 51 10 f0       	push   $0xf0105178
f010262a:	6a 56                	push   $0x56
f010262c:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0102631:	e8 6a da ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102636:	83 ec 04             	sub    $0x4,%esp
f0102639:	68 00 10 00 00       	push   $0x1000
f010263e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102640:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102645:	50                   	push   %eax
f0102646:	e8 e8 1d 00 00       	call   f0104433 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010264b:	89 f0                	mov    %esi,%eax
f010264d:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f0102653:	c1 f8 03             	sar    $0x3,%eax
f0102656:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102659:	89 c2                	mov    %eax,%edx
f010265b:	c1 ea 0c             	shr    $0xc,%edx
f010265e:	83 c4 10             	add    $0x10,%esp
f0102661:	3b 15 44 de 17 f0    	cmp    0xf017de44,%edx
f0102667:	72 12                	jb     f010267b <mem_init+0x153e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102669:	50                   	push   %eax
f010266a:	68 78 51 10 f0       	push   $0xf0105178
f010266f:	6a 56                	push   $0x56
f0102671:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0102676:	e8 25 da ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010267b:	83 ec 04             	sub    $0x4,%esp
f010267e:	68 00 10 00 00       	push   $0x1000
f0102683:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102685:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010268a:	50                   	push   %eax
f010268b:	e8 a3 1d 00 00       	call   f0104433 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102690:	6a 02                	push   $0x2
f0102692:	68 00 10 00 00       	push   $0x1000
f0102697:	57                   	push   %edi
f0102698:	ff 35 48 de 17 f0    	pushl  0xf017de48
f010269e:	e8 2c ea ff ff       	call   f01010cf <page_insert>
	assert(pp1->pp_ref == 1);
f01026a3:	83 c4 20             	add    $0x20,%esp
f01026a6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01026ab:	74 19                	je     f01026c6 <mem_init+0x1589>
f01026ad:	68 61 50 10 f0       	push   $0xf0105061
f01026b2:	68 84 4e 10 f0       	push   $0xf0104e84
f01026b7:	68 f2 03 00 00       	push   $0x3f2
f01026bc:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01026c1:	e8 da d9 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01026c6:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01026cd:	01 01 01 
f01026d0:	74 19                	je     f01026eb <mem_init+0x15ae>
f01026d2:	68 60 58 10 f0       	push   $0xf0105860
f01026d7:	68 84 4e 10 f0       	push   $0xf0104e84
f01026dc:	68 f3 03 00 00       	push   $0x3f3
f01026e1:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01026e6:	e8 b5 d9 ff ff       	call   f01000a0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01026eb:	6a 02                	push   $0x2
f01026ed:	68 00 10 00 00       	push   $0x1000
f01026f2:	56                   	push   %esi
f01026f3:	ff 35 48 de 17 f0    	pushl  0xf017de48
f01026f9:	e8 d1 e9 ff ff       	call   f01010cf <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01026fe:	83 c4 10             	add    $0x10,%esp
f0102701:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102708:	02 02 02 
f010270b:	74 19                	je     f0102726 <mem_init+0x15e9>
f010270d:	68 84 58 10 f0       	push   $0xf0105884
f0102712:	68 84 4e 10 f0       	push   $0xf0104e84
f0102717:	68 f5 03 00 00       	push   $0x3f5
f010271c:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102721:	e8 7a d9 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0102726:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010272b:	74 19                	je     f0102746 <mem_init+0x1609>
f010272d:	68 83 50 10 f0       	push   $0xf0105083
f0102732:	68 84 4e 10 f0       	push   $0xf0104e84
f0102737:	68 f6 03 00 00       	push   $0x3f6
f010273c:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102741:	e8 5a d9 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0102746:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010274b:	74 19                	je     f0102766 <mem_init+0x1629>
f010274d:	68 ed 50 10 f0       	push   $0xf01050ed
f0102752:	68 84 4e 10 f0       	push   $0xf0104e84
f0102757:	68 f7 03 00 00       	push   $0x3f7
f010275c:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102761:	e8 3a d9 ff ff       	call   f01000a0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102766:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010276d:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102770:	89 f0                	mov    %esi,%eax
f0102772:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f0102778:	c1 f8 03             	sar    $0x3,%eax
f010277b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010277e:	89 c2                	mov    %eax,%edx
f0102780:	c1 ea 0c             	shr    $0xc,%edx
f0102783:	3b 15 44 de 17 f0    	cmp    0xf017de44,%edx
f0102789:	72 12                	jb     f010279d <mem_init+0x1660>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010278b:	50                   	push   %eax
f010278c:	68 78 51 10 f0       	push   $0xf0105178
f0102791:	6a 56                	push   $0x56
f0102793:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0102798:	e8 03 d9 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010279d:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01027a4:	03 03 03 
f01027a7:	74 19                	je     f01027c2 <mem_init+0x1685>
f01027a9:	68 a8 58 10 f0       	push   $0xf01058a8
f01027ae:	68 84 4e 10 f0       	push   $0xf0104e84
f01027b3:	68 f9 03 00 00       	push   $0x3f9
f01027b8:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01027bd:	e8 de d8 ff ff       	call   f01000a0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01027c2:	83 ec 08             	sub    $0x8,%esp
f01027c5:	68 00 10 00 00       	push   $0x1000
f01027ca:	ff 35 48 de 17 f0    	pushl  0xf017de48
f01027d0:	e8 a9 e8 ff ff       	call   f010107e <page_remove>
	assert(pp2->pp_ref == 0);
f01027d5:	83 c4 10             	add    $0x10,%esp
f01027d8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01027dd:	74 19                	je     f01027f8 <mem_init+0x16bb>
f01027df:	68 bb 50 10 f0       	push   $0xf01050bb
f01027e4:	68 84 4e 10 f0       	push   $0xf0104e84
f01027e9:	68 fb 03 00 00       	push   $0x3fb
f01027ee:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01027f3:	e8 a8 d8 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027f8:	8b 0d 48 de 17 f0    	mov    0xf017de48,%ecx
f01027fe:	8b 11                	mov    (%ecx),%edx
f0102800:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102806:	89 d8                	mov    %ebx,%eax
f0102808:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f010280e:	c1 f8 03             	sar    $0x3,%eax
f0102811:	c1 e0 0c             	shl    $0xc,%eax
f0102814:	39 c2                	cmp    %eax,%edx
f0102816:	74 19                	je     f0102831 <mem_init+0x16f4>
f0102818:	68 b8 53 10 f0       	push   $0xf01053b8
f010281d:	68 84 4e 10 f0       	push   $0xf0104e84
f0102822:	68 fe 03 00 00       	push   $0x3fe
f0102827:	68 5e 4e 10 f0       	push   $0xf0104e5e
f010282c:	e8 6f d8 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0102831:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102837:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010283c:	74 19                	je     f0102857 <mem_init+0x171a>
f010283e:	68 72 50 10 f0       	push   $0xf0105072
f0102843:	68 84 4e 10 f0       	push   $0xf0104e84
f0102848:	68 00 04 00 00       	push   $0x400
f010284d:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102852:	e8 49 d8 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0102857:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010285d:	83 ec 0c             	sub    $0xc,%esp
f0102860:	53                   	push   %ebx
f0102861:	e8 bb e5 ff ff       	call   f0100e21 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102866:	c7 04 24 d4 58 10 f0 	movl   $0xf01058d4,(%esp)
f010286d:	e8 97 07 00 00       	call   f0103009 <cprintf>
f0102872:	83 c4 10             	add    $0x10,%esp
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102875:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102878:	5b                   	pop    %ebx
f0102879:	5e                   	pop    %esi
f010287a:	5f                   	pop    %edi
f010287b:	5d                   	pop    %ebp
f010287c:	c3                   	ret    

f010287d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010287d:	55                   	push   %ebp
f010287e:	89 e5                	mov    %esp,%ebp
f0102880:	57                   	push   %edi
f0102881:	56                   	push   %esi
f0102882:	53                   	push   %ebx
f0102883:	83 ec 1c             	sub    $0x1c,%esp
f0102886:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102889:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
        uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f010288c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010288f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uint32_t end = (uint32_t) (va+len);
f0102895:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102898:	03 45 10             	add    0x10(%ebp),%eax
f010289b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        uint32_t i;
        for (i = begin; i < end; i+=PGSIZE) {
f010289e:	eb 43                	jmp    f01028e3 <user_mem_check+0x66>
                pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f01028a0:	83 ec 04             	sub    $0x4,%esp
f01028a3:	6a 00                	push   $0x0
f01028a5:	53                   	push   %ebx
f01028a6:	ff 77 5c             	pushl  0x5c(%edi)
f01028a9:	e8 d9 e5 ff ff       	call   f0100e87 <pgdir_walk>
       
                if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f01028ae:	83 c4 10             	add    $0x10,%esp
f01028b1:	85 c0                	test   %eax,%eax
f01028b3:	74 14                	je     f01028c9 <user_mem_check+0x4c>
f01028b5:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01028bb:	77 0c                	ja     f01028c9 <user_mem_check+0x4c>
f01028bd:	8b 00                	mov    (%eax),%eax
f01028bf:	a8 01                	test   $0x1,%al
f01028c1:	74 06                	je     f01028c9 <user_mem_check+0x4c>
f01028c3:	21 f0                	and    %esi,%eax
f01028c5:	39 c6                	cmp    %eax,%esi
f01028c7:	74 14                	je     f01028dd <user_mem_check+0x60>
f01028c9:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01028cc:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
                      user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f01028d0:	89 1d 5c d1 17 f0    	mov    %ebx,0xf017d15c
                      return -E_FAULT;
f01028d6:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01028db:	eb 26                	jmp    f0102903 <user_mem_check+0x86>
{
	// LAB 3: Your code here.
        uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
        uint32_t end = (uint32_t) (va+len);
        uint32_t i;
        for (i = begin; i < end; i+=PGSIZE) {
f01028dd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028e3:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01028e6:	72 b8                	jb     f01028a0 <user_mem_check+0x23>
                if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
                      user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
                      return -E_FAULT;
                }
        }
        cprintf("user_mem_check success va: %x, len: %x\n", va, len);
f01028e8:	83 ec 04             	sub    $0x4,%esp
f01028eb:	ff 75 10             	pushl  0x10(%ebp)
f01028ee:	ff 75 0c             	pushl  0xc(%ebp)
f01028f1:	68 00 59 10 f0       	push   $0xf0105900
f01028f6:	e8 0e 07 00 00       	call   f0103009 <cprintf>
	return 0;
f01028fb:	83 c4 10             	add    $0x10,%esp
f01028fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102903:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102906:	5b                   	pop    %ebx
f0102907:	5e                   	pop    %esi
f0102908:	5f                   	pop    %edi
f0102909:	5d                   	pop    %ebp
f010290a:	c3                   	ret    

f010290b <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010290b:	55                   	push   %ebp
f010290c:	89 e5                	mov    %esp,%ebp
f010290e:	53                   	push   %ebx
f010290f:	83 ec 04             	sub    $0x4,%esp
f0102912:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102915:	8b 45 14             	mov    0x14(%ebp),%eax
f0102918:	83 c8 04             	or     $0x4,%eax
f010291b:	50                   	push   %eax
f010291c:	ff 75 10             	pushl  0x10(%ebp)
f010291f:	ff 75 0c             	pushl  0xc(%ebp)
f0102922:	53                   	push   %ebx
f0102923:	e8 55 ff ff ff       	call   f010287d <user_mem_check>
f0102928:	83 c4 10             	add    $0x10,%esp
f010292b:	85 c0                	test   %eax,%eax
f010292d:	79 21                	jns    f0102950 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f010292f:	83 ec 04             	sub    $0x4,%esp
f0102932:	ff 35 5c d1 17 f0    	pushl  0xf017d15c
f0102938:	ff 73 48             	pushl  0x48(%ebx)
f010293b:	68 28 59 10 f0       	push   $0xf0105928
f0102940:	e8 c4 06 00 00       	call   f0103009 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102945:	89 1c 24             	mov    %ebx,(%esp)
f0102948:	e8 b5 05 00 00       	call   f0102f02 <env_destroy>
f010294d:	83 c4 10             	add    $0x10,%esp
	}
}
f0102950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102953:	c9                   	leave  
f0102954:	c3                   	ret    

f0102955 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102955:	55                   	push   %ebp
f0102956:	89 e5                	mov    %esp,%ebp
f0102958:	57                   	push   %edi
f0102959:	56                   	push   %esi
f010295a:	53                   	push   %ebx
f010295b:	83 ec 1c             	sub    $0x1c,%esp
f010295e:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        void *start, *end;
        struct PageInfo *newpage;
        start = ROUNDDOWN(va, PGSIZE);
f0102960:	89 d3                	mov    %edx,%ebx
f0102962:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        end = ROUNDUP(va + len, PGSIZE);
f0102968:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f010296f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102974:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for(; start < end; start += PGSIZE) {
f0102977:	eb 4c                	jmp    f01029c5 <region_alloc+0x70>
                if((newpage = page_alloc(0)) == NULL)
f0102979:	83 ec 0c             	sub    $0xc,%esp
f010297c:	6a 00                	push   $0x0
f010297e:	e8 30 e4 ff ff       	call   f0100db3 <page_alloc>
f0102983:	89 c6                	mov    %eax,%esi
f0102985:	83 c4 10             	add    $0x10,%esp
f0102988:	85 c0                	test   %eax,%eax
f010298a:	75 10                	jne    f010299c <region_alloc+0x47>
                       cprintf("page_alloc return null\n");
f010298c:	83 ec 0c             	sub    $0xc,%esp
f010298f:	68 5d 59 10 f0       	push   $0xf010595d
f0102994:	e8 70 06 00 00       	call   f0103009 <cprintf>
f0102999:	83 c4 10             	add    $0x10,%esp
                if(page_insert(e->env_pgdir, newpage, start, PTE_U | PTE_W) < 0)
f010299c:	6a 06                	push   $0x6
f010299e:	53                   	push   %ebx
f010299f:	56                   	push   %esi
f01029a0:	ff 77 5c             	pushl  0x5c(%edi)
f01029a3:	e8 27 e7 ff ff       	call   f01010cf <page_insert>
f01029a8:	83 c4 10             	add    $0x10,%esp
f01029ab:	85 c0                	test   %eax,%eax
f01029ad:	79 10                	jns    f01029bf <region_alloc+0x6a>
                       cprintf("insert failing\n");
f01029af:	83 ec 0c             	sub    $0xc,%esp
f01029b2:	68 75 59 10 f0       	push   $0xf0105975
f01029b7:	e8 4d 06 00 00       	call   f0103009 <cprintf>
f01029bc:	83 c4 10             	add    $0x10,%esp
	//   (Watch out for corner-cases!)
        void *start, *end;
        struct PageInfo *newpage;
        start = ROUNDDOWN(va, PGSIZE);
        end = ROUNDUP(va + len, PGSIZE);
        for(; start < end; start += PGSIZE) {
f01029bf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029c5:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01029c8:	72 af                	jb     f0102979 <region_alloc+0x24>
                       cprintf("page_alloc return null\n");
                if(page_insert(e->env_pgdir, newpage, start, PTE_U | PTE_W) < 0)
                       cprintf("insert failing\n");

        }
}
f01029ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029cd:	5b                   	pop    %ebx
f01029ce:	5e                   	pop    %esi
f01029cf:	5f                   	pop    %edi
f01029d0:	5d                   	pop    %ebp
f01029d1:	c3                   	ret    

f01029d2 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01029d2:	55                   	push   %ebp
f01029d3:	89 e5                	mov    %esp,%ebp
f01029d5:	8b 55 08             	mov    0x8(%ebp),%edx
f01029d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01029db:	85 d2                	test   %edx,%edx
f01029dd:	75 11                	jne    f01029f0 <envid2env+0x1e>
		*env_store = curenv;
f01029df:	a1 68 d1 17 f0       	mov    0xf017d168,%eax
f01029e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01029e7:	89 01                	mov    %eax,(%ecx)
		return 0;
f01029e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01029ee:	eb 5e                	jmp    f0102a4e <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01029f0:	89 d0                	mov    %edx,%eax
f01029f2:	25 ff 03 00 00       	and    $0x3ff,%eax
f01029f7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01029fa:	c1 e0 05             	shl    $0x5,%eax
f01029fd:	03 05 6c d1 17 f0    	add    0xf017d16c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102a03:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102a07:	74 05                	je     f0102a0e <envid2env+0x3c>
f0102a09:	39 50 48             	cmp    %edx,0x48(%eax)
f0102a0c:	74 10                	je     f0102a1e <envid2env+0x4c>
		*env_store = 0;
f0102a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a11:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102a17:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102a1c:	eb 30                	jmp    f0102a4e <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102a1e:	84 c9                	test   %cl,%cl
f0102a20:	74 22                	je     f0102a44 <envid2env+0x72>
f0102a22:	8b 15 68 d1 17 f0    	mov    0xf017d168,%edx
f0102a28:	39 d0                	cmp    %edx,%eax
f0102a2a:	74 18                	je     f0102a44 <envid2env+0x72>
f0102a2c:	8b 4a 48             	mov    0x48(%edx),%ecx
f0102a2f:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f0102a32:	74 10                	je     f0102a44 <envid2env+0x72>
		*env_store = 0;
f0102a34:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102a3d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102a42:	eb 0a                	jmp    f0102a4e <envid2env+0x7c>
	}

	*env_store = e;
f0102a44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102a47:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102a49:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a4e:	5d                   	pop    %ebp
f0102a4f:	c3                   	ret    

f0102a50 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102a50:	55                   	push   %ebp
f0102a51:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102a53:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0102a58:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102a5b:	b8 23 00 00 00       	mov    $0x23,%eax
f0102a60:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102a62:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102a64:	b0 10                	mov    $0x10,%al
f0102a66:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102a68:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102a6a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102a6c:	ea 73 2a 10 f0 08 00 	ljmp   $0x8,$0xf0102a73
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102a73:	b0 00                	mov    $0x0,%al
f0102a75:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102a78:	5d                   	pop    %ebp
f0102a79:	c3                   	ret    

f0102a7a <env_init>:
	// Set up envs array
	// LAB 3: Your code here.
         size_t i;
        //has been set to 0 when allocated?
        for(i = NENV - 1; i >= 1; i--) {
                envs[i].env_link = envs + i -1;
f0102a7a:	8b 15 6c d1 17 f0    	mov    0xf017d16c,%edx
f0102a80:	8d 82 40 7f 01 00    	lea    0x17f40(%edx),%eax
f0102a86:	83 ea 60             	sub    $0x60,%edx
f0102a89:	89 80 a4 00 00 00    	mov    %eax,0xa4(%eax)
                envs[i].env_id = 0;
f0102a8f:	c7 80 a8 00 00 00 00 	movl   $0x0,0xa8(%eax)
f0102a96:	00 00 00 
f0102a99:	83 e8 60             	sub    $0x60,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
         size_t i;
        //has been set to 0 when allocated?
        for(i = NENV - 1; i >= 1; i--) {
f0102a9c:	39 d0                	cmp    %edx,%eax
f0102a9e:	75 e9                	jne    f0102a89 <env_init+0xf>
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102aa0:	55                   	push   %ebp
f0102aa1:	89 e5                	mov    %esp,%ebp
        //has been set to 0 when allocated?
        for(i = NENV - 1; i >= 1; i--) {
                envs[i].env_link = envs + i -1;
                envs[i].env_id = 0;
        }
        envs[0].env_id = 0;
f0102aa3:	a1 6c d1 17 f0       	mov    0xf017d16c,%eax
f0102aa8:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        env_free_list = envs;
f0102aaf:	a3 70 d1 17 f0       	mov    %eax,0xf017d170
	// Per-CPU part of the initialization
	env_init_percpu();
f0102ab4:	e8 97 ff ff ff       	call   f0102a50 <env_init_percpu>
}
f0102ab9:	5d                   	pop    %ebp
f0102aba:	c3                   	ret    

f0102abb <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102abb:	55                   	push   %ebp
f0102abc:	89 e5                	mov    %esp,%ebp
f0102abe:	53                   	push   %ebx
f0102abf:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102ac2:	8b 1d 70 d1 17 f0    	mov    0xf017d170,%ebx
f0102ac8:	85 db                	test   %ebx,%ebx
f0102aca:	0f 84 4a 01 00 00    	je     f0102c1a <env_alloc+0x15f>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102ad0:	83 ec 0c             	sub    $0xc,%esp
f0102ad3:	6a 01                	push   $0x1
f0102ad5:	e8 d9 e2 ff ff       	call   f0100db3 <page_alloc>
f0102ada:	83 c4 10             	add    $0x10,%esp
f0102add:	85 c0                	test   %eax,%eax
f0102adf:	0f 84 3c 01 00 00    	je     f0102c21 <env_alloc+0x166>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        p->pp_ref++;
f0102ae5:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0102aea:	2b 05 4c de 17 f0    	sub    0xf017de4c,%eax
f0102af0:	c1 f8 03             	sar    $0x3,%eax
f0102af3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102af6:	89 c2                	mov    %eax,%edx
f0102af8:	c1 ea 0c             	shr    $0xc,%edx
f0102afb:	3b 15 44 de 17 f0    	cmp    0xf017de44,%edx
f0102b01:	72 12                	jb     f0102b15 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b03:	50                   	push   %eax
f0102b04:	68 78 51 10 f0       	push   $0xf0105178
f0102b09:	6a 56                	push   $0x56
f0102b0b:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0102b10:	e8 8b d5 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0102b15:	2d 00 00 00 10       	sub    $0x10000000,%eax
        e->env_pgdir = page2kva(p);    
f0102b1a:	89 43 5c             	mov    %eax,0x5c(%ebx)
        memcpy(e->env_pgdir, kern_pgdir, PGSIZE);  
f0102b1d:	83 ec 04             	sub    $0x4,%esp
f0102b20:	68 00 10 00 00       	push   $0x1000
f0102b25:	ff 35 48 de 17 f0    	pushl  0xf017de48
f0102b2b:	50                   	push   %eax
f0102b2c:	e8 b7 19 00 00       	call   f01044e8 <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102b31:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b34:	83 c4 10             	add    $0x10,%esp
f0102b37:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b3c:	77 15                	ja     f0102b53 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b3e:	50                   	push   %eax
f0102b3f:	68 60 52 10 f0       	push   $0xf0105260
f0102b44:	68 c2 00 00 00       	push   $0xc2
f0102b49:	68 85 59 10 f0       	push   $0xf0105985
f0102b4e:	e8 4d d5 ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102b53:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102b59:	83 ca 05             	or     $0x5,%edx
f0102b5c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102b62:	8b 43 48             	mov    0x48(%ebx),%eax
f0102b65:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102b6a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102b6f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b74:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102b77:	89 da                	mov    %ebx,%edx
f0102b79:	2b 15 6c d1 17 f0    	sub    0xf017d16c,%edx
f0102b7f:	c1 fa 05             	sar    $0x5,%edx
f0102b82:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102b88:	09 d0                	or     %edx,%eax
f0102b8a:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b90:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102b93:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102b9a:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102ba1:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102ba8:	83 ec 04             	sub    $0x4,%esp
f0102bab:	6a 44                	push   $0x44
f0102bad:	6a 00                	push   $0x0
f0102baf:	53                   	push   %ebx
f0102bb0:	e8 7e 18 00 00       	call   f0104433 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102bb5:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102bbb:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102bc1:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102bc7:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102bce:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102bd4:	8b 43 44             	mov    0x44(%ebx),%eax
f0102bd7:	a3 70 d1 17 f0       	mov    %eax,0xf017d170
        e->env_link = NULL;
f0102bdc:	c7 43 44 00 00 00 00 	movl   $0x0,0x44(%ebx)
	*newenv_store = e;
f0102be3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102be6:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102be8:	8b 53 48             	mov    0x48(%ebx),%edx
f0102beb:	a1 68 d1 17 f0       	mov    0xf017d168,%eax
f0102bf0:	83 c4 10             	add    $0x10,%esp
f0102bf3:	85 c0                	test   %eax,%eax
f0102bf5:	74 05                	je     f0102bfc <env_alloc+0x141>
f0102bf7:	8b 40 48             	mov    0x48(%eax),%eax
f0102bfa:	eb 05                	jmp    f0102c01 <env_alloc+0x146>
f0102bfc:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c01:	83 ec 04             	sub    $0x4,%esp
f0102c04:	52                   	push   %edx
f0102c05:	50                   	push   %eax
f0102c06:	68 90 59 10 f0       	push   $0xf0105990
f0102c0b:	e8 f9 03 00 00       	call   f0103009 <cprintf>
	return 0;
f0102c10:	83 c4 10             	add    $0x10,%esp
f0102c13:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c18:	eb 0c                	jmp    f0102c26 <env_alloc+0x16b>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102c1a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102c1f:	eb 05                	jmp    f0102c26 <env_alloc+0x16b>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102c21:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        e->env_link = NULL;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102c26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102c29:	c9                   	leave  
f0102c2a:	c3                   	ret    

f0102c2b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102c2b:	55                   	push   %ebp
f0102c2c:	89 e5                	mov    %esp,%ebp
f0102c2e:	57                   	push   %edi
f0102c2f:	56                   	push   %esi
f0102c30:	53                   	push   %ebx
f0102c31:	83 ec 34             	sub    $0x34,%esp
f0102c34:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
        struct Env *e;
        if(env_alloc(&e, 0) != 0)
f0102c37:	6a 00                	push   $0x0
f0102c39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102c3c:	50                   	push   %eax
f0102c3d:	e8 79 fe ff ff       	call   f0102abb <env_alloc>
f0102c42:	83 c4 10             	add    $0x10,%esp
f0102c45:	85 c0                	test   %eax,%eax
f0102c47:	74 17                	je     f0102c60 <env_create+0x35>
               panic("evn create fails!\n");
f0102c49:	83 ec 04             	sub    $0x4,%esp
f0102c4c:	68 a5 59 10 f0       	push   $0xf01059a5
f0102c51:	68 7e 01 00 00       	push   $0x17e
f0102c56:	68 85 59 10 f0       	push   $0xf0105985
f0102c5b:	e8 40 d4 ff ff       	call   f01000a0 <_panic>
        e->env_type =type;
f0102c60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c63:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c66:	89 47 50             	mov    %eax,0x50(%edi)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf *elf_img = (struct Elf *)binary;
        struct Proghdr *ph, *eph;
        if (elf_img->e_magic != ELF_MAGIC)
f0102c69:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0102c6f:	74 17                	je     f0102c88 <env_create+0x5d>
                panic("Not executable!");
f0102c71:	83 ec 04             	sub    $0x4,%esp
f0102c74:	68 b8 59 10 f0       	push   $0xf01059b8
f0102c79:	68 5e 01 00 00       	push   $0x15e
f0102c7e:	68 85 59 10 f0       	push   $0xf0105985
f0102c83:	e8 18 d4 ff ff       	call   f01000a0 <_panic>
        ph = (struct Proghdr *)(binary + elf_img->e_phoff);
f0102c88:	89 f3                	mov    %esi,%ebx
f0102c8a:	03 5e 1c             	add    0x1c(%esi),%ebx
        eph = ph + elf_img->e_phnum;
f0102c8d:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f0102c91:	c1 e0 05             	shl    $0x5,%eax
f0102c94:	01 d8                	add    %ebx,%eax
f0102c96:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        lcr3(PADDR(e->env_pgdir));
f0102c99:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c9c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ca1:	77 15                	ja     f0102cb8 <env_create+0x8d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ca3:	50                   	push   %eax
f0102ca4:	68 60 52 10 f0       	push   $0xf0105260
f0102ca9:	68 61 01 00 00       	push   $0x161
f0102cae:	68 85 59 10 f0       	push   $0xf0105985
f0102cb3:	e8 e8 d3 ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102cb8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102cbd:	0f 22 d8             	mov    %eax,%cr3
f0102cc0:	eb 37                	jmp    f0102cf9 <env_create+0xce>
        
        for(; ph < eph; ph++) {
                region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102cc2:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102cc5:	8b 53 08             	mov    0x8(%ebx),%edx
f0102cc8:	89 f8                	mov    %edi,%eax
f0102cca:	e8 86 fc ff ff       	call   f0102955 <region_alloc>
                memset((void *)ph->p_va, 0, ph->p_memsz);
f0102ccf:	83 ec 04             	sub    $0x4,%esp
f0102cd2:	ff 73 14             	pushl  0x14(%ebx)
f0102cd5:	6a 00                	push   $0x0
f0102cd7:	ff 73 08             	pushl  0x8(%ebx)
f0102cda:	e8 54 17 00 00       	call   f0104433 <memset>
                memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0102cdf:	83 c4 0c             	add    $0xc,%esp
f0102ce2:	ff 73 10             	pushl  0x10(%ebx)
f0102ce5:	89 f0                	mov    %esi,%eax
f0102ce7:	03 43 04             	add    0x4(%ebx),%eax
f0102cea:	50                   	push   %eax
f0102ceb:	ff 73 08             	pushl  0x8(%ebx)
f0102cee:	e8 f5 17 00 00       	call   f01044e8 <memcpy>
                panic("Not executable!");
        ph = (struct Proghdr *)(binary + elf_img->e_phoff);
        eph = ph + elf_img->e_phnum;
        lcr3(PADDR(e->env_pgdir));
        
        for(; ph < eph; ph++) {
f0102cf3:	83 c3 20             	add    $0x20,%ebx
f0102cf6:	83 c4 10             	add    $0x10,%esp
f0102cf9:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102cfc:	77 c4                	ja     f0102cc2 <env_create+0x97>
                region_alloc(e, (void *)ph->p_va, ph->p_memsz);
                memset((void *)ph->p_va, 0, ph->p_memsz);
                memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
        }
        lcr3(PADDR(kern_pgdir));
f0102cfe:	a1 48 de 17 f0       	mov    0xf017de48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d03:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d08:	77 15                	ja     f0102d1f <env_create+0xf4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d0a:	50                   	push   %eax
f0102d0b:	68 60 52 10 f0       	push   $0xf0105260
f0102d10:	68 68 01 00 00       	push   $0x168
f0102d15:	68 85 59 10 f0       	push   $0xf0105985
f0102d1a:	e8 81 d3 ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102d1f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d24:	0f 22 d8             	mov    %eax,%cr3
        e->env_tf.tf_eip = elf_img->e_entry;
f0102d27:	8b 46 18             	mov    0x18(%esi),%eax
f0102d2a:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
        region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0102d2d:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102d32:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102d37:	89 f8                	mov    %edi,%eax
f0102d39:	e8 17 fc ff ff       	call   f0102955 <region_alloc>
        struct Env *e;
        if(env_alloc(&e, 0) != 0)
               panic("evn create fails!\n");
        e->env_type =type;
        load_icode(e, binary);
}
f0102d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d41:	5b                   	pop    %ebx
f0102d42:	5e                   	pop    %esi
f0102d43:	5f                   	pop    %edi
f0102d44:	5d                   	pop    %ebp
f0102d45:	c3                   	ret    

f0102d46 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102d46:	55                   	push   %ebp
f0102d47:	89 e5                	mov    %esp,%ebp
f0102d49:	57                   	push   %edi
f0102d4a:	56                   	push   %esi
f0102d4b:	53                   	push   %ebx
f0102d4c:	83 ec 1c             	sub    $0x1c,%esp
f0102d4f:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102d52:	8b 15 68 d1 17 f0    	mov    0xf017d168,%edx
f0102d58:	39 d7                	cmp    %edx,%edi
f0102d5a:	75 29                	jne    f0102d85 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102d5c:	a1 48 de 17 f0       	mov    0xf017de48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d61:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d66:	77 15                	ja     f0102d7d <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d68:	50                   	push   %eax
f0102d69:	68 60 52 10 f0       	push   $0xf0105260
f0102d6e:	68 91 01 00 00       	push   $0x191
f0102d73:	68 85 59 10 f0       	push   $0xf0105985
f0102d78:	e8 23 d3 ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102d7d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d82:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102d85:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102d88:	85 d2                	test   %edx,%edx
f0102d8a:	74 05                	je     f0102d91 <env_free+0x4b>
f0102d8c:	8b 42 48             	mov    0x48(%edx),%eax
f0102d8f:	eb 05                	jmp    f0102d96 <env_free+0x50>
f0102d91:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d96:	83 ec 04             	sub    $0x4,%esp
f0102d99:	51                   	push   %ecx
f0102d9a:	50                   	push   %eax
f0102d9b:	68 c8 59 10 f0       	push   $0xf01059c8
f0102da0:	e8 64 02 00 00       	call   f0103009 <cprintf>
f0102da5:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102da8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102daf:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102db2:	89 d0                	mov    %edx,%eax
f0102db4:	c1 e0 02             	shl    $0x2,%eax
f0102db7:	89 45 d8             	mov    %eax,-0x28(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102dba:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102dbd:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102dc0:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102dc6:	0f 84 a8 00 00 00    	je     f0102e74 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102dcc:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dd2:	89 f0                	mov    %esi,%eax
f0102dd4:	c1 e8 0c             	shr    $0xc,%eax
f0102dd7:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102dda:	3b 05 44 de 17 f0    	cmp    0xf017de44,%eax
f0102de0:	72 15                	jb     f0102df7 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102de2:	56                   	push   %esi
f0102de3:	68 78 51 10 f0       	push   $0xf0105178
f0102de8:	68 a0 01 00 00       	push   $0x1a0
f0102ded:	68 85 59 10 f0       	push   $0xf0105985
f0102df2:	e8 a9 d2 ff ff       	call   f01000a0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102df7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102dfa:	c1 e0 16             	shl    $0x16,%eax
f0102dfd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e00:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102e05:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102e0c:	01 
f0102e0d:	74 17                	je     f0102e26 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102e0f:	83 ec 08             	sub    $0x8,%esp
f0102e12:	89 d8                	mov    %ebx,%eax
f0102e14:	c1 e0 0c             	shl    $0xc,%eax
f0102e17:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102e1a:	50                   	push   %eax
f0102e1b:	ff 77 5c             	pushl  0x5c(%edi)
f0102e1e:	e8 5b e2 ff ff       	call   f010107e <page_remove>
f0102e23:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e26:	83 c3 01             	add    $0x1,%ebx
f0102e29:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102e2f:	75 d4                	jne    f0102e05 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102e31:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e34:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102e37:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102e41:	3b 05 44 de 17 f0    	cmp    0xf017de44,%eax
f0102e47:	72 14                	jb     f0102e5d <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102e49:	83 ec 04             	sub    $0x4,%esp
f0102e4c:	68 84 52 10 f0       	push   $0xf0105284
f0102e51:	6a 4f                	push   $0x4f
f0102e53:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0102e58:	e8 43 d2 ff ff       	call   f01000a0 <_panic>
		page_decref(pa2page(pa));
f0102e5d:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102e60:	a1 4c de 17 f0       	mov    0xf017de4c,%eax
f0102e65:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e68:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102e6b:	50                   	push   %eax
f0102e6c:	e8 ef df ff ff       	call   f0100e60 <page_decref>
f0102e71:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102e74:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102e78:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e7b:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102e80:	0f 85 29 ff ff ff    	jne    f0102daf <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102e86:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e89:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e8e:	77 15                	ja     f0102ea5 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e90:	50                   	push   %eax
f0102e91:	68 60 52 10 f0       	push   $0xf0105260
f0102e96:	68 ae 01 00 00       	push   $0x1ae
f0102e9b:	68 85 59 10 f0       	push   $0xf0105985
f0102ea0:	e8 fb d1 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = 0;
f0102ea5:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0102eac:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102eb1:	c1 e8 0c             	shr    $0xc,%eax
f0102eb4:	3b 05 44 de 17 f0    	cmp    0xf017de44,%eax
f0102eba:	72 14                	jb     f0102ed0 <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102ebc:	83 ec 04             	sub    $0x4,%esp
f0102ebf:	68 84 52 10 f0       	push   $0xf0105284
f0102ec4:	6a 4f                	push   $0x4f
f0102ec6:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0102ecb:	e8 d0 d1 ff ff       	call   f01000a0 <_panic>
	page_decref(pa2page(pa));
f0102ed0:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102ed3:	8b 15 4c de 17 f0    	mov    0xf017de4c,%edx
f0102ed9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102edc:	50                   	push   %eax
f0102edd:	e8 7e df ff ff       	call   f0100e60 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102ee2:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102ee9:	a1 70 d1 17 f0       	mov    0xf017d170,%eax
f0102eee:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102ef1:	89 3d 70 d1 17 f0    	mov    %edi,0xf017d170
f0102ef7:	83 c4 10             	add    $0x10,%esp
}
f0102efa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102efd:	5b                   	pop    %ebx
f0102efe:	5e                   	pop    %esi
f0102eff:	5f                   	pop    %edi
f0102f00:	5d                   	pop    %ebp
f0102f01:	c3                   	ret    

f0102f02 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102f02:	55                   	push   %ebp
f0102f03:	89 e5                	mov    %esp,%ebp
f0102f05:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102f08:	ff 75 08             	pushl  0x8(%ebp)
f0102f0b:	e8 36 fe ff ff       	call   f0102d46 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102f10:	c7 04 24 ec 59 10 f0 	movl   $0xf01059ec,(%esp)
f0102f17:	e8 ed 00 00 00       	call   f0103009 <cprintf>
f0102f1c:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102f1f:	83 ec 0c             	sub    $0xc,%esp
f0102f22:	6a 00                	push   $0x0
f0102f24:	e8 f9 d8 ff ff       	call   f0100822 <monitor>
f0102f29:	83 c4 10             	add    $0x10,%esp
f0102f2c:	eb f1                	jmp    f0102f1f <env_destroy+0x1d>

f0102f2e <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102f2e:	55                   	push   %ebp
f0102f2f:	89 e5                	mov    %esp,%ebp
f0102f31:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102f34:	8b 65 08             	mov    0x8(%ebp),%esp
f0102f37:	61                   	popa   
f0102f38:	07                   	pop    %es
f0102f39:	1f                   	pop    %ds
f0102f3a:	83 c4 08             	add    $0x8,%esp
f0102f3d:	cf                   	iret   
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");

	panic("iret failed");  /* mostly to placate the compiler */
f0102f3e:	68 de 59 10 f0       	push   $0xf01059de
f0102f43:	68 d7 01 00 00       	push   $0x1d7
f0102f48:	68 85 59 10 f0       	push   $0xf0105985
f0102f4d:	e8 4e d1 ff ff       	call   f01000a0 <_panic>

f0102f52 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102f52:	55                   	push   %ebp
f0102f53:	89 e5                	mov    %esp,%ebp
f0102f55:	83 ec 08             	sub    $0x8,%esp
f0102f58:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        if( e != curenv) {
f0102f5b:	3b 05 68 d1 17 f0    	cmp    0xf017d168,%eax
f0102f61:	74 37                	je     f0102f9a <env_run+0x48>
                
             //   if(curenv->env_status == ENV_RUNNING)
             //           curenv->env_status = ENV_RUNNABLE;
                curenv = e;
f0102f63:	a3 68 d1 17 f0       	mov    %eax,0xf017d168
                curenv->env_runs++;
f0102f68:	83 40 58 01          	addl   $0x1,0x58(%eax)
                curenv->env_status = ENV_RUNNING;
f0102f6c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
                lcr3(PADDR(curenv->env_pgdir));
f0102f73:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f76:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f7b:	77 15                	ja     f0102f92 <env_run+0x40>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f7d:	50                   	push   %eax
f0102f7e:	68 60 52 10 f0       	push   $0xf0105260
f0102f83:	68 fc 01 00 00       	push   $0x1fc
f0102f88:	68 85 59 10 f0       	push   $0xf0105985
f0102f8d:	e8 0e d1 ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102f92:	05 00 00 00 10       	add    $0x10000000,%eax
f0102f97:	0f 22 d8             	mov    %eax,%cr3
        }
        env_pop_tf(&curenv->env_tf);
f0102f9a:	83 ec 0c             	sub    $0xc,%esp
f0102f9d:	ff 35 68 d1 17 f0    	pushl  0xf017d168
f0102fa3:	e8 86 ff ff ff       	call   f0102f2e <env_pop_tf>

f0102fa8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102fa8:	55                   	push   %ebp
f0102fa9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fab:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fb3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102fb4:	b2 71                	mov    $0x71,%dl
f0102fb6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102fb7:	0f b6 c0             	movzbl %al,%eax
}
f0102fba:	5d                   	pop    %ebp
f0102fbb:	c3                   	ret    

f0102fbc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102fbc:	55                   	push   %ebp
f0102fbd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fbf:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fc4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fc7:	ee                   	out    %al,(%dx)
f0102fc8:	b2 71                	mov    $0x71,%dl
f0102fca:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fcd:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102fce:	5d                   	pop    %ebp
f0102fcf:	c3                   	ret    

f0102fd0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102fd0:	55                   	push   %ebp
f0102fd1:	89 e5                	mov    %esp,%ebp
f0102fd3:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102fd6:	ff 75 08             	pushl  0x8(%ebp)
f0102fd9:	e8 17 d6 ff ff       	call   f01005f5 <cputchar>
f0102fde:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0102fe1:	c9                   	leave  
f0102fe2:	c3                   	ret    

f0102fe3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102fe3:	55                   	push   %ebp
f0102fe4:	89 e5                	mov    %esp,%ebp
f0102fe6:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102fe9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102ff0:	ff 75 0c             	pushl  0xc(%ebp)
f0102ff3:	ff 75 08             	pushl  0x8(%ebp)
f0102ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102ff9:	50                   	push   %eax
f0102ffa:	68 d0 2f 10 f0       	push   $0xf0102fd0
f0102fff:	e8 bc 0d 00 00       	call   f0103dc0 <vprintfmt>
	return cnt;
}
f0103004:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103007:	c9                   	leave  
f0103008:	c3                   	ret    

f0103009 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103009:	55                   	push   %ebp
f010300a:	89 e5                	mov    %esp,%ebp
f010300c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010300f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103012:	50                   	push   %eax
f0103013:	ff 75 08             	pushl  0x8(%ebp)
f0103016:	e8 c8 ff ff ff       	call   f0102fe3 <vcprintf>
	va_end(ap);

	return cnt;
}
f010301b:	c9                   	leave  
f010301c:	c3                   	ret    

f010301d <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010301d:	55                   	push   %ebp
f010301e:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103020:	b8 c0 d9 17 f0       	mov    $0xf017d9c0,%eax
f0103025:	c7 05 c4 d9 17 f0 00 	movl   $0xf0000000,0xf017d9c4
f010302c:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010302f:	66 c7 05 c8 d9 17 f0 	movw   $0x10,0xf017d9c8
f0103036:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103038:	66 c7 05 48 b3 11 f0 	movw   $0x68,0xf011b348
f010303f:	68 00 
f0103041:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f0103047:	89 c2                	mov    %eax,%edx
f0103049:	c1 ea 10             	shr    $0x10,%edx
f010304c:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103052:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f0103059:	c1 e8 18             	shr    $0x18,%eax
f010305c:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103061:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103068:	b8 28 00 00 00       	mov    $0x28,%eax
f010306d:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103070:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f0103075:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103078:	5d                   	pop    %ebp
f0103079:	c3                   	ret    

f010307a <trap_init>:
}


void
trap_init(void)
{
f010307a:	55                   	push   %ebp
f010307b:	89 e5                	mov    %esp,%ebp
        extern void i17();
        extern void i18();
        extern void i19();
        extern void i20();
	
        SETGATE(idt[0], 0, GD_KT, i0, 0);
f010307d:	b8 78 37 10 f0       	mov    $0xf0103778,%eax
f0103082:	66 a3 80 d1 17 f0    	mov    %ax,0xf017d180
f0103088:	66 c7 05 82 d1 17 f0 	movw   $0x8,0xf017d182
f010308f:	08 00 
f0103091:	c6 05 84 d1 17 f0 00 	movb   $0x0,0xf017d184
f0103098:	c6 05 85 d1 17 f0 8e 	movb   $0x8e,0xf017d185
f010309f:	c1 e8 10             	shr    $0x10,%eax
f01030a2:	66 a3 86 d1 17 f0    	mov    %ax,0xf017d186
        SETGATE(idt[1], 0, GD_KT, i1, 0);
f01030a8:	b8 7e 37 10 f0       	mov    $0xf010377e,%eax
f01030ad:	66 a3 88 d1 17 f0    	mov    %ax,0xf017d188
f01030b3:	66 c7 05 8a d1 17 f0 	movw   $0x8,0xf017d18a
f01030ba:	08 00 
f01030bc:	c6 05 8c d1 17 f0 00 	movb   $0x0,0xf017d18c
f01030c3:	c6 05 8d d1 17 f0 8e 	movb   $0x8e,0xf017d18d
f01030ca:	c1 e8 10             	shr    $0x10,%eax
f01030cd:	66 a3 8e d1 17 f0    	mov    %ax,0xf017d18e
        SETGATE(idt[2], 0, GD_KT, i2, 0);
f01030d3:	b8 84 37 10 f0       	mov    $0xf0103784,%eax
f01030d8:	66 a3 90 d1 17 f0    	mov    %ax,0xf017d190
f01030de:	66 c7 05 92 d1 17 f0 	movw   $0x8,0xf017d192
f01030e5:	08 00 
f01030e7:	c6 05 94 d1 17 f0 00 	movb   $0x0,0xf017d194
f01030ee:	c6 05 95 d1 17 f0 8e 	movb   $0x8e,0xf017d195
f01030f5:	c1 e8 10             	shr    $0x10,%eax
f01030f8:	66 a3 96 d1 17 f0    	mov    %ax,0xf017d196
        SETGATE(idt[3], 0, GD_KT, i3, 3);
f01030fe:	b8 8a 37 10 f0       	mov    $0xf010378a,%eax
f0103103:	66 a3 98 d1 17 f0    	mov    %ax,0xf017d198
f0103109:	66 c7 05 9a d1 17 f0 	movw   $0x8,0xf017d19a
f0103110:	08 00 
f0103112:	c6 05 9c d1 17 f0 00 	movb   $0x0,0xf017d19c
f0103119:	c6 05 9d d1 17 f0 ee 	movb   $0xee,0xf017d19d
f0103120:	c1 e8 10             	shr    $0x10,%eax
f0103123:	66 a3 9e d1 17 f0    	mov    %ax,0xf017d19e
        SETGATE(idt[4], 0, GD_KT, i4, 0);
f0103129:	b8 90 37 10 f0       	mov    $0xf0103790,%eax
f010312e:	66 a3 a0 d1 17 f0    	mov    %ax,0xf017d1a0
f0103134:	66 c7 05 a2 d1 17 f0 	movw   $0x8,0xf017d1a2
f010313b:	08 00 
f010313d:	c6 05 a4 d1 17 f0 00 	movb   $0x0,0xf017d1a4
f0103144:	c6 05 a5 d1 17 f0 8e 	movb   $0x8e,0xf017d1a5
f010314b:	c1 e8 10             	shr    $0x10,%eax
f010314e:	66 a3 a6 d1 17 f0    	mov    %ax,0xf017d1a6
        SETGATE(idt[5], 0, GD_KT, i5, 0);
f0103154:	b8 96 37 10 f0       	mov    $0xf0103796,%eax
f0103159:	66 a3 a8 d1 17 f0    	mov    %ax,0xf017d1a8
f010315f:	66 c7 05 aa d1 17 f0 	movw   $0x8,0xf017d1aa
f0103166:	08 00 
f0103168:	c6 05 ac d1 17 f0 00 	movb   $0x0,0xf017d1ac
f010316f:	c6 05 ad d1 17 f0 8e 	movb   $0x8e,0xf017d1ad
f0103176:	c1 e8 10             	shr    $0x10,%eax
f0103179:	66 a3 ae d1 17 f0    	mov    %ax,0xf017d1ae
        SETGATE(idt[6], 0, GD_KT, i6, 0);
f010317f:	b8 9c 37 10 f0       	mov    $0xf010379c,%eax
f0103184:	66 a3 b0 d1 17 f0    	mov    %ax,0xf017d1b0
f010318a:	66 c7 05 b2 d1 17 f0 	movw   $0x8,0xf017d1b2
f0103191:	08 00 
f0103193:	c6 05 b4 d1 17 f0 00 	movb   $0x0,0xf017d1b4
f010319a:	c6 05 b5 d1 17 f0 8e 	movb   $0x8e,0xf017d1b5
f01031a1:	c1 e8 10             	shr    $0x10,%eax
f01031a4:	66 a3 b6 d1 17 f0    	mov    %ax,0xf017d1b6
        SETGATE(idt[7], 0, GD_KT, i7, 0);
f01031aa:	b8 a2 37 10 f0       	mov    $0xf01037a2,%eax
f01031af:	66 a3 b8 d1 17 f0    	mov    %ax,0xf017d1b8
f01031b5:	66 c7 05 ba d1 17 f0 	movw   $0x8,0xf017d1ba
f01031bc:	08 00 
f01031be:	c6 05 bc d1 17 f0 00 	movb   $0x0,0xf017d1bc
f01031c5:	c6 05 bd d1 17 f0 8e 	movb   $0x8e,0xf017d1bd
f01031cc:	c1 e8 10             	shr    $0x10,%eax
f01031cf:	66 a3 be d1 17 f0    	mov    %ax,0xf017d1be
        SETGATE(idt[8], 0, GD_KT, i8, 0);
f01031d5:	b8 a8 37 10 f0       	mov    $0xf01037a8,%eax
f01031da:	66 a3 c0 d1 17 f0    	mov    %ax,0xf017d1c0
f01031e0:	66 c7 05 c2 d1 17 f0 	movw   $0x8,0xf017d1c2
f01031e7:	08 00 
f01031e9:	c6 05 c4 d1 17 f0 00 	movb   $0x0,0xf017d1c4
f01031f0:	c6 05 c5 d1 17 f0 8e 	movb   $0x8e,0xf017d1c5
f01031f7:	c1 e8 10             	shr    $0x10,%eax
f01031fa:	66 a3 c6 d1 17 f0    	mov    %ax,0xf017d1c6
        SETGATE(idt[9], 0, GD_KT, i9, 0);
f0103200:	b8 ac 37 10 f0       	mov    $0xf01037ac,%eax
f0103205:	66 a3 c8 d1 17 f0    	mov    %ax,0xf017d1c8
f010320b:	66 c7 05 ca d1 17 f0 	movw   $0x8,0xf017d1ca
f0103212:	08 00 
f0103214:	c6 05 cc d1 17 f0 00 	movb   $0x0,0xf017d1cc
f010321b:	c6 05 cd d1 17 f0 8e 	movb   $0x8e,0xf017d1cd
f0103222:	c1 e8 10             	shr    $0x10,%eax
f0103225:	66 a3 ce d1 17 f0    	mov    %ax,0xf017d1ce
        SETGATE(idt[10], 0, GD_KT, i10, 0);
f010322b:	b8 b2 37 10 f0       	mov    $0xf01037b2,%eax
f0103230:	66 a3 d0 d1 17 f0    	mov    %ax,0xf017d1d0
f0103236:	66 c7 05 d2 d1 17 f0 	movw   $0x8,0xf017d1d2
f010323d:	08 00 
f010323f:	c6 05 d4 d1 17 f0 00 	movb   $0x0,0xf017d1d4
f0103246:	c6 05 d5 d1 17 f0 8e 	movb   $0x8e,0xf017d1d5
f010324d:	c1 e8 10             	shr    $0x10,%eax
f0103250:	66 a3 d6 d1 17 f0    	mov    %ax,0xf017d1d6
        SETGATE(idt[11], 0, GD_KT, i11, 0);
f0103256:	b8 b6 37 10 f0       	mov    $0xf01037b6,%eax
f010325b:	66 a3 d8 d1 17 f0    	mov    %ax,0xf017d1d8
f0103261:	66 c7 05 da d1 17 f0 	movw   $0x8,0xf017d1da
f0103268:	08 00 
f010326a:	c6 05 dc d1 17 f0 00 	movb   $0x0,0xf017d1dc
f0103271:	c6 05 dd d1 17 f0 8e 	movb   $0x8e,0xf017d1dd
f0103278:	c1 e8 10             	shr    $0x10,%eax
f010327b:	66 a3 de d1 17 f0    	mov    %ax,0xf017d1de
        SETGATE(idt[12], 0, GD_KT, i12, 0);
f0103281:	b8 ba 37 10 f0       	mov    $0xf01037ba,%eax
f0103286:	66 a3 e0 d1 17 f0    	mov    %ax,0xf017d1e0
f010328c:	66 c7 05 e2 d1 17 f0 	movw   $0x8,0xf017d1e2
f0103293:	08 00 
f0103295:	c6 05 e4 d1 17 f0 00 	movb   $0x0,0xf017d1e4
f010329c:	c6 05 e5 d1 17 f0 8e 	movb   $0x8e,0xf017d1e5
f01032a3:	c1 e8 10             	shr    $0x10,%eax
f01032a6:	66 a3 e6 d1 17 f0    	mov    %ax,0xf017d1e6
        SETGATE(idt[13], 0, GD_KT, i13, 0);
f01032ac:	b8 be 37 10 f0       	mov    $0xf01037be,%eax
f01032b1:	66 a3 e8 d1 17 f0    	mov    %ax,0xf017d1e8
f01032b7:	66 c7 05 ea d1 17 f0 	movw   $0x8,0xf017d1ea
f01032be:	08 00 
f01032c0:	c6 05 ec d1 17 f0 00 	movb   $0x0,0xf017d1ec
f01032c7:	c6 05 ed d1 17 f0 8e 	movb   $0x8e,0xf017d1ed
f01032ce:	c1 e8 10             	shr    $0x10,%eax
f01032d1:	66 a3 ee d1 17 f0    	mov    %ax,0xf017d1ee
        SETGATE(idt[14], 0, GD_KT, i14, 0);
f01032d7:	b8 c2 37 10 f0       	mov    $0xf01037c2,%eax
f01032dc:	66 a3 f0 d1 17 f0    	mov    %ax,0xf017d1f0
f01032e2:	66 c7 05 f2 d1 17 f0 	movw   $0x8,0xf017d1f2
f01032e9:	08 00 
f01032eb:	c6 05 f4 d1 17 f0 00 	movb   $0x0,0xf017d1f4
f01032f2:	c6 05 f5 d1 17 f0 8e 	movb   $0x8e,0xf017d1f5
f01032f9:	c1 e8 10             	shr    $0x10,%eax
f01032fc:	66 a3 f6 d1 17 f0    	mov    %ax,0xf017d1f6
        SETGATE(idt[16], 0, GD_KT, i16, 0);
f0103302:	b8 cc 37 10 f0       	mov    $0xf01037cc,%eax
f0103307:	66 a3 00 d2 17 f0    	mov    %ax,0xf017d200
f010330d:	66 c7 05 02 d2 17 f0 	movw   $0x8,0xf017d202
f0103314:	08 00 
f0103316:	c6 05 04 d2 17 f0 00 	movb   $0x0,0xf017d204
f010331d:	c6 05 05 d2 17 f0 8e 	movb   $0x8e,0xf017d205
f0103324:	c1 e8 10             	shr    $0x10,%eax
f0103327:	66 a3 06 d2 17 f0    	mov    %ax,0xf017d206
        SETGATE(idt[17], 0, GD_KT, i17, 0);
f010332d:	b8 d2 37 10 f0       	mov    $0xf01037d2,%eax
f0103332:	66 a3 08 d2 17 f0    	mov    %ax,0xf017d208
f0103338:	66 c7 05 0a d2 17 f0 	movw   $0x8,0xf017d20a
f010333f:	08 00 
f0103341:	c6 05 0c d2 17 f0 00 	movb   $0x0,0xf017d20c
f0103348:	c6 05 0d d2 17 f0 8e 	movb   $0x8e,0xf017d20d
f010334f:	c1 e8 10             	shr    $0x10,%eax
f0103352:	66 a3 0e d2 17 f0    	mov    %ax,0xf017d20e
        SETGATE(idt[18], 0, GD_KT, i18, 0);
f0103358:	b8 d6 37 10 f0       	mov    $0xf01037d6,%eax
f010335d:	66 a3 10 d2 17 f0    	mov    %ax,0xf017d210
f0103363:	66 c7 05 12 d2 17 f0 	movw   $0x8,0xf017d212
f010336a:	08 00 
f010336c:	c6 05 14 d2 17 f0 00 	movb   $0x0,0xf017d214
f0103373:	c6 05 15 d2 17 f0 8e 	movb   $0x8e,0xf017d215
f010337a:	c1 e8 10             	shr    $0x10,%eax
f010337d:	66 a3 16 d2 17 f0    	mov    %ax,0xf017d216
        SETGATE(idt[19], 0, GD_KT, i19, 0);
f0103383:	b8 dc 37 10 f0       	mov    $0xf01037dc,%eax
f0103388:	66 a3 18 d2 17 f0    	mov    %ax,0xf017d218
f010338e:	66 c7 05 1a d2 17 f0 	movw   $0x8,0xf017d21a
f0103395:	08 00 
f0103397:	c6 05 1c d2 17 f0 00 	movb   $0x0,0xf017d21c
f010339e:	c6 05 1d d2 17 f0 8e 	movb   $0x8e,0xf017d21d
f01033a5:	c1 e8 10             	shr    $0x10,%eax
f01033a8:	66 a3 1e d2 17 f0    	mov    %ax,0xf017d21e
        SETGATE(idt[48], 0, GD_KT, i20, 3);
f01033ae:	b8 e2 37 10 f0       	mov    $0xf01037e2,%eax
f01033b3:	66 a3 00 d3 17 f0    	mov    %ax,0xf017d300
f01033b9:	66 c7 05 02 d3 17 f0 	movw   $0x8,0xf017d302
f01033c0:	08 00 
f01033c2:	c6 05 04 d3 17 f0 00 	movb   $0x0,0xf017d304
f01033c9:	c6 05 05 d3 17 f0 ee 	movb   $0xee,0xf017d305
f01033d0:	c1 e8 10             	shr    $0x10,%eax
f01033d3:	66 a3 06 d3 17 f0    	mov    %ax,0xf017d306
	// Per-CPU setup 
	trap_init_percpu();
f01033d9:	e8 3f fc ff ff       	call   f010301d <trap_init_percpu>
}
f01033de:	5d                   	pop    %ebp
f01033df:	c3                   	ret    

f01033e0 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01033e0:	55                   	push   %ebp
f01033e1:	89 e5                	mov    %esp,%ebp
f01033e3:	53                   	push   %ebx
f01033e4:	83 ec 0c             	sub    $0xc,%esp
f01033e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01033ea:	ff 33                	pushl  (%ebx)
f01033ec:	68 22 5a 10 f0       	push   $0xf0105a22
f01033f1:	e8 13 fc ff ff       	call   f0103009 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01033f6:	83 c4 08             	add    $0x8,%esp
f01033f9:	ff 73 04             	pushl  0x4(%ebx)
f01033fc:	68 31 5a 10 f0       	push   $0xf0105a31
f0103401:	e8 03 fc ff ff       	call   f0103009 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103406:	83 c4 08             	add    $0x8,%esp
f0103409:	ff 73 08             	pushl  0x8(%ebx)
f010340c:	68 40 5a 10 f0       	push   $0xf0105a40
f0103411:	e8 f3 fb ff ff       	call   f0103009 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103416:	83 c4 08             	add    $0x8,%esp
f0103419:	ff 73 0c             	pushl  0xc(%ebx)
f010341c:	68 4f 5a 10 f0       	push   $0xf0105a4f
f0103421:	e8 e3 fb ff ff       	call   f0103009 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103426:	83 c4 08             	add    $0x8,%esp
f0103429:	ff 73 10             	pushl  0x10(%ebx)
f010342c:	68 5e 5a 10 f0       	push   $0xf0105a5e
f0103431:	e8 d3 fb ff ff       	call   f0103009 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103436:	83 c4 08             	add    $0x8,%esp
f0103439:	ff 73 14             	pushl  0x14(%ebx)
f010343c:	68 6d 5a 10 f0       	push   $0xf0105a6d
f0103441:	e8 c3 fb ff ff       	call   f0103009 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103446:	83 c4 08             	add    $0x8,%esp
f0103449:	ff 73 18             	pushl  0x18(%ebx)
f010344c:	68 7c 5a 10 f0       	push   $0xf0105a7c
f0103451:	e8 b3 fb ff ff       	call   f0103009 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103456:	83 c4 08             	add    $0x8,%esp
f0103459:	ff 73 1c             	pushl  0x1c(%ebx)
f010345c:	68 8b 5a 10 f0       	push   $0xf0105a8b
f0103461:	e8 a3 fb ff ff       	call   f0103009 <cprintf>
f0103466:	83 c4 10             	add    $0x10,%esp
}
f0103469:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010346c:	c9                   	leave  
f010346d:	c3                   	ret    

f010346e <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010346e:	55                   	push   %ebp
f010346f:	89 e5                	mov    %esp,%ebp
f0103471:	56                   	push   %esi
f0103472:	53                   	push   %ebx
f0103473:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103476:	83 ec 08             	sub    $0x8,%esp
f0103479:	53                   	push   %ebx
f010347a:	68 d4 5b 10 f0       	push   $0xf0105bd4
f010347f:	e8 85 fb ff ff       	call   f0103009 <cprintf>
	print_regs(&tf->tf_regs);
f0103484:	89 1c 24             	mov    %ebx,(%esp)
f0103487:	e8 54 ff ff ff       	call   f01033e0 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010348c:	83 c4 08             	add    $0x8,%esp
f010348f:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103493:	50                   	push   %eax
f0103494:	68 dc 5a 10 f0       	push   $0xf0105adc
f0103499:	e8 6b fb ff ff       	call   f0103009 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010349e:	83 c4 08             	add    $0x8,%esp
f01034a1:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01034a5:	50                   	push   %eax
f01034a6:	68 ef 5a 10 f0       	push   $0xf0105aef
f01034ab:	e8 59 fb ff ff       	call   f0103009 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01034b0:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01034b3:	83 c4 10             	add    $0x10,%esp
f01034b6:	83 f8 13             	cmp    $0x13,%eax
f01034b9:	77 09                	ja     f01034c4 <print_trapframe+0x56>
		return excnames[trapno];
f01034bb:	8b 14 85 c0 5d 10 f0 	mov    -0xfefa240(,%eax,4),%edx
f01034c2:	eb 10                	jmp    f01034d4 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f01034c4:	83 f8 30             	cmp    $0x30,%eax
f01034c7:	b9 a6 5a 10 f0       	mov    $0xf0105aa6,%ecx
f01034cc:	ba 9a 5a 10 f0       	mov    $0xf0105a9a,%edx
f01034d1:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01034d4:	83 ec 04             	sub    $0x4,%esp
f01034d7:	52                   	push   %edx
f01034d8:	50                   	push   %eax
f01034d9:	68 02 5b 10 f0       	push   $0xf0105b02
f01034de:	e8 26 fb ff ff       	call   f0103009 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01034e3:	83 c4 10             	add    $0x10,%esp
f01034e6:	3b 1d 80 d9 17 f0    	cmp    0xf017d980,%ebx
f01034ec:	75 1a                	jne    f0103508 <print_trapframe+0x9a>
f01034ee:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01034f2:	75 14                	jne    f0103508 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01034f4:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01034f7:	83 ec 08             	sub    $0x8,%esp
f01034fa:	50                   	push   %eax
f01034fb:	68 14 5b 10 f0       	push   $0xf0105b14
f0103500:	e8 04 fb ff ff       	call   f0103009 <cprintf>
f0103505:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103508:	83 ec 08             	sub    $0x8,%esp
f010350b:	ff 73 2c             	pushl  0x2c(%ebx)
f010350e:	68 23 5b 10 f0       	push   $0xf0105b23
f0103513:	e8 f1 fa ff ff       	call   f0103009 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103518:	83 c4 10             	add    $0x10,%esp
f010351b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010351f:	75 49                	jne    f010356a <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103521:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103524:	89 c2                	mov    %eax,%edx
f0103526:	83 e2 01             	and    $0x1,%edx
f0103529:	ba c0 5a 10 f0       	mov    $0xf0105ac0,%edx
f010352e:	b9 b5 5a 10 f0       	mov    $0xf0105ab5,%ecx
f0103533:	0f 44 ca             	cmove  %edx,%ecx
f0103536:	89 c2                	mov    %eax,%edx
f0103538:	83 e2 02             	and    $0x2,%edx
f010353b:	ba d2 5a 10 f0       	mov    $0xf0105ad2,%edx
f0103540:	be cc 5a 10 f0       	mov    $0xf0105acc,%esi
f0103545:	0f 45 d6             	cmovne %esi,%edx
f0103548:	83 e0 04             	and    $0x4,%eax
f010354b:	be ff 5b 10 f0       	mov    $0xf0105bff,%esi
f0103550:	b8 d7 5a 10 f0       	mov    $0xf0105ad7,%eax
f0103555:	0f 44 c6             	cmove  %esi,%eax
f0103558:	51                   	push   %ecx
f0103559:	52                   	push   %edx
f010355a:	50                   	push   %eax
f010355b:	68 31 5b 10 f0       	push   $0xf0105b31
f0103560:	e8 a4 fa ff ff       	call   f0103009 <cprintf>
f0103565:	83 c4 10             	add    $0x10,%esp
f0103568:	eb 10                	jmp    f010357a <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010356a:	83 ec 0c             	sub    $0xc,%esp
f010356d:	68 44 51 10 f0       	push   $0xf0105144
f0103572:	e8 92 fa ff ff       	call   f0103009 <cprintf>
f0103577:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010357a:	83 ec 08             	sub    $0x8,%esp
f010357d:	ff 73 30             	pushl  0x30(%ebx)
f0103580:	68 40 5b 10 f0       	push   $0xf0105b40
f0103585:	e8 7f fa ff ff       	call   f0103009 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010358a:	83 c4 08             	add    $0x8,%esp
f010358d:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103591:	50                   	push   %eax
f0103592:	68 4f 5b 10 f0       	push   $0xf0105b4f
f0103597:	e8 6d fa ff ff       	call   f0103009 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010359c:	83 c4 08             	add    $0x8,%esp
f010359f:	ff 73 38             	pushl  0x38(%ebx)
f01035a2:	68 62 5b 10 f0       	push   $0xf0105b62
f01035a7:	e8 5d fa ff ff       	call   f0103009 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01035ac:	83 c4 10             	add    $0x10,%esp
f01035af:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01035b3:	74 25                	je     f01035da <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01035b5:	83 ec 08             	sub    $0x8,%esp
f01035b8:	ff 73 3c             	pushl  0x3c(%ebx)
f01035bb:	68 71 5b 10 f0       	push   $0xf0105b71
f01035c0:	e8 44 fa ff ff       	call   f0103009 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01035c5:	83 c4 08             	add    $0x8,%esp
f01035c8:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01035cc:	50                   	push   %eax
f01035cd:	68 80 5b 10 f0       	push   $0xf0105b80
f01035d2:	e8 32 fa ff ff       	call   f0103009 <cprintf>
f01035d7:	83 c4 10             	add    $0x10,%esp
	}
}
f01035da:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01035dd:	5b                   	pop    %ebx
f01035de:	5e                   	pop    %esi
f01035df:	5d                   	pop    %ebp
f01035e0:	c3                   	ret    

f01035e1 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01035e1:	55                   	push   %ebp
f01035e2:	89 e5                	mov    %esp,%ebp
f01035e4:	53                   	push   %ebx
f01035e5:	83 ec 04             	sub    $0x4,%esp
f01035e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01035eb:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
        if ((tf->tf_cs & 3) == 0)  
f01035ee:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01035f2:	75 17                	jne    f010360b <page_fault_handler+0x2a>
                panic("Kernel page fault!");
f01035f4:	83 ec 04             	sub    $0x4,%esp
f01035f7:	68 93 5b 10 f0       	push   $0xf0105b93
f01035fc:	68 03 01 00 00       	push   $0x103
f0103601:	68 a6 5b 10 f0       	push   $0xf0105ba6
f0103606:	e8 95 ca ff ff       	call   f01000a0 <_panic>
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010360b:	ff 73 30             	pushl  0x30(%ebx)
f010360e:	50                   	push   %eax
f010360f:	a1 68 d1 17 f0       	mov    0xf017d168,%eax
f0103614:	ff 70 48             	pushl  0x48(%eax)
f0103617:	68 4c 5d 10 f0       	push   $0xf0105d4c
f010361c:	e8 e8 f9 ff ff       	call   f0103009 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103621:	89 1c 24             	mov    %ebx,(%esp)
f0103624:	e8 45 fe ff ff       	call   f010346e <print_trapframe>
	env_destroy(curenv);
f0103629:	83 c4 04             	add    $0x4,%esp
f010362c:	ff 35 68 d1 17 f0    	pushl  0xf017d168
f0103632:	e8 cb f8 ff ff       	call   f0102f02 <env_destroy>
f0103637:	83 c4 10             	add    $0x10,%esp
}
f010363a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010363d:	c9                   	leave  
f010363e:	c3                   	ret    

f010363f <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010363f:	55                   	push   %ebp
f0103640:	89 e5                	mov    %esp,%ebp
f0103642:	57                   	push   %edi
f0103643:	56                   	push   %esi
f0103644:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103647:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103648:	9c                   	pushf  
f0103649:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010364a:	f6 c4 02             	test   $0x2,%ah
f010364d:	74 19                	je     f0103668 <trap+0x29>
f010364f:	68 b2 5b 10 f0       	push   $0xf0105bb2
f0103654:	68 84 4e 10 f0       	push   $0xf0104e84
f0103659:	68 dc 00 00 00       	push   $0xdc
f010365e:	68 a6 5b 10 f0       	push   $0xf0105ba6
f0103663:	e8 38 ca ff ff       	call   f01000a0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103668:	83 ec 08             	sub    $0x8,%esp
f010366b:	56                   	push   %esi
f010366c:	68 cb 5b 10 f0       	push   $0xf0105bcb
f0103671:	e8 93 f9 ff ff       	call   f0103009 <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f0103676:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010367a:	83 e0 03             	and    $0x3,%eax
f010367d:	83 c4 10             	add    $0x10,%esp
f0103680:	66 83 f8 03          	cmp    $0x3,%ax
f0103684:	75 31                	jne    f01036b7 <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f0103686:	a1 68 d1 17 f0       	mov    0xf017d168,%eax
f010368b:	85 c0                	test   %eax,%eax
f010368d:	75 19                	jne    f01036a8 <trap+0x69>
f010368f:	68 e6 5b 10 f0       	push   $0xf0105be6
f0103694:	68 84 4e 10 f0       	push   $0xf0104e84
f0103699:	68 e1 00 00 00       	push   $0xe1
f010369e:	68 a6 5b 10 f0       	push   $0xf0105ba6
f01036a3:	e8 f8 c9 ff ff       	call   f01000a0 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01036a8:	b9 11 00 00 00       	mov    $0x11,%ecx
f01036ad:	89 c7                	mov    %eax,%edi
f01036af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01036b1:	8b 35 68 d1 17 f0    	mov    0xf017d168,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01036b7:	89 35 80 d9 17 f0    	mov    %esi,0xf017d980
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
         if(tf->tf_trapno == T_PGFLT ) {
f01036bd:	8b 46 28             	mov    0x28(%esi),%eax
f01036c0:	83 f8 0e             	cmp    $0xe,%eax
f01036c3:	75 0e                	jne    f01036d3 <trap+0x94>
                page_fault_handler(tf);
f01036c5:	83 ec 0c             	sub    $0xc,%esp
f01036c8:	56                   	push   %esi
f01036c9:	e8 13 ff ff ff       	call   f01035e1 <page_fault_handler>
f01036ce:	83 c4 10             	add    $0x10,%esp
f01036d1:	eb 74                	jmp    f0103747 <trap+0x108>
                return;
        } 
       
        if(tf->tf_trapno == T_BRKPT ) { 
f01036d3:	83 f8 03             	cmp    $0x3,%eax
f01036d6:	75 0e                	jne    f01036e6 <trap+0xa7>
                monitor(tf);
f01036d8:	83 ec 0c             	sub    $0xc,%esp
f01036db:	56                   	push   %esi
f01036dc:	e8 41 d1 ff ff       	call   f0100822 <monitor>
f01036e1:	83 c4 10             	add    $0x10,%esp
f01036e4:	eb 61                	jmp    f0103747 <trap+0x108>
                return;
        }
        if(tf->tf_trapno == T_SYSCALL ) { 
f01036e6:	83 f8 30             	cmp    $0x30,%eax
f01036e9:	75 21                	jne    f010370c <trap+0xcd>
                tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f01036eb:	83 ec 08             	sub    $0x8,%esp
f01036ee:	ff 76 04             	pushl  0x4(%esi)
f01036f1:	ff 36                	pushl  (%esi)
f01036f3:	ff 76 10             	pushl  0x10(%esi)
f01036f6:	ff 76 18             	pushl  0x18(%esi)
f01036f9:	ff 76 14             	pushl  0x14(%esi)
f01036fc:	ff 76 1c             	pushl  0x1c(%esi)
f01036ff:	e8 f8 00 00 00       	call   f01037fc <syscall>
f0103704:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103707:	83 c4 20             	add    $0x20,%esp
f010370a:	eb 3b                	jmp    f0103747 <trap+0x108>
                tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
                return;
        }
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010370c:	83 ec 0c             	sub    $0xc,%esp
f010370f:	56                   	push   %esi
f0103710:	e8 59 fd ff ff       	call   f010346e <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103715:	83 c4 10             	add    $0x10,%esp
f0103718:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010371d:	75 17                	jne    f0103736 <trap+0xf7>
		panic("unhandled trap in kernel");
f010371f:	83 ec 04             	sub    $0x4,%esp
f0103722:	68 ed 5b 10 f0       	push   $0xf0105bed
f0103727:	68 cc 00 00 00       	push   $0xcc
f010372c:	68 a6 5b 10 f0       	push   $0xf0105ba6
f0103731:	e8 6a c9 ff ff       	call   f01000a0 <_panic>
	else {
		env_destroy(curenv);
f0103736:	83 ec 0c             	sub    $0xc,%esp
f0103739:	ff 35 68 d1 17 f0    	pushl  0xf017d168
f010373f:	e8 be f7 ff ff       	call   f0102f02 <env_destroy>
f0103744:	83 c4 10             	add    $0x10,%esp
	last_tf = tf;
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103747:	a1 68 d1 17 f0       	mov    0xf017d168,%eax
f010374c:	85 c0                	test   %eax,%eax
f010374e:	74 06                	je     f0103756 <trap+0x117>
f0103750:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103754:	74 19                	je     f010376f <trap+0x130>
f0103756:	68 70 5d 10 f0       	push   $0xf0105d70
f010375b:	68 84 4e 10 f0       	push   $0xf0104e84
f0103760:	68 f2 00 00 00       	push   $0xf2
f0103765:	68 a6 5b 10 f0       	push   $0xf0105ba6
f010376a:	e8 31 c9 ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f010376f:	83 ec 0c             	sub    $0xc,%esp
f0103772:	50                   	push   %eax
f0103773:	e8 da f7 ff ff       	call   f0102f52 <env_run>

f0103778 <i0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(i0, T_DIVIDE)
f0103778:	6a 00                	push   $0x0
f010377a:	6a 00                	push   $0x0
f010377c:	eb 6a                	jmp    f01037e8 <_alltraps>

f010377e <i1>:
TRAPHANDLER_NOEC(i1, T_DEBUG)
f010377e:	6a 00                	push   $0x0
f0103780:	6a 01                	push   $0x1
f0103782:	eb 64                	jmp    f01037e8 <_alltraps>

f0103784 <i2>:
TRAPHANDLER_NOEC(i2, T_NMI)
f0103784:	6a 00                	push   $0x0
f0103786:	6a 02                	push   $0x2
f0103788:	eb 5e                	jmp    f01037e8 <_alltraps>

f010378a <i3>:
TRAPHANDLER_NOEC(i3, T_BRKPT)
f010378a:	6a 00                	push   $0x0
f010378c:	6a 03                	push   $0x3
f010378e:	eb 58                	jmp    f01037e8 <_alltraps>

f0103790 <i4>:
TRAPHANDLER_NOEC(i4, T_OFLOW)
f0103790:	6a 00                	push   $0x0
f0103792:	6a 04                	push   $0x4
f0103794:	eb 52                	jmp    f01037e8 <_alltraps>

f0103796 <i5>:
TRAPHANDLER_NOEC(i5, T_BOUND)
f0103796:	6a 00                	push   $0x0
f0103798:	6a 05                	push   $0x5
f010379a:	eb 4c                	jmp    f01037e8 <_alltraps>

f010379c <i6>:
TRAPHANDLER_NOEC(i6, T_ILLOP)
f010379c:	6a 00                	push   $0x0
f010379e:	6a 06                	push   $0x6
f01037a0:	eb 46                	jmp    f01037e8 <_alltraps>

f01037a2 <i7>:
TRAPHANDLER_NOEC(i7, T_DEVICE)
f01037a2:	6a 00                	push   $0x0
f01037a4:	6a 07                	push   $0x7
f01037a6:	eb 40                	jmp    f01037e8 <_alltraps>

f01037a8 <i8>:
TRAPHANDLER(i8, T_DBLFLT)
f01037a8:	6a 08                	push   $0x8
f01037aa:	eb 3c                	jmp    f01037e8 <_alltraps>

f01037ac <i9>:
TRAPHANDLER_NOEC(i9, 9)
f01037ac:	6a 00                	push   $0x0
f01037ae:	6a 09                	push   $0x9
f01037b0:	eb 36                	jmp    f01037e8 <_alltraps>

f01037b2 <i10>:
TRAPHANDLER(i10, T_TSS)
f01037b2:	6a 0a                	push   $0xa
f01037b4:	eb 32                	jmp    f01037e8 <_alltraps>

f01037b6 <i11>:
TRAPHANDLER(i11, T_SEGNP)
f01037b6:	6a 0b                	push   $0xb
f01037b8:	eb 2e                	jmp    f01037e8 <_alltraps>

f01037ba <i12>:
TRAPHANDLER(i12, T_STACK)
f01037ba:	6a 0c                	push   $0xc
f01037bc:	eb 2a                	jmp    f01037e8 <_alltraps>

f01037be <i13>:
TRAPHANDLER(i13, T_GPFLT)
f01037be:	6a 0d                	push   $0xd
f01037c0:	eb 26                	jmp    f01037e8 <_alltraps>

f01037c2 <i14>:
TRAPHANDLER(i14, T_PGFLT)
f01037c2:	6a 0e                	push   $0xe
f01037c4:	eb 22                	jmp    f01037e8 <_alltraps>

f01037c6 <i15>:
TRAPHANDLER_NOEC(i15, 15)
f01037c6:	6a 00                	push   $0x0
f01037c8:	6a 0f                	push   $0xf
f01037ca:	eb 1c                	jmp    f01037e8 <_alltraps>

f01037cc <i16>:
TRAPHANDLER_NOEC(i16, T_FPERR)
f01037cc:	6a 00                	push   $0x0
f01037ce:	6a 10                	push   $0x10
f01037d0:	eb 16                	jmp    f01037e8 <_alltraps>

f01037d2 <i17>:
TRAPHANDLER(i17, T_ALIGN)
f01037d2:	6a 11                	push   $0x11
f01037d4:	eb 12                	jmp    f01037e8 <_alltraps>

f01037d6 <i18>:
TRAPHANDLER_NOEC(i18, T_MCHK)
f01037d6:	6a 00                	push   $0x0
f01037d8:	6a 12                	push   $0x12
f01037da:	eb 0c                	jmp    f01037e8 <_alltraps>

f01037dc <i19>:
TRAPHANDLER_NOEC(i19, T_SIMDERR)
f01037dc:	6a 00                	push   $0x0
f01037de:	6a 13                	push   $0x13
f01037e0:	eb 06                	jmp    f01037e8 <_alltraps>

f01037e2 <i20>:
TRAPHANDLER_NOEC(i20, T_SYSCALL)
f01037e2:	6a 00                	push   $0x0
f01037e4:	6a 30                	push   $0x30
f01037e6:	eb 00                	jmp    f01037e8 <_alltraps>

f01037e8 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
        pushl %ds
f01037e8:	1e                   	push   %ds
        pushl %es
f01037e9:	06                   	push   %es
        pushal
f01037ea:	60                   	pusha  
        pushl $GD_KD
f01037eb:	6a 10                	push   $0x10
        popl %ds
f01037ed:	1f                   	pop    %ds
        pushl $GD_KD
f01037ee:	6a 10                	push   $0x10
        popl %es
f01037f0:	07                   	pop    %es
        pushl %esp
f01037f1:	54                   	push   %esp
        call trap
f01037f2:	e8 48 fe ff ff       	call   f010363f <trap>
        popl %esp
f01037f7:	5c                   	pop    %esp
        popal
f01037f8:	61                   	popa   
        popl %es
f01037f9:	07                   	pop    %es
        popl %ds
f01037fa:	1f                   	pop    %ds
        iret
f01037fb:	cf                   	iret   

f01037fc <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01037fc:	55                   	push   %ebp
f01037fd:	89 e5                	mov    %esp,%ebp
f01037ff:	83 ec 18             	sub    $0x18,%esp
f0103802:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
        int32_t rslt;
	switch (syscallno) {
f0103805:	83 f8 01             	cmp    $0x1,%eax
f0103808:	74 57                	je     f0103861 <syscall+0x65>
f010380a:	83 f8 01             	cmp    $0x1,%eax
f010380d:	72 0f                	jb     f010381e <syscall+0x22>
f010380f:	83 f8 02             	cmp    $0x2,%eax
f0103812:	74 54                	je     f0103868 <syscall+0x6c>
f0103814:	83 f8 03             	cmp    $0x3,%eax
f0103817:	74 59                	je     f0103872 <syscall+0x76>
f0103819:	e9 b9 00 00 00       	jmp    f01038d7 <syscall+0xdb>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f010381e:	83 ec 04             	sub    $0x4,%esp
f0103821:	6a 01                	push   $0x1
f0103823:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103826:	50                   	push   %eax

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103827:	a1 68 d1 17 f0       	mov    0xf017d168,%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f010382c:	ff 70 48             	pushl  0x48(%eax)
f010382f:	e8 9e f1 ff ff       	call   f01029d2 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0103834:	6a 04                	push   $0x4
f0103836:	ff 75 10             	pushl  0x10(%ebp)
f0103839:	ff 75 0c             	pushl  0xc(%ebp)
f010383c:	ff 75 f4             	pushl  -0xc(%ebp)
f010383f:	e8 c7 f0 ff ff       	call   f010290b <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103844:	83 c4 1c             	add    $0x1c,%esp
f0103847:	ff 75 0c             	pushl  0xc(%ebp)
f010384a:	ff 75 10             	pushl  0x10(%ebp)
f010384d:	68 10 5e 10 f0       	push   $0xf0105e10
f0103852:	e8 b2 f7 ff ff       	call   f0103009 <cprintf>
f0103857:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");
        int32_t rslt;
	switch (syscallno) {
        case SYS_cputs:
                sys_cputs((char *)a1, a2);
                rslt = 0;
f010385a:	b8 00 00 00 00       	mov    $0x0,%eax
f010385f:	eb 7b                	jmp    f01038dc <syscall+0xe0>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103861:	e8 4c cc ff ff       	call   f01004b2 <cons_getc>
                sys_cputs((char *)a1, a2);
                rslt = 0;
                break;
	case SYS_cgetc:
                rslt = sys_cgetc();
                break;
f0103866:	eb 74                	jmp    f01038dc <syscall+0xe0>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103868:	a1 68 d1 17 f0       	mov    0xf017d168,%eax
f010386d:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_cgetc:
                rslt = sys_cgetc();
                break;
	case SYS_getenvid:
                rslt = sys_getenvid();
                break;
f0103870:	eb 6a                	jmp    f01038dc <syscall+0xe0>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103872:	83 ec 04             	sub    $0x4,%esp
f0103875:	6a 01                	push   $0x1
f0103877:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010387a:	50                   	push   %eax
f010387b:	ff 75 0c             	pushl  0xc(%ebp)
f010387e:	e8 4f f1 ff ff       	call   f01029d2 <envid2env>
f0103883:	83 c4 10             	add    $0x10,%esp
f0103886:	85 c0                	test   %eax,%eax
f0103888:	78 52                	js     f01038dc <syscall+0xe0>
		return r;
	if (e == curenv)
f010388a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010388d:	8b 15 68 d1 17 f0    	mov    0xf017d168,%edx
f0103893:	39 d0                	cmp    %edx,%eax
f0103895:	75 15                	jne    f01038ac <syscall+0xb0>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103897:	83 ec 08             	sub    $0x8,%esp
f010389a:	ff 70 48             	pushl  0x48(%eax)
f010389d:	68 15 5e 10 f0       	push   $0xf0105e15
f01038a2:	e8 62 f7 ff ff       	call   f0103009 <cprintf>
f01038a7:	83 c4 10             	add    $0x10,%esp
f01038aa:	eb 16                	jmp    f01038c2 <syscall+0xc6>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01038ac:	83 ec 04             	sub    $0x4,%esp
f01038af:	ff 70 48             	pushl  0x48(%eax)
f01038b2:	ff 72 48             	pushl  0x48(%edx)
f01038b5:	68 30 5e 10 f0       	push   $0xf0105e30
f01038ba:	e8 4a f7 ff ff       	call   f0103009 <cprintf>
f01038bf:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01038c2:	83 ec 0c             	sub    $0xc,%esp
f01038c5:	ff 75 f4             	pushl  -0xc(%ebp)
f01038c8:	e8 35 f6 ff ff       	call   f0102f02 <env_destroy>
f01038cd:	83 c4 10             	add    $0x10,%esp
	return 0;
f01038d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01038d5:	eb 05                	jmp    f01038dc <syscall+0xe0>
                break;
	case SYS_env_destroy:
                rslt = sys_env_destroy(a1);
	        break;
	default:
		return -E_NO_SYS;
f01038d7:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	}
        return rslt;
}
f01038dc:	c9                   	leave  
f01038dd:	c3                   	ret    

f01038de <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01038de:	55                   	push   %ebp
f01038df:	89 e5                	mov    %esp,%ebp
f01038e1:	57                   	push   %edi
f01038e2:	56                   	push   %esi
f01038e3:	53                   	push   %ebx
f01038e4:	83 ec 14             	sub    $0x14,%esp
f01038e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01038ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01038ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01038f0:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01038f3:	8b 1a                	mov    (%edx),%ebx
f01038f5:	8b 01                	mov    (%ecx),%eax
f01038f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01038fa:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103901:	e9 88 00 00 00       	jmp    f010398e <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0103906:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103909:	01 d8                	add    %ebx,%eax
f010390b:	89 c6                	mov    %eax,%esi
f010390d:	c1 ee 1f             	shr    $0x1f,%esi
f0103910:	01 c6                	add    %eax,%esi
f0103912:	d1 fe                	sar    %esi
f0103914:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103917:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010391a:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010391d:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010391f:	eb 03                	jmp    f0103924 <stab_binsearch+0x46>
			m--;
f0103921:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103924:	39 c3                	cmp    %eax,%ebx
f0103926:	7f 1f                	jg     f0103947 <stab_binsearch+0x69>
f0103928:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010392c:	83 ea 0c             	sub    $0xc,%edx
f010392f:	39 f9                	cmp    %edi,%ecx
f0103931:	75 ee                	jne    f0103921 <stab_binsearch+0x43>
f0103933:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103936:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103939:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010393c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103940:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103943:	76 18                	jbe    f010395d <stab_binsearch+0x7f>
f0103945:	eb 05                	jmp    f010394c <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103947:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010394a:	eb 42                	jmp    f010398e <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010394c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010394f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103951:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103954:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010395b:	eb 31                	jmp    f010398e <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010395d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103960:	73 17                	jae    f0103979 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103962:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103965:	83 e8 01             	sub    $0x1,%eax
f0103968:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010396b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010396e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103970:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103977:	eb 15                	jmp    f010398e <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103979:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010397c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010397f:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f0103981:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103985:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103987:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010398e:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103991:	0f 8e 6f ff ff ff    	jle    f0103906 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103997:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010399b:	75 0f                	jne    f01039ac <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f010399d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039a0:	8b 00                	mov    (%eax),%eax
f01039a2:	83 e8 01             	sub    $0x1,%eax
f01039a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01039a8:	89 06                	mov    %eax,(%esi)
f01039aa:	eb 2c                	jmp    f01039d8 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039af:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01039b1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01039b4:	8b 0e                	mov    (%esi),%ecx
f01039b6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01039b9:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01039bc:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039bf:	eb 03                	jmp    f01039c4 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01039c1:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039c4:	39 c8                	cmp    %ecx,%eax
f01039c6:	7e 0b                	jle    f01039d3 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01039c8:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01039cc:	83 ea 0c             	sub    $0xc,%edx
f01039cf:	39 fb                	cmp    %edi,%ebx
f01039d1:	75 ee                	jne    f01039c1 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f01039d3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01039d6:	89 06                	mov    %eax,(%esi)
	}
}
f01039d8:	83 c4 14             	add    $0x14,%esp
f01039db:	5b                   	pop    %ebx
f01039dc:	5e                   	pop    %esi
f01039dd:	5f                   	pop    %edi
f01039de:	5d                   	pop    %ebp
f01039df:	c3                   	ret    

f01039e0 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01039e0:	55                   	push   %ebp
f01039e1:	89 e5                	mov    %esp,%ebp
f01039e3:	57                   	push   %edi
f01039e4:	56                   	push   %esi
f01039e5:	53                   	push   %ebx
f01039e6:	83 ec 3c             	sub    $0x3c,%esp
f01039e9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01039ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01039ef:	c7 03 48 5e 10 f0    	movl   $0xf0105e48,(%ebx)
	info->eip_line = 0;
f01039f5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01039fc:	c7 43 08 48 5e 10 f0 	movl   $0xf0105e48,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103a03:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103a0a:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103a0d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103a14:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103a1a:	77 7e                	ja     f0103a9a <debuginfo_eip+0xba>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0103a1c:	6a 04                	push   $0x4
f0103a1e:	6a 10                	push   $0x10
f0103a20:	68 00 00 20 00       	push   $0x200000
f0103a25:	ff 35 68 d1 17 f0    	pushl  0xf017d168
f0103a2b:	e8 4d ee ff ff       	call   f010287d <user_mem_check>
f0103a30:	83 c4 10             	add    $0x10,%esp
f0103a33:	85 c0                	test   %eax,%eax
f0103a35:	0f 85 05 02 00 00    	jne    f0103c40 <debuginfo_eip+0x260>
			return -1;
		stabs = usd->stabs;
f0103a3b:	a1 00 00 20 00       	mov    0x200000,%eax
f0103a40:	89 c1                	mov    %eax,%ecx
f0103a42:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0103a45:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0103a4b:	a1 08 00 20 00       	mov    0x200008,%eax
f0103a50:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0103a53:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103a59:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0103a5c:	6a 04                	push   $0x4
f0103a5e:	6a 0c                	push   $0xc
f0103a60:	51                   	push   %ecx
f0103a61:	ff 35 68 d1 17 f0    	pushl  0xf017d168
f0103a67:	e8 11 ee ff ff       	call   f010287d <user_mem_check>
f0103a6c:	83 c4 10             	add    $0x10,%esp
f0103a6f:	85 c0                	test   %eax,%eax
f0103a71:	0f 85 d0 01 00 00    	jne    f0103c47 <debuginfo_eip+0x267>
                        return -1;
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0103a77:	6a 04                	push   $0x4
f0103a79:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0103a7c:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0103a7f:	29 ca                	sub    %ecx,%edx
f0103a81:	52                   	push   %edx
f0103a82:	51                   	push   %ecx
f0103a83:	ff 35 68 d1 17 f0    	pushl  0xf017d168
f0103a89:	e8 ef ed ff ff       	call   f010287d <user_mem_check>
f0103a8e:	83 c4 10             	add    $0x10,%esp
f0103a91:	85 c0                	test   %eax,%eax
f0103a93:	74 1f                	je     f0103ab4 <debuginfo_eip+0xd4>
f0103a95:	e9 b4 01 00 00       	jmp    f0103c4e <debuginfo_eip+0x26e>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103a9a:	c7 45 bc 24 09 11 f0 	movl   $0xf0110924,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103aa1:	c7 45 c0 01 df 10 f0 	movl   $0xf010df01,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103aa8:	be 00 df 10 f0       	mov    $0xf010df00,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103aad:	c7 45 c4 70 60 10 f0 	movl   $0xf0106070,-0x3c(%ebp)
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
                        return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103ab4:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103ab7:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0103aba:	0f 83 95 01 00 00    	jae    f0103c55 <debuginfo_eip+0x275>
f0103ac0:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103ac4:	0f 85 92 01 00 00    	jne    f0103c5c <debuginfo_eip+0x27c>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103aca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103ad1:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0103ad4:	c1 fe 02             	sar    $0x2,%esi
f0103ad7:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0103add:	83 e8 01             	sub    $0x1,%eax
f0103ae0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103ae3:	83 ec 08             	sub    $0x8,%esp
f0103ae6:	57                   	push   %edi
f0103ae7:	6a 64                	push   $0x64
f0103ae9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103aec:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103aef:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0103af2:	89 f0                	mov    %esi,%eax
f0103af4:	e8 e5 fd ff ff       	call   f01038de <stab_binsearch>
	if (lfile == 0)
f0103af9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103afc:	83 c4 10             	add    $0x10,%esp
f0103aff:	85 c0                	test   %eax,%eax
f0103b01:	0f 84 5c 01 00 00    	je     f0103c63 <debuginfo_eip+0x283>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103b07:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103b0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103b10:	83 ec 08             	sub    $0x8,%esp
f0103b13:	57                   	push   %edi
f0103b14:	6a 24                	push   $0x24
f0103b16:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103b19:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103b1c:	89 f0                	mov    %esi,%eax
f0103b1e:	e8 bb fd ff ff       	call   f01038de <stab_binsearch>

	if (lfun <= rfun) {
f0103b23:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b26:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103b29:	83 c4 10             	add    $0x10,%esp
f0103b2c:	39 f0                	cmp    %esi,%eax
f0103b2e:	7f 32                	jg     f0103b62 <debuginfo_eip+0x182>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103b30:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103b33:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103b36:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0103b39:	8b 11                	mov    (%ecx),%edx
f0103b3b:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0103b3e:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0103b41:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0103b44:	39 55 b8             	cmp    %edx,-0x48(%ebp)
f0103b47:	73 09                	jae    f0103b52 <debuginfo_eip+0x172>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103b49:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0103b4c:	03 55 c0             	add    -0x40(%ebp),%edx
f0103b4f:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103b52:	8b 51 08             	mov    0x8(%ecx),%edx
f0103b55:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103b58:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0103b5a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103b5d:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0103b60:	eb 0f                	jmp    f0103b71 <debuginfo_eip+0x191>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103b62:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0103b65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b68:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103b6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b6e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103b71:	83 ec 08             	sub    $0x8,%esp
f0103b74:	6a 3a                	push   $0x3a
f0103b76:	ff 73 08             	pushl  0x8(%ebx)
f0103b79:	e8 99 08 00 00       	call   f0104417 <strfind>
f0103b7e:	2b 43 08             	sub    0x8(%ebx),%eax
f0103b81:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103b84:	83 c4 08             	add    $0x8,%esp
f0103b87:	57                   	push   %edi
f0103b88:	6a 44                	push   $0x44
f0103b8a:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103b8d:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103b90:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0103b93:	89 f0                	mov    %esi,%eax
f0103b95:	e8 44 fd ff ff       	call   f01038de <stab_binsearch>
        if(lline <= rline)
f0103b9a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103b9d:	83 c4 10             	add    $0x10,%esp
f0103ba0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103ba3:	0f 8f c1 00 00 00    	jg     f0103c6a <debuginfo_eip+0x28a>
              info->eip_line = stabs[lline].n_desc;
f0103ba9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103bac:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0103bb1:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103bb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103bb7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bba:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103bbd:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103bc0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103bc3:	eb 06                	jmp    f0103bcb <debuginfo_eip+0x1eb>
f0103bc5:	83 e8 01             	sub    $0x1,%eax
f0103bc8:	83 ea 0c             	sub    $0xc,%edx
f0103bcb:	39 c7                	cmp    %eax,%edi
f0103bcd:	7f 2a                	jg     f0103bf9 <debuginfo_eip+0x219>
	       && stabs[lline].n_type != N_SOL
f0103bcf:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103bd3:	80 f9 84             	cmp    $0x84,%cl
f0103bd6:	0f 84 9c 00 00 00    	je     f0103c78 <debuginfo_eip+0x298>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103bdc:	80 f9 64             	cmp    $0x64,%cl
f0103bdf:	75 e4                	jne    f0103bc5 <debuginfo_eip+0x1e5>
f0103be1:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103be5:	74 de                	je     f0103bc5 <debuginfo_eip+0x1e5>
f0103be7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103bed:	e9 8c 00 00 00       	jmp    f0103c7e <debuginfo_eip+0x29e>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103bf2:	03 55 c0             	add    -0x40(%ebp),%edx
f0103bf5:	89 13                	mov    %edx,(%ebx)
f0103bf7:	eb 03                	jmp    f0103bfc <debuginfo_eip+0x21c>
f0103bf9:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103bfc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103bff:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c02:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103c07:	39 f2                	cmp    %esi,%edx
f0103c09:	0f 8d 8b 00 00 00    	jge    f0103c9a <debuginfo_eip+0x2ba>
		for (lline = lfun + 1;
f0103c0f:	83 c2 01             	add    $0x1,%edx
f0103c12:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103c15:	89 d0                	mov    %edx,%eax
f0103c17:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103c1a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103c1d:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103c20:	eb 04                	jmp    f0103c26 <debuginfo_eip+0x246>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103c22:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103c26:	39 c6                	cmp    %eax,%esi
f0103c28:	7e 47                	jle    f0103c71 <debuginfo_eip+0x291>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103c2a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103c2e:	83 c0 01             	add    $0x1,%eax
f0103c31:	83 c2 0c             	add    $0xc,%edx
f0103c34:	80 f9 a0             	cmp    $0xa0,%cl
f0103c37:	74 e9                	je     f0103c22 <debuginfo_eip+0x242>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c39:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c3e:	eb 5a                	jmp    f0103c9a <debuginfo_eip+0x2ba>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0103c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c45:	eb 53                	jmp    f0103c9a <debuginfo_eip+0x2ba>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
                        return -1;
f0103c47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c4c:	eb 4c                	jmp    f0103c9a <debuginfo_eip+0x2ba>
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
                        return -1;
f0103c4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c53:	eb 45                	jmp    f0103c9a <debuginfo_eip+0x2ba>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103c55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c5a:	eb 3e                	jmp    f0103c9a <debuginfo_eip+0x2ba>
f0103c5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c61:	eb 37                	jmp    f0103c9a <debuginfo_eip+0x2ba>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103c63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c68:	eb 30                	jmp    f0103c9a <debuginfo_eip+0x2ba>
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
        if(lline <= rline)
              info->eip_line = stabs[lline].n_desc;
        else
              return -1;
f0103c6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c6f:	eb 29                	jmp    f0103c9a <debuginfo_eip+0x2ba>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c71:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c76:	eb 22                	jmp    f0103c9a <debuginfo_eip+0x2ba>
f0103c78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c7b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103c7e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103c81:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103c84:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103c87:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103c8a:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0103c8d:	39 c2                	cmp    %eax,%edx
f0103c8f:	0f 82 5d ff ff ff    	jb     f0103bf2 <debuginfo_eip+0x212>
f0103c95:	e9 62 ff ff ff       	jmp    f0103bfc <debuginfo_eip+0x21c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0103c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c9d:	5b                   	pop    %ebx
f0103c9e:	5e                   	pop    %esi
f0103c9f:	5f                   	pop    %edi
f0103ca0:	5d                   	pop    %ebp
f0103ca1:	c3                   	ret    

f0103ca2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103ca2:	55                   	push   %ebp
f0103ca3:	89 e5                	mov    %esp,%ebp
f0103ca5:	57                   	push   %edi
f0103ca6:	56                   	push   %esi
f0103ca7:	53                   	push   %ebx
f0103ca8:	83 ec 1c             	sub    $0x1c,%esp
f0103cab:	89 c7                	mov    %eax,%edi
f0103cad:	89 d6                	mov    %edx,%esi
f0103caf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cb2:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103cb5:	89 d1                	mov    %edx,%ecx
f0103cb7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103cba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103cbd:	8b 45 10             	mov    0x10(%ebp),%eax
f0103cc0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103cc3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103cc6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103ccd:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0103cd0:	72 05                	jb     f0103cd7 <printnum+0x35>
f0103cd2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103cd5:	77 3e                	ja     f0103d15 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103cd7:	83 ec 0c             	sub    $0xc,%esp
f0103cda:	ff 75 18             	pushl  0x18(%ebp)
f0103cdd:	83 eb 01             	sub    $0x1,%ebx
f0103ce0:	53                   	push   %ebx
f0103ce1:	50                   	push   %eax
f0103ce2:	83 ec 08             	sub    $0x8,%esp
f0103ce5:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103ce8:	ff 75 e0             	pushl  -0x20(%ebp)
f0103ceb:	ff 75 dc             	pushl  -0x24(%ebp)
f0103cee:	ff 75 d8             	pushl  -0x28(%ebp)
f0103cf1:	e8 4a 09 00 00       	call   f0104640 <__udivdi3>
f0103cf6:	83 c4 18             	add    $0x18,%esp
f0103cf9:	52                   	push   %edx
f0103cfa:	50                   	push   %eax
f0103cfb:	89 f2                	mov    %esi,%edx
f0103cfd:	89 f8                	mov    %edi,%eax
f0103cff:	e8 9e ff ff ff       	call   f0103ca2 <printnum>
f0103d04:	83 c4 20             	add    $0x20,%esp
f0103d07:	eb 13                	jmp    f0103d1c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103d09:	83 ec 08             	sub    $0x8,%esp
f0103d0c:	56                   	push   %esi
f0103d0d:	ff 75 18             	pushl  0x18(%ebp)
f0103d10:	ff d7                	call   *%edi
f0103d12:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103d15:	83 eb 01             	sub    $0x1,%ebx
f0103d18:	85 db                	test   %ebx,%ebx
f0103d1a:	7f ed                	jg     f0103d09 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103d1c:	83 ec 08             	sub    $0x8,%esp
f0103d1f:	56                   	push   %esi
f0103d20:	83 ec 04             	sub    $0x4,%esp
f0103d23:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103d26:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d29:	ff 75 dc             	pushl  -0x24(%ebp)
f0103d2c:	ff 75 d8             	pushl  -0x28(%ebp)
f0103d2f:	e8 3c 0a 00 00       	call   f0104770 <__umoddi3>
f0103d34:	83 c4 14             	add    $0x14,%esp
f0103d37:	0f be 80 52 5e 10 f0 	movsbl -0xfefa1ae(%eax),%eax
f0103d3e:	50                   	push   %eax
f0103d3f:	ff d7                	call   *%edi
f0103d41:	83 c4 10             	add    $0x10,%esp
}
f0103d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d47:	5b                   	pop    %ebx
f0103d48:	5e                   	pop    %esi
f0103d49:	5f                   	pop    %edi
f0103d4a:	5d                   	pop    %ebp
f0103d4b:	c3                   	ret    

f0103d4c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103d4c:	55                   	push   %ebp
f0103d4d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103d4f:	83 fa 01             	cmp    $0x1,%edx
f0103d52:	7e 0e                	jle    f0103d62 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103d54:	8b 10                	mov    (%eax),%edx
f0103d56:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103d59:	89 08                	mov    %ecx,(%eax)
f0103d5b:	8b 02                	mov    (%edx),%eax
f0103d5d:	8b 52 04             	mov    0x4(%edx),%edx
f0103d60:	eb 22                	jmp    f0103d84 <getuint+0x38>
	else if (lflag)
f0103d62:	85 d2                	test   %edx,%edx
f0103d64:	74 10                	je     f0103d76 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103d66:	8b 10                	mov    (%eax),%edx
f0103d68:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103d6b:	89 08                	mov    %ecx,(%eax)
f0103d6d:	8b 02                	mov    (%edx),%eax
f0103d6f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d74:	eb 0e                	jmp    f0103d84 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103d76:	8b 10                	mov    (%eax),%edx
f0103d78:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103d7b:	89 08                	mov    %ecx,(%eax)
f0103d7d:	8b 02                	mov    (%edx),%eax
f0103d7f:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103d84:	5d                   	pop    %ebp
f0103d85:	c3                   	ret    

f0103d86 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103d86:	55                   	push   %ebp
f0103d87:	89 e5                	mov    %esp,%ebp
f0103d89:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103d8c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103d90:	8b 10                	mov    (%eax),%edx
f0103d92:	3b 50 04             	cmp    0x4(%eax),%edx
f0103d95:	73 0a                	jae    f0103da1 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103d97:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103d9a:	89 08                	mov    %ecx,(%eax)
f0103d9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d9f:	88 02                	mov    %al,(%edx)
}
f0103da1:	5d                   	pop    %ebp
f0103da2:	c3                   	ret    

f0103da3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103da3:	55                   	push   %ebp
f0103da4:	89 e5                	mov    %esp,%ebp
f0103da6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103da9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103dac:	50                   	push   %eax
f0103dad:	ff 75 10             	pushl  0x10(%ebp)
f0103db0:	ff 75 0c             	pushl  0xc(%ebp)
f0103db3:	ff 75 08             	pushl  0x8(%ebp)
f0103db6:	e8 05 00 00 00       	call   f0103dc0 <vprintfmt>
	va_end(ap);
f0103dbb:	83 c4 10             	add    $0x10,%esp
}
f0103dbe:	c9                   	leave  
f0103dbf:	c3                   	ret    

f0103dc0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103dc0:	55                   	push   %ebp
f0103dc1:	89 e5                	mov    %esp,%ebp
f0103dc3:	57                   	push   %edi
f0103dc4:	56                   	push   %esi
f0103dc5:	53                   	push   %ebx
f0103dc6:	83 ec 2c             	sub    $0x2c,%esp
f0103dc9:	8b 75 08             	mov    0x8(%ebp),%esi
f0103dcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103dcf:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103dd2:	eb 12                	jmp    f0103de6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103dd4:	85 c0                	test   %eax,%eax
f0103dd6:	0f 84 90 03 00 00    	je     f010416c <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0103ddc:	83 ec 08             	sub    $0x8,%esp
f0103ddf:	53                   	push   %ebx
f0103de0:	50                   	push   %eax
f0103de1:	ff d6                	call   *%esi
f0103de3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103de6:	83 c7 01             	add    $0x1,%edi
f0103de9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103ded:	83 f8 25             	cmp    $0x25,%eax
f0103df0:	75 e2                	jne    f0103dd4 <vprintfmt+0x14>
f0103df2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103df6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103dfd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103e04:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103e0b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103e10:	eb 07                	jmp    f0103e19 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e12:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103e15:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e19:	8d 47 01             	lea    0x1(%edi),%eax
f0103e1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e1f:	0f b6 07             	movzbl (%edi),%eax
f0103e22:	0f b6 c8             	movzbl %al,%ecx
f0103e25:	83 e8 23             	sub    $0x23,%eax
f0103e28:	3c 55                	cmp    $0x55,%al
f0103e2a:	0f 87 21 03 00 00    	ja     f0104151 <vprintfmt+0x391>
f0103e30:	0f b6 c0             	movzbl %al,%eax
f0103e33:	ff 24 85 e0 5e 10 f0 	jmp    *-0xfefa120(,%eax,4)
f0103e3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103e3d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103e41:	eb d6                	jmp    f0103e19 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e46:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e4b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103e4e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103e51:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0103e55:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0103e58:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0103e5b:	83 fa 09             	cmp    $0x9,%edx
f0103e5e:	77 39                	ja     f0103e99 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103e60:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103e63:	eb e9                	jmp    f0103e4e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103e65:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e68:	8d 48 04             	lea    0x4(%eax),%ecx
f0103e6b:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103e6e:	8b 00                	mov    (%eax),%eax
f0103e70:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103e76:	eb 27                	jmp    f0103e9f <vprintfmt+0xdf>
f0103e78:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e7b:	85 c0                	test   %eax,%eax
f0103e7d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e82:	0f 49 c8             	cmovns %eax,%ecx
f0103e85:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e8b:	eb 8c                	jmp    f0103e19 <vprintfmt+0x59>
f0103e8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103e90:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103e97:	eb 80                	jmp    f0103e19 <vprintfmt+0x59>
f0103e99:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103e9c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103e9f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103ea3:	0f 89 70 ff ff ff    	jns    f0103e19 <vprintfmt+0x59>
				width = precision, precision = -1;
f0103ea9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103eac:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103eaf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103eb6:	e9 5e ff ff ff       	jmp    f0103e19 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103ebb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ebe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103ec1:	e9 53 ff ff ff       	jmp    f0103e19 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103ec6:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ec9:	8d 50 04             	lea    0x4(%eax),%edx
f0103ecc:	89 55 14             	mov    %edx,0x14(%ebp)
f0103ecf:	83 ec 08             	sub    $0x8,%esp
f0103ed2:	53                   	push   %ebx
f0103ed3:	ff 30                	pushl  (%eax)
f0103ed5:	ff d6                	call   *%esi
			break;
f0103ed7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103eda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103edd:	e9 04 ff ff ff       	jmp    f0103de6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103ee2:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ee5:	8d 50 04             	lea    0x4(%eax),%edx
f0103ee8:	89 55 14             	mov    %edx,0x14(%ebp)
f0103eeb:	8b 00                	mov    (%eax),%eax
f0103eed:	99                   	cltd   
f0103eee:	31 d0                	xor    %edx,%eax
f0103ef0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103ef2:	83 f8 07             	cmp    $0x7,%eax
f0103ef5:	7f 0b                	jg     f0103f02 <vprintfmt+0x142>
f0103ef7:	8b 14 85 40 60 10 f0 	mov    -0xfef9fc0(,%eax,4),%edx
f0103efe:	85 d2                	test   %edx,%edx
f0103f00:	75 18                	jne    f0103f1a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0103f02:	50                   	push   %eax
f0103f03:	68 6a 5e 10 f0       	push   $0xf0105e6a
f0103f08:	53                   	push   %ebx
f0103f09:	56                   	push   %esi
f0103f0a:	e8 94 fe ff ff       	call   f0103da3 <printfmt>
f0103f0f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103f15:	e9 cc fe ff ff       	jmp    f0103de6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103f1a:	52                   	push   %edx
f0103f1b:	68 96 4e 10 f0       	push   $0xf0104e96
f0103f20:	53                   	push   %ebx
f0103f21:	56                   	push   %esi
f0103f22:	e8 7c fe ff ff       	call   f0103da3 <printfmt>
f0103f27:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f2a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f2d:	e9 b4 fe ff ff       	jmp    f0103de6 <vprintfmt+0x26>
f0103f32:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103f35:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f38:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103f3b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f3e:	8d 50 04             	lea    0x4(%eax),%edx
f0103f41:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f44:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103f46:	85 ff                	test   %edi,%edi
f0103f48:	ba 63 5e 10 f0       	mov    $0xf0105e63,%edx
f0103f4d:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
f0103f50:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103f54:	0f 84 92 00 00 00    	je     f0103fec <vprintfmt+0x22c>
f0103f5a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0103f5e:	0f 8e 96 00 00 00    	jle    f0103ffa <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f64:	83 ec 08             	sub    $0x8,%esp
f0103f67:	51                   	push   %ecx
f0103f68:	57                   	push   %edi
f0103f69:	e8 5f 03 00 00       	call   f01042cd <strnlen>
f0103f6e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103f71:	29 c1                	sub    %eax,%ecx
f0103f73:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103f76:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103f79:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103f7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103f80:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103f83:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f85:	eb 0f                	jmp    f0103f96 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0103f87:	83 ec 08             	sub    $0x8,%esp
f0103f8a:	53                   	push   %ebx
f0103f8b:	ff 75 e0             	pushl  -0x20(%ebp)
f0103f8e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f90:	83 ef 01             	sub    $0x1,%edi
f0103f93:	83 c4 10             	add    $0x10,%esp
f0103f96:	85 ff                	test   %edi,%edi
f0103f98:	7f ed                	jg     f0103f87 <vprintfmt+0x1c7>
f0103f9a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103f9d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103fa0:	85 c9                	test   %ecx,%ecx
f0103fa2:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fa7:	0f 49 c1             	cmovns %ecx,%eax
f0103faa:	29 c1                	sub    %eax,%ecx
f0103fac:	89 75 08             	mov    %esi,0x8(%ebp)
f0103faf:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103fb2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103fb5:	89 cb                	mov    %ecx,%ebx
f0103fb7:	eb 4d                	jmp    f0104006 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103fb9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103fbd:	74 1b                	je     f0103fda <vprintfmt+0x21a>
f0103fbf:	0f be c0             	movsbl %al,%eax
f0103fc2:	83 e8 20             	sub    $0x20,%eax
f0103fc5:	83 f8 5e             	cmp    $0x5e,%eax
f0103fc8:	76 10                	jbe    f0103fda <vprintfmt+0x21a>
					putch('?', putdat);
f0103fca:	83 ec 08             	sub    $0x8,%esp
f0103fcd:	ff 75 0c             	pushl  0xc(%ebp)
f0103fd0:	6a 3f                	push   $0x3f
f0103fd2:	ff 55 08             	call   *0x8(%ebp)
f0103fd5:	83 c4 10             	add    $0x10,%esp
f0103fd8:	eb 0d                	jmp    f0103fe7 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0103fda:	83 ec 08             	sub    $0x8,%esp
f0103fdd:	ff 75 0c             	pushl  0xc(%ebp)
f0103fe0:	52                   	push   %edx
f0103fe1:	ff 55 08             	call   *0x8(%ebp)
f0103fe4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103fe7:	83 eb 01             	sub    $0x1,%ebx
f0103fea:	eb 1a                	jmp    f0104006 <vprintfmt+0x246>
f0103fec:	89 75 08             	mov    %esi,0x8(%ebp)
f0103fef:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103ff2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103ff5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103ff8:	eb 0c                	jmp    f0104006 <vprintfmt+0x246>
f0103ffa:	89 75 08             	mov    %esi,0x8(%ebp)
f0103ffd:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104000:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104003:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104006:	83 c7 01             	add    $0x1,%edi
f0104009:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010400d:	0f be d0             	movsbl %al,%edx
f0104010:	85 d2                	test   %edx,%edx
f0104012:	74 23                	je     f0104037 <vprintfmt+0x277>
f0104014:	85 f6                	test   %esi,%esi
f0104016:	78 a1                	js     f0103fb9 <vprintfmt+0x1f9>
f0104018:	83 ee 01             	sub    $0x1,%esi
f010401b:	79 9c                	jns    f0103fb9 <vprintfmt+0x1f9>
f010401d:	89 df                	mov    %ebx,%edi
f010401f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104022:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104025:	eb 18                	jmp    f010403f <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104027:	83 ec 08             	sub    $0x8,%esp
f010402a:	53                   	push   %ebx
f010402b:	6a 20                	push   $0x20
f010402d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010402f:	83 ef 01             	sub    $0x1,%edi
f0104032:	83 c4 10             	add    $0x10,%esp
f0104035:	eb 08                	jmp    f010403f <vprintfmt+0x27f>
f0104037:	89 df                	mov    %ebx,%edi
f0104039:	8b 75 08             	mov    0x8(%ebp),%esi
f010403c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010403f:	85 ff                	test   %edi,%edi
f0104041:	7f e4                	jg     f0104027 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104043:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104046:	e9 9b fd ff ff       	jmp    f0103de6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010404b:	83 fa 01             	cmp    $0x1,%edx
f010404e:	7e 16                	jle    f0104066 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f0104050:	8b 45 14             	mov    0x14(%ebp),%eax
f0104053:	8d 50 08             	lea    0x8(%eax),%edx
f0104056:	89 55 14             	mov    %edx,0x14(%ebp)
f0104059:	8b 50 04             	mov    0x4(%eax),%edx
f010405c:	8b 00                	mov    (%eax),%eax
f010405e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104061:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104064:	eb 32                	jmp    f0104098 <vprintfmt+0x2d8>
	else if (lflag)
f0104066:	85 d2                	test   %edx,%edx
f0104068:	74 18                	je     f0104082 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f010406a:	8b 45 14             	mov    0x14(%ebp),%eax
f010406d:	8d 50 04             	lea    0x4(%eax),%edx
f0104070:	89 55 14             	mov    %edx,0x14(%ebp)
f0104073:	8b 00                	mov    (%eax),%eax
f0104075:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104078:	89 c1                	mov    %eax,%ecx
f010407a:	c1 f9 1f             	sar    $0x1f,%ecx
f010407d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104080:	eb 16                	jmp    f0104098 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f0104082:	8b 45 14             	mov    0x14(%ebp),%eax
f0104085:	8d 50 04             	lea    0x4(%eax),%edx
f0104088:	89 55 14             	mov    %edx,0x14(%ebp)
f010408b:	8b 00                	mov    (%eax),%eax
f010408d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104090:	89 c1                	mov    %eax,%ecx
f0104092:	c1 f9 1f             	sar    $0x1f,%ecx
f0104095:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104098:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010409b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010409e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01040a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01040a7:	79 74                	jns    f010411d <vprintfmt+0x35d>
				putch('-', putdat);
f01040a9:	83 ec 08             	sub    $0x8,%esp
f01040ac:	53                   	push   %ebx
f01040ad:	6a 2d                	push   $0x2d
f01040af:	ff d6                	call   *%esi
				num = -(long long) num;
f01040b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01040b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01040b7:	f7 d8                	neg    %eax
f01040b9:	83 d2 00             	adc    $0x0,%edx
f01040bc:	f7 da                	neg    %edx
f01040be:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01040c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01040c6:	eb 55                	jmp    f010411d <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01040c8:	8d 45 14             	lea    0x14(%ebp),%eax
f01040cb:	e8 7c fc ff ff       	call   f0103d4c <getuint>
			base = 10;
f01040d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01040d5:	eb 46                	jmp    f010411d <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01040d7:	8d 45 14             	lea    0x14(%ebp),%eax
f01040da:	e8 6d fc ff ff       	call   f0103d4c <getuint>
                        base = 8;
f01040df:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f01040e4:	eb 37                	jmp    f010411d <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
f01040e6:	83 ec 08             	sub    $0x8,%esp
f01040e9:	53                   	push   %ebx
f01040ea:	6a 30                	push   $0x30
f01040ec:	ff d6                	call   *%esi
			putch('x', putdat);
f01040ee:	83 c4 08             	add    $0x8,%esp
f01040f1:	53                   	push   %ebx
f01040f2:	6a 78                	push   $0x78
f01040f4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01040f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01040f9:	8d 50 04             	lea    0x4(%eax),%edx
f01040fc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01040ff:	8b 00                	mov    (%eax),%eax
f0104101:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104106:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104109:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010410e:	eb 0d                	jmp    f010411d <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104110:	8d 45 14             	lea    0x14(%ebp),%eax
f0104113:	e8 34 fc ff ff       	call   f0103d4c <getuint>
			base = 16;
f0104118:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010411d:	83 ec 0c             	sub    $0xc,%esp
f0104120:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104124:	57                   	push   %edi
f0104125:	ff 75 e0             	pushl  -0x20(%ebp)
f0104128:	51                   	push   %ecx
f0104129:	52                   	push   %edx
f010412a:	50                   	push   %eax
f010412b:	89 da                	mov    %ebx,%edx
f010412d:	89 f0                	mov    %esi,%eax
f010412f:	e8 6e fb ff ff       	call   f0103ca2 <printnum>
			break;
f0104134:	83 c4 20             	add    $0x20,%esp
f0104137:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010413a:	e9 a7 fc ff ff       	jmp    f0103de6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010413f:	83 ec 08             	sub    $0x8,%esp
f0104142:	53                   	push   %ebx
f0104143:	51                   	push   %ecx
f0104144:	ff d6                	call   *%esi
			break;
f0104146:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104149:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010414c:	e9 95 fc ff ff       	jmp    f0103de6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104151:	83 ec 08             	sub    $0x8,%esp
f0104154:	53                   	push   %ebx
f0104155:	6a 25                	push   $0x25
f0104157:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104159:	83 c4 10             	add    $0x10,%esp
f010415c:	eb 03                	jmp    f0104161 <vprintfmt+0x3a1>
f010415e:	83 ef 01             	sub    $0x1,%edi
f0104161:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104165:	75 f7                	jne    f010415e <vprintfmt+0x39e>
f0104167:	e9 7a fc ff ff       	jmp    f0103de6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010416c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010416f:	5b                   	pop    %ebx
f0104170:	5e                   	pop    %esi
f0104171:	5f                   	pop    %edi
f0104172:	5d                   	pop    %ebp
f0104173:	c3                   	ret    

f0104174 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104174:	55                   	push   %ebp
f0104175:	89 e5                	mov    %esp,%ebp
f0104177:	83 ec 18             	sub    $0x18,%esp
f010417a:	8b 45 08             	mov    0x8(%ebp),%eax
f010417d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104180:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104183:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104187:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010418a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104191:	85 c0                	test   %eax,%eax
f0104193:	74 26                	je     f01041bb <vsnprintf+0x47>
f0104195:	85 d2                	test   %edx,%edx
f0104197:	7e 22                	jle    f01041bb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104199:	ff 75 14             	pushl  0x14(%ebp)
f010419c:	ff 75 10             	pushl  0x10(%ebp)
f010419f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01041a2:	50                   	push   %eax
f01041a3:	68 86 3d 10 f0       	push   $0xf0103d86
f01041a8:	e8 13 fc ff ff       	call   f0103dc0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01041ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01041b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01041b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01041b6:	83 c4 10             	add    $0x10,%esp
f01041b9:	eb 05                	jmp    f01041c0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01041bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01041c0:	c9                   	leave  
f01041c1:	c3                   	ret    

f01041c2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01041c2:	55                   	push   %ebp
f01041c3:	89 e5                	mov    %esp,%ebp
f01041c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01041c8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01041cb:	50                   	push   %eax
f01041cc:	ff 75 10             	pushl  0x10(%ebp)
f01041cf:	ff 75 0c             	pushl  0xc(%ebp)
f01041d2:	ff 75 08             	pushl  0x8(%ebp)
f01041d5:	e8 9a ff ff ff       	call   f0104174 <vsnprintf>
	va_end(ap);

	return rc;
}
f01041da:	c9                   	leave  
f01041db:	c3                   	ret    

f01041dc <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01041dc:	55                   	push   %ebp
f01041dd:	89 e5                	mov    %esp,%ebp
f01041df:	57                   	push   %edi
f01041e0:	56                   	push   %esi
f01041e1:	53                   	push   %ebx
f01041e2:	83 ec 0c             	sub    $0xc,%esp
f01041e5:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01041e8:	85 c0                	test   %eax,%eax
f01041ea:	74 11                	je     f01041fd <readline+0x21>
		cprintf("%s", prompt);
f01041ec:	83 ec 08             	sub    $0x8,%esp
f01041ef:	50                   	push   %eax
f01041f0:	68 96 4e 10 f0       	push   $0xf0104e96
f01041f5:	e8 0f ee ff ff       	call   f0103009 <cprintf>
f01041fa:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01041fd:	83 ec 0c             	sub    $0xc,%esp
f0104200:	6a 00                	push   $0x0
f0104202:	e8 0f c4 ff ff       	call   f0100616 <iscons>
f0104207:	89 c7                	mov    %eax,%edi
f0104209:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010420c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104211:	e8 ef c3 ff ff       	call   f0100605 <getchar>
f0104216:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104218:	85 c0                	test   %eax,%eax
f010421a:	79 18                	jns    f0104234 <readline+0x58>
			cprintf("read error: %e\n", c);
f010421c:	83 ec 08             	sub    $0x8,%esp
f010421f:	50                   	push   %eax
f0104220:	68 60 60 10 f0       	push   $0xf0106060
f0104225:	e8 df ed ff ff       	call   f0103009 <cprintf>
			return NULL;
f010422a:	83 c4 10             	add    $0x10,%esp
f010422d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104232:	eb 79                	jmp    f01042ad <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104234:	83 f8 7f             	cmp    $0x7f,%eax
f0104237:	0f 94 c2             	sete   %dl
f010423a:	83 f8 08             	cmp    $0x8,%eax
f010423d:	0f 94 c0             	sete   %al
f0104240:	08 c2                	or     %al,%dl
f0104242:	74 1a                	je     f010425e <readline+0x82>
f0104244:	85 f6                	test   %esi,%esi
f0104246:	7e 16                	jle    f010425e <readline+0x82>
			if (echoing)
f0104248:	85 ff                	test   %edi,%edi
f010424a:	74 0d                	je     f0104259 <readline+0x7d>
				cputchar('\b');
f010424c:	83 ec 0c             	sub    $0xc,%esp
f010424f:	6a 08                	push   $0x8
f0104251:	e8 9f c3 ff ff       	call   f01005f5 <cputchar>
f0104256:	83 c4 10             	add    $0x10,%esp
			i--;
f0104259:	83 ee 01             	sub    $0x1,%esi
f010425c:	eb b3                	jmp    f0104211 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010425e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104264:	7f 20                	jg     f0104286 <readline+0xaa>
f0104266:	83 fb 1f             	cmp    $0x1f,%ebx
f0104269:	7e 1b                	jle    f0104286 <readline+0xaa>
			if (echoing)
f010426b:	85 ff                	test   %edi,%edi
f010426d:	74 0c                	je     f010427b <readline+0x9f>
				cputchar(c);
f010426f:	83 ec 0c             	sub    $0xc,%esp
f0104272:	53                   	push   %ebx
f0104273:	e8 7d c3 ff ff       	call   f01005f5 <cputchar>
f0104278:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010427b:	88 9e 40 da 17 f0    	mov    %bl,-0xfe825c0(%esi)
f0104281:	8d 76 01             	lea    0x1(%esi),%esi
f0104284:	eb 8b                	jmp    f0104211 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104286:	83 fb 0d             	cmp    $0xd,%ebx
f0104289:	74 05                	je     f0104290 <readline+0xb4>
f010428b:	83 fb 0a             	cmp    $0xa,%ebx
f010428e:	75 81                	jne    f0104211 <readline+0x35>
			if (echoing)
f0104290:	85 ff                	test   %edi,%edi
f0104292:	74 0d                	je     f01042a1 <readline+0xc5>
				cputchar('\n');
f0104294:	83 ec 0c             	sub    $0xc,%esp
f0104297:	6a 0a                	push   $0xa
f0104299:	e8 57 c3 ff ff       	call   f01005f5 <cputchar>
f010429e:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01042a1:	c6 86 40 da 17 f0 00 	movb   $0x0,-0xfe825c0(%esi)
			return buf;
f01042a8:	b8 40 da 17 f0       	mov    $0xf017da40,%eax
		}
	}
}
f01042ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01042b0:	5b                   	pop    %ebx
f01042b1:	5e                   	pop    %esi
f01042b2:	5f                   	pop    %edi
f01042b3:	5d                   	pop    %ebp
f01042b4:	c3                   	ret    

f01042b5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01042b5:	55                   	push   %ebp
f01042b6:	89 e5                	mov    %esp,%ebp
f01042b8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01042bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01042c0:	eb 03                	jmp    f01042c5 <strlen+0x10>
		n++;
f01042c2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01042c5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01042c9:	75 f7                	jne    f01042c2 <strlen+0xd>
		n++;
	return n;
}
f01042cb:	5d                   	pop    %ebp
f01042cc:	c3                   	ret    

f01042cd <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01042cd:	55                   	push   %ebp
f01042ce:	89 e5                	mov    %esp,%ebp
f01042d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01042d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01042d6:	ba 00 00 00 00       	mov    $0x0,%edx
f01042db:	eb 03                	jmp    f01042e0 <strnlen+0x13>
		n++;
f01042dd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01042e0:	39 c2                	cmp    %eax,%edx
f01042e2:	74 08                	je     f01042ec <strnlen+0x1f>
f01042e4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01042e8:	75 f3                	jne    f01042dd <strnlen+0x10>
f01042ea:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01042ec:	5d                   	pop    %ebp
f01042ed:	c3                   	ret    

f01042ee <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01042ee:	55                   	push   %ebp
f01042ef:	89 e5                	mov    %esp,%ebp
f01042f1:	53                   	push   %ebx
f01042f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01042f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01042f8:	89 c2                	mov    %eax,%edx
f01042fa:	83 c2 01             	add    $0x1,%edx
f01042fd:	83 c1 01             	add    $0x1,%ecx
f0104300:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104304:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104307:	84 db                	test   %bl,%bl
f0104309:	75 ef                	jne    f01042fa <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010430b:	5b                   	pop    %ebx
f010430c:	5d                   	pop    %ebp
f010430d:	c3                   	ret    

f010430e <strcat>:

char *
strcat(char *dst, const char *src)
{
f010430e:	55                   	push   %ebp
f010430f:	89 e5                	mov    %esp,%ebp
f0104311:	53                   	push   %ebx
f0104312:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104315:	53                   	push   %ebx
f0104316:	e8 9a ff ff ff       	call   f01042b5 <strlen>
f010431b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010431e:	ff 75 0c             	pushl  0xc(%ebp)
f0104321:	01 d8                	add    %ebx,%eax
f0104323:	50                   	push   %eax
f0104324:	e8 c5 ff ff ff       	call   f01042ee <strcpy>
	return dst;
}
f0104329:	89 d8                	mov    %ebx,%eax
f010432b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010432e:	c9                   	leave  
f010432f:	c3                   	ret    

f0104330 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104330:	55                   	push   %ebp
f0104331:	89 e5                	mov    %esp,%ebp
f0104333:	56                   	push   %esi
f0104334:	53                   	push   %ebx
f0104335:	8b 75 08             	mov    0x8(%ebp),%esi
f0104338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010433b:	89 f3                	mov    %esi,%ebx
f010433d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104340:	89 f2                	mov    %esi,%edx
f0104342:	eb 0f                	jmp    f0104353 <strncpy+0x23>
		*dst++ = *src;
f0104344:	83 c2 01             	add    $0x1,%edx
f0104347:	0f b6 01             	movzbl (%ecx),%eax
f010434a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010434d:	80 39 01             	cmpb   $0x1,(%ecx)
f0104350:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104353:	39 da                	cmp    %ebx,%edx
f0104355:	75 ed                	jne    f0104344 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104357:	89 f0                	mov    %esi,%eax
f0104359:	5b                   	pop    %ebx
f010435a:	5e                   	pop    %esi
f010435b:	5d                   	pop    %ebp
f010435c:	c3                   	ret    

f010435d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010435d:	55                   	push   %ebp
f010435e:	89 e5                	mov    %esp,%ebp
f0104360:	56                   	push   %esi
f0104361:	53                   	push   %ebx
f0104362:	8b 75 08             	mov    0x8(%ebp),%esi
f0104365:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104368:	8b 55 10             	mov    0x10(%ebp),%edx
f010436b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010436d:	85 d2                	test   %edx,%edx
f010436f:	74 21                	je     f0104392 <strlcpy+0x35>
f0104371:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104375:	89 f2                	mov    %esi,%edx
f0104377:	eb 09                	jmp    f0104382 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104379:	83 c2 01             	add    $0x1,%edx
f010437c:	83 c1 01             	add    $0x1,%ecx
f010437f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104382:	39 c2                	cmp    %eax,%edx
f0104384:	74 09                	je     f010438f <strlcpy+0x32>
f0104386:	0f b6 19             	movzbl (%ecx),%ebx
f0104389:	84 db                	test   %bl,%bl
f010438b:	75 ec                	jne    f0104379 <strlcpy+0x1c>
f010438d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010438f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104392:	29 f0                	sub    %esi,%eax
}
f0104394:	5b                   	pop    %ebx
f0104395:	5e                   	pop    %esi
f0104396:	5d                   	pop    %ebp
f0104397:	c3                   	ret    

f0104398 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104398:	55                   	push   %ebp
f0104399:	89 e5                	mov    %esp,%ebp
f010439b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010439e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01043a1:	eb 06                	jmp    f01043a9 <strcmp+0x11>
		p++, q++;
f01043a3:	83 c1 01             	add    $0x1,%ecx
f01043a6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01043a9:	0f b6 01             	movzbl (%ecx),%eax
f01043ac:	84 c0                	test   %al,%al
f01043ae:	74 04                	je     f01043b4 <strcmp+0x1c>
f01043b0:	3a 02                	cmp    (%edx),%al
f01043b2:	74 ef                	je     f01043a3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01043b4:	0f b6 c0             	movzbl %al,%eax
f01043b7:	0f b6 12             	movzbl (%edx),%edx
f01043ba:	29 d0                	sub    %edx,%eax
}
f01043bc:	5d                   	pop    %ebp
f01043bd:	c3                   	ret    

f01043be <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01043be:	55                   	push   %ebp
f01043bf:	89 e5                	mov    %esp,%ebp
f01043c1:	53                   	push   %ebx
f01043c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01043c5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01043c8:	89 c3                	mov    %eax,%ebx
f01043ca:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01043cd:	eb 06                	jmp    f01043d5 <strncmp+0x17>
		n--, p++, q++;
f01043cf:	83 c0 01             	add    $0x1,%eax
f01043d2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01043d5:	39 d8                	cmp    %ebx,%eax
f01043d7:	74 15                	je     f01043ee <strncmp+0x30>
f01043d9:	0f b6 08             	movzbl (%eax),%ecx
f01043dc:	84 c9                	test   %cl,%cl
f01043de:	74 04                	je     f01043e4 <strncmp+0x26>
f01043e0:	3a 0a                	cmp    (%edx),%cl
f01043e2:	74 eb                	je     f01043cf <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01043e4:	0f b6 00             	movzbl (%eax),%eax
f01043e7:	0f b6 12             	movzbl (%edx),%edx
f01043ea:	29 d0                	sub    %edx,%eax
f01043ec:	eb 05                	jmp    f01043f3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01043ee:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01043f3:	5b                   	pop    %ebx
f01043f4:	5d                   	pop    %ebp
f01043f5:	c3                   	ret    

f01043f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01043f6:	55                   	push   %ebp
f01043f7:	89 e5                	mov    %esp,%ebp
f01043f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01043fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104400:	eb 07                	jmp    f0104409 <strchr+0x13>
		if (*s == c)
f0104402:	38 ca                	cmp    %cl,%dl
f0104404:	74 0f                	je     f0104415 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104406:	83 c0 01             	add    $0x1,%eax
f0104409:	0f b6 10             	movzbl (%eax),%edx
f010440c:	84 d2                	test   %dl,%dl
f010440e:	75 f2                	jne    f0104402 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104410:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104415:	5d                   	pop    %ebp
f0104416:	c3                   	ret    

f0104417 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104417:	55                   	push   %ebp
f0104418:	89 e5                	mov    %esp,%ebp
f010441a:	8b 45 08             	mov    0x8(%ebp),%eax
f010441d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104421:	eb 03                	jmp    f0104426 <strfind+0xf>
f0104423:	83 c0 01             	add    $0x1,%eax
f0104426:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104429:	84 d2                	test   %dl,%dl
f010442b:	74 04                	je     f0104431 <strfind+0x1a>
f010442d:	38 ca                	cmp    %cl,%dl
f010442f:	75 f2                	jne    f0104423 <strfind+0xc>
			break;
	return (char *) s;
}
f0104431:	5d                   	pop    %ebp
f0104432:	c3                   	ret    

f0104433 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104433:	55                   	push   %ebp
f0104434:	89 e5                	mov    %esp,%ebp
f0104436:	57                   	push   %edi
f0104437:	56                   	push   %esi
f0104438:	53                   	push   %ebx
f0104439:	8b 7d 08             	mov    0x8(%ebp),%edi
f010443c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010443f:	85 c9                	test   %ecx,%ecx
f0104441:	74 36                	je     f0104479 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104443:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104449:	75 28                	jne    f0104473 <memset+0x40>
f010444b:	f6 c1 03             	test   $0x3,%cl
f010444e:	75 23                	jne    f0104473 <memset+0x40>
		c &= 0xFF;
f0104450:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104454:	89 d3                	mov    %edx,%ebx
f0104456:	c1 e3 08             	shl    $0x8,%ebx
f0104459:	89 d6                	mov    %edx,%esi
f010445b:	c1 e6 18             	shl    $0x18,%esi
f010445e:	89 d0                	mov    %edx,%eax
f0104460:	c1 e0 10             	shl    $0x10,%eax
f0104463:	09 f0                	or     %esi,%eax
f0104465:	09 c2                	or     %eax,%edx
f0104467:	89 d0                	mov    %edx,%eax
f0104469:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010446b:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010446e:	fc                   	cld    
f010446f:	f3 ab                	rep stos %eax,%es:(%edi)
f0104471:	eb 06                	jmp    f0104479 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104473:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104476:	fc                   	cld    
f0104477:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104479:	89 f8                	mov    %edi,%eax
f010447b:	5b                   	pop    %ebx
f010447c:	5e                   	pop    %esi
f010447d:	5f                   	pop    %edi
f010447e:	5d                   	pop    %ebp
f010447f:	c3                   	ret    

f0104480 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104480:	55                   	push   %ebp
f0104481:	89 e5                	mov    %esp,%ebp
f0104483:	57                   	push   %edi
f0104484:	56                   	push   %esi
f0104485:	8b 45 08             	mov    0x8(%ebp),%eax
f0104488:	8b 75 0c             	mov    0xc(%ebp),%esi
f010448b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010448e:	39 c6                	cmp    %eax,%esi
f0104490:	73 35                	jae    f01044c7 <memmove+0x47>
f0104492:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104495:	39 d0                	cmp    %edx,%eax
f0104497:	73 2e                	jae    f01044c7 <memmove+0x47>
		s += n;
		d += n;
f0104499:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f010449c:	89 d6                	mov    %edx,%esi
f010449e:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01044a0:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01044a6:	75 13                	jne    f01044bb <memmove+0x3b>
f01044a8:	f6 c1 03             	test   $0x3,%cl
f01044ab:	75 0e                	jne    f01044bb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01044ad:	83 ef 04             	sub    $0x4,%edi
f01044b0:	8d 72 fc             	lea    -0x4(%edx),%esi
f01044b3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01044b6:	fd                   	std    
f01044b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01044b9:	eb 09                	jmp    f01044c4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01044bb:	83 ef 01             	sub    $0x1,%edi
f01044be:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01044c1:	fd                   	std    
f01044c2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01044c4:	fc                   	cld    
f01044c5:	eb 1d                	jmp    f01044e4 <memmove+0x64>
f01044c7:	89 f2                	mov    %esi,%edx
f01044c9:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01044cb:	f6 c2 03             	test   $0x3,%dl
f01044ce:	75 0f                	jne    f01044df <memmove+0x5f>
f01044d0:	f6 c1 03             	test   $0x3,%cl
f01044d3:	75 0a                	jne    f01044df <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01044d5:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01044d8:	89 c7                	mov    %eax,%edi
f01044da:	fc                   	cld    
f01044db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01044dd:	eb 05                	jmp    f01044e4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01044df:	89 c7                	mov    %eax,%edi
f01044e1:	fc                   	cld    
f01044e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01044e4:	5e                   	pop    %esi
f01044e5:	5f                   	pop    %edi
f01044e6:	5d                   	pop    %ebp
f01044e7:	c3                   	ret    

f01044e8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01044e8:	55                   	push   %ebp
f01044e9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01044eb:	ff 75 10             	pushl  0x10(%ebp)
f01044ee:	ff 75 0c             	pushl  0xc(%ebp)
f01044f1:	ff 75 08             	pushl  0x8(%ebp)
f01044f4:	e8 87 ff ff ff       	call   f0104480 <memmove>
}
f01044f9:	c9                   	leave  
f01044fa:	c3                   	ret    

f01044fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01044fb:	55                   	push   %ebp
f01044fc:	89 e5                	mov    %esp,%ebp
f01044fe:	56                   	push   %esi
f01044ff:	53                   	push   %ebx
f0104500:	8b 45 08             	mov    0x8(%ebp),%eax
f0104503:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104506:	89 c6                	mov    %eax,%esi
f0104508:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010450b:	eb 1a                	jmp    f0104527 <memcmp+0x2c>
		if (*s1 != *s2)
f010450d:	0f b6 08             	movzbl (%eax),%ecx
f0104510:	0f b6 1a             	movzbl (%edx),%ebx
f0104513:	38 d9                	cmp    %bl,%cl
f0104515:	74 0a                	je     f0104521 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0104517:	0f b6 c1             	movzbl %cl,%eax
f010451a:	0f b6 db             	movzbl %bl,%ebx
f010451d:	29 d8                	sub    %ebx,%eax
f010451f:	eb 0f                	jmp    f0104530 <memcmp+0x35>
		s1++, s2++;
f0104521:	83 c0 01             	add    $0x1,%eax
f0104524:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104527:	39 f0                	cmp    %esi,%eax
f0104529:	75 e2                	jne    f010450d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010452b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104530:	5b                   	pop    %ebx
f0104531:	5e                   	pop    %esi
f0104532:	5d                   	pop    %ebp
f0104533:	c3                   	ret    

f0104534 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104534:	55                   	push   %ebp
f0104535:	89 e5                	mov    %esp,%ebp
f0104537:	8b 45 08             	mov    0x8(%ebp),%eax
f010453a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010453d:	89 c2                	mov    %eax,%edx
f010453f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104542:	eb 07                	jmp    f010454b <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104544:	38 08                	cmp    %cl,(%eax)
f0104546:	74 07                	je     f010454f <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104548:	83 c0 01             	add    $0x1,%eax
f010454b:	39 d0                	cmp    %edx,%eax
f010454d:	72 f5                	jb     f0104544 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010454f:	5d                   	pop    %ebp
f0104550:	c3                   	ret    

f0104551 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104551:	55                   	push   %ebp
f0104552:	89 e5                	mov    %esp,%ebp
f0104554:	57                   	push   %edi
f0104555:	56                   	push   %esi
f0104556:	53                   	push   %ebx
f0104557:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010455a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010455d:	eb 03                	jmp    f0104562 <strtol+0x11>
		s++;
f010455f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104562:	0f b6 01             	movzbl (%ecx),%eax
f0104565:	3c 09                	cmp    $0x9,%al
f0104567:	74 f6                	je     f010455f <strtol+0xe>
f0104569:	3c 20                	cmp    $0x20,%al
f010456b:	74 f2                	je     f010455f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010456d:	3c 2b                	cmp    $0x2b,%al
f010456f:	75 0a                	jne    f010457b <strtol+0x2a>
		s++;
f0104571:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104574:	bf 00 00 00 00       	mov    $0x0,%edi
f0104579:	eb 10                	jmp    f010458b <strtol+0x3a>
f010457b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104580:	3c 2d                	cmp    $0x2d,%al
f0104582:	75 07                	jne    f010458b <strtol+0x3a>
		s++, neg = 1;
f0104584:	8d 49 01             	lea    0x1(%ecx),%ecx
f0104587:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010458b:	85 db                	test   %ebx,%ebx
f010458d:	0f 94 c0             	sete   %al
f0104590:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104596:	75 19                	jne    f01045b1 <strtol+0x60>
f0104598:	80 39 30             	cmpb   $0x30,(%ecx)
f010459b:	75 14                	jne    f01045b1 <strtol+0x60>
f010459d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01045a1:	0f 85 82 00 00 00    	jne    f0104629 <strtol+0xd8>
		s += 2, base = 16;
f01045a7:	83 c1 02             	add    $0x2,%ecx
f01045aa:	bb 10 00 00 00       	mov    $0x10,%ebx
f01045af:	eb 16                	jmp    f01045c7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01045b1:	84 c0                	test   %al,%al
f01045b3:	74 12                	je     f01045c7 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01045b5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01045ba:	80 39 30             	cmpb   $0x30,(%ecx)
f01045bd:	75 08                	jne    f01045c7 <strtol+0x76>
		s++, base = 8;
f01045bf:	83 c1 01             	add    $0x1,%ecx
f01045c2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01045c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01045cc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01045cf:	0f b6 11             	movzbl (%ecx),%edx
f01045d2:	8d 72 d0             	lea    -0x30(%edx),%esi
f01045d5:	89 f3                	mov    %esi,%ebx
f01045d7:	80 fb 09             	cmp    $0x9,%bl
f01045da:	77 08                	ja     f01045e4 <strtol+0x93>
			dig = *s - '0';
f01045dc:	0f be d2             	movsbl %dl,%edx
f01045df:	83 ea 30             	sub    $0x30,%edx
f01045e2:	eb 22                	jmp    f0104606 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f01045e4:	8d 72 9f             	lea    -0x61(%edx),%esi
f01045e7:	89 f3                	mov    %esi,%ebx
f01045e9:	80 fb 19             	cmp    $0x19,%bl
f01045ec:	77 08                	ja     f01045f6 <strtol+0xa5>
			dig = *s - 'a' + 10;
f01045ee:	0f be d2             	movsbl %dl,%edx
f01045f1:	83 ea 57             	sub    $0x57,%edx
f01045f4:	eb 10                	jmp    f0104606 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f01045f6:	8d 72 bf             	lea    -0x41(%edx),%esi
f01045f9:	89 f3                	mov    %esi,%ebx
f01045fb:	80 fb 19             	cmp    $0x19,%bl
f01045fe:	77 16                	ja     f0104616 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0104600:	0f be d2             	movsbl %dl,%edx
f0104603:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0104606:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104609:	7d 0f                	jge    f010461a <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f010460b:	83 c1 01             	add    $0x1,%ecx
f010460e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104612:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0104614:	eb b9                	jmp    f01045cf <strtol+0x7e>
f0104616:	89 c2                	mov    %eax,%edx
f0104618:	eb 02                	jmp    f010461c <strtol+0xcb>
f010461a:	89 c2                	mov    %eax,%edx

	if (endptr)
f010461c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104620:	74 0d                	je     f010462f <strtol+0xde>
		*endptr = (char *) s;
f0104622:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104625:	89 0e                	mov    %ecx,(%esi)
f0104627:	eb 06                	jmp    f010462f <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104629:	84 c0                	test   %al,%al
f010462b:	75 92                	jne    f01045bf <strtol+0x6e>
f010462d:	eb 98                	jmp    f01045c7 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010462f:	f7 da                	neg    %edx
f0104631:	85 ff                	test   %edi,%edi
f0104633:	0f 45 c2             	cmovne %edx,%eax
}
f0104636:	5b                   	pop    %ebx
f0104637:	5e                   	pop    %esi
f0104638:	5f                   	pop    %edi
f0104639:	5d                   	pop    %ebp
f010463a:	c3                   	ret    
f010463b:	66 90                	xchg   %ax,%ax
f010463d:	66 90                	xchg   %ax,%ax
f010463f:	90                   	nop

f0104640 <__udivdi3>:
f0104640:	55                   	push   %ebp
f0104641:	57                   	push   %edi
f0104642:	56                   	push   %esi
f0104643:	83 ec 10             	sub    $0x10,%esp
f0104646:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f010464a:	8b 7c 24 20          	mov    0x20(%esp),%edi
f010464e:	8b 74 24 24          	mov    0x24(%esp),%esi
f0104652:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0104656:	85 d2                	test   %edx,%edx
f0104658:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010465c:	89 34 24             	mov    %esi,(%esp)
f010465f:	89 c8                	mov    %ecx,%eax
f0104661:	75 35                	jne    f0104698 <__udivdi3+0x58>
f0104663:	39 f1                	cmp    %esi,%ecx
f0104665:	0f 87 bd 00 00 00    	ja     f0104728 <__udivdi3+0xe8>
f010466b:	85 c9                	test   %ecx,%ecx
f010466d:	89 cd                	mov    %ecx,%ebp
f010466f:	75 0b                	jne    f010467c <__udivdi3+0x3c>
f0104671:	b8 01 00 00 00       	mov    $0x1,%eax
f0104676:	31 d2                	xor    %edx,%edx
f0104678:	f7 f1                	div    %ecx
f010467a:	89 c5                	mov    %eax,%ebp
f010467c:	89 f0                	mov    %esi,%eax
f010467e:	31 d2                	xor    %edx,%edx
f0104680:	f7 f5                	div    %ebp
f0104682:	89 c6                	mov    %eax,%esi
f0104684:	89 f8                	mov    %edi,%eax
f0104686:	f7 f5                	div    %ebp
f0104688:	89 f2                	mov    %esi,%edx
f010468a:	83 c4 10             	add    $0x10,%esp
f010468d:	5e                   	pop    %esi
f010468e:	5f                   	pop    %edi
f010468f:	5d                   	pop    %ebp
f0104690:	c3                   	ret    
f0104691:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104698:	3b 14 24             	cmp    (%esp),%edx
f010469b:	77 7b                	ja     f0104718 <__udivdi3+0xd8>
f010469d:	0f bd f2             	bsr    %edx,%esi
f01046a0:	83 f6 1f             	xor    $0x1f,%esi
f01046a3:	0f 84 97 00 00 00    	je     f0104740 <__udivdi3+0x100>
f01046a9:	bd 20 00 00 00       	mov    $0x20,%ebp
f01046ae:	89 d7                	mov    %edx,%edi
f01046b0:	89 f1                	mov    %esi,%ecx
f01046b2:	29 f5                	sub    %esi,%ebp
f01046b4:	d3 e7                	shl    %cl,%edi
f01046b6:	89 c2                	mov    %eax,%edx
f01046b8:	89 e9                	mov    %ebp,%ecx
f01046ba:	d3 ea                	shr    %cl,%edx
f01046bc:	89 f1                	mov    %esi,%ecx
f01046be:	09 fa                	or     %edi,%edx
f01046c0:	8b 3c 24             	mov    (%esp),%edi
f01046c3:	d3 e0                	shl    %cl,%eax
f01046c5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01046c9:	89 e9                	mov    %ebp,%ecx
f01046cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01046cf:	8b 44 24 04          	mov    0x4(%esp),%eax
f01046d3:	89 fa                	mov    %edi,%edx
f01046d5:	d3 ea                	shr    %cl,%edx
f01046d7:	89 f1                	mov    %esi,%ecx
f01046d9:	d3 e7                	shl    %cl,%edi
f01046db:	89 e9                	mov    %ebp,%ecx
f01046dd:	d3 e8                	shr    %cl,%eax
f01046df:	09 c7                	or     %eax,%edi
f01046e1:	89 f8                	mov    %edi,%eax
f01046e3:	f7 74 24 08          	divl   0x8(%esp)
f01046e7:	89 d5                	mov    %edx,%ebp
f01046e9:	89 c7                	mov    %eax,%edi
f01046eb:	f7 64 24 0c          	mull   0xc(%esp)
f01046ef:	39 d5                	cmp    %edx,%ebp
f01046f1:	89 14 24             	mov    %edx,(%esp)
f01046f4:	72 11                	jb     f0104707 <__udivdi3+0xc7>
f01046f6:	8b 54 24 04          	mov    0x4(%esp),%edx
f01046fa:	89 f1                	mov    %esi,%ecx
f01046fc:	d3 e2                	shl    %cl,%edx
f01046fe:	39 c2                	cmp    %eax,%edx
f0104700:	73 5e                	jae    f0104760 <__udivdi3+0x120>
f0104702:	3b 2c 24             	cmp    (%esp),%ebp
f0104705:	75 59                	jne    f0104760 <__udivdi3+0x120>
f0104707:	8d 47 ff             	lea    -0x1(%edi),%eax
f010470a:	31 f6                	xor    %esi,%esi
f010470c:	89 f2                	mov    %esi,%edx
f010470e:	83 c4 10             	add    $0x10,%esp
f0104711:	5e                   	pop    %esi
f0104712:	5f                   	pop    %edi
f0104713:	5d                   	pop    %ebp
f0104714:	c3                   	ret    
f0104715:	8d 76 00             	lea    0x0(%esi),%esi
f0104718:	31 f6                	xor    %esi,%esi
f010471a:	31 c0                	xor    %eax,%eax
f010471c:	89 f2                	mov    %esi,%edx
f010471e:	83 c4 10             	add    $0x10,%esp
f0104721:	5e                   	pop    %esi
f0104722:	5f                   	pop    %edi
f0104723:	5d                   	pop    %ebp
f0104724:	c3                   	ret    
f0104725:	8d 76 00             	lea    0x0(%esi),%esi
f0104728:	89 f2                	mov    %esi,%edx
f010472a:	31 f6                	xor    %esi,%esi
f010472c:	89 f8                	mov    %edi,%eax
f010472e:	f7 f1                	div    %ecx
f0104730:	89 f2                	mov    %esi,%edx
f0104732:	83 c4 10             	add    $0x10,%esp
f0104735:	5e                   	pop    %esi
f0104736:	5f                   	pop    %edi
f0104737:	5d                   	pop    %ebp
f0104738:	c3                   	ret    
f0104739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104740:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0104744:	76 0b                	jbe    f0104751 <__udivdi3+0x111>
f0104746:	31 c0                	xor    %eax,%eax
f0104748:	3b 14 24             	cmp    (%esp),%edx
f010474b:	0f 83 37 ff ff ff    	jae    f0104688 <__udivdi3+0x48>
f0104751:	b8 01 00 00 00       	mov    $0x1,%eax
f0104756:	e9 2d ff ff ff       	jmp    f0104688 <__udivdi3+0x48>
f010475b:	90                   	nop
f010475c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104760:	89 f8                	mov    %edi,%eax
f0104762:	31 f6                	xor    %esi,%esi
f0104764:	e9 1f ff ff ff       	jmp    f0104688 <__udivdi3+0x48>
f0104769:	66 90                	xchg   %ax,%ax
f010476b:	66 90                	xchg   %ax,%ax
f010476d:	66 90                	xchg   %ax,%ax
f010476f:	90                   	nop

f0104770 <__umoddi3>:
f0104770:	55                   	push   %ebp
f0104771:	57                   	push   %edi
f0104772:	56                   	push   %esi
f0104773:	83 ec 20             	sub    $0x20,%esp
f0104776:	8b 44 24 34          	mov    0x34(%esp),%eax
f010477a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010477e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104782:	89 c6                	mov    %eax,%esi
f0104784:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104788:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010478c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0104790:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104794:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0104798:	89 74 24 18          	mov    %esi,0x18(%esp)
f010479c:	85 c0                	test   %eax,%eax
f010479e:	89 c2                	mov    %eax,%edx
f01047a0:	75 1e                	jne    f01047c0 <__umoddi3+0x50>
f01047a2:	39 f7                	cmp    %esi,%edi
f01047a4:	76 52                	jbe    f01047f8 <__umoddi3+0x88>
f01047a6:	89 c8                	mov    %ecx,%eax
f01047a8:	89 f2                	mov    %esi,%edx
f01047aa:	f7 f7                	div    %edi
f01047ac:	89 d0                	mov    %edx,%eax
f01047ae:	31 d2                	xor    %edx,%edx
f01047b0:	83 c4 20             	add    $0x20,%esp
f01047b3:	5e                   	pop    %esi
f01047b4:	5f                   	pop    %edi
f01047b5:	5d                   	pop    %ebp
f01047b6:	c3                   	ret    
f01047b7:	89 f6                	mov    %esi,%esi
f01047b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01047c0:	39 f0                	cmp    %esi,%eax
f01047c2:	77 5c                	ja     f0104820 <__umoddi3+0xb0>
f01047c4:	0f bd e8             	bsr    %eax,%ebp
f01047c7:	83 f5 1f             	xor    $0x1f,%ebp
f01047ca:	75 64                	jne    f0104830 <__umoddi3+0xc0>
f01047cc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f01047d0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f01047d4:	0f 86 f6 00 00 00    	jbe    f01048d0 <__umoddi3+0x160>
f01047da:	3b 44 24 18          	cmp    0x18(%esp),%eax
f01047de:	0f 82 ec 00 00 00    	jb     f01048d0 <__umoddi3+0x160>
f01047e4:	8b 44 24 14          	mov    0x14(%esp),%eax
f01047e8:	8b 54 24 18          	mov    0x18(%esp),%edx
f01047ec:	83 c4 20             	add    $0x20,%esp
f01047ef:	5e                   	pop    %esi
f01047f0:	5f                   	pop    %edi
f01047f1:	5d                   	pop    %ebp
f01047f2:	c3                   	ret    
f01047f3:	90                   	nop
f01047f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01047f8:	85 ff                	test   %edi,%edi
f01047fa:	89 fd                	mov    %edi,%ebp
f01047fc:	75 0b                	jne    f0104809 <__umoddi3+0x99>
f01047fe:	b8 01 00 00 00       	mov    $0x1,%eax
f0104803:	31 d2                	xor    %edx,%edx
f0104805:	f7 f7                	div    %edi
f0104807:	89 c5                	mov    %eax,%ebp
f0104809:	8b 44 24 10          	mov    0x10(%esp),%eax
f010480d:	31 d2                	xor    %edx,%edx
f010480f:	f7 f5                	div    %ebp
f0104811:	89 c8                	mov    %ecx,%eax
f0104813:	f7 f5                	div    %ebp
f0104815:	eb 95                	jmp    f01047ac <__umoddi3+0x3c>
f0104817:	89 f6                	mov    %esi,%esi
f0104819:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0104820:	89 c8                	mov    %ecx,%eax
f0104822:	89 f2                	mov    %esi,%edx
f0104824:	83 c4 20             	add    $0x20,%esp
f0104827:	5e                   	pop    %esi
f0104828:	5f                   	pop    %edi
f0104829:	5d                   	pop    %ebp
f010482a:	c3                   	ret    
f010482b:	90                   	nop
f010482c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104830:	b8 20 00 00 00       	mov    $0x20,%eax
f0104835:	89 e9                	mov    %ebp,%ecx
f0104837:	29 e8                	sub    %ebp,%eax
f0104839:	d3 e2                	shl    %cl,%edx
f010483b:	89 c7                	mov    %eax,%edi
f010483d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0104841:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0104845:	89 f9                	mov    %edi,%ecx
f0104847:	d3 e8                	shr    %cl,%eax
f0104849:	89 c1                	mov    %eax,%ecx
f010484b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010484f:	09 d1                	or     %edx,%ecx
f0104851:	89 fa                	mov    %edi,%edx
f0104853:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104857:	89 e9                	mov    %ebp,%ecx
f0104859:	d3 e0                	shl    %cl,%eax
f010485b:	89 f9                	mov    %edi,%ecx
f010485d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104861:	89 f0                	mov    %esi,%eax
f0104863:	d3 e8                	shr    %cl,%eax
f0104865:	89 e9                	mov    %ebp,%ecx
f0104867:	89 c7                	mov    %eax,%edi
f0104869:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010486d:	d3 e6                	shl    %cl,%esi
f010486f:	89 d1                	mov    %edx,%ecx
f0104871:	89 fa                	mov    %edi,%edx
f0104873:	d3 e8                	shr    %cl,%eax
f0104875:	89 e9                	mov    %ebp,%ecx
f0104877:	09 f0                	or     %esi,%eax
f0104879:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f010487d:	f7 74 24 10          	divl   0x10(%esp)
f0104881:	d3 e6                	shl    %cl,%esi
f0104883:	89 d1                	mov    %edx,%ecx
f0104885:	f7 64 24 0c          	mull   0xc(%esp)
f0104889:	39 d1                	cmp    %edx,%ecx
f010488b:	89 74 24 14          	mov    %esi,0x14(%esp)
f010488f:	89 d7                	mov    %edx,%edi
f0104891:	89 c6                	mov    %eax,%esi
f0104893:	72 0a                	jb     f010489f <__umoddi3+0x12f>
f0104895:	39 44 24 14          	cmp    %eax,0x14(%esp)
f0104899:	73 10                	jae    f01048ab <__umoddi3+0x13b>
f010489b:	39 d1                	cmp    %edx,%ecx
f010489d:	75 0c                	jne    f01048ab <__umoddi3+0x13b>
f010489f:	89 d7                	mov    %edx,%edi
f01048a1:	89 c6                	mov    %eax,%esi
f01048a3:	2b 74 24 0c          	sub    0xc(%esp),%esi
f01048a7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f01048ab:	89 ca                	mov    %ecx,%edx
f01048ad:	89 e9                	mov    %ebp,%ecx
f01048af:	8b 44 24 14          	mov    0x14(%esp),%eax
f01048b3:	29 f0                	sub    %esi,%eax
f01048b5:	19 fa                	sbb    %edi,%edx
f01048b7:	d3 e8                	shr    %cl,%eax
f01048b9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f01048be:	89 d7                	mov    %edx,%edi
f01048c0:	d3 e7                	shl    %cl,%edi
f01048c2:	89 e9                	mov    %ebp,%ecx
f01048c4:	09 f8                	or     %edi,%eax
f01048c6:	d3 ea                	shr    %cl,%edx
f01048c8:	83 c4 20             	add    $0x20,%esp
f01048cb:	5e                   	pop    %esi
f01048cc:	5f                   	pop    %edi
f01048cd:	5d                   	pop    %ebp
f01048ce:	c3                   	ret    
f01048cf:	90                   	nop
f01048d0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01048d4:	29 f9                	sub    %edi,%ecx
f01048d6:	19 c6                	sbb    %eax,%esi
f01048d8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01048dc:	89 74 24 18          	mov    %esi,0x18(%esp)
f01048e0:	e9 ff fe ff ff       	jmp    f01047e4 <__umoddi3+0x74>
