
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 91 04 00 00       	call   8004c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 80 27 80 00       	push   $0x802780
  80003f:	e8 71 05 00 00       	call   8005b5 <cprintf>
	exit();
  800044:	e8 bf 04 00 00       	call   800508 <exit>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <umain>:

void umain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 58             	sub    $0x58,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  800057:	68 84 27 80 00       	push   $0x802784
  80005c:	e8 54 05 00 00       	call   8005b5 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800061:	c7 04 24 94 27 80 00 	movl   $0x802794,(%esp)
  800068:	e8 23 04 00 00       	call   800490 <inet_addr>
  80006d:	83 c4 0c             	add    $0xc,%esp
  800070:	50                   	push   %eax
  800071:	68 94 27 80 00       	push   $0x802794
  800076:	68 9e 27 80 00       	push   $0x80279e
  80007b:	e8 35 05 00 00       	call   8005b5 <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800080:	83 c4 0c             	add    $0xc,%esp
  800083:	6a 06                	push   $0x6
  800085:	6a 01                	push   $0x1
  800087:	6a 02                	push   $0x2
  800089:	e8 76 1b 00 00       	call   801c04 <socket>
  80008e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	79 0a                	jns    8000a2 <umain+0x54>
		die("Failed to create socket");
  800098:	b8 b3 27 80 00       	mov    $0x8027b3,%eax
  80009d:	e8 91 ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	68 cb 27 80 00       	push   $0x8027cb
  8000aa:	e8 06 05 00 00       	call   8005b5 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000af:	83 c4 0c             	add    $0xc,%esp
  8000b2:	6a 10                	push   $0x10
  8000b4:	6a 00                	push   $0x0
  8000b6:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000b9:	53                   	push   %ebx
  8000ba:	e8 c2 0b 00 00       	call   800c81 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000bf:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000c3:	c7 04 24 94 27 80 00 	movl   $0x802794,(%esp)
  8000ca:	e8 c1 03 00 00       	call   800490 <inet_addr>
  8000cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000d2:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000d9:	e8 83 01 00 00       	call   800261 <htons>
  8000de:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  8000e2:	c7 04 24 da 27 80 00 	movl   $0x8027da,(%esp)
  8000e9:	e8 c7 04 00 00       	call   8005b5 <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  8000ee:	83 c4 0c             	add    $0xc,%esp
  8000f1:	6a 10                	push   $0x10
  8000f3:	53                   	push   %ebx
  8000f4:	ff 75 b4             	pushl  -0x4c(%ebp)
  8000f7:	e8 bb 1a 00 00       	call   801bb7 <connect>
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	85 c0                	test   %eax,%eax
  800101:	79 0a                	jns    80010d <umain+0xbf>
		die("Failed to connect with server");
  800103:	b8 f7 27 80 00       	mov    $0x8027f7,%eax
  800108:	e8 26 ff ff ff       	call   800033 <die>

	cprintf("connected to server\n");
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	68 15 28 80 00       	push   $0x802815
  800115:	e8 9b 04 00 00       	call   8005b5 <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80011a:	83 c4 04             	add    $0x4,%esp
  80011d:	ff 35 00 30 80 00    	pushl  0x803000
  800123:	e8 db 09 00 00       	call   800b03 <strlen>
  800128:	89 c7                	mov    %eax,%edi
  80012a:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80012d:	83 c4 0c             	add    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	ff 35 00 30 80 00    	pushl  0x803000
  800137:	ff 75 b4             	pushl  -0x4c(%ebp)
  80013a:	e8 53 14 00 00       	call   801592 <write>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	39 f8                	cmp    %edi,%eax
  800144:	74 0a                	je     800150 <umain+0x102>
		die("Mismatch in number of sent bytes");
  800146:	b8 44 28 80 00       	mov    $0x802844,%eax
  80014b:	e8 e3 fe ff ff       	call   800033 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	68 2a 28 80 00       	push   $0x80282a
  800158:	e8 58 04 00 00       	call   8005b5 <cprintf>
	while (received < echolen) {
  80015d:	83 c4 10             	add    $0x10,%esp
{
	int sock;
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
  800160:	be 00 00 00 00       	mov    $0x0,%esi

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  800165:	8d 7d b8             	lea    -0x48(%ebp),%edi
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  800168:	eb 34                	jmp    80019e <umain+0x150>
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80016a:	83 ec 04             	sub    $0x4,%esp
  80016d:	6a 1f                	push   $0x1f
  80016f:	57                   	push   %edi
  800170:	ff 75 b4             	pushl  -0x4c(%ebp)
  800173:	e8 44 13 00 00       	call   8014bc <read>
  800178:	89 c3                	mov    %eax,%ebx
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	85 c0                	test   %eax,%eax
  80017f:	7f 0a                	jg     80018b <umain+0x13d>
			die("Failed to receive bytes from server");
  800181:	b8 68 28 80 00       	mov    $0x802868,%eax
  800186:	e8 a8 fe ff ff       	call   800033 <die>
		}
		received += bytes;
  80018b:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  80018d:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	57                   	push   %edi
  800196:	e8 1a 04 00 00       	call   8005b5 <cprintf>
  80019b:	83 c4 10             	add    $0x10,%esp
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  80019e:	39 75 b0             	cmp    %esi,-0x50(%ebp)
  8001a1:	77 c7                	ja     80016a <umain+0x11c>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 34 28 80 00       	push   $0x802834
  8001ab:	e8 05 04 00 00       	call   8005b5 <cprintf>

	close(sock);
  8001b0:	83 c4 04             	add    $0x4,%esp
  8001b3:	ff 75 b4             	pushl  -0x4c(%ebp)
  8001b6:	e8 c1 11 00 00       	call   80137c <close>
  8001bb:	83 c4 10             	add    $0x10,%esp
}
  8001be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001d5:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001d8:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001df:	0f b6 1f             	movzbl (%edi),%ebx
  8001e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001e7:	0f b6 d3             	movzbl %bl,%edx
  8001ea:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8001ed:	8d 04 c2             	lea    (%edx,%eax,8),%eax
  8001f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001f3:	66 c1 e8 0b          	shr    $0xb,%ax
  8001f7:	89 c2                	mov    %eax,%edx
  8001f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001fc:	01 c0                	add    %eax,%eax
  8001fe:	29 c3                	sub    %eax,%ebx
  800200:	89 d8                	mov    %ebx,%eax
      *ap /= (u8_t)10;
  800202:	89 d3                	mov    %edx,%ebx
      inv[i++] = '0' + rem;
  800204:	8d 71 01             	lea    0x1(%ecx),%esi
  800207:	0f b6 c9             	movzbl %cl,%ecx
  80020a:	83 c0 30             	add    $0x30,%eax
  80020d:	88 44 0d ed          	mov    %al,-0x13(%ebp,%ecx,1)
  800211:	89 f1                	mov    %esi,%ecx
    } while(*ap);
  800213:	84 d2                	test   %dl,%dl
  800215:	75 d0                	jne    8001e7 <inet_ntoa+0x21>
  800217:	89 f2                	mov    %esi,%edx
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  800219:	89 f3                	mov    %esi,%ebx
  80021b:	c6 07 00             	movb   $0x0,(%edi)
  80021e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800221:	eb 0d                	jmp    800230 <inet_ntoa+0x6a>
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  800223:	0f b6 c2             	movzbl %dl,%eax
  800226:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  80022b:	88 01                	mov    %al,(%ecx)
  80022d:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800230:	83 ea 01             	sub    $0x1,%edx
  800233:	80 fa ff             	cmp    $0xff,%dl
  800236:	75 eb                	jne    800223 <inet_ntoa+0x5d>
  800238:	0f b6 db             	movzbl %bl,%ebx
  80023b:	03 5d e0             	add    -0x20(%ebp),%ebx
      *rp++ = inv[i];
    *rp++ = '.';
  80023e:	8d 43 01             	lea    0x1(%ebx),%eax
  800241:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800244:	c6 03 2e             	movb   $0x2e,(%ebx)
    ap++;
  800247:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80024a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80024d:	39 c7                	cmp    %eax,%edi
  80024f:	75 8e                	jne    8001df <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800251:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  800254:	b8 00 40 80 00       	mov    $0x804000,%eax
  800259:	83 c4 14             	add    $0x14,%esp
  80025c:	5b                   	pop    %ebx
  80025d:	5e                   	pop    %esi
  80025e:	5f                   	pop    %edi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800264:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800268:	66 c1 c0 08          	rol    $0x8,%ax
}
  80026c:	5d                   	pop    %ebp
  80026d:	c3                   	ret    

0080026e <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800271:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800275:	66 c1 c0 08          	rol    $0x8,%ax
 */
u16_t
ntohs(u16_t n)
{
  return htons(n);
}
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  800281:	89 d1                	mov    %edx,%ecx
  800283:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  800286:	89 d0                	mov    %edx,%eax
  800288:	c1 e0 18             	shl    $0x18,%eax
  80028b:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  80028d:	89 d1                	mov    %edx,%ecx
  80028f:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800295:	c1 e1 08             	shl    $0x8,%ecx
  800298:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  80029a:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002a0:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002a3:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 1c             	sub    $0x1c,%esp
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002b3:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002b6:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8002b9:	89 75 d8             	mov    %esi,-0x28(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002bc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002bf:	80 f9 09             	cmp    $0x9,%cl
  8002c2:	0f 87 a6 01 00 00    	ja     80046e <inet_aton+0x1c7>
      return (0);
    val = 0;
    base = 10;
  8002c8:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
    if (c == '0') {
  8002cf:	83 fa 30             	cmp    $0x30,%edx
  8002d2:	75 2b                	jne    8002ff <inet_aton+0x58>
      c = *++cp;
  8002d4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002d8:	89 d1                	mov    %edx,%ecx
  8002da:	83 e1 df             	and    $0xffffffdf,%ecx
  8002dd:	80 f9 58             	cmp    $0x58,%cl
  8002e0:	74 0f                	je     8002f1 <inet_aton+0x4a>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002e2:	83 c0 01             	add    $0x1,%eax
  8002e5:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8002e8:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  8002ef:	eb 0e                	jmp    8002ff <inet_aton+0x58>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8002f1:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8002f5:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8002f8:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  8002ff:	83 c0 01             	add    $0x1,%eax
  800302:	bf 00 00 00 00       	mov    $0x0,%edi
  800307:	eb 03                	jmp    80030c <inet_aton+0x65>
  800309:	83 c0 01             	add    $0x1,%eax
  80030c:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  80030f:	89 d6                	mov    %edx,%esi
  800311:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800314:	80 f9 09             	cmp    $0x9,%cl
  800317:	77 0d                	ja     800326 <inet_aton+0x7f>
        val = (val * base) + (int)(c - '0');
  800319:	0f af 7d e0          	imul   -0x20(%ebp),%edi
  80031d:	8d 7c 3a d0          	lea    -0x30(%edx,%edi,1),%edi
        c = *++cp;
  800321:	0f be 10             	movsbl (%eax),%edx
  800324:	eb e3                	jmp    800309 <inet_aton+0x62>
      } else if (base == 16 && isxdigit(c)) {
  800326:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  80032a:	75 2e                	jne    80035a <inet_aton+0xb3>
  80032c:	8d 4e 9f             	lea    -0x61(%esi),%ecx
  80032f:	88 4d df             	mov    %cl,-0x21(%ebp)
  800332:	89 d1                	mov    %edx,%ecx
  800334:	83 e1 df             	and    $0xffffffdf,%ecx
  800337:	83 e9 41             	sub    $0x41,%ecx
  80033a:	80 f9 05             	cmp    $0x5,%cl
  80033d:	77 21                	ja     800360 <inet_aton+0xb9>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  80033f:	c1 e7 04             	shl    $0x4,%edi
  800342:	83 c2 0a             	add    $0xa,%edx
  800345:	80 7d df 1a          	cmpb   $0x1a,-0x21(%ebp)
  800349:	19 c9                	sbb    %ecx,%ecx
  80034b:	83 e1 20             	and    $0x20,%ecx
  80034e:	83 c1 41             	add    $0x41,%ecx
  800351:	29 ca                	sub    %ecx,%edx
  800353:	09 d7                	or     %edx,%edi
        c = *++cp;
  800355:	0f be 10             	movsbl (%eax),%edx
  800358:	eb af                	jmp    800309 <inet_aton+0x62>
  80035a:	89 d0                	mov    %edx,%eax
  80035c:	89 f9                	mov    %edi,%ecx
  80035e:	eb 04                	jmp    800364 <inet_aton+0xbd>
  800360:	89 d0                	mov    %edx,%eax
  800362:	89 f9                	mov    %edi,%ecx
      } else
        break;
    }
    if (c == '.') {
  800364:	83 f8 2e             	cmp    $0x2e,%eax
  800367:	75 23                	jne    80038c <inet_aton+0xe5>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800369:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80036c:	8d 75 f0             	lea    -0x10(%ebp),%esi
  80036f:	39 f0                	cmp    %esi,%eax
  800371:	0f 84 fe 00 00 00    	je     800475 <inet_aton+0x1ce>
        return (0);
      *pp++ = val;
  800377:	83 c0 04             	add    $0x4,%eax
  80037a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80037d:	89 48 fc             	mov    %ecx,-0x4(%eax)
      c = *++cp;
  800380:	8d 43 01             	lea    0x1(%ebx),%eax
  800383:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800387:	e9 30 ff ff ff       	jmp    8002bc <inet_aton+0x15>
  80038c:	89 f9                	mov    %edi,%ecx
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80038e:	85 d2                	test   %edx,%edx
  800390:	74 29                	je     8003bb <inet_aton+0x114>
    return (0);
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800397:	89 f3                	mov    %esi,%ebx
  800399:	80 fb 1f             	cmp    $0x1f,%bl
  80039c:	0f 86 e6 00 00 00    	jbe    800488 <inet_aton+0x1e1>
  8003a2:	84 d2                	test   %dl,%dl
  8003a4:	0f 88 d2 00 00 00    	js     80047c <inet_aton+0x1d5>
  8003aa:	83 fa 20             	cmp    $0x20,%edx
  8003ad:	74 0c                	je     8003bb <inet_aton+0x114>
  8003af:	83 ea 09             	sub    $0x9,%edx
  8003b2:	83 fa 04             	cmp    $0x4,%edx
  8003b5:	0f 87 cd 00 00 00    	ja     800488 <inet_aton+0x1e1>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  8003bb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003c1:	29 c2                	sub    %eax,%edx
  8003c3:	c1 fa 02             	sar    $0x2,%edx
  8003c6:	83 c2 01             	add    $0x1,%edx
  switch (n) {
  8003c9:	83 fa 02             	cmp    $0x2,%edx
  8003cc:	74 20                	je     8003ee <inet_aton+0x147>
  8003ce:	83 fa 02             	cmp    $0x2,%edx
  8003d1:	7f 0f                	jg     8003e2 <inet_aton+0x13b>

  case 0:
    return (0);       /* initial nondigit */
  8003d3:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003d8:	85 d2                	test   %edx,%edx
  8003da:	0f 84 a8 00 00 00    	je     800488 <inet_aton+0x1e1>
  8003e0:	eb 71                	jmp    800453 <inet_aton+0x1ac>
  8003e2:	83 fa 03             	cmp    $0x3,%edx
  8003e5:	74 24                	je     80040b <inet_aton+0x164>
  8003e7:	83 fa 04             	cmp    $0x4,%edx
  8003ea:	74 40                	je     80042c <inet_aton+0x185>
  8003ec:	eb 65                	jmp    800453 <inet_aton+0x1ac>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8003f3:	81 f9 ff ff ff 00    	cmp    $0xffffff,%ecx
  8003f9:	0f 87 89 00 00 00    	ja     800488 <inet_aton+0x1e1>
      return (0);
    val |= parts[0] << 24;
  8003ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800402:	c1 e0 18             	shl    $0x18,%eax
  800405:	89 cf                	mov    %ecx,%edi
  800407:	09 c7                	or     %eax,%edi
    break;
  800409:	eb 48                	jmp    800453 <inet_aton+0x1ac>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800410:	81 f9 ff ff 00 00    	cmp    $0xffff,%ecx
  800416:	77 70                	ja     800488 <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800418:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80041b:	c1 e2 10             	shl    $0x10,%edx
  80041e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800421:	c1 e0 18             	shl    $0x18,%eax
  800424:	09 d0                	or     %edx,%eax
  800426:	09 c8                	or     %ecx,%eax
  800428:	89 c7                	mov    %eax,%edi
    break;
  80042a:	eb 27                	jmp    800453 <inet_aton+0x1ac>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80042c:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800431:	81 f9 ff 00 00 00    	cmp    $0xff,%ecx
  800437:	77 4f                	ja     800488 <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800439:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80043c:	c1 e2 10             	shl    $0x10,%edx
  80043f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800442:	c1 e0 18             	shl    $0x18,%eax
  800445:	09 c2                	or     %eax,%edx
  800447:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80044a:	c1 e0 08             	shl    $0x8,%eax
  80044d:	09 d0                	or     %edx,%eax
  80044f:	09 c8                	or     %ecx,%eax
  800451:	89 c7                	mov    %eax,%edi
    break;
  }
  if (addr)
  800453:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800457:	74 2a                	je     800483 <inet_aton+0x1dc>
    addr->s_addr = htonl(val);
  800459:	57                   	push   %edi
  80045a:	e8 1c fe ff ff       	call   80027b <htonl>
  80045f:	83 c4 04             	add    $0x4,%esp
  800462:	8b 75 0c             	mov    0xc(%ebp),%esi
  800465:	89 06                	mov    %eax,(%esi)
  return (1);
  800467:	b8 01 00 00 00       	mov    $0x1,%eax
  80046c:	eb 1a                	jmp    800488 <inet_aton+0x1e1>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	eb 13                	jmp    800488 <inet_aton+0x1e1>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	eb 0c                	jmp    800488 <inet_aton+0x1e1>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	eb 05                	jmp    800488 <inet_aton+0x1e1>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800483:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048b:	5b                   	pop    %ebx
  80048c:	5e                   	pop    %esi
  80048d:	5f                   	pop    %edi
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800496:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800499:	50                   	push   %eax
  80049a:	ff 75 08             	pushl  0x8(%ebp)
  80049d:	e8 05 fe ff ff       	call   8002a7 <inet_aton>
  8004a2:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004ac:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  8004b5:	ff 75 08             	pushl  0x8(%ebp)
  8004b8:	e8 be fd ff ff       	call   80027b <htonl>
  8004bd:	83 c4 04             	add    $0x4,%esp
}
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    

008004c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	56                   	push   %esi
  8004c6:	53                   	push   %ebx
  8004c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8004cd:	e8 35 0a 00 00       	call   800f07 <sys_getenvid>
  8004d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004df:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004e4:	85 db                	test   %ebx,%ebx
  8004e6:	7e 07                	jle    8004ef <libmain+0x2d>
		binaryname = argv[0];
  8004e8:	8b 06                	mov    (%esi),%eax
  8004ea:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	e8 55 fb ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  8004f9:	e8 0a 00 00 00       	call   800508 <exit>
  8004fe:	83 c4 10             	add    $0x10,%esp
}
  800501:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800504:	5b                   	pop    %ebx
  800505:	5e                   	pop    %esi
  800506:	5d                   	pop    %ebp
  800507:	c3                   	ret    

00800508 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80050e:	e8 96 0e 00 00       	call   8013a9 <close_all>
	sys_env_destroy(0);
  800513:	83 ec 0c             	sub    $0xc,%esp
  800516:	6a 00                	push   $0x0
  800518:	e8 a9 09 00 00       	call   800ec6 <sys_env_destroy>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80052c:	8b 13                	mov    (%ebx),%edx
  80052e:	8d 42 01             	lea    0x1(%edx),%eax
  800531:	89 03                	mov    %eax,(%ebx)
  800533:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800536:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80053a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80053f:	75 1a                	jne    80055b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	68 ff 00 00 00       	push   $0xff
  800549:	8d 43 08             	lea    0x8(%ebx),%eax
  80054c:	50                   	push   %eax
  80054d:	e8 37 09 00 00       	call   800e89 <sys_cputs>
		b->idx = 0;
  800552:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800558:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80055b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80055f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80056d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800574:	00 00 00 
	b.cnt = 0;
  800577:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80057e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	ff 75 08             	pushl  0x8(%ebp)
  800587:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80058d:	50                   	push   %eax
  80058e:	68 22 05 80 00       	push   $0x800522
  800593:	e8 4f 01 00 00       	call   8006e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800598:	83 c4 08             	add    $0x8,%esp
  80059b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005a7:	50                   	push   %eax
  8005a8:	e8 dc 08 00 00       	call   800e89 <sys_cputs>

	return b.cnt;
}
  8005ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    

008005b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005be:	50                   	push   %eax
  8005bf:	ff 75 08             	pushl  0x8(%ebp)
  8005c2:	e8 9d ff ff ff       	call   800564 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005c7:	c9                   	leave  
  8005c8:	c3                   	ret    

008005c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005c9:	55                   	push   %ebp
  8005ca:	89 e5                	mov    %esp,%ebp
  8005cc:	57                   	push   %edi
  8005cd:	56                   	push   %esi
  8005ce:	53                   	push   %ebx
  8005cf:	83 ec 1c             	sub    $0x1c,%esp
  8005d2:	89 c7                	mov    %eax,%edi
  8005d4:	89 d6                	mov    %edx,%esi
  8005d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005dc:	89 d1                	mov    %edx,%ecx
  8005de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005f4:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8005f7:	72 05                	jb     8005fe <printnum+0x35>
  8005f9:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8005fc:	77 3e                	ja     80063c <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005fe:	83 ec 0c             	sub    $0xc,%esp
  800601:	ff 75 18             	pushl  0x18(%ebp)
  800604:	83 eb 01             	sub    $0x1,%ebx
  800607:	53                   	push   %ebx
  800608:	50                   	push   %eax
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	ff 75 dc             	pushl  -0x24(%ebp)
  800615:	ff 75 d8             	pushl  -0x28(%ebp)
  800618:	e8 b3 1e 00 00       	call   8024d0 <__udivdi3>
  80061d:	83 c4 18             	add    $0x18,%esp
  800620:	52                   	push   %edx
  800621:	50                   	push   %eax
  800622:	89 f2                	mov    %esi,%edx
  800624:	89 f8                	mov    %edi,%eax
  800626:	e8 9e ff ff ff       	call   8005c9 <printnum>
  80062b:	83 c4 20             	add    $0x20,%esp
  80062e:	eb 13                	jmp    800643 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	ff 75 18             	pushl  0x18(%ebp)
  800637:	ff d7                	call   *%edi
  800639:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80063c:	83 eb 01             	sub    $0x1,%ebx
  80063f:	85 db                	test   %ebx,%ebx
  800641:	7f ed                	jg     800630 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	56                   	push   %esi
  800647:	83 ec 04             	sub    $0x4,%esp
  80064a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80064d:	ff 75 e0             	pushl  -0x20(%ebp)
  800650:	ff 75 dc             	pushl  -0x24(%ebp)
  800653:	ff 75 d8             	pushl  -0x28(%ebp)
  800656:	e8 a5 1f 00 00       	call   802600 <__umoddi3>
  80065b:	83 c4 14             	add    $0x14,%esp
  80065e:	0f be 80 96 28 80 00 	movsbl 0x802896(%eax),%eax
  800665:	50                   	push   %eax
  800666:	ff d7                	call   *%edi
  800668:	83 c4 10             	add    $0x10,%esp
}
  80066b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066e:	5b                   	pop    %ebx
  80066f:	5e                   	pop    %esi
  800670:	5f                   	pop    %edi
  800671:	5d                   	pop    %ebp
  800672:	c3                   	ret    

00800673 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800676:	83 fa 01             	cmp    $0x1,%edx
  800679:	7e 0e                	jle    800689 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800680:	89 08                	mov    %ecx,(%eax)
  800682:	8b 02                	mov    (%edx),%eax
  800684:	8b 52 04             	mov    0x4(%edx),%edx
  800687:	eb 22                	jmp    8006ab <getuint+0x38>
	else if (lflag)
  800689:	85 d2                	test   %edx,%edx
  80068b:	74 10                	je     80069d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800692:	89 08                	mov    %ecx,(%eax)
  800694:	8b 02                	mov    (%edx),%eax
  800696:	ba 00 00 00 00       	mov    $0x0,%edx
  80069b:	eb 0e                	jmp    8006ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a2:	89 08                	mov    %ecx,(%eax)
  8006a4:	8b 02                	mov    (%edx),%eax
  8006a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8006bc:	73 0a                	jae    8006c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006c1:	89 08                	mov    %ecx,(%eax)
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	88 02                	mov    %al,(%edx)
}
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006d3:	50                   	push   %eax
  8006d4:	ff 75 10             	pushl  0x10(%ebp)
  8006d7:	ff 75 0c             	pushl  0xc(%ebp)
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 05 00 00 00       	call   8006e7 <vprintfmt>
	va_end(ap);
  8006e2:	83 c4 10             	add    $0x10,%esp
}
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	57                   	push   %edi
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
  8006ed:	83 ec 2c             	sub    $0x2c,%esp
  8006f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006f9:	eb 12                	jmp    80070d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	0f 84 90 03 00 00    	je     800a93 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	53                   	push   %ebx
  800707:	50                   	push   %eax
  800708:	ff d6                	call   *%esi
  80070a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80070d:	83 c7 01             	add    $0x1,%edi
  800710:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800714:	83 f8 25             	cmp    $0x25,%eax
  800717:	75 e2                	jne    8006fb <vprintfmt+0x14>
  800719:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80071d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800724:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80072b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800732:	ba 00 00 00 00       	mov    $0x0,%edx
  800737:	eb 07                	jmp    800740 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800739:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80073c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800740:	8d 47 01             	lea    0x1(%edi),%eax
  800743:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800746:	0f b6 07             	movzbl (%edi),%eax
  800749:	0f b6 c8             	movzbl %al,%ecx
  80074c:	83 e8 23             	sub    $0x23,%eax
  80074f:	3c 55                	cmp    $0x55,%al
  800751:	0f 87 21 03 00 00    	ja     800a78 <vprintfmt+0x391>
  800757:	0f b6 c0             	movzbl %al,%eax
  80075a:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800764:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800768:	eb d6                	jmp    800740 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80076d:	b8 00 00 00 00       	mov    $0x0,%eax
  800772:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800775:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800778:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80077c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80077f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800782:	83 fa 09             	cmp    $0x9,%edx
  800785:	77 39                	ja     8007c0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800787:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80078a:	eb e9                	jmp    800775 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8d 48 04             	lea    0x4(%eax),%ecx
  800792:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800795:	8b 00                	mov    (%eax),%eax
  800797:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80079d:	eb 27                	jmp    8007c6 <vprintfmt+0xdf>
  80079f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a9:	0f 49 c8             	cmovns %eax,%ecx
  8007ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b2:	eb 8c                	jmp    800740 <vprintfmt+0x59>
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007b7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007be:	eb 80                	jmp    800740 <vprintfmt+0x59>
  8007c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007ca:	0f 89 70 ff ff ff    	jns    800740 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007d6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007dd:	e9 5e ff ff ff       	jmp    800740 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007e8:	e9 53 ff ff ff       	jmp    800740 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8d 50 04             	lea    0x4(%eax),%edx
  8007f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	53                   	push   %ebx
  8007fa:	ff 30                	pushl  (%eax)
  8007fc:	ff d6                	call   *%esi
			break;
  8007fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800804:	e9 04 ff ff ff       	jmp    80070d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8d 50 04             	lea    0x4(%eax),%edx
  80080f:	89 55 14             	mov    %edx,0x14(%ebp)
  800812:	8b 00                	mov    (%eax),%eax
  800814:	99                   	cltd   
  800815:	31 d0                	xor    %edx,%eax
  800817:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800819:	83 f8 0f             	cmp    $0xf,%eax
  80081c:	7f 0b                	jg     800829 <vprintfmt+0x142>
  80081e:	8b 14 85 80 2b 80 00 	mov    0x802b80(,%eax,4),%edx
  800825:	85 d2                	test   %edx,%edx
  800827:	75 18                	jne    800841 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800829:	50                   	push   %eax
  80082a:	68 ae 28 80 00       	push   $0x8028ae
  80082f:	53                   	push   %ebx
  800830:	56                   	push   %esi
  800831:	e8 94 fe ff ff       	call   8006ca <printfmt>
  800836:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800839:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80083c:	e9 cc fe ff ff       	jmp    80070d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800841:	52                   	push   %edx
  800842:	68 b5 2c 80 00       	push   $0x802cb5
  800847:	53                   	push   %ebx
  800848:	56                   	push   %esi
  800849:	e8 7c fe ff ff       	call   8006ca <printfmt>
  80084e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800854:	e9 b4 fe ff ff       	jmp    80070d <vprintfmt+0x26>
  800859:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80085c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80085f:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8d 50 04             	lea    0x4(%eax),%edx
  800868:	89 55 14             	mov    %edx,0x14(%ebp)
  80086b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80086d:	85 ff                	test   %edi,%edi
  80086f:	ba a7 28 80 00       	mov    $0x8028a7,%edx
  800874:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800877:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80087b:	0f 84 92 00 00 00    	je     800913 <vprintfmt+0x22c>
  800881:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800885:	0f 8e 96 00 00 00    	jle    800921 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	51                   	push   %ecx
  80088f:	57                   	push   %edi
  800890:	e8 86 02 00 00       	call   800b1b <strnlen>
  800895:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800898:	29 c1                	sub    %eax,%ecx
  80089a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80089d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008a7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008aa:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ac:	eb 0f                	jmp    8008bd <vprintfmt+0x1d6>
					putch(padc, putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b7:	83 ef 01             	sub    $0x1,%edi
  8008ba:	83 c4 10             	add    $0x10,%esp
  8008bd:	85 ff                	test   %edi,%edi
  8008bf:	7f ed                	jg     8008ae <vprintfmt+0x1c7>
  8008c1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008c4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ce:	0f 49 c1             	cmovns %ecx,%eax
  8008d1:	29 c1                	sub    %eax,%ecx
  8008d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8008d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008dc:	89 cb                	mov    %ecx,%ebx
  8008de:	eb 4d                	jmp    80092d <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008e4:	74 1b                	je     800901 <vprintfmt+0x21a>
  8008e6:	0f be c0             	movsbl %al,%eax
  8008e9:	83 e8 20             	sub    $0x20,%eax
  8008ec:	83 f8 5e             	cmp    $0x5e,%eax
  8008ef:	76 10                	jbe    800901 <vprintfmt+0x21a>
					putch('?', putdat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	6a 3f                	push   $0x3f
  8008f9:	ff 55 08             	call   *0x8(%ebp)
  8008fc:	83 c4 10             	add    $0x10,%esp
  8008ff:	eb 0d                	jmp    80090e <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	ff 75 0c             	pushl  0xc(%ebp)
  800907:	52                   	push   %edx
  800908:	ff 55 08             	call   *0x8(%ebp)
  80090b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090e:	83 eb 01             	sub    $0x1,%ebx
  800911:	eb 1a                	jmp    80092d <vprintfmt+0x246>
  800913:	89 75 08             	mov    %esi,0x8(%ebp)
  800916:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800919:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80091c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80091f:	eb 0c                	jmp    80092d <vprintfmt+0x246>
  800921:	89 75 08             	mov    %esi,0x8(%ebp)
  800924:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800927:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80092a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80092d:	83 c7 01             	add    $0x1,%edi
  800930:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800934:	0f be d0             	movsbl %al,%edx
  800937:	85 d2                	test   %edx,%edx
  800939:	74 23                	je     80095e <vprintfmt+0x277>
  80093b:	85 f6                	test   %esi,%esi
  80093d:	78 a1                	js     8008e0 <vprintfmt+0x1f9>
  80093f:	83 ee 01             	sub    $0x1,%esi
  800942:	79 9c                	jns    8008e0 <vprintfmt+0x1f9>
  800944:	89 df                	mov    %ebx,%edi
  800946:	8b 75 08             	mov    0x8(%ebp),%esi
  800949:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094c:	eb 18                	jmp    800966 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	53                   	push   %ebx
  800952:	6a 20                	push   $0x20
  800954:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800956:	83 ef 01             	sub    $0x1,%edi
  800959:	83 c4 10             	add    $0x10,%esp
  80095c:	eb 08                	jmp    800966 <vprintfmt+0x27f>
  80095e:	89 df                	mov    %ebx,%edi
  800960:	8b 75 08             	mov    0x8(%ebp),%esi
  800963:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800966:	85 ff                	test   %edi,%edi
  800968:	7f e4                	jg     80094e <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096d:	e9 9b fd ff ff       	jmp    80070d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800972:	83 fa 01             	cmp    $0x1,%edx
  800975:	7e 16                	jle    80098d <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800977:	8b 45 14             	mov    0x14(%ebp),%eax
  80097a:	8d 50 08             	lea    0x8(%eax),%edx
  80097d:	89 55 14             	mov    %edx,0x14(%ebp)
  800980:	8b 50 04             	mov    0x4(%eax),%edx
  800983:	8b 00                	mov    (%eax),%eax
  800985:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800988:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80098b:	eb 32                	jmp    8009bf <vprintfmt+0x2d8>
	else if (lflag)
  80098d:	85 d2                	test   %edx,%edx
  80098f:	74 18                	je     8009a9 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800991:	8b 45 14             	mov    0x14(%ebp),%eax
  800994:	8d 50 04             	lea    0x4(%eax),%edx
  800997:	89 55 14             	mov    %edx,0x14(%ebp)
  80099a:	8b 00                	mov    (%eax),%eax
  80099c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80099f:	89 c1                	mov    %eax,%ecx
  8009a1:	c1 f9 1f             	sar    $0x1f,%ecx
  8009a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009a7:	eb 16                	jmp    8009bf <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8009a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ac:	8d 50 04             	lea    0x4(%eax),%edx
  8009af:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b2:	8b 00                	mov    (%eax),%eax
  8009b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009b7:	89 c1                	mov    %eax,%ecx
  8009b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8009bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009ce:	79 74                	jns    800a44 <vprintfmt+0x35d>
				putch('-', putdat);
  8009d0:	83 ec 08             	sub    $0x8,%esp
  8009d3:	53                   	push   %ebx
  8009d4:	6a 2d                	push   $0x2d
  8009d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8009d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009db:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009de:	f7 d8                	neg    %eax
  8009e0:	83 d2 00             	adc    $0x0,%edx
  8009e3:	f7 da                	neg    %edx
  8009e5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009ed:	eb 55                	jmp    800a44 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f2:	e8 7c fc ff ff       	call   800673 <getuint>
			base = 10;
  8009f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009fc:	eb 46                	jmp    800a44 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800a01:	e8 6d fc ff ff       	call   800673 <getuint>
                        base = 8;
  800a06:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800a0b:	eb 37                	jmp    800a44 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	53                   	push   %ebx
  800a11:	6a 30                	push   $0x30
  800a13:	ff d6                	call   *%esi
			putch('x', putdat);
  800a15:	83 c4 08             	add    $0x8,%esp
  800a18:	53                   	push   %ebx
  800a19:	6a 78                	push   $0x78
  800a1b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a20:	8d 50 04             	lea    0x4(%eax),%edx
  800a23:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a26:	8b 00                	mov    (%eax),%eax
  800a28:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a2d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a30:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a35:	eb 0d                	jmp    800a44 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a37:	8d 45 14             	lea    0x14(%ebp),%eax
  800a3a:	e8 34 fc ff ff       	call   800673 <getuint>
			base = 16;
  800a3f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a44:	83 ec 0c             	sub    $0xc,%esp
  800a47:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a4b:	57                   	push   %edi
  800a4c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a4f:	51                   	push   %ecx
  800a50:	52                   	push   %edx
  800a51:	50                   	push   %eax
  800a52:	89 da                	mov    %ebx,%edx
  800a54:	89 f0                	mov    %esi,%eax
  800a56:	e8 6e fb ff ff       	call   8005c9 <printnum>
			break;
  800a5b:	83 c4 20             	add    $0x20,%esp
  800a5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a61:	e9 a7 fc ff ff       	jmp    80070d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a66:	83 ec 08             	sub    $0x8,%esp
  800a69:	53                   	push   %ebx
  800a6a:	51                   	push   %ecx
  800a6b:	ff d6                	call   *%esi
			break;
  800a6d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a73:	e9 95 fc ff ff       	jmp    80070d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a78:	83 ec 08             	sub    $0x8,%esp
  800a7b:	53                   	push   %ebx
  800a7c:	6a 25                	push   $0x25
  800a7e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a80:	83 c4 10             	add    $0x10,%esp
  800a83:	eb 03                	jmp    800a88 <vprintfmt+0x3a1>
  800a85:	83 ef 01             	sub    $0x1,%edi
  800a88:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a8c:	75 f7                	jne    800a85 <vprintfmt+0x39e>
  800a8e:	e9 7a fc ff ff       	jmp    80070d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	83 ec 18             	sub    $0x18,%esp
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aaa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800aae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	74 26                	je     800ae2 <vsnprintf+0x47>
  800abc:	85 d2                	test   %edx,%edx
  800abe:	7e 22                	jle    800ae2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac0:	ff 75 14             	pushl  0x14(%ebp)
  800ac3:	ff 75 10             	pushl  0x10(%ebp)
  800ac6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac9:	50                   	push   %eax
  800aca:	68 ad 06 80 00       	push   $0x8006ad
  800acf:	e8 13 fc ff ff       	call   8006e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	eb 05                	jmp    800ae7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af2:	50                   	push   %eax
  800af3:	ff 75 10             	pushl  0x10(%ebp)
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	ff 75 08             	pushl  0x8(%ebp)
  800afc:	e8 9a ff ff ff       	call   800a9b <vsnprintf>
	va_end(ap);

	return rc;
}
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0e:	eb 03                	jmp    800b13 <strlen+0x10>
		n++;
  800b10:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b17:	75 f7                	jne    800b10 <strlen+0xd>
		n++;
	return n;
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b21:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	eb 03                	jmp    800b2e <strnlen+0x13>
		n++;
  800b2b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2e:	39 c2                	cmp    %eax,%edx
  800b30:	74 08                	je     800b3a <strnlen+0x1f>
  800b32:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b36:	75 f3                	jne    800b2b <strnlen+0x10>
  800b38:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b46:	89 c2                	mov    %eax,%edx
  800b48:	83 c2 01             	add    $0x1,%edx
  800b4b:	83 c1 01             	add    $0x1,%ecx
  800b4e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b52:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b55:	84 db                	test   %bl,%bl
  800b57:	75 ef                	jne    800b48 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	53                   	push   %ebx
  800b60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b63:	53                   	push   %ebx
  800b64:	e8 9a ff ff ff       	call   800b03 <strlen>
  800b69:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b6c:	ff 75 0c             	pushl  0xc(%ebp)
  800b6f:	01 d8                	add    %ebx,%eax
  800b71:	50                   	push   %eax
  800b72:	e8 c5 ff ff ff       	call   800b3c <strcpy>
	return dst;
}
  800b77:	89 d8                	mov    %ebx,%eax
  800b79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	8b 75 08             	mov    0x8(%ebp),%esi
  800b86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b89:	89 f3                	mov    %esi,%ebx
  800b8b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b8e:	89 f2                	mov    %esi,%edx
  800b90:	eb 0f                	jmp    800ba1 <strncpy+0x23>
		*dst++ = *src;
  800b92:	83 c2 01             	add    $0x1,%edx
  800b95:	0f b6 01             	movzbl (%ecx),%eax
  800b98:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b9b:	80 39 01             	cmpb   $0x1,(%ecx)
  800b9e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba1:	39 da                	cmp    %ebx,%edx
  800ba3:	75 ed                	jne    800b92 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ba5:	89 f0                	mov    %esi,%eax
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 10             	mov    0x10(%ebp),%edx
  800bb9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bbb:	85 d2                	test   %edx,%edx
  800bbd:	74 21                	je     800be0 <strlcpy+0x35>
  800bbf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc3:	89 f2                	mov    %esi,%edx
  800bc5:	eb 09                	jmp    800bd0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bc7:	83 c2 01             	add    $0x1,%edx
  800bca:	83 c1 01             	add    $0x1,%ecx
  800bcd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd0:	39 c2                	cmp    %eax,%edx
  800bd2:	74 09                	je     800bdd <strlcpy+0x32>
  800bd4:	0f b6 19             	movzbl (%ecx),%ebx
  800bd7:	84 db                	test   %bl,%bl
  800bd9:	75 ec                	jne    800bc7 <strlcpy+0x1c>
  800bdb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bdd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be0:	29 f0                	sub    %esi,%eax
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bef:	eb 06                	jmp    800bf7 <strcmp+0x11>
		p++, q++;
  800bf1:	83 c1 01             	add    $0x1,%ecx
  800bf4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bf7:	0f b6 01             	movzbl (%ecx),%eax
  800bfa:	84 c0                	test   %al,%al
  800bfc:	74 04                	je     800c02 <strcmp+0x1c>
  800bfe:	3a 02                	cmp    (%edx),%al
  800c00:	74 ef                	je     800bf1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c02:	0f b6 c0             	movzbl %al,%eax
  800c05:	0f b6 12             	movzbl (%edx),%edx
  800c08:	29 d0                	sub    %edx,%eax
}
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	53                   	push   %ebx
  800c10:	8b 45 08             	mov    0x8(%ebp),%eax
  800c13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c16:	89 c3                	mov    %eax,%ebx
  800c18:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c1b:	eb 06                	jmp    800c23 <strncmp+0x17>
		n--, p++, q++;
  800c1d:	83 c0 01             	add    $0x1,%eax
  800c20:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c23:	39 d8                	cmp    %ebx,%eax
  800c25:	74 15                	je     800c3c <strncmp+0x30>
  800c27:	0f b6 08             	movzbl (%eax),%ecx
  800c2a:	84 c9                	test   %cl,%cl
  800c2c:	74 04                	je     800c32 <strncmp+0x26>
  800c2e:	3a 0a                	cmp    (%edx),%cl
  800c30:	74 eb                	je     800c1d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c32:	0f b6 00             	movzbl (%eax),%eax
  800c35:	0f b6 12             	movzbl (%edx),%edx
  800c38:	29 d0                	sub    %edx,%eax
  800c3a:	eb 05                	jmp    800c41 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c4e:	eb 07                	jmp    800c57 <strchr+0x13>
		if (*s == c)
  800c50:	38 ca                	cmp    %cl,%dl
  800c52:	74 0f                	je     800c63 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c54:	83 c0 01             	add    $0x1,%eax
  800c57:	0f b6 10             	movzbl (%eax),%edx
  800c5a:	84 d2                	test   %dl,%dl
  800c5c:	75 f2                	jne    800c50 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c6f:	eb 03                	jmp    800c74 <strfind+0xf>
  800c71:	83 c0 01             	add    $0x1,%eax
  800c74:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c77:	84 d2                	test   %dl,%dl
  800c79:	74 04                	je     800c7f <strfind+0x1a>
  800c7b:	38 ca                	cmp    %cl,%dl
  800c7d:	75 f2                	jne    800c71 <strfind+0xc>
			break;
	return (char *) s;
}
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c8d:	85 c9                	test   %ecx,%ecx
  800c8f:	74 36                	je     800cc7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c91:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c97:	75 28                	jne    800cc1 <memset+0x40>
  800c99:	f6 c1 03             	test   $0x3,%cl
  800c9c:	75 23                	jne    800cc1 <memset+0x40>
		c &= 0xFF;
  800c9e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca2:	89 d3                	mov    %edx,%ebx
  800ca4:	c1 e3 08             	shl    $0x8,%ebx
  800ca7:	89 d6                	mov    %edx,%esi
  800ca9:	c1 e6 18             	shl    $0x18,%esi
  800cac:	89 d0                	mov    %edx,%eax
  800cae:	c1 e0 10             	shl    $0x10,%eax
  800cb1:	09 f0                	or     %esi,%eax
  800cb3:	09 c2                	or     %eax,%edx
  800cb5:	89 d0                	mov    %edx,%eax
  800cb7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cb9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cbc:	fc                   	cld    
  800cbd:	f3 ab                	rep stos %eax,%es:(%edi)
  800cbf:	eb 06                	jmp    800cc7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc4:	fc                   	cld    
  800cc5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cc7:	89 f8                	mov    %edi,%eax
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cdc:	39 c6                	cmp    %eax,%esi
  800cde:	73 35                	jae    800d15 <memmove+0x47>
  800ce0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce3:	39 d0                	cmp    %edx,%eax
  800ce5:	73 2e                	jae    800d15 <memmove+0x47>
		s += n;
		d += n;
  800ce7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cea:	89 d6                	mov    %edx,%esi
  800cec:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cf4:	75 13                	jne    800d09 <memmove+0x3b>
  800cf6:	f6 c1 03             	test   $0x3,%cl
  800cf9:	75 0e                	jne    800d09 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cfb:	83 ef 04             	sub    $0x4,%edi
  800cfe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d01:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d04:	fd                   	std    
  800d05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d07:	eb 09                	jmp    800d12 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d09:	83 ef 01             	sub    $0x1,%edi
  800d0c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d0f:	fd                   	std    
  800d10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d12:	fc                   	cld    
  800d13:	eb 1d                	jmp    800d32 <memmove+0x64>
  800d15:	89 f2                	mov    %esi,%edx
  800d17:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d19:	f6 c2 03             	test   $0x3,%dl
  800d1c:	75 0f                	jne    800d2d <memmove+0x5f>
  800d1e:	f6 c1 03             	test   $0x3,%cl
  800d21:	75 0a                	jne    800d2d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d23:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d26:	89 c7                	mov    %eax,%edi
  800d28:	fc                   	cld    
  800d29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2b:	eb 05                	jmp    800d32 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d2d:	89 c7                	mov    %eax,%edi
  800d2f:	fc                   	cld    
  800d30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d39:	ff 75 10             	pushl  0x10(%ebp)
  800d3c:	ff 75 0c             	pushl  0xc(%ebp)
  800d3f:	ff 75 08             	pushl  0x8(%ebp)
  800d42:	e8 87 ff ff ff       	call   800cce <memmove>
}
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    

00800d49 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d54:	89 c6                	mov    %eax,%esi
  800d56:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d59:	eb 1a                	jmp    800d75 <memcmp+0x2c>
		if (*s1 != *s2)
  800d5b:	0f b6 08             	movzbl (%eax),%ecx
  800d5e:	0f b6 1a             	movzbl (%edx),%ebx
  800d61:	38 d9                	cmp    %bl,%cl
  800d63:	74 0a                	je     800d6f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d65:	0f b6 c1             	movzbl %cl,%eax
  800d68:	0f b6 db             	movzbl %bl,%ebx
  800d6b:	29 d8                	sub    %ebx,%eax
  800d6d:	eb 0f                	jmp    800d7e <memcmp+0x35>
		s1++, s2++;
  800d6f:	83 c0 01             	add    $0x1,%eax
  800d72:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d75:	39 f0                	cmp    %esi,%eax
  800d77:	75 e2                	jne    800d5b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d8b:	89 c2                	mov    %eax,%edx
  800d8d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d90:	eb 07                	jmp    800d99 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d92:	38 08                	cmp    %cl,(%eax)
  800d94:	74 07                	je     800d9d <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d96:	83 c0 01             	add    $0x1,%eax
  800d99:	39 d0                	cmp    %edx,%eax
  800d9b:	72 f5                	jb     800d92 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dab:	eb 03                	jmp    800db0 <strtol+0x11>
		s++;
  800dad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db0:	0f b6 01             	movzbl (%ecx),%eax
  800db3:	3c 09                	cmp    $0x9,%al
  800db5:	74 f6                	je     800dad <strtol+0xe>
  800db7:	3c 20                	cmp    $0x20,%al
  800db9:	74 f2                	je     800dad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dbb:	3c 2b                	cmp    $0x2b,%al
  800dbd:	75 0a                	jne    800dc9 <strtol+0x2a>
		s++;
  800dbf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dc2:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc7:	eb 10                	jmp    800dd9 <strtol+0x3a>
  800dc9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dce:	3c 2d                	cmp    $0x2d,%al
  800dd0:	75 07                	jne    800dd9 <strtol+0x3a>
		s++, neg = 1;
  800dd2:	8d 49 01             	lea    0x1(%ecx),%ecx
  800dd5:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dd9:	85 db                	test   %ebx,%ebx
  800ddb:	0f 94 c0             	sete   %al
  800dde:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800de4:	75 19                	jne    800dff <strtol+0x60>
  800de6:	80 39 30             	cmpb   $0x30,(%ecx)
  800de9:	75 14                	jne    800dff <strtol+0x60>
  800deb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800def:	0f 85 82 00 00 00    	jne    800e77 <strtol+0xd8>
		s += 2, base = 16;
  800df5:	83 c1 02             	add    $0x2,%ecx
  800df8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dfd:	eb 16                	jmp    800e15 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800dff:	84 c0                	test   %al,%al
  800e01:	74 12                	je     800e15 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e03:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e08:	80 39 30             	cmpb   $0x30,(%ecx)
  800e0b:	75 08                	jne    800e15 <strtol+0x76>
		s++, base = 8;
  800e0d:	83 c1 01             	add    $0x1,%ecx
  800e10:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e15:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e1d:	0f b6 11             	movzbl (%ecx),%edx
  800e20:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e23:	89 f3                	mov    %esi,%ebx
  800e25:	80 fb 09             	cmp    $0x9,%bl
  800e28:	77 08                	ja     800e32 <strtol+0x93>
			dig = *s - '0';
  800e2a:	0f be d2             	movsbl %dl,%edx
  800e2d:	83 ea 30             	sub    $0x30,%edx
  800e30:	eb 22                	jmp    800e54 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800e32:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e35:	89 f3                	mov    %esi,%ebx
  800e37:	80 fb 19             	cmp    $0x19,%bl
  800e3a:	77 08                	ja     800e44 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800e3c:	0f be d2             	movsbl %dl,%edx
  800e3f:	83 ea 57             	sub    $0x57,%edx
  800e42:	eb 10                	jmp    800e54 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800e44:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e47:	89 f3                	mov    %esi,%ebx
  800e49:	80 fb 19             	cmp    $0x19,%bl
  800e4c:	77 16                	ja     800e64 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e4e:	0f be d2             	movsbl %dl,%edx
  800e51:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e54:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e57:	7d 0f                	jge    800e68 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800e59:	83 c1 01             	add    $0x1,%ecx
  800e5c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e60:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e62:	eb b9                	jmp    800e1d <strtol+0x7e>
  800e64:	89 c2                	mov    %eax,%edx
  800e66:	eb 02                	jmp    800e6a <strtol+0xcb>
  800e68:	89 c2                	mov    %eax,%edx

	if (endptr)
  800e6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6e:	74 0d                	je     800e7d <strtol+0xde>
		*endptr = (char *) s;
  800e70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e73:	89 0e                	mov    %ecx,(%esi)
  800e75:	eb 06                	jmp    800e7d <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e77:	84 c0                	test   %al,%al
  800e79:	75 92                	jne    800e0d <strtol+0x6e>
  800e7b:	eb 98                	jmp    800e15 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e7d:	f7 da                	neg    %edx
  800e7f:	85 ff                	test   %edi,%edi
  800e81:	0f 45 c2             	cmovne %edx,%eax
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	89 d1                	mov    %edx,%ecx
  800eb9:	89 d3                	mov    %edx,%ebx
  800ebb:	89 d7                	mov    %edx,%edi
  800ebd:	89 d6                	mov    %edx,%esi
  800ebf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 03                	push   $0x3
  800eee:	68 df 2b 80 00       	push   $0x802bdf
  800ef3:	6a 22                	push   $0x22
  800ef5:	68 fc 2b 80 00       	push   $0x802bfc
  800efa:	e8 5b 14 00 00       	call   80235a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f12:	b8 02 00 00 00       	mov    $0x2,%eax
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 d3                	mov    %edx,%ebx
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 d6                	mov    %edx,%esi
  800f1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_yield>:

void
sys_yield(void)
{      
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 04 00 00 00       	mov    $0x4,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	89 f7                	mov    %esi,%edi
  800f63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 17                	jle    800f80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	50                   	push   %eax
  800f6d:	6a 04                	push   $0x4
  800f6f:	68 df 2b 80 00       	push   $0x802bdf
  800f74:	6a 22                	push   $0x22
  800f76:	68 fc 2b 80 00       	push   $0x802bfc
  800f7b:	e8 da 13 00 00       	call   80235a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f91:	b8 05 00 00 00       	mov    $0x5,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa2:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 17                	jle    800fc2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	50                   	push   %eax
  800faf:	6a 05                	push   $0x5
  800fb1:	68 df 2b 80 00       	push   $0x802bdf
  800fb6:	6a 22                	push   $0x22
  800fb8:	68 fc 2b 80 00       	push   $0x802bfc
  800fbd:	e8 98 13 00 00       	call   80235a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 df                	mov    %ebx,%edi
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7e 17                	jle    801004 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	50                   	push   %eax
  800ff1:	6a 06                	push   $0x6
  800ff3:	68 df 2b 80 00       	push   $0x802bdf
  800ff8:	6a 22                	push   $0x22
  800ffa:	68 fc 2b 80 00       	push   $0x802bfc
  800fff:	e8 56 13 00 00       	call   80235a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101a:	b8 08 00 00 00       	mov    $0x8,%eax
  80101f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	89 df                	mov    %ebx,%edi
  801027:	89 de                	mov    %ebx,%esi
  801029:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 17                	jle    801046 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	6a 08                	push   $0x8
  801035:	68 df 2b 80 00       	push   $0x802bdf
  80103a:	6a 22                	push   $0x22
  80103c:	68 fc 2b 80 00       	push   $0x802bfc
  801041:	e8 14 13 00 00       	call   80235a <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  801046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105c:	b8 09 00 00 00       	mov    $0x9,%eax
  801061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 df                	mov    %ebx,%edi
  801069:	89 de                	mov    %ebx,%esi
  80106b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 09                	push   $0x9
  801077:	68 df 2b 80 00       	push   $0x802bdf
  80107c:	6a 22                	push   $0x22
  80107e:	68 fc 2b 80 00       	push   $0x802bfc
  801083:	e8 d2 12 00 00       	call   80235a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 df                	mov    %ebx,%edi
  8010ab:	89 de                	mov    %ebx,%esi
  8010ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 17                	jle    8010ca <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 0a                	push   $0xa
  8010b9:	68 df 2b 80 00       	push   $0x802bdf
  8010be:	6a 22                	push   $0x22
  8010c0:	68 fc 2b 80 00       	push   $0x802bfc
  8010c5:	e8 90 12 00 00       	call   80235a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8010d8:	be 00 00 00 00       	mov    $0x0,%esi
  8010dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ee:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8010fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801103:	b8 0d 00 00 00       	mov    $0xd,%eax
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 cb                	mov    %ecx,%ebx
  80110d:	89 cf                	mov    %ecx,%edi
  80110f:	89 ce                	mov    %ecx,%esi
  801111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 0d                	push   $0xd
  80111d:	68 df 2b 80 00       	push   $0x802bdf
  801122:	6a 22                	push   $0x22
  801124:	68 fc 2b 80 00       	push   $0x802bfc
  801129:	e8 2c 12 00 00       	call   80235a <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80113c:	ba 00 00 00 00       	mov    $0x0,%edx
  801141:	b8 0e 00 00 00       	mov    $0xe,%eax
  801146:	89 d1                	mov    %edx,%ecx
  801148:	89 d3                	mov    %edx,%ebx
  80114a:	89 d7                	mov    %edx,%edi
  80114c:	89 d6                	mov    %edx,%esi
  80114e:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <sys_transmit>:

int
sys_transmit(void *addr)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80115e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801163:	b8 0f 00 00 00       	mov    $0xf,%eax
  801168:	8b 55 08             	mov    0x8(%ebp),%edx
  80116b:	89 cb                	mov    %ecx,%ebx
  80116d:	89 cf                	mov    %ecx,%edi
  80116f:	89 ce                	mov    %ecx,%esi
  801171:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801173:	85 c0                	test   %eax,%eax
  801175:	7e 17                	jle    80118e <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801177:	83 ec 0c             	sub    $0xc,%esp
  80117a:	50                   	push   %eax
  80117b:	6a 0f                	push   $0xf
  80117d:	68 df 2b 80 00       	push   $0x802bdf
  801182:	6a 22                	push   $0x22
  801184:	68 fc 2b 80 00       	push   $0x802bfc
  801189:	e8 cc 11 00 00       	call   80235a <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  80118e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <sys_recv>:

int
sys_recv(void *addr)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	57                   	push   %edi
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
  80119c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80119f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a4:	b8 10 00 00 00       	mov    $0x10,%eax
  8011a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ac:	89 cb                	mov    %ecx,%ebx
  8011ae:	89 cf                	mov    %ecx,%edi
  8011b0:	89 ce                	mov    %ecx,%esi
  8011b2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	7e 17                	jle    8011cf <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b8:	83 ec 0c             	sub    $0xc,%esp
  8011bb:	50                   	push   %eax
  8011bc:	6a 10                	push   $0x10
  8011be:	68 df 2b 80 00       	push   $0x802bdf
  8011c3:	6a 22                	push   $0x22
  8011c5:	68 fc 2b 80 00       	push   $0x802bfc
  8011ca:	e8 8b 11 00 00       	call   80235a <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8011cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011da:	8b 45 08             	mov    0x8(%ebp),%eax
  8011dd:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e2:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ed:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8011f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801204:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801209:	89 c2                	mov    %eax,%edx
  80120b:	c1 ea 16             	shr    $0x16,%edx
  80120e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801215:	f6 c2 01             	test   $0x1,%dl
  801218:	74 11                	je     80122b <fd_alloc+0x2d>
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	c1 ea 0c             	shr    $0xc,%edx
  80121f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801226:	f6 c2 01             	test   $0x1,%dl
  801229:	75 09                	jne    801234 <fd_alloc+0x36>
			*fd_store = fd;
  80122b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
  801232:	eb 17                	jmp    80124b <fd_alloc+0x4d>
  801234:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801239:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80123e:	75 c9                	jne    801209 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801240:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801246:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801253:	83 f8 1f             	cmp    $0x1f,%eax
  801256:	77 36                	ja     80128e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801258:	c1 e0 0c             	shl    $0xc,%eax
  80125b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801260:	89 c2                	mov    %eax,%edx
  801262:	c1 ea 16             	shr    $0x16,%edx
  801265:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126c:	f6 c2 01             	test   $0x1,%dl
  80126f:	74 24                	je     801295 <fd_lookup+0x48>
  801271:	89 c2                	mov    %eax,%edx
  801273:	c1 ea 0c             	shr    $0xc,%edx
  801276:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127d:	f6 c2 01             	test   $0x1,%dl
  801280:	74 1a                	je     80129c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801282:	8b 55 0c             	mov    0xc(%ebp),%edx
  801285:	89 02                	mov    %eax,(%edx)
	return 0;
  801287:	b8 00 00 00 00       	mov    $0x0,%eax
  80128c:	eb 13                	jmp    8012a1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801293:	eb 0c                	jmp    8012a1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801295:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129a:	eb 05                	jmp    8012a1 <fd_lookup+0x54>
  80129c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	83 ec 08             	sub    $0x8,%esp
  8012a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b1:	eb 13                	jmp    8012c6 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8012b3:	39 08                	cmp    %ecx,(%eax)
  8012b5:	75 0c                	jne    8012c3 <dev_lookup+0x20>
			*dev = devtab[i];
  8012b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c1:	eb 36                	jmp    8012f9 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c3:	83 c2 01             	add    $0x1,%edx
  8012c6:	8b 04 95 88 2c 80 00 	mov    0x802c88(,%edx,4),%eax
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	75 e2                	jne    8012b3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d1:	a1 18 40 80 00       	mov    0x804018,%eax
  8012d6:	8b 40 48             	mov    0x48(%eax),%eax
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	51                   	push   %ecx
  8012dd:	50                   	push   %eax
  8012de:	68 0c 2c 80 00       	push   $0x802c0c
  8012e3:	e8 cd f2 ff ff       	call   8005b5 <cprintf>
	*dev = 0;
  8012e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
  801300:	83 ec 10             	sub    $0x10,%esp
  801303:	8b 75 08             	mov    0x8(%ebp),%esi
  801306:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801309:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130c:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80130d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801313:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801316:	50                   	push   %eax
  801317:	e8 31 ff ff ff       	call   80124d <fd_lookup>
  80131c:	83 c4 08             	add    $0x8,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 05                	js     801328 <fd_close+0x2d>
	    || fd != fd2)
  801323:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801326:	74 0c                	je     801334 <fd_close+0x39>
		return (must_exist ? r : 0);
  801328:	84 db                	test   %bl,%bl
  80132a:	ba 00 00 00 00       	mov    $0x0,%edx
  80132f:	0f 44 c2             	cmove  %edx,%eax
  801332:	eb 41                	jmp    801375 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	ff 36                	pushl  (%esi)
  80133d:	e8 61 ff ff ff       	call   8012a3 <dev_lookup>
  801342:	89 c3                	mov    %eax,%ebx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 1a                	js     801365 <fd_close+0x6a>
		if (dev->dev_close)
  80134b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801351:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801356:	85 c0                	test   %eax,%eax
  801358:	74 0b                	je     801365 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	56                   	push   %esi
  80135e:	ff d0                	call   *%eax
  801360:	89 c3                	mov    %eax,%ebx
  801362:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	56                   	push   %esi
  801369:	6a 00                	push   $0x0
  80136b:	e8 5a fc ff ff       	call   800fca <sys_page_unmap>
	return r;
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	89 d8                	mov    %ebx,%eax
}
  801375:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    

0080137c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801385:	50                   	push   %eax
  801386:	ff 75 08             	pushl  0x8(%ebp)
  801389:	e8 bf fe ff ff       	call   80124d <fd_lookup>
  80138e:	89 c2                	mov    %eax,%edx
  801390:	83 c4 08             	add    $0x8,%esp
  801393:	85 d2                	test   %edx,%edx
  801395:	78 10                	js     8013a7 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	6a 01                	push   $0x1
  80139c:	ff 75 f4             	pushl  -0xc(%ebp)
  80139f:	e8 57 ff ff ff       	call   8012fb <fd_close>
  8013a4:	83 c4 10             	add    $0x10,%esp
}
  8013a7:	c9                   	leave  
  8013a8:	c3                   	ret    

008013a9 <close_all>:

void
close_all(void)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b5:	83 ec 0c             	sub    $0xc,%esp
  8013b8:	53                   	push   %ebx
  8013b9:	e8 be ff ff ff       	call   80137c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013be:	83 c3 01             	add    $0x1,%ebx
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	83 fb 20             	cmp    $0x20,%ebx
  8013c7:	75 ec                	jne    8013b5 <close_all+0xc>
		close(i);
}
  8013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 2c             	sub    $0x2c,%esp
  8013d7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013dd:	50                   	push   %eax
  8013de:	ff 75 08             	pushl  0x8(%ebp)
  8013e1:	e8 67 fe ff ff       	call   80124d <fd_lookup>
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	83 c4 08             	add    $0x8,%esp
  8013eb:	85 d2                	test   %edx,%edx
  8013ed:	0f 88 c1 00 00 00    	js     8014b4 <dup+0xe6>
		return r;
	close(newfdnum);
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	56                   	push   %esi
  8013f7:	e8 80 ff ff ff       	call   80137c <close>

	newfd = INDEX2FD(newfdnum);
  8013fc:	89 f3                	mov    %esi,%ebx
  8013fe:	c1 e3 0c             	shl    $0xc,%ebx
  801401:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801407:	83 c4 04             	add    $0x4,%esp
  80140a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140d:	e8 d5 fd ff ff       	call   8011e7 <fd2data>
  801412:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801414:	89 1c 24             	mov    %ebx,(%esp)
  801417:	e8 cb fd ff ff       	call   8011e7 <fd2data>
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801422:	89 f8                	mov    %edi,%eax
  801424:	c1 e8 16             	shr    $0x16,%eax
  801427:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142e:	a8 01                	test   $0x1,%al
  801430:	74 37                	je     801469 <dup+0x9b>
  801432:	89 f8                	mov    %edi,%eax
  801434:	c1 e8 0c             	shr    $0xc,%eax
  801437:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143e:	f6 c2 01             	test   $0x1,%dl
  801441:	74 26                	je     801469 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801443:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	25 07 0e 00 00       	and    $0xe07,%eax
  801452:	50                   	push   %eax
  801453:	ff 75 d4             	pushl  -0x2c(%ebp)
  801456:	6a 00                	push   $0x0
  801458:	57                   	push   %edi
  801459:	6a 00                	push   $0x0
  80145b:	e8 28 fb ff ff       	call   800f88 <sys_page_map>
  801460:	89 c7                	mov    %eax,%edi
  801462:	83 c4 20             	add    $0x20,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 2e                	js     801497 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801469:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80146c:	89 d0                	mov    %edx,%eax
  80146e:	c1 e8 0c             	shr    $0xc,%eax
  801471:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801478:	83 ec 0c             	sub    $0xc,%esp
  80147b:	25 07 0e 00 00       	and    $0xe07,%eax
  801480:	50                   	push   %eax
  801481:	53                   	push   %ebx
  801482:	6a 00                	push   $0x0
  801484:	52                   	push   %edx
  801485:	6a 00                	push   $0x0
  801487:	e8 fc fa ff ff       	call   800f88 <sys_page_map>
  80148c:	89 c7                	mov    %eax,%edi
  80148e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801491:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801493:	85 ff                	test   %edi,%edi
  801495:	79 1d                	jns    8014b4 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	53                   	push   %ebx
  80149b:	6a 00                	push   $0x0
  80149d:	e8 28 fb ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a8:	6a 00                	push   $0x0
  8014aa:	e8 1b fb ff ff       	call   800fca <sys_page_unmap>
	return r;
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	89 f8                	mov    %edi,%eax
}
  8014b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5f                   	pop    %edi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 14             	sub    $0x14,%esp
  8014c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	53                   	push   %ebx
  8014cb:	e8 7d fd ff ff       	call   80124d <fd_lookup>
  8014d0:	83 c4 08             	add    $0x8,%esp
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 6d                	js     801546 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e3:	ff 30                	pushl  (%eax)
  8014e5:	e8 b9 fd ff ff       	call   8012a3 <dev_lookup>
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 4c                	js     80153d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f4:	8b 42 08             	mov    0x8(%edx),%eax
  8014f7:	83 e0 03             	and    $0x3,%eax
  8014fa:	83 f8 01             	cmp    $0x1,%eax
  8014fd:	75 21                	jne    801520 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ff:	a1 18 40 80 00       	mov    0x804018,%eax
  801504:	8b 40 48             	mov    0x48(%eax),%eax
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	53                   	push   %ebx
  80150b:	50                   	push   %eax
  80150c:	68 4d 2c 80 00       	push   $0x802c4d
  801511:	e8 9f f0 ff ff       	call   8005b5 <cprintf>
		return -E_INVAL;
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151e:	eb 26                	jmp    801546 <read+0x8a>
	}
	if (!dev->dev_read)
  801520:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801523:	8b 40 08             	mov    0x8(%eax),%eax
  801526:	85 c0                	test   %eax,%eax
  801528:	74 17                	je     801541 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	ff 75 10             	pushl  0x10(%ebp)
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	52                   	push   %edx
  801534:	ff d0                	call   *%eax
  801536:	89 c2                	mov    %eax,%edx
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb 09                	jmp    801546 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	eb 05                	jmp    801546 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801541:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801546:	89 d0                	mov    %edx,%eax
  801548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	57                   	push   %edi
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 0c             	sub    $0xc,%esp
  801556:	8b 7d 08             	mov    0x8(%ebp),%edi
  801559:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801561:	eb 21                	jmp    801584 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801563:	83 ec 04             	sub    $0x4,%esp
  801566:	89 f0                	mov    %esi,%eax
  801568:	29 d8                	sub    %ebx,%eax
  80156a:	50                   	push   %eax
  80156b:	89 d8                	mov    %ebx,%eax
  80156d:	03 45 0c             	add    0xc(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	57                   	push   %edi
  801572:	e8 45 ff ff ff       	call   8014bc <read>
		if (m < 0)
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 0c                	js     80158a <readn+0x3d>
			return m;
		if (m == 0)
  80157e:	85 c0                	test   %eax,%eax
  801580:	74 06                	je     801588 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801582:	01 c3                	add    %eax,%ebx
  801584:	39 f3                	cmp    %esi,%ebx
  801586:	72 db                	jb     801563 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801588:	89 d8                	mov    %ebx,%eax
}
  80158a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158d:	5b                   	pop    %ebx
  80158e:	5e                   	pop    %esi
  80158f:	5f                   	pop    %edi
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	53                   	push   %ebx
  801596:	83 ec 14             	sub    $0x14,%esp
  801599:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	53                   	push   %ebx
  8015a1:	e8 a7 fc ff ff       	call   80124d <fd_lookup>
  8015a6:	83 c4 08             	add    $0x8,%esp
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 68                	js     801617 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b9:	ff 30                	pushl  (%eax)
  8015bb:	e8 e3 fc ff ff       	call   8012a3 <dev_lookup>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 47                	js     80160e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ce:	75 21                	jne    8015f1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d0:	a1 18 40 80 00       	mov    0x804018,%eax
  8015d5:	8b 40 48             	mov    0x48(%eax),%eax
  8015d8:	83 ec 04             	sub    $0x4,%esp
  8015db:	53                   	push   %ebx
  8015dc:	50                   	push   %eax
  8015dd:	68 69 2c 80 00       	push   $0x802c69
  8015e2:	e8 ce ef ff ff       	call   8005b5 <cprintf>
		return -E_INVAL;
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ef:	eb 26                	jmp    801617 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f7:	85 d2                	test   %edx,%edx
  8015f9:	74 17                	je     801612 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015fb:	83 ec 04             	sub    $0x4,%esp
  8015fe:	ff 75 10             	pushl  0x10(%ebp)
  801601:	ff 75 0c             	pushl  0xc(%ebp)
  801604:	50                   	push   %eax
  801605:	ff d2                	call   *%edx
  801607:	89 c2                	mov    %eax,%edx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	eb 09                	jmp    801617 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160e:	89 c2                	mov    %eax,%edx
  801610:	eb 05                	jmp    801617 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801612:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801617:	89 d0                	mov    %edx,%eax
  801619:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <seek>:

int
seek(int fdnum, off_t offset)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801624:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	ff 75 08             	pushl  0x8(%ebp)
  80162b:	e8 1d fc ff ff       	call   80124d <fd_lookup>
  801630:	83 c4 08             	add    $0x8,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 0e                	js     801645 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801637:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801640:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 14             	sub    $0x14,%esp
  80164e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801651:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	53                   	push   %ebx
  801656:	e8 f2 fb ff ff       	call   80124d <fd_lookup>
  80165b:	83 c4 08             	add    $0x8,%esp
  80165e:	89 c2                	mov    %eax,%edx
  801660:	85 c0                	test   %eax,%eax
  801662:	78 65                	js     8016c9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166e:	ff 30                	pushl  (%eax)
  801670:	e8 2e fc ff ff       	call   8012a3 <dev_lookup>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 44                	js     8016c0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801683:	75 21                	jne    8016a6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801685:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168a:	8b 40 48             	mov    0x48(%eax),%eax
  80168d:	83 ec 04             	sub    $0x4,%esp
  801690:	53                   	push   %ebx
  801691:	50                   	push   %eax
  801692:	68 2c 2c 80 00       	push   $0x802c2c
  801697:	e8 19 ef ff ff       	call   8005b5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a4:	eb 23                	jmp    8016c9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a9:	8b 52 18             	mov    0x18(%edx),%edx
  8016ac:	85 d2                	test   %edx,%edx
  8016ae:	74 14                	je     8016c4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b0:	83 ec 08             	sub    $0x8,%esp
  8016b3:	ff 75 0c             	pushl  0xc(%ebp)
  8016b6:	50                   	push   %eax
  8016b7:	ff d2                	call   *%edx
  8016b9:	89 c2                	mov    %eax,%edx
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	eb 09                	jmp    8016c9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c0:	89 c2                	mov    %eax,%edx
  8016c2:	eb 05                	jmp    8016c9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c9:	89 d0                	mov    %edx,%eax
  8016cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 14             	sub    $0x14,%esp
  8016d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	ff 75 08             	pushl  0x8(%ebp)
  8016e1:	e8 67 fb ff ff       	call   80124d <fd_lookup>
  8016e6:	83 c4 08             	add    $0x8,%esp
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 58                	js     801747 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f9:	ff 30                	pushl  (%eax)
  8016fb:	e8 a3 fb ff ff       	call   8012a3 <dev_lookup>
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	78 37                	js     80173e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170e:	74 32                	je     801742 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801710:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801713:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171a:	00 00 00 
	stat->st_isdir = 0;
  80171d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801724:	00 00 00 
	stat->st_dev = dev;
  801727:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172d:	83 ec 08             	sub    $0x8,%esp
  801730:	53                   	push   %ebx
  801731:	ff 75 f0             	pushl  -0x10(%ebp)
  801734:	ff 50 14             	call   *0x14(%eax)
  801737:	89 c2                	mov    %eax,%edx
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	eb 09                	jmp    801747 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173e:	89 c2                	mov    %eax,%edx
  801740:	eb 05                	jmp    801747 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801742:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801747:	89 d0                	mov    %edx,%eax
  801749:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801753:	83 ec 08             	sub    $0x8,%esp
  801756:	6a 00                	push   $0x0
  801758:	ff 75 08             	pushl  0x8(%ebp)
  80175b:	e8 09 02 00 00       	call   801969 <open>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 db                	test   %ebx,%ebx
  801767:	78 1b                	js     801784 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801769:	83 ec 08             	sub    $0x8,%esp
  80176c:	ff 75 0c             	pushl  0xc(%ebp)
  80176f:	53                   	push   %ebx
  801770:	e8 5b ff ff ff       	call   8016d0 <fstat>
  801775:	89 c6                	mov    %eax,%esi
	close(fd);
  801777:	89 1c 24             	mov    %ebx,(%esp)
  80177a:	e8 fd fb ff ff       	call   80137c <close>
	return r;
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	89 f0                	mov    %esi,%eax
}
  801784:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    

0080178b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	89 c6                	mov    %eax,%esi
  801792:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801794:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  80179b:	75 12                	jne    8017af <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	6a 01                	push   $0x1
  8017a2:	e8 b6 0c 00 00       	call   80245d <ipc_find_env>
  8017a7:	a3 10 40 80 00       	mov    %eax,0x804010
  8017ac:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017af:	6a 07                	push   $0x7
  8017b1:	68 00 50 80 00       	push   $0x805000
  8017b6:	56                   	push   %esi
  8017b7:	ff 35 10 40 80 00    	pushl  0x804010
  8017bd:	e8 47 0c 00 00       	call   802409 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c2:	83 c4 0c             	add    $0xc,%esp
  8017c5:	6a 00                	push   $0x0
  8017c7:	53                   	push   %ebx
  8017c8:	6a 00                	push   $0x0
  8017ca:	e8 d1 0b 00 00       	call   8023a0 <ipc_recv>
}
  8017cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ea:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f9:	e8 8d ff ff ff       	call   80178b <fsipc>
}
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	8b 40 0c             	mov    0xc(%eax),%eax
  80180c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801811:	ba 00 00 00 00       	mov    $0x0,%edx
  801816:	b8 06 00 00 00       	mov    $0x6,%eax
  80181b:	e8 6b ff ff ff       	call   80178b <fsipc>
}
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	53                   	push   %ebx
  801826:	83 ec 04             	sub    $0x4,%esp
  801829:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	8b 40 0c             	mov    0xc(%eax),%eax
  801832:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801837:	ba 00 00 00 00       	mov    $0x0,%edx
  80183c:	b8 05 00 00 00       	mov    $0x5,%eax
  801841:	e8 45 ff ff ff       	call   80178b <fsipc>
  801846:	89 c2                	mov    %eax,%edx
  801848:	85 d2                	test   %edx,%edx
  80184a:	78 2c                	js     801878 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	68 00 50 80 00       	push   $0x805000
  801854:	53                   	push   %ebx
  801855:	e8 e2 f2 ff ff       	call   800b3c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80185a:	a1 80 50 80 00       	mov    0x805080,%eax
  80185f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801865:	a1 84 50 80 00       	mov    0x805084,%eax
  80186a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    

0080187d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	57                   	push   %edi
  801881:	56                   	push   %esi
  801882:	53                   	push   %ebx
  801883:	83 ec 0c             	sub    $0xc,%esp
  801886:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	8b 40 0c             	mov    0xc(%eax),%eax
  80188f:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801894:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801897:	eb 3d                	jmp    8018d6 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801899:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80189f:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8018a4:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8018a7:	83 ec 04             	sub    $0x4,%esp
  8018aa:	57                   	push   %edi
  8018ab:	53                   	push   %ebx
  8018ac:	68 08 50 80 00       	push   $0x805008
  8018b1:	e8 18 f4 ff ff       	call   800cce <memmove>
                fsipcbuf.write.req_n = tmp; 
  8018b6:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c1:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c6:	e8 c0 fe ff ff       	call   80178b <fsipc>
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 0d                	js     8018df <devfile_write+0x62>
		        return r;
                n -= tmp;
  8018d2:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8018d4:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8018d6:	85 f6                	test   %esi,%esi
  8018d8:	75 bf                	jne    801899 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8018da:	89 d8                	mov    %ebx,%eax
  8018dc:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8018df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	5f                   	pop    %edi
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	56                   	push   %esi
  8018eb:	53                   	push   %ebx
  8018ec:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018fa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801900:	ba 00 00 00 00       	mov    $0x0,%edx
  801905:	b8 03 00 00 00       	mov    $0x3,%eax
  80190a:	e8 7c fe ff ff       	call   80178b <fsipc>
  80190f:	89 c3                	mov    %eax,%ebx
  801911:	85 c0                	test   %eax,%eax
  801913:	78 4b                	js     801960 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801915:	39 c6                	cmp    %eax,%esi
  801917:	73 16                	jae    80192f <devfile_read+0x48>
  801919:	68 9c 2c 80 00       	push   $0x802c9c
  80191e:	68 a3 2c 80 00       	push   $0x802ca3
  801923:	6a 7c                	push   $0x7c
  801925:	68 b8 2c 80 00       	push   $0x802cb8
  80192a:	e8 2b 0a 00 00       	call   80235a <_panic>
	assert(r <= PGSIZE);
  80192f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801934:	7e 16                	jle    80194c <devfile_read+0x65>
  801936:	68 c3 2c 80 00       	push   $0x802cc3
  80193b:	68 a3 2c 80 00       	push   $0x802ca3
  801940:	6a 7d                	push   $0x7d
  801942:	68 b8 2c 80 00       	push   $0x802cb8
  801947:	e8 0e 0a 00 00       	call   80235a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80194c:	83 ec 04             	sub    $0x4,%esp
  80194f:	50                   	push   %eax
  801950:	68 00 50 80 00       	push   $0x805000
  801955:	ff 75 0c             	pushl  0xc(%ebp)
  801958:	e8 71 f3 ff ff       	call   800cce <memmove>
	return r;
  80195d:	83 c4 10             	add    $0x10,%esp
}
  801960:	89 d8                	mov    %ebx,%eax
  801962:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    

00801969 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	53                   	push   %ebx
  80196d:	83 ec 20             	sub    $0x20,%esp
  801970:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801973:	53                   	push   %ebx
  801974:	e8 8a f1 ff ff       	call   800b03 <strlen>
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801981:	7f 67                	jg     8019ea <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801989:	50                   	push   %eax
  80198a:	e8 6f f8 ff ff       	call   8011fe <fd_alloc>
  80198f:	83 c4 10             	add    $0x10,%esp
		return r;
  801992:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801994:	85 c0                	test   %eax,%eax
  801996:	78 57                	js     8019ef <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801998:	83 ec 08             	sub    $0x8,%esp
  80199b:	53                   	push   %ebx
  80199c:	68 00 50 80 00       	push   $0x805000
  8019a1:	e8 96 f1 ff ff       	call   800b3c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b6:	e8 d0 fd ff ff       	call   80178b <fsipc>
  8019bb:	89 c3                	mov    %eax,%ebx
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	79 14                	jns    8019d8 <open+0x6f>
		fd_close(fd, 0);
  8019c4:	83 ec 08             	sub    $0x8,%esp
  8019c7:	6a 00                	push   $0x0
  8019c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cc:	e8 2a f9 ff ff       	call   8012fb <fd_close>
		return r;
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	89 da                	mov    %ebx,%edx
  8019d6:	eb 17                	jmp    8019ef <open+0x86>
	}

	return fd2num(fd);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 f4             	pushl  -0xc(%ebp)
  8019de:	e8 f4 f7 ff ff       	call   8011d7 <fd2num>
  8019e3:	89 c2                	mov    %eax,%edx
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	eb 05                	jmp    8019ef <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ea:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ef:	89 d0                	mov    %edx,%eax
  8019f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801a01:	b8 08 00 00 00       	mov    $0x8,%eax
  801a06:	e8 80 fd ff ff       	call   80178b <fsipc>
}
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a13:	68 cf 2c 80 00       	push   $0x802ccf
  801a18:	ff 75 0c             	pushl  0xc(%ebp)
  801a1b:	e8 1c f1 ff ff       	call   800b3c <strcpy>
	return 0;
}
  801a20:	b8 00 00 00 00       	mov    $0x0,%eax
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	53                   	push   %ebx
  801a2b:	83 ec 10             	sub    $0x10,%esp
  801a2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a31:	53                   	push   %ebx
  801a32:	e8 5e 0a 00 00       	call   802495 <pageref>
  801a37:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a3f:	83 f8 01             	cmp    $0x1,%eax
  801a42:	75 10                	jne    801a54 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	ff 73 0c             	pushl  0xc(%ebx)
  801a4a:	e8 ca 02 00 00       	call   801d19 <nsipc_close>
  801a4f:	89 c2                	mov    %eax,%edx
  801a51:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a54:	89 d0                	mov    %edx,%eax
  801a56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a61:	6a 00                	push   $0x0
  801a63:	ff 75 10             	pushl  0x10(%ebp)
  801a66:	ff 75 0c             	pushl  0xc(%ebp)
  801a69:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6c:	ff 70 0c             	pushl  0xc(%eax)
  801a6f:	e8 82 03 00 00       	call   801df6 <nsipc_send>
}
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a7c:	6a 00                	push   $0x0
  801a7e:	ff 75 10             	pushl  0x10(%ebp)
  801a81:	ff 75 0c             	pushl  0xc(%ebp)
  801a84:	8b 45 08             	mov    0x8(%ebp),%eax
  801a87:	ff 70 0c             	pushl  0xc(%eax)
  801a8a:	e8 fb 02 00 00       	call   801d8a <nsipc_recv>
}
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a97:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a9a:	52                   	push   %edx
  801a9b:	50                   	push   %eax
  801a9c:	e8 ac f7 ff ff       	call   80124d <fd_lookup>
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	78 17                	js     801abf <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aab:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801ab1:	39 08                	cmp    %ecx,(%eax)
  801ab3:	75 05                	jne    801aba <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ab5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab8:	eb 05                	jmp    801abf <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801aba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801abf:	c9                   	leave  
  801ac0:	c3                   	ret    

00801ac1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
  801ac6:	83 ec 1c             	sub    $0x1c,%esp
  801ac9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801acb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ace:	50                   	push   %eax
  801acf:	e8 2a f7 ff ff       	call   8011fe <fd_alloc>
  801ad4:	89 c3                	mov    %eax,%ebx
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	78 1b                	js     801af8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801add:	83 ec 04             	sub    $0x4,%esp
  801ae0:	68 07 04 00 00       	push   $0x407
  801ae5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae8:	6a 00                	push   $0x0
  801aea:	e8 56 f4 ff ff       	call   800f45 <sys_page_alloc>
  801aef:	89 c3                	mov    %eax,%ebx
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	79 10                	jns    801b08 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	56                   	push   %esi
  801afc:	e8 18 02 00 00       	call   801d19 <nsipc_close>
		return r;
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	89 d8                	mov    %ebx,%eax
  801b06:	eb 24                	jmp    801b2c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b08:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b11:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b13:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b16:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801b1d:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801b20:	83 ec 0c             	sub    $0xc,%esp
  801b23:	52                   	push   %edx
  801b24:	e8 ae f6 ff ff       	call   8011d7 <fd2num>
  801b29:	83 c4 10             	add    $0x10,%esp
}
  801b2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b39:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3c:	e8 50 ff ff ff       	call   801a91 <fd2sockid>
		return r;
  801b41:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b43:	85 c0                	test   %eax,%eax
  801b45:	78 1f                	js     801b66 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b47:	83 ec 04             	sub    $0x4,%esp
  801b4a:	ff 75 10             	pushl  0x10(%ebp)
  801b4d:	ff 75 0c             	pushl  0xc(%ebp)
  801b50:	50                   	push   %eax
  801b51:	e8 1c 01 00 00       	call   801c72 <nsipc_accept>
  801b56:	83 c4 10             	add    $0x10,%esp
		return r;
  801b59:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	78 07                	js     801b66 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b5f:	e8 5d ff ff ff       	call   801ac1 <alloc_sockfd>
  801b64:	89 c1                	mov    %eax,%ecx
}
  801b66:	89 c8                	mov    %ecx,%eax
  801b68:	c9                   	leave  
  801b69:	c3                   	ret    

00801b6a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b70:	8b 45 08             	mov    0x8(%ebp),%eax
  801b73:	e8 19 ff ff ff       	call   801a91 <fd2sockid>
  801b78:	89 c2                	mov    %eax,%edx
  801b7a:	85 d2                	test   %edx,%edx
  801b7c:	78 12                	js     801b90 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801b7e:	83 ec 04             	sub    $0x4,%esp
  801b81:	ff 75 10             	pushl  0x10(%ebp)
  801b84:	ff 75 0c             	pushl  0xc(%ebp)
  801b87:	52                   	push   %edx
  801b88:	e8 35 01 00 00       	call   801cc2 <nsipc_bind>
  801b8d:	83 c4 10             	add    $0x10,%esp
}
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <shutdown>:

int
shutdown(int s, int how)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	e8 f1 fe ff ff       	call   801a91 <fd2sockid>
  801ba0:	89 c2                	mov    %eax,%edx
  801ba2:	85 d2                	test   %edx,%edx
  801ba4:	78 0f                	js     801bb5 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801ba6:	83 ec 08             	sub    $0x8,%esp
  801ba9:	ff 75 0c             	pushl  0xc(%ebp)
  801bac:	52                   	push   %edx
  801bad:	e8 45 01 00 00       	call   801cf7 <nsipc_shutdown>
  801bb2:	83 c4 10             	add    $0x10,%esp
}
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc0:	e8 cc fe ff ff       	call   801a91 <fd2sockid>
  801bc5:	89 c2                	mov    %eax,%edx
  801bc7:	85 d2                	test   %edx,%edx
  801bc9:	78 12                	js     801bdd <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801bcb:	83 ec 04             	sub    $0x4,%esp
  801bce:	ff 75 10             	pushl  0x10(%ebp)
  801bd1:	ff 75 0c             	pushl  0xc(%ebp)
  801bd4:	52                   	push   %edx
  801bd5:	e8 59 01 00 00       	call   801d33 <nsipc_connect>
  801bda:	83 c4 10             	add    $0x10,%esp
}
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <listen>:

int
listen(int s, int backlog)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	e8 a4 fe ff ff       	call   801a91 <fd2sockid>
  801bed:	89 c2                	mov    %eax,%edx
  801bef:	85 d2                	test   %edx,%edx
  801bf1:	78 0f                	js     801c02 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801bf3:	83 ec 08             	sub    $0x8,%esp
  801bf6:	ff 75 0c             	pushl  0xc(%ebp)
  801bf9:	52                   	push   %edx
  801bfa:	e8 69 01 00 00       	call   801d68 <nsipc_listen>
  801bff:	83 c4 10             	add    $0x10,%esp
}
  801c02:	c9                   	leave  
  801c03:	c3                   	ret    

00801c04 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c0a:	ff 75 10             	pushl  0x10(%ebp)
  801c0d:	ff 75 0c             	pushl  0xc(%ebp)
  801c10:	ff 75 08             	pushl  0x8(%ebp)
  801c13:	e8 3c 02 00 00       	call   801e54 <nsipc_socket>
  801c18:	89 c2                	mov    %eax,%edx
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	85 d2                	test   %edx,%edx
  801c1f:	78 05                	js     801c26 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801c21:	e8 9b fe ff ff       	call   801ac1 <alloc_sockfd>
}
  801c26:	c9                   	leave  
  801c27:	c3                   	ret    

00801c28 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	53                   	push   %ebx
  801c2c:	83 ec 04             	sub    $0x4,%esp
  801c2f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c31:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801c38:	75 12                	jne    801c4c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	6a 02                	push   $0x2
  801c3f:	e8 19 08 00 00       	call   80245d <ipc_find_env>
  801c44:	a3 14 40 80 00       	mov    %eax,0x804014
  801c49:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c4c:	6a 07                	push   $0x7
  801c4e:	68 00 60 80 00       	push   $0x806000
  801c53:	53                   	push   %ebx
  801c54:	ff 35 14 40 80 00    	pushl  0x804014
  801c5a:	e8 aa 07 00 00       	call   802409 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c5f:	83 c4 0c             	add    $0xc,%esp
  801c62:	6a 00                	push   $0x0
  801c64:	6a 00                	push   $0x0
  801c66:	6a 00                	push   $0x0
  801c68:	e8 33 07 00 00       	call   8023a0 <ipc_recv>
}
  801c6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	56                   	push   %esi
  801c76:	53                   	push   %ebx
  801c77:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c82:	8b 06                	mov    (%esi),%eax
  801c84:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c89:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8e:	e8 95 ff ff ff       	call   801c28 <nsipc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 20                	js     801cb9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c99:	83 ec 04             	sub    $0x4,%esp
  801c9c:	ff 35 10 60 80 00    	pushl  0x806010
  801ca2:	68 00 60 80 00       	push   $0x806000
  801ca7:	ff 75 0c             	pushl  0xc(%ebp)
  801caa:	e8 1f f0 ff ff       	call   800cce <memmove>
		*addrlen = ret->ret_addrlen;
  801caf:	a1 10 60 80 00       	mov    0x806010,%eax
  801cb4:	89 06                	mov    %eax,(%esi)
  801cb6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cb9:	89 d8                	mov    %ebx,%eax
  801cbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5e                   	pop    %esi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	53                   	push   %ebx
  801cc6:	83 ec 08             	sub    $0x8,%esp
  801cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cd4:	53                   	push   %ebx
  801cd5:	ff 75 0c             	pushl  0xc(%ebp)
  801cd8:	68 04 60 80 00       	push   $0x806004
  801cdd:	e8 ec ef ff ff       	call   800cce <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ce2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ce8:	b8 02 00 00 00       	mov    $0x2,%eax
  801ced:	e8 36 ff ff ff       	call   801c28 <nsipc>
}
  801cf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf5:	c9                   	leave  
  801cf6:	c3                   	ret    

00801cf7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801d00:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d08:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d0d:	b8 03 00 00 00       	mov    $0x3,%eax
  801d12:	e8 11 ff ff ff       	call   801c28 <nsipc>
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <nsipc_close>:

int
nsipc_close(int s)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d22:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d27:	b8 04 00 00 00       	mov    $0x4,%eax
  801d2c:	e8 f7 fe ff ff       	call   801c28 <nsipc>
}
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    

00801d33 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	53                   	push   %ebx
  801d37:	83 ec 08             	sub    $0x8,%esp
  801d3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d40:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d45:	53                   	push   %ebx
  801d46:	ff 75 0c             	pushl  0xc(%ebp)
  801d49:	68 04 60 80 00       	push   $0x806004
  801d4e:	e8 7b ef ff ff       	call   800cce <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d53:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d59:	b8 05 00 00 00       	mov    $0x5,%eax
  801d5e:	e8 c5 fe ff ff       	call   801c28 <nsipc>
}
  801d63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d71:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d79:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d7e:	b8 06 00 00 00       	mov    $0x6,%eax
  801d83:	e8 a0 fe ff ff       	call   801c28 <nsipc>
}
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    

00801d8a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	56                   	push   %esi
  801d8e:	53                   	push   %ebx
  801d8f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d92:	8b 45 08             	mov    0x8(%ebp),%eax
  801d95:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d9a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801da0:	8b 45 14             	mov    0x14(%ebp),%eax
  801da3:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801da8:	b8 07 00 00 00       	mov    $0x7,%eax
  801dad:	e8 76 fe ff ff       	call   801c28 <nsipc>
  801db2:	89 c3                	mov    %eax,%ebx
  801db4:	85 c0                	test   %eax,%eax
  801db6:	78 35                	js     801ded <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801db8:	39 f0                	cmp    %esi,%eax
  801dba:	7f 07                	jg     801dc3 <nsipc_recv+0x39>
  801dbc:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801dc1:	7e 16                	jle    801dd9 <nsipc_recv+0x4f>
  801dc3:	68 db 2c 80 00       	push   $0x802cdb
  801dc8:	68 a3 2c 80 00       	push   $0x802ca3
  801dcd:	6a 62                	push   $0x62
  801dcf:	68 f0 2c 80 00       	push   $0x802cf0
  801dd4:	e8 81 05 00 00       	call   80235a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801dd9:	83 ec 04             	sub    $0x4,%esp
  801ddc:	50                   	push   %eax
  801ddd:	68 00 60 80 00       	push   $0x806000
  801de2:	ff 75 0c             	pushl  0xc(%ebp)
  801de5:	e8 e4 ee ff ff       	call   800cce <memmove>
  801dea:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ded:	89 d8                	mov    %ebx,%eax
  801def:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df2:	5b                   	pop    %ebx
  801df3:	5e                   	pop    %esi
  801df4:	5d                   	pop    %ebp
  801df5:	c3                   	ret    

00801df6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	53                   	push   %ebx
  801dfa:	83 ec 04             	sub    $0x4,%esp
  801dfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e00:	8b 45 08             	mov    0x8(%ebp),%eax
  801e03:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e08:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e0e:	7e 16                	jle    801e26 <nsipc_send+0x30>
  801e10:	68 fc 2c 80 00       	push   $0x802cfc
  801e15:	68 a3 2c 80 00       	push   $0x802ca3
  801e1a:	6a 6d                	push   $0x6d
  801e1c:	68 f0 2c 80 00       	push   $0x802cf0
  801e21:	e8 34 05 00 00       	call   80235a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e26:	83 ec 04             	sub    $0x4,%esp
  801e29:	53                   	push   %ebx
  801e2a:	ff 75 0c             	pushl  0xc(%ebp)
  801e2d:	68 0c 60 80 00       	push   $0x80600c
  801e32:	e8 97 ee ff ff       	call   800cce <memmove>
	nsipcbuf.send.req_size = size;
  801e37:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e40:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e45:	b8 08 00 00 00       	mov    $0x8,%eax
  801e4a:	e8 d9 fd ff ff       	call   801c28 <nsipc>
}
  801e4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e52:	c9                   	leave  
  801e53:	c3                   	ret    

00801e54 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e65:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e6d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e72:	b8 09 00 00 00       	mov    $0x9,%eax
  801e77:	e8 ac fd ff ff       	call   801c28 <nsipc>
}
  801e7c:	c9                   	leave  
  801e7d:	c3                   	ret    

00801e7e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	56                   	push   %esi
  801e82:	53                   	push   %ebx
  801e83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e86:	83 ec 0c             	sub    $0xc,%esp
  801e89:	ff 75 08             	pushl  0x8(%ebp)
  801e8c:	e8 56 f3 ff ff       	call   8011e7 <fd2data>
  801e91:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e93:	83 c4 08             	add    $0x8,%esp
  801e96:	68 08 2d 80 00       	push   $0x802d08
  801e9b:	53                   	push   %ebx
  801e9c:	e8 9b ec ff ff       	call   800b3c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ea1:	8b 56 04             	mov    0x4(%esi),%edx
  801ea4:	89 d0                	mov    %edx,%eax
  801ea6:	2b 06                	sub    (%esi),%eax
  801ea8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801eae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eb5:	00 00 00 
	stat->st_dev = &devpipe;
  801eb8:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801ebf:	30 80 00 
	return 0;
}
  801ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eca:	5b                   	pop    %ebx
  801ecb:	5e                   	pop    %esi
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    

00801ece <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	53                   	push   %ebx
  801ed2:	83 ec 0c             	sub    $0xc,%esp
  801ed5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ed8:	53                   	push   %ebx
  801ed9:	6a 00                	push   $0x0
  801edb:	e8 ea f0 ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ee0:	89 1c 24             	mov    %ebx,(%esp)
  801ee3:	e8 ff f2 ff ff       	call   8011e7 <fd2data>
  801ee8:	83 c4 08             	add    $0x8,%esp
  801eeb:	50                   	push   %eax
  801eec:	6a 00                	push   $0x0
  801eee:	e8 d7 f0 ff ff       	call   800fca <sys_page_unmap>
}
  801ef3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	57                   	push   %edi
  801efc:	56                   	push   %esi
  801efd:	53                   	push   %ebx
  801efe:	83 ec 1c             	sub    $0x1c,%esp
  801f01:	89 c6                	mov    %eax,%esi
  801f03:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f06:	a1 18 40 80 00       	mov    0x804018,%eax
  801f0b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f0e:	83 ec 0c             	sub    $0xc,%esp
  801f11:	56                   	push   %esi
  801f12:	e8 7e 05 00 00       	call   802495 <pageref>
  801f17:	89 c7                	mov    %eax,%edi
  801f19:	83 c4 04             	add    $0x4,%esp
  801f1c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f1f:	e8 71 05 00 00       	call   802495 <pageref>
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	39 c7                	cmp    %eax,%edi
  801f29:	0f 94 c2             	sete   %dl
  801f2c:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801f2f:	8b 0d 18 40 80 00    	mov    0x804018,%ecx
  801f35:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801f38:	39 fb                	cmp    %edi,%ebx
  801f3a:	74 19                	je     801f55 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801f3c:	84 d2                	test   %dl,%dl
  801f3e:	74 c6                	je     801f06 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f40:	8b 51 58             	mov    0x58(%ecx),%edx
  801f43:	50                   	push   %eax
  801f44:	52                   	push   %edx
  801f45:	53                   	push   %ebx
  801f46:	68 0f 2d 80 00       	push   $0x802d0f
  801f4b:	e8 65 e6 ff ff       	call   8005b5 <cprintf>
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	eb b1                	jmp    801f06 <_pipeisclosed+0xe>
	}
}
  801f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f58:	5b                   	pop    %ebx
  801f59:	5e                   	pop    %esi
  801f5a:	5f                   	pop    %edi
  801f5b:	5d                   	pop    %ebp
  801f5c:	c3                   	ret    

00801f5d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	57                   	push   %edi
  801f61:	56                   	push   %esi
  801f62:	53                   	push   %ebx
  801f63:	83 ec 28             	sub    $0x28,%esp
  801f66:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f69:	56                   	push   %esi
  801f6a:	e8 78 f2 ff ff       	call   8011e7 <fd2data>
  801f6f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	bf 00 00 00 00       	mov    $0x0,%edi
  801f79:	eb 4b                	jmp    801fc6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f7b:	89 da                	mov    %ebx,%edx
  801f7d:	89 f0                	mov    %esi,%eax
  801f7f:	e8 74 ff ff ff       	call   801ef8 <_pipeisclosed>
  801f84:	85 c0                	test   %eax,%eax
  801f86:	75 48                	jne    801fd0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f88:	e8 99 ef ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f8d:	8b 43 04             	mov    0x4(%ebx),%eax
  801f90:	8b 0b                	mov    (%ebx),%ecx
  801f92:	8d 51 20             	lea    0x20(%ecx),%edx
  801f95:	39 d0                	cmp    %edx,%eax
  801f97:	73 e2                	jae    801f7b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f9c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fa0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fa3:	89 c2                	mov    %eax,%edx
  801fa5:	c1 fa 1f             	sar    $0x1f,%edx
  801fa8:	89 d1                	mov    %edx,%ecx
  801faa:	c1 e9 1b             	shr    $0x1b,%ecx
  801fad:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fb0:	83 e2 1f             	and    $0x1f,%edx
  801fb3:	29 ca                	sub    %ecx,%edx
  801fb5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fb9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fbd:	83 c0 01             	add    $0x1,%eax
  801fc0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fc3:	83 c7 01             	add    $0x1,%edi
  801fc6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fc9:	75 c2                	jne    801f8d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fcb:	8b 45 10             	mov    0x10(%ebp),%eax
  801fce:	eb 05                	jmp    801fd5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fd0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	57                   	push   %edi
  801fe1:	56                   	push   %esi
  801fe2:	53                   	push   %ebx
  801fe3:	83 ec 18             	sub    $0x18,%esp
  801fe6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fe9:	57                   	push   %edi
  801fea:	e8 f8 f1 ff ff       	call   8011e7 <fd2data>
  801fef:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff1:	83 c4 10             	add    $0x10,%esp
  801ff4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ff9:	eb 3d                	jmp    802038 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ffb:	85 db                	test   %ebx,%ebx
  801ffd:	74 04                	je     802003 <devpipe_read+0x26>
				return i;
  801fff:	89 d8                	mov    %ebx,%eax
  802001:	eb 44                	jmp    802047 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802003:	89 f2                	mov    %esi,%edx
  802005:	89 f8                	mov    %edi,%eax
  802007:	e8 ec fe ff ff       	call   801ef8 <_pipeisclosed>
  80200c:	85 c0                	test   %eax,%eax
  80200e:	75 32                	jne    802042 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802010:	e8 11 ef ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802015:	8b 06                	mov    (%esi),%eax
  802017:	3b 46 04             	cmp    0x4(%esi),%eax
  80201a:	74 df                	je     801ffb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80201c:	99                   	cltd   
  80201d:	c1 ea 1b             	shr    $0x1b,%edx
  802020:	01 d0                	add    %edx,%eax
  802022:	83 e0 1f             	and    $0x1f,%eax
  802025:	29 d0                	sub    %edx,%eax
  802027:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80202c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80202f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802032:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802035:	83 c3 01             	add    $0x1,%ebx
  802038:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80203b:	75 d8                	jne    802015 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80203d:	8b 45 10             	mov    0x10(%ebp),%eax
  802040:	eb 05                	jmp    802047 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802042:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802047:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204a:	5b                   	pop    %ebx
  80204b:	5e                   	pop    %esi
  80204c:	5f                   	pop    %edi
  80204d:	5d                   	pop    %ebp
  80204e:	c3                   	ret    

0080204f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802057:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80205a:	50                   	push   %eax
  80205b:	e8 9e f1 ff ff       	call   8011fe <fd_alloc>
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	89 c2                	mov    %eax,%edx
  802065:	85 c0                	test   %eax,%eax
  802067:	0f 88 2c 01 00 00    	js     802199 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206d:	83 ec 04             	sub    $0x4,%esp
  802070:	68 07 04 00 00       	push   $0x407
  802075:	ff 75 f4             	pushl  -0xc(%ebp)
  802078:	6a 00                	push   $0x0
  80207a:	e8 c6 ee ff ff       	call   800f45 <sys_page_alloc>
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	89 c2                	mov    %eax,%edx
  802084:	85 c0                	test   %eax,%eax
  802086:	0f 88 0d 01 00 00    	js     802199 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80208c:	83 ec 0c             	sub    $0xc,%esp
  80208f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802092:	50                   	push   %eax
  802093:	e8 66 f1 ff ff       	call   8011fe <fd_alloc>
  802098:	89 c3                	mov    %eax,%ebx
  80209a:	83 c4 10             	add    $0x10,%esp
  80209d:	85 c0                	test   %eax,%eax
  80209f:	0f 88 e2 00 00 00    	js     802187 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a5:	83 ec 04             	sub    $0x4,%esp
  8020a8:	68 07 04 00 00       	push   $0x407
  8020ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b0:	6a 00                	push   $0x0
  8020b2:	e8 8e ee ff ff       	call   800f45 <sys_page_alloc>
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	83 c4 10             	add    $0x10,%esp
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	0f 88 c3 00 00 00    	js     802187 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020c4:	83 ec 0c             	sub    $0xc,%esp
  8020c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ca:	e8 18 f1 ff ff       	call   8011e7 <fd2data>
  8020cf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d1:	83 c4 0c             	add    $0xc,%esp
  8020d4:	68 07 04 00 00       	push   $0x407
  8020d9:	50                   	push   %eax
  8020da:	6a 00                	push   $0x0
  8020dc:	e8 64 ee ff ff       	call   800f45 <sys_page_alloc>
  8020e1:	89 c3                	mov    %eax,%ebx
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	85 c0                	test   %eax,%eax
  8020e8:	0f 88 89 00 00 00    	js     802177 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ee:	83 ec 0c             	sub    $0xc,%esp
  8020f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f4:	e8 ee f0 ff ff       	call   8011e7 <fd2data>
  8020f9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802100:	50                   	push   %eax
  802101:	6a 00                	push   $0x0
  802103:	56                   	push   %esi
  802104:	6a 00                	push   $0x0
  802106:	e8 7d ee ff ff       	call   800f88 <sys_page_map>
  80210b:	89 c3                	mov    %eax,%ebx
  80210d:	83 c4 20             	add    $0x20,%esp
  802110:	85 c0                	test   %eax,%eax
  802112:	78 55                	js     802169 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802114:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80211a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80211f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802122:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802129:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80212f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802132:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802134:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802137:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80213e:	83 ec 0c             	sub    $0xc,%esp
  802141:	ff 75 f4             	pushl  -0xc(%ebp)
  802144:	e8 8e f0 ff ff       	call   8011d7 <fd2num>
  802149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80214c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80214e:	83 c4 04             	add    $0x4,%esp
  802151:	ff 75 f0             	pushl  -0x10(%ebp)
  802154:	e8 7e f0 ff ff       	call   8011d7 <fd2num>
  802159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80215c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80215f:	83 c4 10             	add    $0x10,%esp
  802162:	ba 00 00 00 00       	mov    $0x0,%edx
  802167:	eb 30                	jmp    802199 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802169:	83 ec 08             	sub    $0x8,%esp
  80216c:	56                   	push   %esi
  80216d:	6a 00                	push   $0x0
  80216f:	e8 56 ee ff ff       	call   800fca <sys_page_unmap>
  802174:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802177:	83 ec 08             	sub    $0x8,%esp
  80217a:	ff 75 f0             	pushl  -0x10(%ebp)
  80217d:	6a 00                	push   $0x0
  80217f:	e8 46 ee ff ff       	call   800fca <sys_page_unmap>
  802184:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802187:	83 ec 08             	sub    $0x8,%esp
  80218a:	ff 75 f4             	pushl  -0xc(%ebp)
  80218d:	6a 00                	push   $0x0
  80218f:	e8 36 ee ff ff       	call   800fca <sys_page_unmap>
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802199:	89 d0                	mov    %edx,%eax
  80219b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80219e:	5b                   	pop    %ebx
  80219f:	5e                   	pop    %esi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    

008021a2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ab:	50                   	push   %eax
  8021ac:	ff 75 08             	pushl  0x8(%ebp)
  8021af:	e8 99 f0 ff ff       	call   80124d <fd_lookup>
  8021b4:	89 c2                	mov    %eax,%edx
  8021b6:	83 c4 10             	add    $0x10,%esp
  8021b9:	85 d2                	test   %edx,%edx
  8021bb:	78 18                	js     8021d5 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021bd:	83 ec 0c             	sub    $0xc,%esp
  8021c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c3:	e8 1f f0 ff ff       	call   8011e7 <fd2data>
	return _pipeisclosed(fd, p);
  8021c8:	89 c2                	mov    %eax,%edx
  8021ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cd:	e8 26 fd ff ff       	call   801ef8 <_pipeisclosed>
  8021d2:	83 c4 10             	add    $0x10,%esp
}
  8021d5:	c9                   	leave  
  8021d6:	c3                   	ret    

008021d7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021d7:	55                   	push   %ebp
  8021d8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021da:	b8 00 00 00 00       	mov    $0x0,%eax
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021e7:	68 27 2d 80 00       	push   $0x802d27
  8021ec:	ff 75 0c             	pushl  0xc(%ebp)
  8021ef:	e8 48 e9 ff ff       	call   800b3c <strcpy>
	return 0;
}
  8021f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f9:	c9                   	leave  
  8021fa:	c3                   	ret    

008021fb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	57                   	push   %edi
  8021ff:	56                   	push   %esi
  802200:	53                   	push   %ebx
  802201:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802207:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80220c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802212:	eb 2d                	jmp    802241 <devcons_write+0x46>
		m = n - tot;
  802214:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802217:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802219:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80221c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802221:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802224:	83 ec 04             	sub    $0x4,%esp
  802227:	53                   	push   %ebx
  802228:	03 45 0c             	add    0xc(%ebp),%eax
  80222b:	50                   	push   %eax
  80222c:	57                   	push   %edi
  80222d:	e8 9c ea ff ff       	call   800cce <memmove>
		sys_cputs(buf, m);
  802232:	83 c4 08             	add    $0x8,%esp
  802235:	53                   	push   %ebx
  802236:	57                   	push   %edi
  802237:	e8 4d ec ff ff       	call   800e89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80223c:	01 de                	add    %ebx,%esi
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	89 f0                	mov    %esi,%eax
  802243:	3b 75 10             	cmp    0x10(%ebp),%esi
  802246:	72 cc                	jb     802214 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80224b:	5b                   	pop    %ebx
  80224c:	5e                   	pop    %esi
  80224d:	5f                   	pop    %edi
  80224e:	5d                   	pop    %ebp
  80224f:	c3                   	ret    

00802250 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802250:	55                   	push   %ebp
  802251:	89 e5                	mov    %esp,%ebp
  802253:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802256:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80225b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80225f:	75 07                	jne    802268 <devcons_read+0x18>
  802261:	eb 28                	jmp    80228b <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802263:	e8 be ec ff ff       	call   800f26 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802268:	e8 3a ec ff ff       	call   800ea7 <sys_cgetc>
  80226d:	85 c0                	test   %eax,%eax
  80226f:	74 f2                	je     802263 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802271:	85 c0                	test   %eax,%eax
  802273:	78 16                	js     80228b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802275:	83 f8 04             	cmp    $0x4,%eax
  802278:	74 0c                	je     802286 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80227a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80227d:	88 02                	mov    %al,(%edx)
	return 1;
  80227f:	b8 01 00 00 00       	mov    $0x1,%eax
  802284:	eb 05                	jmp    80228b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802286:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80228b:	c9                   	leave  
  80228c:	c3                   	ret    

0080228d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80228d:	55                   	push   %ebp
  80228e:	89 e5                	mov    %esp,%ebp
  802290:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802293:	8b 45 08             	mov    0x8(%ebp),%eax
  802296:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802299:	6a 01                	push   $0x1
  80229b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80229e:	50                   	push   %eax
  80229f:	e8 e5 eb ff ff       	call   800e89 <sys_cputs>
  8022a4:	83 c4 10             	add    $0x10,%esp
}
  8022a7:	c9                   	leave  
  8022a8:	c3                   	ret    

008022a9 <getchar>:

int
getchar(void)
{
  8022a9:	55                   	push   %ebp
  8022aa:	89 e5                	mov    %esp,%ebp
  8022ac:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022af:	6a 01                	push   $0x1
  8022b1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022b4:	50                   	push   %eax
  8022b5:	6a 00                	push   $0x0
  8022b7:	e8 00 f2 ff ff       	call   8014bc <read>
	if (r < 0)
  8022bc:	83 c4 10             	add    $0x10,%esp
  8022bf:	85 c0                	test   %eax,%eax
  8022c1:	78 0f                	js     8022d2 <getchar+0x29>
		return r;
	if (r < 1)
  8022c3:	85 c0                	test   %eax,%eax
  8022c5:	7e 06                	jle    8022cd <getchar+0x24>
		return -E_EOF;
	return c;
  8022c7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022cb:	eb 05                	jmp    8022d2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022cd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022d2:	c9                   	leave  
  8022d3:	c3                   	ret    

008022d4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022d4:	55                   	push   %ebp
  8022d5:	89 e5                	mov    %esp,%ebp
  8022d7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022dd:	50                   	push   %eax
  8022de:	ff 75 08             	pushl  0x8(%ebp)
  8022e1:	e8 67 ef ff ff       	call   80124d <fd_lookup>
  8022e6:	83 c4 10             	add    $0x10,%esp
  8022e9:	85 c0                	test   %eax,%eax
  8022eb:	78 11                	js     8022fe <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f0:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8022f6:	39 10                	cmp    %edx,(%eax)
  8022f8:	0f 94 c0             	sete   %al
  8022fb:	0f b6 c0             	movzbl %al,%eax
}
  8022fe:	c9                   	leave  
  8022ff:	c3                   	ret    

00802300 <opencons>:

int
opencons(void)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802309:	50                   	push   %eax
  80230a:	e8 ef ee ff ff       	call   8011fe <fd_alloc>
  80230f:	83 c4 10             	add    $0x10,%esp
		return r;
  802312:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802314:	85 c0                	test   %eax,%eax
  802316:	78 3e                	js     802356 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802318:	83 ec 04             	sub    $0x4,%esp
  80231b:	68 07 04 00 00       	push   $0x407
  802320:	ff 75 f4             	pushl  -0xc(%ebp)
  802323:	6a 00                	push   $0x0
  802325:	e8 1b ec ff ff       	call   800f45 <sys_page_alloc>
  80232a:	83 c4 10             	add    $0x10,%esp
		return r;
  80232d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80232f:	85 c0                	test   %eax,%eax
  802331:	78 23                	js     802356 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802333:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802339:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80233e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802341:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802348:	83 ec 0c             	sub    $0xc,%esp
  80234b:	50                   	push   %eax
  80234c:	e8 86 ee ff ff       	call   8011d7 <fd2num>
  802351:	89 c2                	mov    %eax,%edx
  802353:	83 c4 10             	add    $0x10,%esp
}
  802356:	89 d0                	mov    %edx,%eax
  802358:	c9                   	leave  
  802359:	c3                   	ret    

0080235a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80235a:	55                   	push   %ebp
  80235b:	89 e5                	mov    %esp,%ebp
  80235d:	56                   	push   %esi
  80235e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80235f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802362:	8b 35 04 30 80 00    	mov    0x803004,%esi
  802368:	e8 9a eb ff ff       	call   800f07 <sys_getenvid>
  80236d:	83 ec 0c             	sub    $0xc,%esp
  802370:	ff 75 0c             	pushl  0xc(%ebp)
  802373:	ff 75 08             	pushl  0x8(%ebp)
  802376:	56                   	push   %esi
  802377:	50                   	push   %eax
  802378:	68 34 2d 80 00       	push   $0x802d34
  80237d:	e8 33 e2 ff ff       	call   8005b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802382:	83 c4 18             	add    $0x18,%esp
  802385:	53                   	push   %ebx
  802386:	ff 75 10             	pushl  0x10(%ebp)
  802389:	e8 d6 e1 ff ff       	call   800564 <vcprintf>
	cprintf("\n");
  80238e:	c7 04 24 34 28 80 00 	movl   $0x802834,(%esp)
  802395:	e8 1b e2 ff ff       	call   8005b5 <cprintf>
  80239a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80239d:	cc                   	int3   
  80239e:	eb fd                	jmp    80239d <_panic+0x43>

008023a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	56                   	push   %esi
  8023a4:	53                   	push   %ebx
  8023a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8023a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8023ae:	85 c0                	test   %eax,%eax
  8023b0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023b5:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8023b8:	83 ec 0c             	sub    $0xc,%esp
  8023bb:	50                   	push   %eax
  8023bc:	e8 34 ed ff ff       	call   8010f5 <sys_ipc_recv>
  8023c1:	83 c4 10             	add    $0x10,%esp
  8023c4:	85 c0                	test   %eax,%eax
  8023c6:	79 16                	jns    8023de <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8023c8:	85 f6                	test   %esi,%esi
  8023ca:	74 06                	je     8023d2 <ipc_recv+0x32>
  8023cc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8023d2:	85 db                	test   %ebx,%ebx
  8023d4:	74 2c                	je     802402 <ipc_recv+0x62>
  8023d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8023dc:	eb 24                	jmp    802402 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8023de:	85 f6                	test   %esi,%esi
  8023e0:	74 0a                	je     8023ec <ipc_recv+0x4c>
  8023e2:	a1 18 40 80 00       	mov    0x804018,%eax
  8023e7:	8b 40 74             	mov    0x74(%eax),%eax
  8023ea:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8023ec:	85 db                	test   %ebx,%ebx
  8023ee:	74 0a                	je     8023fa <ipc_recv+0x5a>
  8023f0:	a1 18 40 80 00       	mov    0x804018,%eax
  8023f5:	8b 40 78             	mov    0x78(%eax),%eax
  8023f8:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8023fa:	a1 18 40 80 00       	mov    0x804018,%eax
  8023ff:	8b 40 70             	mov    0x70(%eax),%eax
}
  802402:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802405:	5b                   	pop    %ebx
  802406:	5e                   	pop    %esi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    

00802409 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802409:	55                   	push   %ebp
  80240a:	89 e5                	mov    %esp,%ebp
  80240c:	57                   	push   %edi
  80240d:	56                   	push   %esi
  80240e:	53                   	push   %ebx
  80240f:	83 ec 0c             	sub    $0xc,%esp
  802412:	8b 7d 08             	mov    0x8(%ebp),%edi
  802415:	8b 75 0c             	mov    0xc(%ebp),%esi
  802418:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80241b:	85 db                	test   %ebx,%ebx
  80241d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802422:	0f 44 d8             	cmove  %eax,%ebx
  802425:	eb 1c                	jmp    802443 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802427:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80242a:	74 12                	je     80243e <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80242c:	50                   	push   %eax
  80242d:	68 58 2d 80 00       	push   $0x802d58
  802432:	6a 39                	push   $0x39
  802434:	68 73 2d 80 00       	push   $0x802d73
  802439:	e8 1c ff ff ff       	call   80235a <_panic>
                 sys_yield();
  80243e:	e8 e3 ea ff ff       	call   800f26 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802443:	ff 75 14             	pushl  0x14(%ebp)
  802446:	53                   	push   %ebx
  802447:	56                   	push   %esi
  802448:	57                   	push   %edi
  802449:	e8 84 ec ff ff       	call   8010d2 <sys_ipc_try_send>
  80244e:	83 c4 10             	add    $0x10,%esp
  802451:	85 c0                	test   %eax,%eax
  802453:	78 d2                	js     802427 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802455:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802458:	5b                   	pop    %ebx
  802459:	5e                   	pop    %esi
  80245a:	5f                   	pop    %edi
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    

0080245d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80245d:	55                   	push   %ebp
  80245e:	89 e5                	mov    %esp,%ebp
  802460:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802463:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802468:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80246b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802471:	8b 52 50             	mov    0x50(%edx),%edx
  802474:	39 ca                	cmp    %ecx,%edx
  802476:	75 0d                	jne    802485 <ipc_find_env+0x28>
			return envs[i].env_id;
  802478:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80247b:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802480:	8b 40 08             	mov    0x8(%eax),%eax
  802483:	eb 0e                	jmp    802493 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802485:	83 c0 01             	add    $0x1,%eax
  802488:	3d 00 04 00 00       	cmp    $0x400,%eax
  80248d:	75 d9                	jne    802468 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80248f:	66 b8 00 00          	mov    $0x0,%ax
}
  802493:	5d                   	pop    %ebp
  802494:	c3                   	ret    

00802495 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802495:	55                   	push   %ebp
  802496:	89 e5                	mov    %esp,%ebp
  802498:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80249b:	89 d0                	mov    %edx,%eax
  80249d:	c1 e8 16             	shr    $0x16,%eax
  8024a0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024a7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024ac:	f6 c1 01             	test   $0x1,%cl
  8024af:	74 1d                	je     8024ce <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024b1:	c1 ea 0c             	shr    $0xc,%edx
  8024b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024bb:	f6 c2 01             	test   $0x1,%dl
  8024be:	74 0e                	je     8024ce <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024c0:	c1 ea 0c             	shr    $0xc,%edx
  8024c3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024ca:	ef 
  8024cb:	0f b7 c0             	movzwl %ax,%eax
}
  8024ce:	5d                   	pop    %ebp
  8024cf:	c3                   	ret    

008024d0 <__udivdi3>:
  8024d0:	55                   	push   %ebp
  8024d1:	57                   	push   %edi
  8024d2:	56                   	push   %esi
  8024d3:	83 ec 10             	sub    $0x10,%esp
  8024d6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8024da:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8024de:	8b 74 24 24          	mov    0x24(%esp),%esi
  8024e2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8024e6:	85 d2                	test   %edx,%edx
  8024e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024ec:	89 34 24             	mov    %esi,(%esp)
  8024ef:	89 c8                	mov    %ecx,%eax
  8024f1:	75 35                	jne    802528 <__udivdi3+0x58>
  8024f3:	39 f1                	cmp    %esi,%ecx
  8024f5:	0f 87 bd 00 00 00    	ja     8025b8 <__udivdi3+0xe8>
  8024fb:	85 c9                	test   %ecx,%ecx
  8024fd:	89 cd                	mov    %ecx,%ebp
  8024ff:	75 0b                	jne    80250c <__udivdi3+0x3c>
  802501:	b8 01 00 00 00       	mov    $0x1,%eax
  802506:	31 d2                	xor    %edx,%edx
  802508:	f7 f1                	div    %ecx
  80250a:	89 c5                	mov    %eax,%ebp
  80250c:	89 f0                	mov    %esi,%eax
  80250e:	31 d2                	xor    %edx,%edx
  802510:	f7 f5                	div    %ebp
  802512:	89 c6                	mov    %eax,%esi
  802514:	89 f8                	mov    %edi,%eax
  802516:	f7 f5                	div    %ebp
  802518:	89 f2                	mov    %esi,%edx
  80251a:	83 c4 10             	add    $0x10,%esp
  80251d:	5e                   	pop    %esi
  80251e:	5f                   	pop    %edi
  80251f:	5d                   	pop    %ebp
  802520:	c3                   	ret    
  802521:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802528:	3b 14 24             	cmp    (%esp),%edx
  80252b:	77 7b                	ja     8025a8 <__udivdi3+0xd8>
  80252d:	0f bd f2             	bsr    %edx,%esi
  802530:	83 f6 1f             	xor    $0x1f,%esi
  802533:	0f 84 97 00 00 00    	je     8025d0 <__udivdi3+0x100>
  802539:	bd 20 00 00 00       	mov    $0x20,%ebp
  80253e:	89 d7                	mov    %edx,%edi
  802540:	89 f1                	mov    %esi,%ecx
  802542:	29 f5                	sub    %esi,%ebp
  802544:	d3 e7                	shl    %cl,%edi
  802546:	89 c2                	mov    %eax,%edx
  802548:	89 e9                	mov    %ebp,%ecx
  80254a:	d3 ea                	shr    %cl,%edx
  80254c:	89 f1                	mov    %esi,%ecx
  80254e:	09 fa                	or     %edi,%edx
  802550:	8b 3c 24             	mov    (%esp),%edi
  802553:	d3 e0                	shl    %cl,%eax
  802555:	89 54 24 08          	mov    %edx,0x8(%esp)
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80255f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802563:	89 fa                	mov    %edi,%edx
  802565:	d3 ea                	shr    %cl,%edx
  802567:	89 f1                	mov    %esi,%ecx
  802569:	d3 e7                	shl    %cl,%edi
  80256b:	89 e9                	mov    %ebp,%ecx
  80256d:	d3 e8                	shr    %cl,%eax
  80256f:	09 c7                	or     %eax,%edi
  802571:	89 f8                	mov    %edi,%eax
  802573:	f7 74 24 08          	divl   0x8(%esp)
  802577:	89 d5                	mov    %edx,%ebp
  802579:	89 c7                	mov    %eax,%edi
  80257b:	f7 64 24 0c          	mull   0xc(%esp)
  80257f:	39 d5                	cmp    %edx,%ebp
  802581:	89 14 24             	mov    %edx,(%esp)
  802584:	72 11                	jb     802597 <__udivdi3+0xc7>
  802586:	8b 54 24 04          	mov    0x4(%esp),%edx
  80258a:	89 f1                	mov    %esi,%ecx
  80258c:	d3 e2                	shl    %cl,%edx
  80258e:	39 c2                	cmp    %eax,%edx
  802590:	73 5e                	jae    8025f0 <__udivdi3+0x120>
  802592:	3b 2c 24             	cmp    (%esp),%ebp
  802595:	75 59                	jne    8025f0 <__udivdi3+0x120>
  802597:	8d 47 ff             	lea    -0x1(%edi),%eax
  80259a:	31 f6                	xor    %esi,%esi
  80259c:	89 f2                	mov    %esi,%edx
  80259e:	83 c4 10             	add    $0x10,%esp
  8025a1:	5e                   	pop    %esi
  8025a2:	5f                   	pop    %edi
  8025a3:	5d                   	pop    %ebp
  8025a4:	c3                   	ret    
  8025a5:	8d 76 00             	lea    0x0(%esi),%esi
  8025a8:	31 f6                	xor    %esi,%esi
  8025aa:	31 c0                	xor    %eax,%eax
  8025ac:	89 f2                	mov    %esi,%edx
  8025ae:	83 c4 10             	add    $0x10,%esp
  8025b1:	5e                   	pop    %esi
  8025b2:	5f                   	pop    %edi
  8025b3:	5d                   	pop    %ebp
  8025b4:	c3                   	ret    
  8025b5:	8d 76 00             	lea    0x0(%esi),%esi
  8025b8:	89 f2                	mov    %esi,%edx
  8025ba:	31 f6                	xor    %esi,%esi
  8025bc:	89 f8                	mov    %edi,%eax
  8025be:	f7 f1                	div    %ecx
  8025c0:	89 f2                	mov    %esi,%edx
  8025c2:	83 c4 10             	add    $0x10,%esp
  8025c5:	5e                   	pop    %esi
  8025c6:	5f                   	pop    %edi
  8025c7:	5d                   	pop    %ebp
  8025c8:	c3                   	ret    
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8025d4:	76 0b                	jbe    8025e1 <__udivdi3+0x111>
  8025d6:	31 c0                	xor    %eax,%eax
  8025d8:	3b 14 24             	cmp    (%esp),%edx
  8025db:	0f 83 37 ff ff ff    	jae    802518 <__udivdi3+0x48>
  8025e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e6:	e9 2d ff ff ff       	jmp    802518 <__udivdi3+0x48>
  8025eb:	90                   	nop
  8025ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	89 f8                	mov    %edi,%eax
  8025f2:	31 f6                	xor    %esi,%esi
  8025f4:	e9 1f ff ff ff       	jmp    802518 <__udivdi3+0x48>
  8025f9:	66 90                	xchg   %ax,%ax
  8025fb:	66 90                	xchg   %ax,%ax
  8025fd:	66 90                	xchg   %ax,%ax
  8025ff:	90                   	nop

00802600 <__umoddi3>:
  802600:	55                   	push   %ebp
  802601:	57                   	push   %edi
  802602:	56                   	push   %esi
  802603:	83 ec 20             	sub    $0x20,%esp
  802606:	8b 44 24 34          	mov    0x34(%esp),%eax
  80260a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80260e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802612:	89 c6                	mov    %eax,%esi
  802614:	89 44 24 10          	mov    %eax,0x10(%esp)
  802618:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80261c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802620:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802624:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802628:	89 74 24 18          	mov    %esi,0x18(%esp)
  80262c:	85 c0                	test   %eax,%eax
  80262e:	89 c2                	mov    %eax,%edx
  802630:	75 1e                	jne    802650 <__umoddi3+0x50>
  802632:	39 f7                	cmp    %esi,%edi
  802634:	76 52                	jbe    802688 <__umoddi3+0x88>
  802636:	89 c8                	mov    %ecx,%eax
  802638:	89 f2                	mov    %esi,%edx
  80263a:	f7 f7                	div    %edi
  80263c:	89 d0                	mov    %edx,%eax
  80263e:	31 d2                	xor    %edx,%edx
  802640:	83 c4 20             	add    $0x20,%esp
  802643:	5e                   	pop    %esi
  802644:	5f                   	pop    %edi
  802645:	5d                   	pop    %ebp
  802646:	c3                   	ret    
  802647:	89 f6                	mov    %esi,%esi
  802649:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802650:	39 f0                	cmp    %esi,%eax
  802652:	77 5c                	ja     8026b0 <__umoddi3+0xb0>
  802654:	0f bd e8             	bsr    %eax,%ebp
  802657:	83 f5 1f             	xor    $0x1f,%ebp
  80265a:	75 64                	jne    8026c0 <__umoddi3+0xc0>
  80265c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802660:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802664:	0f 86 f6 00 00 00    	jbe    802760 <__umoddi3+0x160>
  80266a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80266e:	0f 82 ec 00 00 00    	jb     802760 <__umoddi3+0x160>
  802674:	8b 44 24 14          	mov    0x14(%esp),%eax
  802678:	8b 54 24 18          	mov    0x18(%esp),%edx
  80267c:	83 c4 20             	add    $0x20,%esp
  80267f:	5e                   	pop    %esi
  802680:	5f                   	pop    %edi
  802681:	5d                   	pop    %ebp
  802682:	c3                   	ret    
  802683:	90                   	nop
  802684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802688:	85 ff                	test   %edi,%edi
  80268a:	89 fd                	mov    %edi,%ebp
  80268c:	75 0b                	jne    802699 <__umoddi3+0x99>
  80268e:	b8 01 00 00 00       	mov    $0x1,%eax
  802693:	31 d2                	xor    %edx,%edx
  802695:	f7 f7                	div    %edi
  802697:	89 c5                	mov    %eax,%ebp
  802699:	8b 44 24 10          	mov    0x10(%esp),%eax
  80269d:	31 d2                	xor    %edx,%edx
  80269f:	f7 f5                	div    %ebp
  8026a1:	89 c8                	mov    %ecx,%eax
  8026a3:	f7 f5                	div    %ebp
  8026a5:	eb 95                	jmp    80263c <__umoddi3+0x3c>
  8026a7:	89 f6                	mov    %esi,%esi
  8026a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8026b0:	89 c8                	mov    %ecx,%eax
  8026b2:	89 f2                	mov    %esi,%edx
  8026b4:	83 c4 20             	add    $0x20,%esp
  8026b7:	5e                   	pop    %esi
  8026b8:	5f                   	pop    %edi
  8026b9:	5d                   	pop    %ebp
  8026ba:	c3                   	ret    
  8026bb:	90                   	nop
  8026bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	b8 20 00 00 00       	mov    $0x20,%eax
  8026c5:	89 e9                	mov    %ebp,%ecx
  8026c7:	29 e8                	sub    %ebp,%eax
  8026c9:	d3 e2                	shl    %cl,%edx
  8026cb:	89 c7                	mov    %eax,%edi
  8026cd:	89 44 24 18          	mov    %eax,0x18(%esp)
  8026d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026d5:	89 f9                	mov    %edi,%ecx
  8026d7:	d3 e8                	shr    %cl,%eax
  8026d9:	89 c1                	mov    %eax,%ecx
  8026db:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026df:	09 d1                	or     %edx,%ecx
  8026e1:	89 fa                	mov    %edi,%edx
  8026e3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8026e7:	89 e9                	mov    %ebp,%ecx
  8026e9:	d3 e0                	shl    %cl,%eax
  8026eb:	89 f9                	mov    %edi,%ecx
  8026ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026f1:	89 f0                	mov    %esi,%eax
  8026f3:	d3 e8                	shr    %cl,%eax
  8026f5:	89 e9                	mov    %ebp,%ecx
  8026f7:	89 c7                	mov    %eax,%edi
  8026f9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8026fd:	d3 e6                	shl    %cl,%esi
  8026ff:	89 d1                	mov    %edx,%ecx
  802701:	89 fa                	mov    %edi,%edx
  802703:	d3 e8                	shr    %cl,%eax
  802705:	89 e9                	mov    %ebp,%ecx
  802707:	09 f0                	or     %esi,%eax
  802709:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80270d:	f7 74 24 10          	divl   0x10(%esp)
  802711:	d3 e6                	shl    %cl,%esi
  802713:	89 d1                	mov    %edx,%ecx
  802715:	f7 64 24 0c          	mull   0xc(%esp)
  802719:	39 d1                	cmp    %edx,%ecx
  80271b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80271f:	89 d7                	mov    %edx,%edi
  802721:	89 c6                	mov    %eax,%esi
  802723:	72 0a                	jb     80272f <__umoddi3+0x12f>
  802725:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802729:	73 10                	jae    80273b <__umoddi3+0x13b>
  80272b:	39 d1                	cmp    %edx,%ecx
  80272d:	75 0c                	jne    80273b <__umoddi3+0x13b>
  80272f:	89 d7                	mov    %edx,%edi
  802731:	89 c6                	mov    %eax,%esi
  802733:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802737:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80273b:	89 ca                	mov    %ecx,%edx
  80273d:	89 e9                	mov    %ebp,%ecx
  80273f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802743:	29 f0                	sub    %esi,%eax
  802745:	19 fa                	sbb    %edi,%edx
  802747:	d3 e8                	shr    %cl,%eax
  802749:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80274e:	89 d7                	mov    %edx,%edi
  802750:	d3 e7                	shl    %cl,%edi
  802752:	89 e9                	mov    %ebp,%ecx
  802754:	09 f8                	or     %edi,%eax
  802756:	d3 ea                	shr    %cl,%edx
  802758:	83 c4 20             	add    $0x20,%esp
  80275b:	5e                   	pop    %esi
  80275c:	5f                   	pop    %edi
  80275d:	5d                   	pop    %ebp
  80275e:	c3                   	ret    
  80275f:	90                   	nop
  802760:	8b 74 24 10          	mov    0x10(%esp),%esi
  802764:	29 f9                	sub    %edi,%ecx
  802766:	19 c6                	sbb    %eax,%esi
  802768:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80276c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802770:	e9 ff fe ff ff       	jmp    802674 <__umoddi3+0x74>
