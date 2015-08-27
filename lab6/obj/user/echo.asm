
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 c0 23 80 00       	push   $0x8023c0
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 c3 01 00 00       	call   800221 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 c3 23 80 00       	push   $0x8023c3
  80008f:	6a 01                	push   $0x1
  800091:	e8 37 0b 00 00       	call   800bcd <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 1b 0b 00 00       	call   800bcd <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 10 25 80 00       	push   $0x802510
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 fa 0a 00 00       	call   800bcd <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000e9:	e8 54 04 00 00       	call   800542 <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x2d>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
  80011a:	83 c4 10             	add    $0x10,%esp
}
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 b5 08 00 00       	call   8009e4 <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 c8 03 00 00       	call   800501 <sys_env_destroy>
  800139:	83 c4 10             	add    $0x10,%esp
}
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800144:	b8 00 00 00 00       	mov    $0x0,%eax
  800149:	eb 03                	jmp    80014e <strlen+0x10>
		n++;
  80014b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80014e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800152:	75 f7                	jne    80014b <strlen+0xd>
		n++;
	return n;
}
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	eb 03                	jmp    800169 <strnlen+0x13>
		n++;
  800166:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800169:	39 c2                	cmp    %eax,%edx
  80016b:	74 08                	je     800175 <strnlen+0x1f>
  80016d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800171:	75 f3                	jne    800166 <strnlen+0x10>
  800173:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800181:	89 c2                	mov    %eax,%edx
  800183:	83 c2 01             	add    $0x1,%edx
  800186:	83 c1 01             	add    $0x1,%ecx
  800189:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80018d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800190:	84 db                	test   %bl,%bl
  800192:	75 ef                	jne    800183 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800194:	5b                   	pop    %ebx
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80019e:	53                   	push   %ebx
  80019f:	e8 9a ff ff ff       	call   80013e <strlen>
  8001a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	01 d8                	add    %ebx,%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 c5 ff ff ff       	call   800177 <strcpy>
	return dst;
}
  8001b2:	89 d8                	mov    %ebx,%eax
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	89 f3                	mov    %esi,%ebx
  8001c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	eb 0f                	jmp    8001dc <strncpy+0x23>
		*dst++ = *src;
  8001cd:	83 c2 01             	add    $0x1,%edx
  8001d0:	0f b6 01             	movzbl (%ecx),%eax
  8001d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8001d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001dc:	39 da                	cmp    %ebx,%edx
  8001de:	75 ed                	jne    8001cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001e0:	89 f0                	mov    %esi,%eax
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8001f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001f6:	85 d2                	test   %edx,%edx
  8001f8:	74 21                	je     80021b <strlcpy+0x35>
  8001fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	eb 09                	jmp    80020b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800202:	83 c2 01             	add    $0x1,%edx
  800205:	83 c1 01             	add    $0x1,%ecx
  800208:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80020b:	39 c2                	cmp    %eax,%edx
  80020d:	74 09                	je     800218 <strlcpy+0x32>
  80020f:	0f b6 19             	movzbl (%ecx),%ebx
  800212:	84 db                	test   %bl,%bl
  800214:	75 ec                	jne    800202 <strlcpy+0x1c>
  800216:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 15                	je     800277 <strncmp+0x30>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
  800275:	eb 05                	jmp    80027c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800277:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80027c:	5b                   	pop    %ebx
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	eb 07                	jmp    800292 <strchr+0x13>
		if (*s == c)
  80028b:	38 ca                	cmp    %cl,%dl
  80028d:	74 0f                	je     80029e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80028f:	83 c0 01             	add    $0x1,%eax
  800292:	0f b6 10             	movzbl (%eax),%edx
  800295:	84 d2                	test   %dl,%dl
  800297:	75 f2                	jne    80028b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	84 d2                	test   %dl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	38 ca                	cmp    %cl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 36                	je     800302 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 28                	jne    8002fc <memset+0x40>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	75 23                	jne    8002fc <memset+0x40>
		c &= 0xFF;
  8002d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002dd:	89 d3                	mov    %edx,%ebx
  8002df:	c1 e3 08             	shl    $0x8,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	c1 e6 18             	shl    $0x18,%esi
  8002e7:	89 d0                	mov    %edx,%eax
  8002e9:	c1 e0 10             	shl    $0x10,%eax
  8002ec:	09 f0                	or     %esi,%eax
  8002ee:	09 c2                	or     %eax,%edx
  8002f0:	89 d0                	mov    %edx,%eax
  8002f2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8002f4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8002f7:	fc                   	cld    
  8002f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8002fa:	eb 06                	jmp    800302 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	fc                   	cld    
  800300:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800302:	89 f8                	mov    %edi,%eax
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 d0                	cmp    %edx,%eax
  800320:	73 2e                	jae    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	75 13                	jne    800344 <memmove+0x3b>
  800331:	f6 c1 03             	test   $0x3,%cl
  800334:	75 0e                	jne    800344 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800336:	83 ef 04             	sub    $0x4,%edi
  800339:	8d 72 fc             	lea    -0x4(%edx),%esi
  80033c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80033f:	fd                   	std    
  800340:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800342:	eb 09                	jmp    80034d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800344:	83 ef 01             	sub    $0x1,%edi
  800347:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80034a:	fd                   	std    
  80034b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80034d:	fc                   	cld    
  80034e:	eb 1d                	jmp    80036d <memmove+0x64>
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	75 0f                	jne    800368 <memmove+0x5f>
  800359:	f6 c1 03             	test   $0x3,%cl
  80035c:	75 0a                	jne    800368 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80035e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800361:	89 c7                	mov    %eax,%edi
  800363:	fc                   	cld    
  800364:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800366:	eb 05                	jmp    80036d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800368:	89 c7                	mov    %eax,%edi
  80036a:	fc                   	cld    
  80036b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	eb 1a                	jmp    8003b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800396:	0f b6 08             	movzbl (%eax),%ecx
  800399:	0f b6 1a             	movzbl (%edx),%ebx
  80039c:	38 d9                	cmp    %bl,%cl
  80039e:	74 0a                	je     8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003a0:	0f b6 c1             	movzbl %cl,%eax
  8003a3:	0f b6 db             	movzbl %bl,%ebx
  8003a6:	29 d8                	sub    %ebx,%eax
  8003a8:	eb 0f                	jmp    8003b9 <memcmp+0x35>
		s1++, s2++;
  8003aa:	83 c0 01             	add    $0x1,%eax
  8003ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b0:	39 f0                	cmp    %esi,%eax
  8003b2:	75 e2                	jne    800396 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003cb:	eb 07                	jmp    8003d4 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cd:	38 08                	cmp    %cl,(%eax)
  8003cf:	74 07                	je     8003d8 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d1:	83 c0 01             	add    $0x1,%eax
  8003d4:	39 d0                	cmp    %edx,%eax
  8003d6:	72 f5                	jb     8003cd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003d8:	5d                   	pop    %ebp
  8003d9:	c3                   	ret    

008003da <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	57                   	push   %edi
  8003de:	56                   	push   %esi
  8003df:	53                   	push   %ebx
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003e6:	eb 03                	jmp    8003eb <strtol+0x11>
		s++;
  8003e8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003eb:	0f b6 01             	movzbl (%ecx),%eax
  8003ee:	3c 09                	cmp    $0x9,%al
  8003f0:	74 f6                	je     8003e8 <strtol+0xe>
  8003f2:	3c 20                	cmp    $0x20,%al
  8003f4:	74 f2                	je     8003e8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003f6:	3c 2b                	cmp    $0x2b,%al
  8003f8:	75 0a                	jne    800404 <strtol+0x2a>
		s++;
  8003fa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8003fd:	bf 00 00 00 00       	mov    $0x0,%edi
  800402:	eb 10                	jmp    800414 <strtol+0x3a>
  800404:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800409:	3c 2d                	cmp    $0x2d,%al
  80040b:	75 07                	jne    800414 <strtol+0x3a>
		s++, neg = 1;
  80040d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800410:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800414:	85 db                	test   %ebx,%ebx
  800416:	0f 94 c0             	sete   %al
  800419:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80041f:	75 19                	jne    80043a <strtol+0x60>
  800421:	80 39 30             	cmpb   $0x30,(%ecx)
  800424:	75 14                	jne    80043a <strtol+0x60>
  800426:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80042a:	0f 85 82 00 00 00    	jne    8004b2 <strtol+0xd8>
		s += 2, base = 16;
  800430:	83 c1 02             	add    $0x2,%ecx
  800433:	bb 10 00 00 00       	mov    $0x10,%ebx
  800438:	eb 16                	jmp    800450 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80043a:	84 c0                	test   %al,%al
  80043c:	74 12                	je     800450 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80043e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800443:	80 39 30             	cmpb   $0x30,(%ecx)
  800446:	75 08                	jne    800450 <strtol+0x76>
		s++, base = 8;
  800448:	83 c1 01             	add    $0x1,%ecx
  80044b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800450:	b8 00 00 00 00       	mov    $0x0,%eax
  800455:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800458:	0f b6 11             	movzbl (%ecx),%edx
  80045b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80045e:	89 f3                	mov    %esi,%ebx
  800460:	80 fb 09             	cmp    $0x9,%bl
  800463:	77 08                	ja     80046d <strtol+0x93>
			dig = *s - '0';
  800465:	0f be d2             	movsbl %dl,%edx
  800468:	83 ea 30             	sub    $0x30,%edx
  80046b:	eb 22                	jmp    80048f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  80046d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800470:	89 f3                	mov    %esi,%ebx
  800472:	80 fb 19             	cmp    $0x19,%bl
  800475:	77 08                	ja     80047f <strtol+0xa5>
			dig = *s - 'a' + 10;
  800477:	0f be d2             	movsbl %dl,%edx
  80047a:	83 ea 57             	sub    $0x57,%edx
  80047d:	eb 10                	jmp    80048f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  80047f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800482:	89 f3                	mov    %esi,%ebx
  800484:	80 fb 19             	cmp    $0x19,%bl
  800487:	77 16                	ja     80049f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800489:	0f be d2             	movsbl %dl,%edx
  80048c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80048f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800492:	7d 0f                	jge    8004a3 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800494:	83 c1 01             	add    $0x1,%ecx
  800497:	0f af 45 10          	imul   0x10(%ebp),%eax
  80049b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80049d:	eb b9                	jmp    800458 <strtol+0x7e>
  80049f:	89 c2                	mov    %eax,%edx
  8004a1:	eb 02                	jmp    8004a5 <strtol+0xcb>
  8004a3:	89 c2                	mov    %eax,%edx

	if (endptr)
  8004a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a9:	74 0d                	je     8004b8 <strtol+0xde>
		*endptr = (char *) s;
  8004ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004ae:	89 0e                	mov    %ecx,(%esi)
  8004b0:	eb 06                	jmp    8004b8 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004b2:	84 c0                	test   %al,%al
  8004b4:	75 92                	jne    800448 <strtol+0x6e>
  8004b6:	eb 98                	jmp    800450 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004b8:	f7 da                	neg    %edx
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	0f 45 c2             	cmovne %edx,%eax
}
  8004bf:	5b                   	pop    %ebx
  8004c0:	5e                   	pop    %esi
  8004c1:	5f                   	pop    %edi
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    

008004c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	57                   	push   %edi
  8004c8:	56                   	push   %esi
  8004c9:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8004ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d5:	89 c3                	mov    %eax,%ebx
  8004d7:	89 c7                	mov    %eax,%edi
  8004d9:	89 c6                	mov    %eax,%esi
  8004db:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004dd:	5b                   	pop    %ebx
  8004de:	5e                   	pop    %esi
  8004df:	5f                   	pop    %edi
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	57                   	push   %edi
  8004e6:	56                   	push   %esi
  8004e7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8004e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8004f2:	89 d1                	mov    %edx,%ecx
  8004f4:	89 d3                	mov    %edx,%ebx
  8004f6:	89 d7                	mov    %edx,%edi
  8004f8:	89 d6                	mov    %edx,%esi
  8004fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004fc:	5b                   	pop    %ebx
  8004fd:	5e                   	pop    %esi
  8004fe:	5f                   	pop    %edi
  8004ff:	5d                   	pop    %ebp
  800500:	c3                   	ret    

00800501 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800501:	55                   	push   %ebp
  800502:	89 e5                	mov    %esp,%ebp
  800504:	57                   	push   %edi
  800505:	56                   	push   %esi
  800506:	53                   	push   %ebx
  800507:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80050a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050f:	b8 03 00 00 00       	mov    $0x3,%eax
  800514:	8b 55 08             	mov    0x8(%ebp),%edx
  800517:	89 cb                	mov    %ecx,%ebx
  800519:	89 cf                	mov    %ecx,%edi
  80051b:	89 ce                	mov    %ecx,%esi
  80051d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80051f:	85 c0                	test   %eax,%eax
  800521:	7e 17                	jle    80053a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800523:	83 ec 0c             	sub    $0xc,%esp
  800526:	50                   	push   %eax
  800527:	6a 03                	push   $0x3
  800529:	68 cf 23 80 00       	push   $0x8023cf
  80052e:	6a 22                	push   $0x22
  800530:	68 ec 23 80 00       	push   $0x8023ec
  800535:	e8 5b 14 00 00       	call   801995 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80053a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80053d:	5b                   	pop    %ebx
  80053e:	5e                   	pop    %esi
  80053f:	5f                   	pop    %edi
  800540:	5d                   	pop    %ebp
  800541:	c3                   	ret    

00800542 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	57                   	push   %edi
  800546:	56                   	push   %esi
  800547:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800548:	ba 00 00 00 00       	mov    $0x0,%edx
  80054d:	b8 02 00 00 00       	mov    $0x2,%eax
  800552:	89 d1                	mov    %edx,%ecx
  800554:	89 d3                	mov    %edx,%ebx
  800556:	89 d7                	mov    %edx,%edi
  800558:	89 d6                	mov    %edx,%esi
  80055a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80055c:	5b                   	pop    %ebx
  80055d:	5e                   	pop    %esi
  80055e:	5f                   	pop    %edi
  80055f:	5d                   	pop    %ebp
  800560:	c3                   	ret    

00800561 <sys_yield>:

void
sys_yield(void)
{      
  800561:	55                   	push   %ebp
  800562:	89 e5                	mov    %esp,%ebp
  800564:	57                   	push   %edi
  800565:	56                   	push   %esi
  800566:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800567:	ba 00 00 00 00       	mov    $0x0,%edx
  80056c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800571:	89 d1                	mov    %edx,%ecx
  800573:	89 d3                	mov    %edx,%ebx
  800575:	89 d7                	mov    %edx,%edi
  800577:	89 d6                	mov    %edx,%esi
  800579:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80057b:	5b                   	pop    %ebx
  80057c:	5e                   	pop    %esi
  80057d:	5f                   	pop    %edi
  80057e:	5d                   	pop    %ebp
  80057f:	c3                   	ret    

00800580 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800589:	be 00 00 00 00       	mov    $0x0,%esi
  80058e:	b8 04 00 00 00       	mov    $0x4,%eax
  800593:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800596:	8b 55 08             	mov    0x8(%ebp),%edx
  800599:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80059c:	89 f7                	mov    %esi,%edi
  80059e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005a0:	85 c0                	test   %eax,%eax
  8005a2:	7e 17                	jle    8005bb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	50                   	push   %eax
  8005a8:	6a 04                	push   $0x4
  8005aa:	68 cf 23 80 00       	push   $0x8023cf
  8005af:	6a 22                	push   $0x22
  8005b1:	68 ec 23 80 00       	push   $0x8023ec
  8005b6:	e8 da 13 00 00       	call   801995 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005be:	5b                   	pop    %ebx
  8005bf:	5e                   	pop    %esi
  8005c0:	5f                   	pop    %edi
  8005c1:	5d                   	pop    %ebp
  8005c2:	c3                   	ret    

008005c3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005c3:	55                   	push   %ebp
  8005c4:	89 e5                	mov    %esp,%ebp
  8005c6:	57                   	push   %edi
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8005cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8005d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005da:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005dd:	8b 75 18             	mov    0x18(%ebp),%esi
  8005e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	7e 17                	jle    8005fd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e6:	83 ec 0c             	sub    $0xc,%esp
  8005e9:	50                   	push   %eax
  8005ea:	6a 05                	push   $0x5
  8005ec:	68 cf 23 80 00       	push   $0x8023cf
  8005f1:	6a 22                	push   $0x22
  8005f3:	68 ec 23 80 00       	push   $0x8023ec
  8005f8:	e8 98 13 00 00       	call   801995 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800600:	5b                   	pop    %ebx
  800601:	5e                   	pop    %esi
  800602:	5f                   	pop    %edi
  800603:	5d                   	pop    %ebp
  800604:	c3                   	ret    

00800605 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	57                   	push   %edi
  800609:	56                   	push   %esi
  80060a:	53                   	push   %ebx
  80060b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80060e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800613:	b8 06 00 00 00       	mov    $0x6,%eax
  800618:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80061b:	8b 55 08             	mov    0x8(%ebp),%edx
  80061e:	89 df                	mov    %ebx,%edi
  800620:	89 de                	mov    %ebx,%esi
  800622:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800624:	85 c0                	test   %eax,%eax
  800626:	7e 17                	jle    80063f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800628:	83 ec 0c             	sub    $0xc,%esp
  80062b:	50                   	push   %eax
  80062c:	6a 06                	push   $0x6
  80062e:	68 cf 23 80 00       	push   $0x8023cf
  800633:	6a 22                	push   $0x22
  800635:	68 ec 23 80 00       	push   $0x8023ec
  80063a:	e8 56 13 00 00       	call   801995 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80063f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800642:	5b                   	pop    %ebx
  800643:	5e                   	pop    %esi
  800644:	5f                   	pop    %edi
  800645:	5d                   	pop    %ebp
  800646:	c3                   	ret    

00800647 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800647:	55                   	push   %ebp
  800648:	89 e5                	mov    %esp,%ebp
  80064a:	57                   	push   %edi
  80064b:	56                   	push   %esi
  80064c:	53                   	push   %ebx
  80064d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800650:	bb 00 00 00 00       	mov    $0x0,%ebx
  800655:	b8 08 00 00 00       	mov    $0x8,%eax
  80065a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80065d:	8b 55 08             	mov    0x8(%ebp),%edx
  800660:	89 df                	mov    %ebx,%edi
  800662:	89 de                	mov    %ebx,%esi
  800664:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800666:	85 c0                	test   %eax,%eax
  800668:	7e 17                	jle    800681 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80066a:	83 ec 0c             	sub    $0xc,%esp
  80066d:	50                   	push   %eax
  80066e:	6a 08                	push   $0x8
  800670:	68 cf 23 80 00       	push   $0x8023cf
  800675:	6a 22                	push   $0x22
  800677:	68 ec 23 80 00       	push   $0x8023ec
  80067c:	e8 14 13 00 00       	call   801995 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800681:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800684:	5b                   	pop    %ebx
  800685:	5e                   	pop    %esi
  800686:	5f                   	pop    %edi
  800687:	5d                   	pop    %ebp
  800688:	c3                   	ret    

00800689 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800689:	55                   	push   %ebp
  80068a:	89 e5                	mov    %esp,%ebp
  80068c:	57                   	push   %edi
  80068d:	56                   	push   %esi
  80068e:	53                   	push   %ebx
  80068f:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800692:	bb 00 00 00 00       	mov    $0x0,%ebx
  800697:	b8 09 00 00 00       	mov    $0x9,%eax
  80069c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80069f:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a2:	89 df                	mov    %ebx,%edi
  8006a4:	89 de                	mov    %ebx,%esi
  8006a6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006a8:	85 c0                	test   %eax,%eax
  8006aa:	7e 17                	jle    8006c3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ac:	83 ec 0c             	sub    $0xc,%esp
  8006af:	50                   	push   %eax
  8006b0:	6a 09                	push   $0x9
  8006b2:	68 cf 23 80 00       	push   $0x8023cf
  8006b7:	6a 22                	push   $0x22
  8006b9:	68 ec 23 80 00       	push   $0x8023ec
  8006be:	e8 d2 12 00 00       	call   801995 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c6:	5b                   	pop    %ebx
  8006c7:	5e                   	pop    %esi
  8006c8:	5f                   	pop    %edi
  8006c9:	5d                   	pop    %ebp
  8006ca:	c3                   	ret    

008006cb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	57                   	push   %edi
  8006cf:	56                   	push   %esi
  8006d0:	53                   	push   %ebx
  8006d1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e4:	89 df                	mov    %ebx,%edi
  8006e6:	89 de                	mov    %ebx,%esi
  8006e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	7e 17                	jle    800705 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ee:	83 ec 0c             	sub    $0xc,%esp
  8006f1:	50                   	push   %eax
  8006f2:	6a 0a                	push   $0xa
  8006f4:	68 cf 23 80 00       	push   $0x8023cf
  8006f9:	6a 22                	push   $0x22
  8006fb:	68 ec 23 80 00       	push   $0x8023ec
  800700:	e8 90 12 00 00       	call   801995 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	57                   	push   %edi
  800711:	56                   	push   %esi
  800712:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800713:	be 00 00 00 00       	mov    $0x0,%esi
  800718:	b8 0c 00 00 00       	mov    $0xc,%eax
  80071d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800720:	8b 55 08             	mov    0x8(%ebp),%edx
  800723:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800726:	8b 7d 14             	mov    0x14(%ebp),%edi
  800729:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80072b:	5b                   	pop    %ebx
  80072c:	5e                   	pop    %esi
  80072d:	5f                   	pop    %edi
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	57                   	push   %edi
  800734:	56                   	push   %esi
  800735:	53                   	push   %ebx
  800736:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
  800746:	89 cb                	mov    %ecx,%ebx
  800748:	89 cf                	mov    %ecx,%edi
  80074a:	89 ce                	mov    %ecx,%esi
  80074c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80074e:	85 c0                	test   %eax,%eax
  800750:	7e 17                	jle    800769 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800752:	83 ec 0c             	sub    $0xc,%esp
  800755:	50                   	push   %eax
  800756:	6a 0d                	push   $0xd
  800758:	68 cf 23 80 00       	push   $0x8023cf
  80075d:	6a 22                	push   $0x22
  80075f:	68 ec 23 80 00       	push   $0x8023ec
  800764:	e8 2c 12 00 00       	call   801995 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800769:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5f                   	pop    %edi
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	57                   	push   %edi
  800775:	56                   	push   %esi
  800776:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800777:	ba 00 00 00 00       	mov    $0x0,%edx
  80077c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800781:	89 d1                	mov    %edx,%ecx
  800783:	89 d3                	mov    %edx,%ebx
  800785:	89 d7                	mov    %edx,%edi
  800787:	89 d6                	mov    %edx,%esi
  800789:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5f                   	pop    %edi
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	57                   	push   %edi
  800794:	56                   	push   %esi
  800795:	53                   	push   %ebx
  800796:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800799:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079e:	b8 0f 00 00 00       	mov    $0xf,%eax
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a6:	89 cb                	mov    %ecx,%ebx
  8007a8:	89 cf                	mov    %ecx,%edi
  8007aa:	89 ce                	mov    %ecx,%esi
  8007ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	7e 17                	jle    8007c9 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007b2:	83 ec 0c             	sub    $0xc,%esp
  8007b5:	50                   	push   %eax
  8007b6:	6a 0f                	push   $0xf
  8007b8:	68 cf 23 80 00       	push   $0x8023cf
  8007bd:	6a 22                	push   $0x22
  8007bf:	68 ec 23 80 00       	push   $0x8023ec
  8007c4:	e8 cc 11 00 00       	call   801995 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8007c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007cc:	5b                   	pop    %ebx
  8007cd:	5e                   	pop    %esi
  8007ce:	5f                   	pop    %edi
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <sys_recv>:

int
sys_recv(void *addr)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	57                   	push   %edi
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8007da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007df:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e7:	89 cb                	mov    %ecx,%ebx
  8007e9:	89 cf                	mov    %ecx,%edi
  8007eb:	89 ce                	mov    %ecx,%esi
  8007ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007ef:	85 c0                	test   %eax,%eax
  8007f1:	7e 17                	jle    80080a <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007f3:	83 ec 0c             	sub    $0xc,%esp
  8007f6:	50                   	push   %eax
  8007f7:	6a 10                	push   $0x10
  8007f9:	68 cf 23 80 00       	push   $0x8023cf
  8007fe:	6a 22                	push   $0x22
  800800:	68 ec 23 80 00       	push   $0x8023ec
  800805:	e8 8b 11 00 00       	call   801995 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  80080a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080d:	5b                   	pop    %ebx
  80080e:	5e                   	pop    %esi
  80080f:	5f                   	pop    %edi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	05 00 00 00 30       	add    $0x30000000,%eax
  80081d:	c1 e8 0c             	shr    $0xc,%eax
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80082d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800832:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800844:	89 c2                	mov    %eax,%edx
  800846:	c1 ea 16             	shr    $0x16,%edx
  800849:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800850:	f6 c2 01             	test   $0x1,%dl
  800853:	74 11                	je     800866 <fd_alloc+0x2d>
  800855:	89 c2                	mov    %eax,%edx
  800857:	c1 ea 0c             	shr    $0xc,%edx
  80085a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800861:	f6 c2 01             	test   $0x1,%dl
  800864:	75 09                	jne    80086f <fd_alloc+0x36>
			*fd_store = fd;
  800866:	89 01                	mov    %eax,(%ecx)
			return 0;
  800868:	b8 00 00 00 00       	mov    $0x0,%eax
  80086d:	eb 17                	jmp    800886 <fd_alloc+0x4d>
  80086f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800874:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800879:	75 c9                	jne    800844 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80087b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800881:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80088e:	83 f8 1f             	cmp    $0x1f,%eax
  800891:	77 36                	ja     8008c9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800893:	c1 e0 0c             	shl    $0xc,%eax
  800896:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80089b:	89 c2                	mov    %eax,%edx
  80089d:	c1 ea 16             	shr    $0x16,%edx
  8008a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8008a7:	f6 c2 01             	test   $0x1,%dl
  8008aa:	74 24                	je     8008d0 <fd_lookup+0x48>
  8008ac:	89 c2                	mov    %eax,%edx
  8008ae:	c1 ea 0c             	shr    $0xc,%edx
  8008b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8008b8:	f6 c2 01             	test   $0x1,%dl
  8008bb:	74 1a                	je     8008d7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c0:	89 02                	mov    %eax,(%edx)
	return 0;
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c7:	eb 13                	jmp    8008dc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ce:	eb 0c                	jmp    8008dc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d5:	eb 05                	jmp    8008dc <fd_lookup+0x54>
  8008d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8008e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ec:	eb 13                	jmp    800901 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8008ee:	39 08                	cmp    %ecx,(%eax)
  8008f0:	75 0c                	jne    8008fe <dev_lookup+0x20>
			*dev = devtab[i];
  8008f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fc:	eb 36                	jmp    800934 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008fe:	83 c2 01             	add    $0x1,%edx
  800901:	8b 04 95 78 24 80 00 	mov    0x802478(,%edx,4),%eax
  800908:	85 c0                	test   %eax,%eax
  80090a:	75 e2                	jne    8008ee <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80090c:	a1 08 40 80 00       	mov    0x804008,%eax
  800911:	8b 40 48             	mov    0x48(%eax),%eax
  800914:	83 ec 04             	sub    $0x4,%esp
  800917:	51                   	push   %ecx
  800918:	50                   	push   %eax
  800919:	68 fc 23 80 00       	push   $0x8023fc
  80091e:	e8 4b 11 00 00       	call   801a6e <cprintf>
	*dev = 0;
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
  800926:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80092c:	83 c4 10             	add    $0x10,%esp
  80092f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	83 ec 10             	sub    $0x10,%esp
  80093e:	8b 75 08             	mov    0x8(%ebp),%esi
  800941:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800947:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800948:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80094e:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800951:	50                   	push   %eax
  800952:	e8 31 ff ff ff       	call   800888 <fd_lookup>
  800957:	83 c4 08             	add    $0x8,%esp
  80095a:	85 c0                	test   %eax,%eax
  80095c:	78 05                	js     800963 <fd_close+0x2d>
	    || fd != fd2)
  80095e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800961:	74 0c                	je     80096f <fd_close+0x39>
		return (must_exist ? r : 0);
  800963:	84 db                	test   %bl,%bl
  800965:	ba 00 00 00 00       	mov    $0x0,%edx
  80096a:	0f 44 c2             	cmove  %edx,%eax
  80096d:	eb 41                	jmp    8009b0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80096f:	83 ec 08             	sub    $0x8,%esp
  800972:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800975:	50                   	push   %eax
  800976:	ff 36                	pushl  (%esi)
  800978:	e8 61 ff ff ff       	call   8008de <dev_lookup>
  80097d:	89 c3                	mov    %eax,%ebx
  80097f:	83 c4 10             	add    $0x10,%esp
  800982:	85 c0                	test   %eax,%eax
  800984:	78 1a                	js     8009a0 <fd_close+0x6a>
		if (dev->dev_close)
  800986:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800989:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80098c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800991:	85 c0                	test   %eax,%eax
  800993:	74 0b                	je     8009a0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800995:	83 ec 0c             	sub    $0xc,%esp
  800998:	56                   	push   %esi
  800999:	ff d0                	call   *%eax
  80099b:	89 c3                	mov    %eax,%ebx
  80099d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8009a0:	83 ec 08             	sub    $0x8,%esp
  8009a3:	56                   	push   %esi
  8009a4:	6a 00                	push   $0x0
  8009a6:	e8 5a fc ff ff       	call   800605 <sys_page_unmap>
	return r;
  8009ab:	83 c4 10             	add    $0x10,%esp
  8009ae:	89 d8                	mov    %ebx,%eax
}
  8009b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009b3:	5b                   	pop    %ebx
  8009b4:	5e                   	pop    %esi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009c0:	50                   	push   %eax
  8009c1:	ff 75 08             	pushl  0x8(%ebp)
  8009c4:	e8 bf fe ff ff       	call   800888 <fd_lookup>
  8009c9:	89 c2                	mov    %eax,%edx
  8009cb:	83 c4 08             	add    $0x8,%esp
  8009ce:	85 d2                	test   %edx,%edx
  8009d0:	78 10                	js     8009e2 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8009d2:	83 ec 08             	sub    $0x8,%esp
  8009d5:	6a 01                	push   $0x1
  8009d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8009da:	e8 57 ff ff ff       	call   800936 <fd_close>
  8009df:	83 c4 10             	add    $0x10,%esp
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <close_all>:

void
close_all(void)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	53                   	push   %ebx
  8009e8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8009eb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009f0:	83 ec 0c             	sub    $0xc,%esp
  8009f3:	53                   	push   %ebx
  8009f4:	e8 be ff ff ff       	call   8009b7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009f9:	83 c3 01             	add    $0x1,%ebx
  8009fc:	83 c4 10             	add    $0x10,%esp
  8009ff:	83 fb 20             	cmp    $0x20,%ebx
  800a02:	75 ec                	jne    8009f0 <close_all+0xc>
		close(i);
}
  800a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	57                   	push   %edi
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
  800a0f:	83 ec 2c             	sub    $0x2c,%esp
  800a12:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a15:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a18:	50                   	push   %eax
  800a19:	ff 75 08             	pushl  0x8(%ebp)
  800a1c:	e8 67 fe ff ff       	call   800888 <fd_lookup>
  800a21:	89 c2                	mov    %eax,%edx
  800a23:	83 c4 08             	add    $0x8,%esp
  800a26:	85 d2                	test   %edx,%edx
  800a28:	0f 88 c1 00 00 00    	js     800aef <dup+0xe6>
		return r;
	close(newfdnum);
  800a2e:	83 ec 0c             	sub    $0xc,%esp
  800a31:	56                   	push   %esi
  800a32:	e8 80 ff ff ff       	call   8009b7 <close>

	newfd = INDEX2FD(newfdnum);
  800a37:	89 f3                	mov    %esi,%ebx
  800a39:	c1 e3 0c             	shl    $0xc,%ebx
  800a3c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800a42:	83 c4 04             	add    $0x4,%esp
  800a45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a48:	e8 d5 fd ff ff       	call   800822 <fd2data>
  800a4d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800a4f:	89 1c 24             	mov    %ebx,(%esp)
  800a52:	e8 cb fd ff ff       	call   800822 <fd2data>
  800a57:	83 c4 10             	add    $0x10,%esp
  800a5a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a5d:	89 f8                	mov    %edi,%eax
  800a5f:	c1 e8 16             	shr    $0x16,%eax
  800a62:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a69:	a8 01                	test   $0x1,%al
  800a6b:	74 37                	je     800aa4 <dup+0x9b>
  800a6d:	89 f8                	mov    %edi,%eax
  800a6f:	c1 e8 0c             	shr    $0xc,%eax
  800a72:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a79:	f6 c2 01             	test   $0x1,%dl
  800a7c:	74 26                	je     800aa4 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a85:	83 ec 0c             	sub    $0xc,%esp
  800a88:	25 07 0e 00 00       	and    $0xe07,%eax
  800a8d:	50                   	push   %eax
  800a8e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a91:	6a 00                	push   $0x0
  800a93:	57                   	push   %edi
  800a94:	6a 00                	push   $0x0
  800a96:	e8 28 fb ff ff       	call   8005c3 <sys_page_map>
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	83 c4 20             	add    $0x20,%esp
  800aa0:	85 c0                	test   %eax,%eax
  800aa2:	78 2e                	js     800ad2 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800aa4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aa7:	89 d0                	mov    %edx,%eax
  800aa9:	c1 e8 0c             	shr    $0xc,%eax
  800aac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ab3:	83 ec 0c             	sub    $0xc,%esp
  800ab6:	25 07 0e 00 00       	and    $0xe07,%eax
  800abb:	50                   	push   %eax
  800abc:	53                   	push   %ebx
  800abd:	6a 00                	push   $0x0
  800abf:	52                   	push   %edx
  800ac0:	6a 00                	push   $0x0
  800ac2:	e8 fc fa ff ff       	call   8005c3 <sys_page_map>
  800ac7:	89 c7                	mov    %eax,%edi
  800ac9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800acc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ace:	85 ff                	test   %edi,%edi
  800ad0:	79 1d                	jns    800aef <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ad2:	83 ec 08             	sub    $0x8,%esp
  800ad5:	53                   	push   %ebx
  800ad6:	6a 00                	push   $0x0
  800ad8:	e8 28 fb ff ff       	call   800605 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800add:	83 c4 08             	add    $0x8,%esp
  800ae0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ae3:	6a 00                	push   $0x0
  800ae5:	e8 1b fb ff ff       	call   800605 <sys_page_unmap>
	return r;
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	89 f8                	mov    %edi,%eax
}
  800aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	83 ec 14             	sub    $0x14,%esp
  800afe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b01:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b04:	50                   	push   %eax
  800b05:	53                   	push   %ebx
  800b06:	e8 7d fd ff ff       	call   800888 <fd_lookup>
  800b0b:	83 c4 08             	add    $0x8,%esp
  800b0e:	89 c2                	mov    %eax,%edx
  800b10:	85 c0                	test   %eax,%eax
  800b12:	78 6d                	js     800b81 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b14:	83 ec 08             	sub    $0x8,%esp
  800b17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1a:	50                   	push   %eax
  800b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b1e:	ff 30                	pushl  (%eax)
  800b20:	e8 b9 fd ff ff       	call   8008de <dev_lookup>
  800b25:	83 c4 10             	add    $0x10,%esp
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	78 4c                	js     800b78 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b2f:	8b 42 08             	mov    0x8(%edx),%eax
  800b32:	83 e0 03             	and    $0x3,%eax
  800b35:	83 f8 01             	cmp    $0x1,%eax
  800b38:	75 21                	jne    800b5b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b3a:	a1 08 40 80 00       	mov    0x804008,%eax
  800b3f:	8b 40 48             	mov    0x48(%eax),%eax
  800b42:	83 ec 04             	sub    $0x4,%esp
  800b45:	53                   	push   %ebx
  800b46:	50                   	push   %eax
  800b47:	68 3d 24 80 00       	push   $0x80243d
  800b4c:	e8 1d 0f 00 00       	call   801a6e <cprintf>
		return -E_INVAL;
  800b51:	83 c4 10             	add    $0x10,%esp
  800b54:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b59:	eb 26                	jmp    800b81 <read+0x8a>
	}
	if (!dev->dev_read)
  800b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b5e:	8b 40 08             	mov    0x8(%eax),%eax
  800b61:	85 c0                	test   %eax,%eax
  800b63:	74 17                	je     800b7c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b65:	83 ec 04             	sub    $0x4,%esp
  800b68:	ff 75 10             	pushl  0x10(%ebp)
  800b6b:	ff 75 0c             	pushl  0xc(%ebp)
  800b6e:	52                   	push   %edx
  800b6f:	ff d0                	call   *%eax
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	83 c4 10             	add    $0x10,%esp
  800b76:	eb 09                	jmp    800b81 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b78:	89 c2                	mov    %eax,%edx
  800b7a:	eb 05                	jmp    800b81 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b7c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800b81:	89 d0                	mov    %edx,%eax
  800b83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 0c             	sub    $0xc,%esp
  800b91:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b94:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b9c:	eb 21                	jmp    800bbf <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b9e:	83 ec 04             	sub    $0x4,%esp
  800ba1:	89 f0                	mov    %esi,%eax
  800ba3:	29 d8                	sub    %ebx,%eax
  800ba5:	50                   	push   %eax
  800ba6:	89 d8                	mov    %ebx,%eax
  800ba8:	03 45 0c             	add    0xc(%ebp),%eax
  800bab:	50                   	push   %eax
  800bac:	57                   	push   %edi
  800bad:	e8 45 ff ff ff       	call   800af7 <read>
		if (m < 0)
  800bb2:	83 c4 10             	add    $0x10,%esp
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	78 0c                	js     800bc5 <readn+0x3d>
			return m;
		if (m == 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	74 06                	je     800bc3 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bbd:	01 c3                	add    %eax,%ebx
  800bbf:	39 f3                	cmp    %esi,%ebx
  800bc1:	72 db                	jb     800b9e <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800bc3:	89 d8                	mov    %ebx,%eax
}
  800bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 14             	sub    $0x14,%esp
  800bd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bd7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bda:	50                   	push   %eax
  800bdb:	53                   	push   %ebx
  800bdc:	e8 a7 fc ff ff       	call   800888 <fd_lookup>
  800be1:	83 c4 08             	add    $0x8,%esp
  800be4:	89 c2                	mov    %eax,%edx
  800be6:	85 c0                	test   %eax,%eax
  800be8:	78 68                	js     800c52 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bea:	83 ec 08             	sub    $0x8,%esp
  800bed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf0:	50                   	push   %eax
  800bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf4:	ff 30                	pushl  (%eax)
  800bf6:	e8 e3 fc ff ff       	call   8008de <dev_lookup>
  800bfb:	83 c4 10             	add    $0x10,%esp
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	78 47                	js     800c49 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c05:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c09:	75 21                	jne    800c2c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c0b:	a1 08 40 80 00       	mov    0x804008,%eax
  800c10:	8b 40 48             	mov    0x48(%eax),%eax
  800c13:	83 ec 04             	sub    $0x4,%esp
  800c16:	53                   	push   %ebx
  800c17:	50                   	push   %eax
  800c18:	68 59 24 80 00       	push   $0x802459
  800c1d:	e8 4c 0e 00 00       	call   801a6e <cprintf>
		return -E_INVAL;
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c2a:	eb 26                	jmp    800c52 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800c2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c2f:	8b 52 0c             	mov    0xc(%edx),%edx
  800c32:	85 d2                	test   %edx,%edx
  800c34:	74 17                	je     800c4d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800c36:	83 ec 04             	sub    $0x4,%esp
  800c39:	ff 75 10             	pushl  0x10(%ebp)
  800c3c:	ff 75 0c             	pushl  0xc(%ebp)
  800c3f:	50                   	push   %eax
  800c40:	ff d2                	call   *%edx
  800c42:	89 c2                	mov    %eax,%edx
  800c44:	83 c4 10             	add    $0x10,%esp
  800c47:	eb 09                	jmp    800c52 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c49:	89 c2                	mov    %eax,%edx
  800c4b:	eb 05                	jmp    800c52 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c4d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800c52:	89 d0                	mov    %edx,%eax
  800c54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c57:	c9                   	leave  
  800c58:	c3                   	ret    

00800c59 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c5f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c62:	50                   	push   %eax
  800c63:	ff 75 08             	pushl  0x8(%ebp)
  800c66:	e8 1d fc ff ff       	call   800888 <fd_lookup>
  800c6b:	83 c4 08             	add    $0x8,%esp
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	78 0e                	js     800c80 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c72:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c78:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    

00800c82 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	53                   	push   %ebx
  800c86:	83 ec 14             	sub    $0x14,%esp
  800c89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c8f:	50                   	push   %eax
  800c90:	53                   	push   %ebx
  800c91:	e8 f2 fb ff ff       	call   800888 <fd_lookup>
  800c96:	83 c4 08             	add    $0x8,%esp
  800c99:	89 c2                	mov    %eax,%edx
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	78 65                	js     800d04 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c9f:	83 ec 08             	sub    $0x8,%esp
  800ca2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca5:	50                   	push   %eax
  800ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca9:	ff 30                	pushl  (%eax)
  800cab:	e8 2e fc ff ff       	call   8008de <dev_lookup>
  800cb0:	83 c4 10             	add    $0x10,%esp
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	78 44                	js     800cfb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cbe:	75 21                	jne    800ce1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800cc0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800cc5:	8b 40 48             	mov    0x48(%eax),%eax
  800cc8:	83 ec 04             	sub    $0x4,%esp
  800ccb:	53                   	push   %ebx
  800ccc:	50                   	push   %eax
  800ccd:	68 1c 24 80 00       	push   $0x80241c
  800cd2:	e8 97 0d 00 00       	call   801a6e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800cdf:	eb 23                	jmp    800d04 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800ce1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ce4:	8b 52 18             	mov    0x18(%edx),%edx
  800ce7:	85 d2                	test   %edx,%edx
  800ce9:	74 14                	je     800cff <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800ceb:	83 ec 08             	sub    $0x8,%esp
  800cee:	ff 75 0c             	pushl  0xc(%ebp)
  800cf1:	50                   	push   %eax
  800cf2:	ff d2                	call   *%edx
  800cf4:	89 c2                	mov    %eax,%edx
  800cf6:	83 c4 10             	add    $0x10,%esp
  800cf9:	eb 09                	jmp    800d04 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cfb:	89 c2                	mov    %eax,%edx
  800cfd:	eb 05                	jmp    800d04 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800cff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800d04:	89 d0                	mov    %edx,%eax
  800d06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 14             	sub    $0x14,%esp
  800d12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d18:	50                   	push   %eax
  800d19:	ff 75 08             	pushl  0x8(%ebp)
  800d1c:	e8 67 fb ff ff       	call   800888 <fd_lookup>
  800d21:	83 c4 08             	add    $0x8,%esp
  800d24:	89 c2                	mov    %eax,%edx
  800d26:	85 c0                	test   %eax,%eax
  800d28:	78 58                	js     800d82 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d2a:	83 ec 08             	sub    $0x8,%esp
  800d2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d30:	50                   	push   %eax
  800d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d34:	ff 30                	pushl  (%eax)
  800d36:	e8 a3 fb ff ff       	call   8008de <dev_lookup>
  800d3b:	83 c4 10             	add    $0x10,%esp
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	78 37                	js     800d79 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d45:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d49:	74 32                	je     800d7d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d4b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d4e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d55:	00 00 00 
	stat->st_isdir = 0;
  800d58:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d5f:	00 00 00 
	stat->st_dev = dev;
  800d62:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d68:	83 ec 08             	sub    $0x8,%esp
  800d6b:	53                   	push   %ebx
  800d6c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d6f:	ff 50 14             	call   *0x14(%eax)
  800d72:	89 c2                	mov    %eax,%edx
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	eb 09                	jmp    800d82 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d79:	89 c2                	mov    %eax,%edx
  800d7b:	eb 05                	jmp    800d82 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d7d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d82:	89 d0                	mov    %edx,%eax
  800d84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d8e:	83 ec 08             	sub    $0x8,%esp
  800d91:	6a 00                	push   $0x0
  800d93:	ff 75 08             	pushl  0x8(%ebp)
  800d96:	e8 09 02 00 00       	call   800fa4 <open>
  800d9b:	89 c3                	mov    %eax,%ebx
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	85 db                	test   %ebx,%ebx
  800da2:	78 1b                	js     800dbf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800da4:	83 ec 08             	sub    $0x8,%esp
  800da7:	ff 75 0c             	pushl  0xc(%ebp)
  800daa:	53                   	push   %ebx
  800dab:	e8 5b ff ff ff       	call   800d0b <fstat>
  800db0:	89 c6                	mov    %eax,%esi
	close(fd);
  800db2:	89 1c 24             	mov    %ebx,(%esp)
  800db5:	e8 fd fb ff ff       	call   8009b7 <close>
	return r;
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	89 f0                	mov    %esi,%eax
}
  800dbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	89 c6                	mov    %eax,%esi
  800dcd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800dcf:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800dd6:	75 12                	jne    800dea <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	6a 01                	push   $0x1
  800ddd:	e8 97 12 00 00       	call   802079 <ipc_find_env>
  800de2:	a3 00 40 80 00       	mov    %eax,0x804000
  800de7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800dea:	6a 07                	push   $0x7
  800dec:	68 00 50 80 00       	push   $0x805000
  800df1:	56                   	push   %esi
  800df2:	ff 35 00 40 80 00    	pushl  0x804000
  800df8:	e8 28 12 00 00       	call   802025 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800dfd:	83 c4 0c             	add    $0xc,%esp
  800e00:	6a 00                	push   $0x0
  800e02:	53                   	push   %ebx
  800e03:	6a 00                	push   $0x0
  800e05:	e8 b2 11 00 00       	call   801fbc <ipc_recv>
}
  800e0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e1d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e25:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2f:	b8 02 00 00 00       	mov    $0x2,%eax
  800e34:	e8 8d ff ff ff       	call   800dc6 <fsipc>
}
  800e39:	c9                   	leave  
  800e3a:	c3                   	ret    

00800e3b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	8b 40 0c             	mov    0xc(%eax),%eax
  800e47:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e51:	b8 06 00 00 00       	mov    $0x6,%eax
  800e56:	e8 6b ff ff ff       	call   800dc6 <fsipc>
}
  800e5b:	c9                   	leave  
  800e5c:	c3                   	ret    

00800e5d <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	53                   	push   %ebx
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e6d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e72:	ba 00 00 00 00       	mov    $0x0,%edx
  800e77:	b8 05 00 00 00       	mov    $0x5,%eax
  800e7c:	e8 45 ff ff ff       	call   800dc6 <fsipc>
  800e81:	89 c2                	mov    %eax,%edx
  800e83:	85 d2                	test   %edx,%edx
  800e85:	78 2c                	js     800eb3 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e87:	83 ec 08             	sub    $0x8,%esp
  800e8a:	68 00 50 80 00       	push   $0x805000
  800e8f:	53                   	push   %ebx
  800e90:	e8 e2 f2 ff ff       	call   800177 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e95:	a1 80 50 80 00       	mov    0x805080,%eax
  800e9a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ea0:	a1 84 50 80 00       	mov    0x805084,%eax
  800ea5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb6:	c9                   	leave  
  800eb7:	c3                   	ret    

00800eb8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
  800ebe:	83 ec 0c             	sub    $0xc,%esp
  800ec1:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	8b 40 0c             	mov    0xc(%eax),%eax
  800eca:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800ecf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800ed2:	eb 3d                	jmp    800f11 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800ed4:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800eda:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800edf:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	57                   	push   %edi
  800ee6:	53                   	push   %ebx
  800ee7:	68 08 50 80 00       	push   $0x805008
  800eec:	e8 18 f4 ff ff       	call   800309 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800ef1:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800ef7:	ba 00 00 00 00       	mov    $0x0,%edx
  800efc:	b8 04 00 00 00       	mov    $0x4,%eax
  800f01:	e8 c0 fe ff ff       	call   800dc6 <fsipc>
  800f06:	83 c4 10             	add    $0x10,%esp
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	78 0d                	js     800f1a <devfile_write+0x62>
		        return r;
                n -= tmp;
  800f0d:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800f0f:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800f11:	85 f6                	test   %esi,%esi
  800f13:	75 bf                	jne    800ed4 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800f15:	89 d8                	mov    %ebx,%eax
  800f17:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2d:	8b 40 0c             	mov    0xc(%eax),%eax
  800f30:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800f35:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800f3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f40:	b8 03 00 00 00       	mov    $0x3,%eax
  800f45:	e8 7c fe ff ff       	call   800dc6 <fsipc>
  800f4a:	89 c3                	mov    %eax,%ebx
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	78 4b                	js     800f9b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800f50:	39 c6                	cmp    %eax,%esi
  800f52:	73 16                	jae    800f6a <devfile_read+0x48>
  800f54:	68 8c 24 80 00       	push   $0x80248c
  800f59:	68 93 24 80 00       	push   $0x802493
  800f5e:	6a 7c                	push   $0x7c
  800f60:	68 a8 24 80 00       	push   $0x8024a8
  800f65:	e8 2b 0a 00 00       	call   801995 <_panic>
	assert(r <= PGSIZE);
  800f6a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800f6f:	7e 16                	jle    800f87 <devfile_read+0x65>
  800f71:	68 b3 24 80 00       	push   $0x8024b3
  800f76:	68 93 24 80 00       	push   $0x802493
  800f7b:	6a 7d                	push   $0x7d
  800f7d:	68 a8 24 80 00       	push   $0x8024a8
  800f82:	e8 0e 0a 00 00       	call   801995 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	50                   	push   %eax
  800f8b:	68 00 50 80 00       	push   $0x805000
  800f90:	ff 75 0c             	pushl  0xc(%ebp)
  800f93:	e8 71 f3 ff ff       	call   800309 <memmove>
	return r;
  800f98:	83 c4 10             	add    $0x10,%esp
}
  800f9b:	89 d8                	mov    %ebx,%eax
  800f9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 20             	sub    $0x20,%esp
  800fab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800fae:	53                   	push   %ebx
  800faf:	e8 8a f1 ff ff       	call   80013e <strlen>
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800fbc:	7f 67                	jg     801025 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc4:	50                   	push   %eax
  800fc5:	e8 6f f8 ff ff       	call   800839 <fd_alloc>
  800fca:	83 c4 10             	add    $0x10,%esp
		return r;
  800fcd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 57                	js     80102a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800fd3:	83 ec 08             	sub    $0x8,%esp
  800fd6:	53                   	push   %ebx
  800fd7:	68 00 50 80 00       	push   $0x805000
  800fdc:	e8 96 f1 ff ff       	call   800177 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800fe9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fec:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff1:	e8 d0 fd ff ff       	call   800dc6 <fsipc>
  800ff6:	89 c3                	mov    %eax,%ebx
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	79 14                	jns    801013 <open+0x6f>
		fd_close(fd, 0);
  800fff:	83 ec 08             	sub    $0x8,%esp
  801002:	6a 00                	push   $0x0
  801004:	ff 75 f4             	pushl  -0xc(%ebp)
  801007:	e8 2a f9 ff ff       	call   800936 <fd_close>
		return r;
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	89 da                	mov    %ebx,%edx
  801011:	eb 17                	jmp    80102a <open+0x86>
	}

	return fd2num(fd);
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	ff 75 f4             	pushl  -0xc(%ebp)
  801019:	e8 f4 f7 ff ff       	call   800812 <fd2num>
  80101e:	89 c2                	mov    %eax,%edx
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	eb 05                	jmp    80102a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801025:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80102a:	89 d0                	mov    %edx,%eax
  80102c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801037:	ba 00 00 00 00       	mov    $0x0,%edx
  80103c:	b8 08 00 00 00       	mov    $0x8,%eax
  801041:	e8 80 fd ff ff       	call   800dc6 <fsipc>
}
  801046:	c9                   	leave  
  801047:	c3                   	ret    

00801048 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80104e:	68 bf 24 80 00       	push   $0x8024bf
  801053:	ff 75 0c             	pushl  0xc(%ebp)
  801056:	e8 1c f1 ff ff       	call   800177 <strcpy>
	return 0;
}
  80105b:	b8 00 00 00 00       	mov    $0x0,%eax
  801060:	c9                   	leave  
  801061:	c3                   	ret    

00801062 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	53                   	push   %ebx
  801066:	83 ec 10             	sub    $0x10,%esp
  801069:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80106c:	53                   	push   %ebx
  80106d:	e8 3f 10 00 00       	call   8020b1 <pageref>
  801072:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801075:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80107a:	83 f8 01             	cmp    $0x1,%eax
  80107d:	75 10                	jne    80108f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80107f:	83 ec 0c             	sub    $0xc,%esp
  801082:	ff 73 0c             	pushl  0xc(%ebx)
  801085:	e8 ca 02 00 00       	call   801354 <nsipc_close>
  80108a:	89 c2                	mov    %eax,%edx
  80108c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80108f:	89 d0                	mov    %edx,%eax
  801091:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801094:	c9                   	leave  
  801095:	c3                   	ret    

00801096 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80109c:	6a 00                	push   $0x0
  80109e:	ff 75 10             	pushl  0x10(%ebp)
  8010a1:	ff 75 0c             	pushl  0xc(%ebp)
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	ff 70 0c             	pushl  0xc(%eax)
  8010aa:	e8 82 03 00 00       	call   801431 <nsipc_send>
}
  8010af:	c9                   	leave  
  8010b0:	c3                   	ret    

008010b1 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8010b7:	6a 00                	push   $0x0
  8010b9:	ff 75 10             	pushl  0x10(%ebp)
  8010bc:	ff 75 0c             	pushl  0xc(%ebp)
  8010bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c2:	ff 70 0c             	pushl  0xc(%eax)
  8010c5:	e8 fb 02 00 00       	call   8013c5 <nsipc_recv>
}
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8010d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010d5:	52                   	push   %edx
  8010d6:	50                   	push   %eax
  8010d7:	e8 ac f7 ff ff       	call   800888 <fd_lookup>
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	78 17                	js     8010fa <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8010e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010e6:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8010ec:	39 08                	cmp    %ecx,(%eax)
  8010ee:	75 05                	jne    8010f5 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8010f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8010f3:	eb 05                	jmp    8010fa <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8010f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 1c             	sub    $0x1c,%esp
  801104:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801106:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801109:	50                   	push   %eax
  80110a:	e8 2a f7 ff ff       	call   800839 <fd_alloc>
  80110f:	89 c3                	mov    %eax,%ebx
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	78 1b                	js     801133 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801118:	83 ec 04             	sub    $0x4,%esp
  80111b:	68 07 04 00 00       	push   $0x407
  801120:	ff 75 f4             	pushl  -0xc(%ebp)
  801123:	6a 00                	push   $0x0
  801125:	e8 56 f4 ff ff       	call   800580 <sys_page_alloc>
  80112a:	89 c3                	mov    %eax,%ebx
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	79 10                	jns    801143 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	56                   	push   %esi
  801137:	e8 18 02 00 00       	call   801354 <nsipc_close>
		return r;
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	89 d8                	mov    %ebx,%eax
  801141:	eb 24                	jmp    801167 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801143:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80114e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801151:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801158:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80115b:	83 ec 0c             	sub    $0xc,%esp
  80115e:	52                   	push   %edx
  80115f:	e8 ae f6 ff ff       	call   800812 <fd2num>
  801164:	83 c4 10             	add    $0x10,%esp
}
  801167:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80116a:	5b                   	pop    %ebx
  80116b:	5e                   	pop    %esi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
  801177:	e8 50 ff ff ff       	call   8010cc <fd2sockid>
		return r;
  80117c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 1f                	js     8011a1 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	ff 75 10             	pushl  0x10(%ebp)
  801188:	ff 75 0c             	pushl  0xc(%ebp)
  80118b:	50                   	push   %eax
  80118c:	e8 1c 01 00 00       	call   8012ad <nsipc_accept>
  801191:	83 c4 10             	add    $0x10,%esp
		return r;
  801194:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801196:	85 c0                	test   %eax,%eax
  801198:	78 07                	js     8011a1 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80119a:	e8 5d ff ff ff       	call   8010fc <alloc_sockfd>
  80119f:	89 c1                	mov    %eax,%ecx
}
  8011a1:	89 c8                	mov    %ecx,%eax
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    

008011a5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8011ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ae:	e8 19 ff ff ff       	call   8010cc <fd2sockid>
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	85 d2                	test   %edx,%edx
  8011b7:	78 12                	js     8011cb <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  8011b9:	83 ec 04             	sub    $0x4,%esp
  8011bc:	ff 75 10             	pushl  0x10(%ebp)
  8011bf:	ff 75 0c             	pushl  0xc(%ebp)
  8011c2:	52                   	push   %edx
  8011c3:	e8 35 01 00 00       	call   8012fd <nsipc_bind>
  8011c8:	83 c4 10             	add    $0x10,%esp
}
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <shutdown>:

int
shutdown(int s, int how)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	e8 f1 fe ff ff       	call   8010cc <fd2sockid>
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	85 d2                	test   %edx,%edx
  8011df:	78 0f                	js     8011f0 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	ff 75 0c             	pushl  0xc(%ebp)
  8011e7:	52                   	push   %edx
  8011e8:	e8 45 01 00 00       	call   801332 <nsipc_shutdown>
  8011ed:	83 c4 10             	add    $0x10,%esp
}
  8011f0:	c9                   	leave  
  8011f1:	c3                   	ret    

008011f2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8011f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fb:	e8 cc fe ff ff       	call   8010cc <fd2sockid>
  801200:	89 c2                	mov    %eax,%edx
  801202:	85 d2                	test   %edx,%edx
  801204:	78 12                	js     801218 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801206:	83 ec 04             	sub    $0x4,%esp
  801209:	ff 75 10             	pushl  0x10(%ebp)
  80120c:	ff 75 0c             	pushl  0xc(%ebp)
  80120f:	52                   	push   %edx
  801210:	e8 59 01 00 00       	call   80136e <nsipc_connect>
  801215:	83 c4 10             	add    $0x10,%esp
}
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <listen>:

int
listen(int s, int backlog)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801220:	8b 45 08             	mov    0x8(%ebp),%eax
  801223:	e8 a4 fe ff ff       	call   8010cc <fd2sockid>
  801228:	89 c2                	mov    %eax,%edx
  80122a:	85 d2                	test   %edx,%edx
  80122c:	78 0f                	js     80123d <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  80122e:	83 ec 08             	sub    $0x8,%esp
  801231:	ff 75 0c             	pushl  0xc(%ebp)
  801234:	52                   	push   %edx
  801235:	e8 69 01 00 00       	call   8013a3 <nsipc_listen>
  80123a:	83 c4 10             	add    $0x10,%esp
}
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801245:	ff 75 10             	pushl  0x10(%ebp)
  801248:	ff 75 0c             	pushl  0xc(%ebp)
  80124b:	ff 75 08             	pushl  0x8(%ebp)
  80124e:	e8 3c 02 00 00       	call   80148f <nsipc_socket>
  801253:	89 c2                	mov    %eax,%edx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 d2                	test   %edx,%edx
  80125a:	78 05                	js     801261 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  80125c:	e8 9b fe ff ff       	call   8010fc <alloc_sockfd>
}
  801261:	c9                   	leave  
  801262:	c3                   	ret    

00801263 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	53                   	push   %ebx
  801267:	83 ec 04             	sub    $0x4,%esp
  80126a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80126c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801273:	75 12                	jne    801287 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801275:	83 ec 0c             	sub    $0xc,%esp
  801278:	6a 02                	push   $0x2
  80127a:	e8 fa 0d 00 00       	call   802079 <ipc_find_env>
  80127f:	a3 04 40 80 00       	mov    %eax,0x804004
  801284:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801287:	6a 07                	push   $0x7
  801289:	68 00 60 80 00       	push   $0x806000
  80128e:	53                   	push   %ebx
  80128f:	ff 35 04 40 80 00    	pushl  0x804004
  801295:	e8 8b 0d 00 00       	call   802025 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80129a:	83 c4 0c             	add    $0xc,%esp
  80129d:	6a 00                	push   $0x0
  80129f:	6a 00                	push   $0x0
  8012a1:	6a 00                	push   $0x0
  8012a3:	e8 14 0d 00 00       	call   801fbc <ipc_recv>
}
  8012a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ab:	c9                   	leave  
  8012ac:	c3                   	ret    

008012ad <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8012b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8012bd:	8b 06                	mov    (%esi),%eax
  8012bf:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8012c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c9:	e8 95 ff ff ff       	call   801263 <nsipc>
  8012ce:	89 c3                	mov    %eax,%ebx
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 20                	js     8012f4 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8012d4:	83 ec 04             	sub    $0x4,%esp
  8012d7:	ff 35 10 60 80 00    	pushl  0x806010
  8012dd:	68 00 60 80 00       	push   $0x806000
  8012e2:	ff 75 0c             	pushl  0xc(%ebp)
  8012e5:	e8 1f f0 ff ff       	call   800309 <memmove>
		*addrlen = ret->ret_addrlen;
  8012ea:	a1 10 60 80 00       	mov    0x806010,%eax
  8012ef:	89 06                	mov    %eax,(%esi)
  8012f1:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8012f4:	89 d8                	mov    %ebx,%eax
  8012f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801307:	8b 45 08             	mov    0x8(%ebp),%eax
  80130a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80130f:	53                   	push   %ebx
  801310:	ff 75 0c             	pushl  0xc(%ebp)
  801313:	68 04 60 80 00       	push   $0x806004
  801318:	e8 ec ef ff ff       	call   800309 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80131d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801323:	b8 02 00 00 00       	mov    $0x2,%eax
  801328:	e8 36 ff ff ff       	call   801263 <nsipc>
}
  80132d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801338:	8b 45 08             	mov    0x8(%ebp),%eax
  80133b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801340:	8b 45 0c             	mov    0xc(%ebp),%eax
  801343:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801348:	b8 03 00 00 00       	mov    $0x3,%eax
  80134d:	e8 11 ff ff ff       	call   801263 <nsipc>
}
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <nsipc_close>:

int
nsipc_close(int s)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80135a:	8b 45 08             	mov    0x8(%ebp),%eax
  80135d:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801362:	b8 04 00 00 00       	mov    $0x4,%eax
  801367:	e8 f7 fe ff ff       	call   801263 <nsipc>
}
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    

0080136e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	53                   	push   %ebx
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
  80137b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801380:	53                   	push   %ebx
  801381:	ff 75 0c             	pushl  0xc(%ebp)
  801384:	68 04 60 80 00       	push   $0x806004
  801389:	e8 7b ef ff ff       	call   800309 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80138e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801394:	b8 05 00 00 00       	mov    $0x5,%eax
  801399:	e8 c5 fe ff ff       	call   801263 <nsipc>
}
  80139e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8013b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8013b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8013be:	e8 a0 fe ff ff       	call   801263 <nsipc>
}
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
  8013ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8013d5:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8013db:	8b 45 14             	mov    0x14(%ebp),%eax
  8013de:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8013e3:	b8 07 00 00 00       	mov    $0x7,%eax
  8013e8:	e8 76 fe ff ff       	call   801263 <nsipc>
  8013ed:	89 c3                	mov    %eax,%ebx
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 35                	js     801428 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8013f3:	39 f0                	cmp    %esi,%eax
  8013f5:	7f 07                	jg     8013fe <nsipc_recv+0x39>
  8013f7:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8013fc:	7e 16                	jle    801414 <nsipc_recv+0x4f>
  8013fe:	68 cb 24 80 00       	push   $0x8024cb
  801403:	68 93 24 80 00       	push   $0x802493
  801408:	6a 62                	push   $0x62
  80140a:	68 e0 24 80 00       	push   $0x8024e0
  80140f:	e8 81 05 00 00       	call   801995 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801414:	83 ec 04             	sub    $0x4,%esp
  801417:	50                   	push   %eax
  801418:	68 00 60 80 00       	push   $0x806000
  80141d:	ff 75 0c             	pushl  0xc(%ebp)
  801420:	e8 e4 ee ff ff       	call   800309 <memmove>
  801425:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801428:	89 d8                	mov    %ebx,%eax
  80142a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5e                   	pop    %esi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	53                   	push   %ebx
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801443:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801449:	7e 16                	jle    801461 <nsipc_send+0x30>
  80144b:	68 ec 24 80 00       	push   $0x8024ec
  801450:	68 93 24 80 00       	push   $0x802493
  801455:	6a 6d                	push   $0x6d
  801457:	68 e0 24 80 00       	push   $0x8024e0
  80145c:	e8 34 05 00 00       	call   801995 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801461:	83 ec 04             	sub    $0x4,%esp
  801464:	53                   	push   %ebx
  801465:	ff 75 0c             	pushl  0xc(%ebp)
  801468:	68 0c 60 80 00       	push   $0x80600c
  80146d:	e8 97 ee ff ff       	call   800309 <memmove>
	nsipcbuf.send.req_size = size;
  801472:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801478:	8b 45 14             	mov    0x14(%ebp),%eax
  80147b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801480:	b8 08 00 00 00       	mov    $0x8,%eax
  801485:	e8 d9 fd ff ff       	call   801263 <nsipc>
}
  80148a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801495:	8b 45 08             	mov    0x8(%ebp),%eax
  801498:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80149d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8014a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8014a8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8014ad:	b8 09 00 00 00       	mov    $0x9,%eax
  8014b2:	e8 ac fd ff ff       	call   801263 <nsipc>
}
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	56                   	push   %esi
  8014bd:	53                   	push   %ebx
  8014be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014c1:	83 ec 0c             	sub    $0xc,%esp
  8014c4:	ff 75 08             	pushl  0x8(%ebp)
  8014c7:	e8 56 f3 ff ff       	call   800822 <fd2data>
  8014cc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8014ce:	83 c4 08             	add    $0x8,%esp
  8014d1:	68 f8 24 80 00       	push   $0x8024f8
  8014d6:	53                   	push   %ebx
  8014d7:	e8 9b ec ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014dc:	8b 56 04             	mov    0x4(%esi),%edx
  8014df:	89 d0                	mov    %edx,%eax
  8014e1:	2b 06                	sub    (%esi),%eax
  8014e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8014e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014f0:	00 00 00 
	stat->st_dev = &devpipe;
  8014f3:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8014fa:	30 80 00 
	return 0;
}
  8014fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801502:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    

00801509 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	53                   	push   %ebx
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801513:	53                   	push   %ebx
  801514:	6a 00                	push   $0x0
  801516:	e8 ea f0 ff ff       	call   800605 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80151b:	89 1c 24             	mov    %ebx,(%esp)
  80151e:	e8 ff f2 ff ff       	call   800822 <fd2data>
  801523:	83 c4 08             	add    $0x8,%esp
  801526:	50                   	push   %eax
  801527:	6a 00                	push   $0x0
  801529:	e8 d7 f0 ff ff       	call   800605 <sys_page_unmap>
}
  80152e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	57                   	push   %edi
  801537:	56                   	push   %esi
  801538:	53                   	push   %ebx
  801539:	83 ec 1c             	sub    $0x1c,%esp
  80153c:	89 c6                	mov    %eax,%esi
  80153e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801541:	a1 08 40 80 00       	mov    0x804008,%eax
  801546:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801549:	83 ec 0c             	sub    $0xc,%esp
  80154c:	56                   	push   %esi
  80154d:	e8 5f 0b 00 00       	call   8020b1 <pageref>
  801552:	89 c7                	mov    %eax,%edi
  801554:	83 c4 04             	add    $0x4,%esp
  801557:	ff 75 e4             	pushl  -0x1c(%ebp)
  80155a:	e8 52 0b 00 00       	call   8020b1 <pageref>
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	39 c7                	cmp    %eax,%edi
  801564:	0f 94 c2             	sete   %dl
  801567:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80156a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801570:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801573:	39 fb                	cmp    %edi,%ebx
  801575:	74 19                	je     801590 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801577:	84 d2                	test   %dl,%dl
  801579:	74 c6                	je     801541 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80157b:	8b 51 58             	mov    0x58(%ecx),%edx
  80157e:	50                   	push   %eax
  80157f:	52                   	push   %edx
  801580:	53                   	push   %ebx
  801581:	68 ff 24 80 00       	push   $0x8024ff
  801586:	e8 e3 04 00 00       	call   801a6e <cprintf>
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	eb b1                	jmp    801541 <_pipeisclosed+0xe>
	}
}
  801590:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5f                   	pop    %edi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	57                   	push   %edi
  80159c:	56                   	push   %esi
  80159d:	53                   	push   %ebx
  80159e:	83 ec 28             	sub    $0x28,%esp
  8015a1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015a4:	56                   	push   %esi
  8015a5:	e8 78 f2 ff ff       	call   800822 <fd2data>
  8015aa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	bf 00 00 00 00       	mov    $0x0,%edi
  8015b4:	eb 4b                	jmp    801601 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015b6:	89 da                	mov    %ebx,%edx
  8015b8:	89 f0                	mov    %esi,%eax
  8015ba:	e8 74 ff ff ff       	call   801533 <_pipeisclosed>
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	75 48                	jne    80160b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015c3:	e8 99 ef ff ff       	call   800561 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015c8:	8b 43 04             	mov    0x4(%ebx),%eax
  8015cb:	8b 0b                	mov    (%ebx),%ecx
  8015cd:	8d 51 20             	lea    0x20(%ecx),%edx
  8015d0:	39 d0                	cmp    %edx,%eax
  8015d2:	73 e2                	jae    8015b6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015d7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8015db:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	c1 fa 1f             	sar    $0x1f,%edx
  8015e3:	89 d1                	mov    %edx,%ecx
  8015e5:	c1 e9 1b             	shr    $0x1b,%ecx
  8015e8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8015eb:	83 e2 1f             	and    $0x1f,%edx
  8015ee:	29 ca                	sub    %ecx,%edx
  8015f0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8015f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015f8:	83 c0 01             	add    $0x1,%eax
  8015fb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015fe:	83 c7 01             	add    $0x1,%edi
  801601:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801604:	75 c2                	jne    8015c8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801606:	8b 45 10             	mov    0x10(%ebp),%eax
  801609:	eb 05                	jmp    801610 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80160b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801610:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801613:	5b                   	pop    %ebx
  801614:	5e                   	pop    %esi
  801615:	5f                   	pop    %edi
  801616:	5d                   	pop    %ebp
  801617:	c3                   	ret    

00801618 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	57                   	push   %edi
  80161c:	56                   	push   %esi
  80161d:	53                   	push   %ebx
  80161e:	83 ec 18             	sub    $0x18,%esp
  801621:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801624:	57                   	push   %edi
  801625:	e8 f8 f1 ff ff       	call   800822 <fd2data>
  80162a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801634:	eb 3d                	jmp    801673 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801636:	85 db                	test   %ebx,%ebx
  801638:	74 04                	je     80163e <devpipe_read+0x26>
				return i;
  80163a:	89 d8                	mov    %ebx,%eax
  80163c:	eb 44                	jmp    801682 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80163e:	89 f2                	mov    %esi,%edx
  801640:	89 f8                	mov    %edi,%eax
  801642:	e8 ec fe ff ff       	call   801533 <_pipeisclosed>
  801647:	85 c0                	test   %eax,%eax
  801649:	75 32                	jne    80167d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80164b:	e8 11 ef ff ff       	call   800561 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801650:	8b 06                	mov    (%esi),%eax
  801652:	3b 46 04             	cmp    0x4(%esi),%eax
  801655:	74 df                	je     801636 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801657:	99                   	cltd   
  801658:	c1 ea 1b             	shr    $0x1b,%edx
  80165b:	01 d0                	add    %edx,%eax
  80165d:	83 e0 1f             	and    $0x1f,%eax
  801660:	29 d0                	sub    %edx,%eax
  801662:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801667:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80166a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80166d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801670:	83 c3 01             	add    $0x1,%ebx
  801673:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801676:	75 d8                	jne    801650 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801678:	8b 45 10             	mov    0x10(%ebp),%eax
  80167b:	eb 05                	jmp    801682 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80167d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	56                   	push   %esi
  80168e:	53                   	push   %ebx
  80168f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801692:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	e8 9e f1 ff ff       	call   800839 <fd_alloc>
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	0f 88 2c 01 00 00    	js     8017d4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016a8:	83 ec 04             	sub    $0x4,%esp
  8016ab:	68 07 04 00 00       	push   $0x407
  8016b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b3:	6a 00                	push   $0x0
  8016b5:	e8 c6 ee ff ff       	call   800580 <sys_page_alloc>
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	0f 88 0d 01 00 00    	js     8017d4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016c7:	83 ec 0c             	sub    $0xc,%esp
  8016ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cd:	50                   	push   %eax
  8016ce:	e8 66 f1 ff ff       	call   800839 <fd_alloc>
  8016d3:	89 c3                	mov    %eax,%ebx
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	0f 88 e2 00 00 00    	js     8017c2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e0:	83 ec 04             	sub    $0x4,%esp
  8016e3:	68 07 04 00 00       	push   $0x407
  8016e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8016eb:	6a 00                	push   $0x0
  8016ed:	e8 8e ee ff ff       	call   800580 <sys_page_alloc>
  8016f2:	89 c3                	mov    %eax,%ebx
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	0f 88 c3 00 00 00    	js     8017c2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	ff 75 f4             	pushl  -0xc(%ebp)
  801705:	e8 18 f1 ff ff       	call   800822 <fd2data>
  80170a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80170c:	83 c4 0c             	add    $0xc,%esp
  80170f:	68 07 04 00 00       	push   $0x407
  801714:	50                   	push   %eax
  801715:	6a 00                	push   $0x0
  801717:	e8 64 ee ff ff       	call   800580 <sys_page_alloc>
  80171c:	89 c3                	mov    %eax,%ebx
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	85 c0                	test   %eax,%eax
  801723:	0f 88 89 00 00 00    	js     8017b2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801729:	83 ec 0c             	sub    $0xc,%esp
  80172c:	ff 75 f0             	pushl  -0x10(%ebp)
  80172f:	e8 ee f0 ff ff       	call   800822 <fd2data>
  801734:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80173b:	50                   	push   %eax
  80173c:	6a 00                	push   $0x0
  80173e:	56                   	push   %esi
  80173f:	6a 00                	push   $0x0
  801741:	e8 7d ee ff ff       	call   8005c3 <sys_page_map>
  801746:	89 c3                	mov    %eax,%ebx
  801748:	83 c4 20             	add    $0x20,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 55                	js     8017a4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80174f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801758:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80175a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801764:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80176a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80176f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801772:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801779:	83 ec 0c             	sub    $0xc,%esp
  80177c:	ff 75 f4             	pushl  -0xc(%ebp)
  80177f:	e8 8e f0 ff ff       	call   800812 <fd2num>
  801784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801787:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801789:	83 c4 04             	add    $0x4,%esp
  80178c:	ff 75 f0             	pushl  -0x10(%ebp)
  80178f:	e8 7e f0 ff ff       	call   800812 <fd2num>
  801794:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801797:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a2:	eb 30                	jmp    8017d4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017a4:	83 ec 08             	sub    $0x8,%esp
  8017a7:	56                   	push   %esi
  8017a8:	6a 00                	push   $0x0
  8017aa:	e8 56 ee ff ff       	call   800605 <sys_page_unmap>
  8017af:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b8:	6a 00                	push   $0x0
  8017ba:	e8 46 ee ff ff       	call   800605 <sys_page_unmap>
  8017bf:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017c2:	83 ec 08             	sub    $0x8,%esp
  8017c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c8:	6a 00                	push   $0x0
  8017ca:	e8 36 ee ff ff       	call   800605 <sys_page_unmap>
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8017d4:	89 d0                	mov    %edx,%eax
  8017d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5e                   	pop    %esi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e6:	50                   	push   %eax
  8017e7:	ff 75 08             	pushl  0x8(%ebp)
  8017ea:	e8 99 f0 ff ff       	call   800888 <fd_lookup>
  8017ef:	89 c2                	mov    %eax,%edx
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	85 d2                	test   %edx,%edx
  8017f6:	78 18                	js     801810 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8017f8:	83 ec 0c             	sub    $0xc,%esp
  8017fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fe:	e8 1f f0 ff ff       	call   800822 <fd2data>
	return _pipeisclosed(fd, p);
  801803:	89 c2                	mov    %eax,%edx
  801805:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801808:	e8 26 fd ff ff       	call   801533 <_pipeisclosed>
  80180d:	83 c4 10             	add    $0x10,%esp
}
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801815:	b8 00 00 00 00       	mov    $0x0,%eax
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801822:	68 17 25 80 00       	push   $0x802517
  801827:	ff 75 0c             	pushl  0xc(%ebp)
  80182a:	e8 48 e9 ff ff       	call   800177 <strcpy>
	return 0;
}
  80182f:	b8 00 00 00 00       	mov    $0x0,%eax
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	57                   	push   %edi
  80183a:	56                   	push   %esi
  80183b:	53                   	push   %ebx
  80183c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801842:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801847:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80184d:	eb 2d                	jmp    80187c <devcons_write+0x46>
		m = n - tot;
  80184f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801852:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801854:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801857:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80185c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	53                   	push   %ebx
  801863:	03 45 0c             	add    0xc(%ebp),%eax
  801866:	50                   	push   %eax
  801867:	57                   	push   %edi
  801868:	e8 9c ea ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  80186d:	83 c4 08             	add    $0x8,%esp
  801870:	53                   	push   %ebx
  801871:	57                   	push   %edi
  801872:	e8 4d ec ff ff       	call   8004c4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801877:	01 de                	add    %ebx,%esi
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	89 f0                	mov    %esi,%eax
  80187e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801881:	72 cc                	jb     80184f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801883:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5f                   	pop    %edi
  801889:	5d                   	pop    %ebp
  80188a:	c3                   	ret    

0080188b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801891:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801896:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80189a:	75 07                	jne    8018a3 <devcons_read+0x18>
  80189c:	eb 28                	jmp    8018c6 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80189e:	e8 be ec ff ff       	call   800561 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018a3:	e8 3a ec ff ff       	call   8004e2 <sys_cgetc>
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	74 f2                	je     80189e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	78 16                	js     8018c6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018b0:	83 f8 04             	cmp    $0x4,%eax
  8018b3:	74 0c                	je     8018c1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b8:	88 02                	mov    %al,(%edx)
	return 1;
  8018ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8018bf:	eb 05                	jmp    8018c6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018c1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8018d4:	6a 01                	push   $0x1
  8018d6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018d9:	50                   	push   %eax
  8018da:	e8 e5 eb ff ff       	call   8004c4 <sys_cputs>
  8018df:	83 c4 10             	add    $0x10,%esp
}
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <getchar>:

int
getchar(void)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8018ea:	6a 01                	push   $0x1
  8018ec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018ef:	50                   	push   %eax
  8018f0:	6a 00                	push   $0x0
  8018f2:	e8 00 f2 ff ff       	call   800af7 <read>
	if (r < 0)
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	78 0f                	js     80190d <getchar+0x29>
		return r;
	if (r < 1)
  8018fe:	85 c0                	test   %eax,%eax
  801900:	7e 06                	jle    801908 <getchar+0x24>
		return -E_EOF;
	return c;
  801902:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801906:	eb 05                	jmp    80190d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801908:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801915:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801918:	50                   	push   %eax
  801919:	ff 75 08             	pushl  0x8(%ebp)
  80191c:	e8 67 ef ff ff       	call   800888 <fd_lookup>
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	85 c0                	test   %eax,%eax
  801926:	78 11                	js     801939 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801928:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801931:	39 10                	cmp    %edx,(%eax)
  801933:	0f 94 c0             	sete   %al
  801936:	0f b6 c0             	movzbl %al,%eax
}
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <opencons>:

int
opencons(void)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801941:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801944:	50                   	push   %eax
  801945:	e8 ef ee ff ff       	call   800839 <fd_alloc>
  80194a:	83 c4 10             	add    $0x10,%esp
		return r;
  80194d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 3e                	js     801991 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801953:	83 ec 04             	sub    $0x4,%esp
  801956:	68 07 04 00 00       	push   $0x407
  80195b:	ff 75 f4             	pushl  -0xc(%ebp)
  80195e:	6a 00                	push   $0x0
  801960:	e8 1b ec ff ff       	call   800580 <sys_page_alloc>
  801965:	83 c4 10             	add    $0x10,%esp
		return r;
  801968:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80196a:	85 c0                	test   %eax,%eax
  80196c:	78 23                	js     801991 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80196e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801974:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801977:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	50                   	push   %eax
  801987:	e8 86 ee ff ff       	call   800812 <fd2num>
  80198c:	89 c2                	mov    %eax,%edx
  80198e:	83 c4 10             	add    $0x10,%esp
}
  801991:	89 d0                	mov    %edx,%eax
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80199a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80199d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019a3:	e8 9a eb ff ff       	call   800542 <sys_getenvid>
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	ff 75 0c             	pushl  0xc(%ebp)
  8019ae:	ff 75 08             	pushl  0x8(%ebp)
  8019b1:	56                   	push   %esi
  8019b2:	50                   	push   %eax
  8019b3:	68 24 25 80 00       	push   $0x802524
  8019b8:	e8 b1 00 00 00       	call   801a6e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019bd:	83 c4 18             	add    $0x18,%esp
  8019c0:	53                   	push   %ebx
  8019c1:	ff 75 10             	pushl  0x10(%ebp)
  8019c4:	e8 54 00 00 00       	call   801a1d <vcprintf>
	cprintf("\n");
  8019c9:	c7 04 24 10 25 80 00 	movl   $0x802510,(%esp)
  8019d0:	e8 99 00 00 00       	call   801a6e <cprintf>
  8019d5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019d8:	cc                   	int3   
  8019d9:	eb fd                	jmp    8019d8 <_panic+0x43>

008019db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	53                   	push   %ebx
  8019df:	83 ec 04             	sub    $0x4,%esp
  8019e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019e5:	8b 13                	mov    (%ebx),%edx
  8019e7:	8d 42 01             	lea    0x1(%edx),%eax
  8019ea:	89 03                	mov    %eax,(%ebx)
  8019ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8019f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8019f8:	75 1a                	jne    801a14 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8019fa:	83 ec 08             	sub    $0x8,%esp
  8019fd:	68 ff 00 00 00       	push   $0xff
  801a02:	8d 43 08             	lea    0x8(%ebx),%eax
  801a05:	50                   	push   %eax
  801a06:	e8 b9 ea ff ff       	call   8004c4 <sys_cputs>
		b->idx = 0;
  801a0b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a11:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801a14:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a26:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a2d:	00 00 00 
	b.cnt = 0;
  801a30:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a37:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a3a:	ff 75 0c             	pushl  0xc(%ebp)
  801a3d:	ff 75 08             	pushl  0x8(%ebp)
  801a40:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a46:	50                   	push   %eax
  801a47:	68 db 19 80 00       	push   $0x8019db
  801a4c:	e8 4f 01 00 00       	call   801ba0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a51:	83 c4 08             	add    $0x8,%esp
  801a54:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a5a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a60:	50                   	push   %eax
  801a61:	e8 5e ea ff ff       	call   8004c4 <sys_cputs>

	return b.cnt;
}
  801a66:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a74:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a77:	50                   	push   %eax
  801a78:	ff 75 08             	pushl  0x8(%ebp)
  801a7b:	e8 9d ff ff ff       	call   801a1d <vcprintf>
	va_end(ap);

	return cnt;
}
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	57                   	push   %edi
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	83 ec 1c             	sub    $0x1c,%esp
  801a8b:	89 c7                	mov    %eax,%edi
  801a8d:	89 d6                	mov    %edx,%esi
  801a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a95:	89 d1                	mov    %edx,%ecx
  801a97:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a9a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801aa3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801aad:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801ab0:	72 05                	jb     801ab7 <printnum+0x35>
  801ab2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801ab5:	77 3e                	ja     801af5 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	ff 75 18             	pushl  0x18(%ebp)
  801abd:	83 eb 01             	sub    $0x1,%ebx
  801ac0:	53                   	push   %ebx
  801ac1:	50                   	push   %eax
  801ac2:	83 ec 08             	sub    $0x8,%esp
  801ac5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac8:	ff 75 e0             	pushl  -0x20(%ebp)
  801acb:	ff 75 dc             	pushl  -0x24(%ebp)
  801ace:	ff 75 d8             	pushl  -0x28(%ebp)
  801ad1:	e8 1a 06 00 00       	call   8020f0 <__udivdi3>
  801ad6:	83 c4 18             	add    $0x18,%esp
  801ad9:	52                   	push   %edx
  801ada:	50                   	push   %eax
  801adb:	89 f2                	mov    %esi,%edx
  801add:	89 f8                	mov    %edi,%eax
  801adf:	e8 9e ff ff ff       	call   801a82 <printnum>
  801ae4:	83 c4 20             	add    $0x20,%esp
  801ae7:	eb 13                	jmp    801afc <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801ae9:	83 ec 08             	sub    $0x8,%esp
  801aec:	56                   	push   %esi
  801aed:	ff 75 18             	pushl  0x18(%ebp)
  801af0:	ff d7                	call   *%edi
  801af2:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801af5:	83 eb 01             	sub    $0x1,%ebx
  801af8:	85 db                	test   %ebx,%ebx
  801afa:	7f ed                	jg     801ae9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801afc:	83 ec 08             	sub    $0x8,%esp
  801aff:	56                   	push   %esi
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b06:	ff 75 e0             	pushl  -0x20(%ebp)
  801b09:	ff 75 dc             	pushl  -0x24(%ebp)
  801b0c:	ff 75 d8             	pushl  -0x28(%ebp)
  801b0f:	e8 0c 07 00 00       	call   802220 <__umoddi3>
  801b14:	83 c4 14             	add    $0x14,%esp
  801b17:	0f be 80 47 25 80 00 	movsbl 0x802547(%eax),%eax
  801b1e:	50                   	push   %eax
  801b1f:	ff d7                	call   *%edi
  801b21:	83 c4 10             	add    $0x10,%esp
}
  801b24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5f                   	pop    %edi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    

00801b2c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b2f:	83 fa 01             	cmp    $0x1,%edx
  801b32:	7e 0e                	jle    801b42 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b34:	8b 10                	mov    (%eax),%edx
  801b36:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b39:	89 08                	mov    %ecx,(%eax)
  801b3b:	8b 02                	mov    (%edx),%eax
  801b3d:	8b 52 04             	mov    0x4(%edx),%edx
  801b40:	eb 22                	jmp    801b64 <getuint+0x38>
	else if (lflag)
  801b42:	85 d2                	test   %edx,%edx
  801b44:	74 10                	je     801b56 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b46:	8b 10                	mov    (%eax),%edx
  801b48:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b4b:	89 08                	mov    %ecx,(%eax)
  801b4d:	8b 02                	mov    (%edx),%eax
  801b4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b54:	eb 0e                	jmp    801b64 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b56:	8b 10                	mov    (%eax),%edx
  801b58:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b5b:	89 08                	mov    %ecx,(%eax)
  801b5d:	8b 02                	mov    (%edx),%eax
  801b5f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b6c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b70:	8b 10                	mov    (%eax),%edx
  801b72:	3b 50 04             	cmp    0x4(%eax),%edx
  801b75:	73 0a                	jae    801b81 <sprintputch+0x1b>
		*b->buf++ = ch;
  801b77:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b7a:	89 08                	mov    %ecx,(%eax)
  801b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7f:	88 02                	mov    %al,(%edx)
}
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b89:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b8c:	50                   	push   %eax
  801b8d:	ff 75 10             	pushl  0x10(%ebp)
  801b90:	ff 75 0c             	pushl  0xc(%ebp)
  801b93:	ff 75 08             	pushl  0x8(%ebp)
  801b96:	e8 05 00 00 00       	call   801ba0 <vprintfmt>
	va_end(ap);
  801b9b:	83 c4 10             	add    $0x10,%esp
}
  801b9e:	c9                   	leave  
  801b9f:	c3                   	ret    

00801ba0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	57                   	push   %edi
  801ba4:	56                   	push   %esi
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 2c             	sub    $0x2c,%esp
  801ba9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801baf:	8b 7d 10             	mov    0x10(%ebp),%edi
  801bb2:	eb 12                	jmp    801bc6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	0f 84 90 03 00 00    	je     801f4c <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  801bbc:	83 ec 08             	sub    $0x8,%esp
  801bbf:	53                   	push   %ebx
  801bc0:	50                   	push   %eax
  801bc1:	ff d6                	call   *%esi
  801bc3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801bc6:	83 c7 01             	add    $0x1,%edi
  801bc9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801bcd:	83 f8 25             	cmp    $0x25,%eax
  801bd0:	75 e2                	jne    801bb4 <vprintfmt+0x14>
  801bd2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801bd6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801bdd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801be4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801beb:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf0:	eb 07                	jmp    801bf9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801bf5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bf9:	8d 47 01             	lea    0x1(%edi),%eax
  801bfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bff:	0f b6 07             	movzbl (%edi),%eax
  801c02:	0f b6 c8             	movzbl %al,%ecx
  801c05:	83 e8 23             	sub    $0x23,%eax
  801c08:	3c 55                	cmp    $0x55,%al
  801c0a:	0f 87 21 03 00 00    	ja     801f31 <vprintfmt+0x391>
  801c10:	0f b6 c0             	movzbl %al,%eax
  801c13:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  801c1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c1d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c21:	eb d6                	jmp    801bf9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c2e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c31:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c35:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c38:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c3b:	83 fa 09             	cmp    $0x9,%edx
  801c3e:	77 39                	ja     801c79 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c40:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c43:	eb e9                	jmp    801c2e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c45:	8b 45 14             	mov    0x14(%ebp),%eax
  801c48:	8d 48 04             	lea    0x4(%eax),%ecx
  801c4b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c4e:	8b 00                	mov    (%eax),%eax
  801c50:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c56:	eb 27                	jmp    801c7f <vprintfmt+0xdf>
  801c58:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c62:	0f 49 c8             	cmovns %eax,%ecx
  801c65:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c6b:	eb 8c                	jmp    801bf9 <vprintfmt+0x59>
  801c6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c70:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c77:	eb 80                	jmp    801bf9 <vprintfmt+0x59>
  801c79:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c7c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c7f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c83:	0f 89 70 ff ff ff    	jns    801bf9 <vprintfmt+0x59>
				width = precision, precision = -1;
  801c89:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c8f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c96:	e9 5e ff ff ff       	jmp    801bf9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c9b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801ca1:	e9 53 ff ff ff       	jmp    801bf9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801ca6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca9:	8d 50 04             	lea    0x4(%eax),%edx
  801cac:	89 55 14             	mov    %edx,0x14(%ebp)
  801caf:	83 ec 08             	sub    $0x8,%esp
  801cb2:	53                   	push   %ebx
  801cb3:	ff 30                	pushl  (%eax)
  801cb5:	ff d6                	call   *%esi
			break;
  801cb7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801cbd:	e9 04 ff ff ff       	jmp    801bc6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801cc2:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc5:	8d 50 04             	lea    0x4(%eax),%edx
  801cc8:	89 55 14             	mov    %edx,0x14(%ebp)
  801ccb:	8b 00                	mov    (%eax),%eax
  801ccd:	99                   	cltd   
  801cce:	31 d0                	xor    %edx,%eax
  801cd0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801cd2:	83 f8 0f             	cmp    $0xf,%eax
  801cd5:	7f 0b                	jg     801ce2 <vprintfmt+0x142>
  801cd7:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  801cde:	85 d2                	test   %edx,%edx
  801ce0:	75 18                	jne    801cfa <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801ce2:	50                   	push   %eax
  801ce3:	68 5f 25 80 00       	push   $0x80255f
  801ce8:	53                   	push   %ebx
  801ce9:	56                   	push   %esi
  801cea:	e8 94 fe ff ff       	call   801b83 <printfmt>
  801cef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801cf5:	e9 cc fe ff ff       	jmp    801bc6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801cfa:	52                   	push   %edx
  801cfb:	68 a5 24 80 00       	push   $0x8024a5
  801d00:	53                   	push   %ebx
  801d01:	56                   	push   %esi
  801d02:	e8 7c fe ff ff       	call   801b83 <printfmt>
  801d07:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d0d:	e9 b4 fe ff ff       	jmp    801bc6 <vprintfmt+0x26>
  801d12:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801d15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d18:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d1b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d1e:	8d 50 04             	lea    0x4(%eax),%edx
  801d21:	89 55 14             	mov    %edx,0x14(%ebp)
  801d24:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d26:	85 ff                	test   %edi,%edi
  801d28:	ba 58 25 80 00       	mov    $0x802558,%edx
  801d2d:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801d30:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d34:	0f 84 92 00 00 00    	je     801dcc <vprintfmt+0x22c>
  801d3a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801d3e:	0f 8e 96 00 00 00    	jle    801dda <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d44:	83 ec 08             	sub    $0x8,%esp
  801d47:	51                   	push   %ecx
  801d48:	57                   	push   %edi
  801d49:	e8 08 e4 ff ff       	call   800156 <strnlen>
  801d4e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d51:	29 c1                	sub    %eax,%ecx
  801d53:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d56:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d59:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d60:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d63:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d65:	eb 0f                	jmp    801d76 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801d67:	83 ec 08             	sub    $0x8,%esp
  801d6a:	53                   	push   %ebx
  801d6b:	ff 75 e0             	pushl  -0x20(%ebp)
  801d6e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d70:	83 ef 01             	sub    $0x1,%edi
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	85 ff                	test   %edi,%edi
  801d78:	7f ed                	jg     801d67 <vprintfmt+0x1c7>
  801d7a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d7d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d80:	85 c9                	test   %ecx,%ecx
  801d82:	b8 00 00 00 00       	mov    $0x0,%eax
  801d87:	0f 49 c1             	cmovns %ecx,%eax
  801d8a:	29 c1                	sub    %eax,%ecx
  801d8c:	89 75 08             	mov    %esi,0x8(%ebp)
  801d8f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d92:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d95:	89 cb                	mov    %ecx,%ebx
  801d97:	eb 4d                	jmp    801de6 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d99:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d9d:	74 1b                	je     801dba <vprintfmt+0x21a>
  801d9f:	0f be c0             	movsbl %al,%eax
  801da2:	83 e8 20             	sub    $0x20,%eax
  801da5:	83 f8 5e             	cmp    $0x5e,%eax
  801da8:	76 10                	jbe    801dba <vprintfmt+0x21a>
					putch('?', putdat);
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	ff 75 0c             	pushl  0xc(%ebp)
  801db0:	6a 3f                	push   $0x3f
  801db2:	ff 55 08             	call   *0x8(%ebp)
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	eb 0d                	jmp    801dc7 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801dba:	83 ec 08             	sub    $0x8,%esp
  801dbd:	ff 75 0c             	pushl  0xc(%ebp)
  801dc0:	52                   	push   %edx
  801dc1:	ff 55 08             	call   *0x8(%ebp)
  801dc4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801dc7:	83 eb 01             	sub    $0x1,%ebx
  801dca:	eb 1a                	jmp    801de6 <vprintfmt+0x246>
  801dcc:	89 75 08             	mov    %esi,0x8(%ebp)
  801dcf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dd2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dd5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dd8:	eb 0c                	jmp    801de6 <vprintfmt+0x246>
  801dda:	89 75 08             	mov    %esi,0x8(%ebp)
  801ddd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801de0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801de3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801de6:	83 c7 01             	add    $0x1,%edi
  801de9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ded:	0f be d0             	movsbl %al,%edx
  801df0:	85 d2                	test   %edx,%edx
  801df2:	74 23                	je     801e17 <vprintfmt+0x277>
  801df4:	85 f6                	test   %esi,%esi
  801df6:	78 a1                	js     801d99 <vprintfmt+0x1f9>
  801df8:	83 ee 01             	sub    $0x1,%esi
  801dfb:	79 9c                	jns    801d99 <vprintfmt+0x1f9>
  801dfd:	89 df                	mov    %ebx,%edi
  801dff:	8b 75 08             	mov    0x8(%ebp),%esi
  801e02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e05:	eb 18                	jmp    801e1f <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	53                   	push   %ebx
  801e0b:	6a 20                	push   $0x20
  801e0d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801e0f:	83 ef 01             	sub    $0x1,%edi
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	eb 08                	jmp    801e1f <vprintfmt+0x27f>
  801e17:	89 df                	mov    %ebx,%edi
  801e19:	8b 75 08             	mov    0x8(%ebp),%esi
  801e1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e1f:	85 ff                	test   %edi,%edi
  801e21:	7f e4                	jg     801e07 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e26:	e9 9b fd ff ff       	jmp    801bc6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e2b:	83 fa 01             	cmp    $0x1,%edx
  801e2e:	7e 16                	jle    801e46 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801e30:	8b 45 14             	mov    0x14(%ebp),%eax
  801e33:	8d 50 08             	lea    0x8(%eax),%edx
  801e36:	89 55 14             	mov    %edx,0x14(%ebp)
  801e39:	8b 50 04             	mov    0x4(%eax),%edx
  801e3c:	8b 00                	mov    (%eax),%eax
  801e3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e41:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e44:	eb 32                	jmp    801e78 <vprintfmt+0x2d8>
	else if (lflag)
  801e46:	85 d2                	test   %edx,%edx
  801e48:	74 18                	je     801e62 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801e4a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e4d:	8d 50 04             	lea    0x4(%eax),%edx
  801e50:	89 55 14             	mov    %edx,0x14(%ebp)
  801e53:	8b 00                	mov    (%eax),%eax
  801e55:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e58:	89 c1                	mov    %eax,%ecx
  801e5a:	c1 f9 1f             	sar    $0x1f,%ecx
  801e5d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e60:	eb 16                	jmp    801e78 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801e62:	8b 45 14             	mov    0x14(%ebp),%eax
  801e65:	8d 50 04             	lea    0x4(%eax),%edx
  801e68:	89 55 14             	mov    %edx,0x14(%ebp)
  801e6b:	8b 00                	mov    (%eax),%eax
  801e6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e70:	89 c1                	mov    %eax,%ecx
  801e72:	c1 f9 1f             	sar    $0x1f,%ecx
  801e75:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e78:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e7e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e83:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e87:	79 74                	jns    801efd <vprintfmt+0x35d>
				putch('-', putdat);
  801e89:	83 ec 08             	sub    $0x8,%esp
  801e8c:	53                   	push   %ebx
  801e8d:	6a 2d                	push   $0x2d
  801e8f:	ff d6                	call   *%esi
				num = -(long long) num;
  801e91:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e94:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e97:	f7 d8                	neg    %eax
  801e99:	83 d2 00             	adc    $0x0,%edx
  801e9c:	f7 da                	neg    %edx
  801e9e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ea1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ea6:	eb 55                	jmp    801efd <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ea8:	8d 45 14             	lea    0x14(%ebp),%eax
  801eab:	e8 7c fc ff ff       	call   801b2c <getuint>
			base = 10;
  801eb0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801eb5:	eb 46                	jmp    801efd <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801eb7:	8d 45 14             	lea    0x14(%ebp),%eax
  801eba:	e8 6d fc ff ff       	call   801b2c <getuint>
                        base = 8;
  801ebf:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ec4:	eb 37                	jmp    801efd <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801ec6:	83 ec 08             	sub    $0x8,%esp
  801ec9:	53                   	push   %ebx
  801eca:	6a 30                	push   $0x30
  801ecc:	ff d6                	call   *%esi
			putch('x', putdat);
  801ece:	83 c4 08             	add    $0x8,%esp
  801ed1:	53                   	push   %ebx
  801ed2:	6a 78                	push   $0x78
  801ed4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ed6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ed9:	8d 50 04             	lea    0x4(%eax),%edx
  801edc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801edf:	8b 00                	mov    (%eax),%eax
  801ee1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ee6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ee9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801eee:	eb 0d                	jmp    801efd <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ef0:	8d 45 14             	lea    0x14(%ebp),%eax
  801ef3:	e8 34 fc ff ff       	call   801b2c <getuint>
			base = 16;
  801ef8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801f04:	57                   	push   %edi
  801f05:	ff 75 e0             	pushl  -0x20(%ebp)
  801f08:	51                   	push   %ecx
  801f09:	52                   	push   %edx
  801f0a:	50                   	push   %eax
  801f0b:	89 da                	mov    %ebx,%edx
  801f0d:	89 f0                	mov    %esi,%eax
  801f0f:	e8 6e fb ff ff       	call   801a82 <printnum>
			break;
  801f14:	83 c4 20             	add    $0x20,%esp
  801f17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f1a:	e9 a7 fc ff ff       	jmp    801bc6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f1f:	83 ec 08             	sub    $0x8,%esp
  801f22:	53                   	push   %ebx
  801f23:	51                   	push   %ecx
  801f24:	ff d6                	call   *%esi
			break;
  801f26:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f29:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f2c:	e9 95 fc ff ff       	jmp    801bc6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f31:	83 ec 08             	sub    $0x8,%esp
  801f34:	53                   	push   %ebx
  801f35:	6a 25                	push   $0x25
  801f37:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	eb 03                	jmp    801f41 <vprintfmt+0x3a1>
  801f3e:	83 ef 01             	sub    $0x1,%edi
  801f41:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f45:	75 f7                	jne    801f3e <vprintfmt+0x39e>
  801f47:	e9 7a fc ff ff       	jmp    801bc6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    

00801f54 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	83 ec 18             	sub    $0x18,%esp
  801f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f60:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f63:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f67:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f71:	85 c0                	test   %eax,%eax
  801f73:	74 26                	je     801f9b <vsnprintf+0x47>
  801f75:	85 d2                	test   %edx,%edx
  801f77:	7e 22                	jle    801f9b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f79:	ff 75 14             	pushl  0x14(%ebp)
  801f7c:	ff 75 10             	pushl  0x10(%ebp)
  801f7f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f82:	50                   	push   %eax
  801f83:	68 66 1b 80 00       	push   $0x801b66
  801f88:	e8 13 fc ff ff       	call   801ba0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f90:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	eb 05                	jmp    801fa0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801f9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801fa8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801fab:	50                   	push   %eax
  801fac:	ff 75 10             	pushl  0x10(%ebp)
  801faf:	ff 75 0c             	pushl  0xc(%ebp)
  801fb2:	ff 75 08             	pushl  0x8(%ebp)
  801fb5:	e8 9a ff ff ff       	call   801f54 <vsnprintf>
	va_end(ap);

	return rc;
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	56                   	push   %esi
  801fc0:	53                   	push   %ebx
  801fc1:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fd1:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801fd4:	83 ec 0c             	sub    $0xc,%esp
  801fd7:	50                   	push   %eax
  801fd8:	e8 53 e7 ff ff       	call   800730 <sys_ipc_recv>
  801fdd:	83 c4 10             	add    $0x10,%esp
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	79 16                	jns    801ffa <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801fe4:	85 f6                	test   %esi,%esi
  801fe6:	74 06                	je     801fee <ipc_recv+0x32>
  801fe8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801fee:	85 db                	test   %ebx,%ebx
  801ff0:	74 2c                	je     80201e <ipc_recv+0x62>
  801ff2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ff8:	eb 24                	jmp    80201e <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801ffa:	85 f6                	test   %esi,%esi
  801ffc:	74 0a                	je     802008 <ipc_recv+0x4c>
  801ffe:	a1 08 40 80 00       	mov    0x804008,%eax
  802003:	8b 40 74             	mov    0x74(%eax),%eax
  802006:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802008:	85 db                	test   %ebx,%ebx
  80200a:	74 0a                	je     802016 <ipc_recv+0x5a>
  80200c:	a1 08 40 80 00       	mov    0x804008,%eax
  802011:	8b 40 78             	mov    0x78(%eax),%eax
  802014:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802016:	a1 08 40 80 00       	mov    0x804008,%eax
  80201b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80201e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802021:	5b                   	pop    %ebx
  802022:	5e                   	pop    %esi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    

00802025 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	57                   	push   %edi
  802029:	56                   	push   %esi
  80202a:	53                   	push   %ebx
  80202b:	83 ec 0c             	sub    $0xc,%esp
  80202e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802031:	8b 75 0c             	mov    0xc(%ebp),%esi
  802034:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802037:	85 db                	test   %ebx,%ebx
  802039:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80203e:	0f 44 d8             	cmove  %eax,%ebx
  802041:	eb 1c                	jmp    80205f <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802043:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802046:	74 12                	je     80205a <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802048:	50                   	push   %eax
  802049:	68 60 28 80 00       	push   $0x802860
  80204e:	6a 39                	push   $0x39
  802050:	68 7b 28 80 00       	push   $0x80287b
  802055:	e8 3b f9 ff ff       	call   801995 <_panic>
                 sys_yield();
  80205a:	e8 02 e5 ff ff       	call   800561 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80205f:	ff 75 14             	pushl  0x14(%ebp)
  802062:	53                   	push   %ebx
  802063:	56                   	push   %esi
  802064:	57                   	push   %edi
  802065:	e8 a3 e6 ff ff       	call   80070d <sys_ipc_try_send>
  80206a:	83 c4 10             	add    $0x10,%esp
  80206d:	85 c0                	test   %eax,%eax
  80206f:	78 d2                	js     802043 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802071:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    

00802079 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80207f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802084:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802087:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80208d:	8b 52 50             	mov    0x50(%edx),%edx
  802090:	39 ca                	cmp    %ecx,%edx
  802092:	75 0d                	jne    8020a1 <ipc_find_env+0x28>
			return envs[i].env_id;
  802094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802097:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80209c:	8b 40 08             	mov    0x8(%eax),%eax
  80209f:	eb 0e                	jmp    8020af <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020a1:	83 c0 01             	add    $0x1,%eax
  8020a4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020a9:	75 d9                	jne    802084 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020ab:	66 b8 00 00          	mov    $0x0,%ax
}
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    

008020b1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b7:	89 d0                	mov    %edx,%eax
  8020b9:	c1 e8 16             	shr    $0x16,%eax
  8020bc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020c3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c8:	f6 c1 01             	test   $0x1,%cl
  8020cb:	74 1d                	je     8020ea <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020cd:	c1 ea 0c             	shr    $0xc,%edx
  8020d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020d7:	f6 c2 01             	test   $0x1,%dl
  8020da:	74 0e                	je     8020ea <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020dc:	c1 ea 0c             	shr    $0xc,%edx
  8020df:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020e6:	ef 
  8020e7:	0f b7 c0             	movzwl %ax,%eax
}
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	83 ec 10             	sub    $0x10,%esp
  8020f6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8020fa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8020fe:	8b 74 24 24          	mov    0x24(%esp),%esi
  802102:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802106:	85 d2                	test   %edx,%edx
  802108:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80210c:	89 34 24             	mov    %esi,(%esp)
  80210f:	89 c8                	mov    %ecx,%eax
  802111:	75 35                	jne    802148 <__udivdi3+0x58>
  802113:	39 f1                	cmp    %esi,%ecx
  802115:	0f 87 bd 00 00 00    	ja     8021d8 <__udivdi3+0xe8>
  80211b:	85 c9                	test   %ecx,%ecx
  80211d:	89 cd                	mov    %ecx,%ebp
  80211f:	75 0b                	jne    80212c <__udivdi3+0x3c>
  802121:	b8 01 00 00 00       	mov    $0x1,%eax
  802126:	31 d2                	xor    %edx,%edx
  802128:	f7 f1                	div    %ecx
  80212a:	89 c5                	mov    %eax,%ebp
  80212c:	89 f0                	mov    %esi,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f5                	div    %ebp
  802132:	89 c6                	mov    %eax,%esi
  802134:	89 f8                	mov    %edi,%eax
  802136:	f7 f5                	div    %ebp
  802138:	89 f2                	mov    %esi,%edx
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	5e                   	pop    %esi
  80213e:	5f                   	pop    %edi
  80213f:	5d                   	pop    %ebp
  802140:	c3                   	ret    
  802141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802148:	3b 14 24             	cmp    (%esp),%edx
  80214b:	77 7b                	ja     8021c8 <__udivdi3+0xd8>
  80214d:	0f bd f2             	bsr    %edx,%esi
  802150:	83 f6 1f             	xor    $0x1f,%esi
  802153:	0f 84 97 00 00 00    	je     8021f0 <__udivdi3+0x100>
  802159:	bd 20 00 00 00       	mov    $0x20,%ebp
  80215e:	89 d7                	mov    %edx,%edi
  802160:	89 f1                	mov    %esi,%ecx
  802162:	29 f5                	sub    %esi,%ebp
  802164:	d3 e7                	shl    %cl,%edi
  802166:	89 c2                	mov    %eax,%edx
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	d3 ea                	shr    %cl,%edx
  80216c:	89 f1                	mov    %esi,%ecx
  80216e:	09 fa                	or     %edi,%edx
  802170:	8b 3c 24             	mov    (%esp),%edi
  802173:	d3 e0                	shl    %cl,%eax
  802175:	89 54 24 08          	mov    %edx,0x8(%esp)
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802183:	89 fa                	mov    %edi,%edx
  802185:	d3 ea                	shr    %cl,%edx
  802187:	89 f1                	mov    %esi,%ecx
  802189:	d3 e7                	shl    %cl,%edi
  80218b:	89 e9                	mov    %ebp,%ecx
  80218d:	d3 e8                	shr    %cl,%eax
  80218f:	09 c7                	or     %eax,%edi
  802191:	89 f8                	mov    %edi,%eax
  802193:	f7 74 24 08          	divl   0x8(%esp)
  802197:	89 d5                	mov    %edx,%ebp
  802199:	89 c7                	mov    %eax,%edi
  80219b:	f7 64 24 0c          	mull   0xc(%esp)
  80219f:	39 d5                	cmp    %edx,%ebp
  8021a1:	89 14 24             	mov    %edx,(%esp)
  8021a4:	72 11                	jb     8021b7 <__udivdi3+0xc7>
  8021a6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021aa:	89 f1                	mov    %esi,%ecx
  8021ac:	d3 e2                	shl    %cl,%edx
  8021ae:	39 c2                	cmp    %eax,%edx
  8021b0:	73 5e                	jae    802210 <__udivdi3+0x120>
  8021b2:	3b 2c 24             	cmp    (%esp),%ebp
  8021b5:	75 59                	jne    802210 <__udivdi3+0x120>
  8021b7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021ba:	31 f6                	xor    %esi,%esi
  8021bc:	89 f2                	mov    %esi,%edx
  8021be:	83 c4 10             	add    $0x10,%esp
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
  8021c8:	31 f6                	xor    %esi,%esi
  8021ca:	31 c0                	xor    %eax,%eax
  8021cc:	89 f2                	mov    %esi,%edx
  8021ce:	83 c4 10             	add    $0x10,%esp
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    
  8021d5:	8d 76 00             	lea    0x0(%esi),%esi
  8021d8:	89 f2                	mov    %esi,%edx
  8021da:	31 f6                	xor    %esi,%esi
  8021dc:	89 f8                	mov    %edi,%eax
  8021de:	f7 f1                	div    %ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	83 c4 10             	add    $0x10,%esp
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021f4:	76 0b                	jbe    802201 <__udivdi3+0x111>
  8021f6:	31 c0                	xor    %eax,%eax
  8021f8:	3b 14 24             	cmp    (%esp),%edx
  8021fb:	0f 83 37 ff ff ff    	jae    802138 <__udivdi3+0x48>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	e9 2d ff ff ff       	jmp    802138 <__udivdi3+0x48>
  80220b:	90                   	nop
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 f8                	mov    %edi,%eax
  802212:	31 f6                	xor    %esi,%esi
  802214:	e9 1f ff ff ff       	jmp    802138 <__udivdi3+0x48>
  802219:	66 90                	xchg   %ax,%ax
  80221b:	66 90                	xchg   %ax,%ax
  80221d:	66 90                	xchg   %ax,%ax
  80221f:	90                   	nop

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	83 ec 20             	sub    $0x20,%esp
  802226:	8b 44 24 34          	mov    0x34(%esp),%eax
  80222a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802232:	89 c6                	mov    %eax,%esi
  802234:	89 44 24 10          	mov    %eax,0x10(%esp)
  802238:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80223c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802240:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802244:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802248:	89 74 24 18          	mov    %esi,0x18(%esp)
  80224c:	85 c0                	test   %eax,%eax
  80224e:	89 c2                	mov    %eax,%edx
  802250:	75 1e                	jne    802270 <__umoddi3+0x50>
  802252:	39 f7                	cmp    %esi,%edi
  802254:	76 52                	jbe    8022a8 <__umoddi3+0x88>
  802256:	89 c8                	mov    %ecx,%eax
  802258:	89 f2                	mov    %esi,%edx
  80225a:	f7 f7                	div    %edi
  80225c:	89 d0                	mov    %edx,%eax
  80225e:	31 d2                	xor    %edx,%edx
  802260:	83 c4 20             	add    $0x20,%esp
  802263:	5e                   	pop    %esi
  802264:	5f                   	pop    %edi
  802265:	5d                   	pop    %ebp
  802266:	c3                   	ret    
  802267:	89 f6                	mov    %esi,%esi
  802269:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802270:	39 f0                	cmp    %esi,%eax
  802272:	77 5c                	ja     8022d0 <__umoddi3+0xb0>
  802274:	0f bd e8             	bsr    %eax,%ebp
  802277:	83 f5 1f             	xor    $0x1f,%ebp
  80227a:	75 64                	jne    8022e0 <__umoddi3+0xc0>
  80227c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802280:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802284:	0f 86 f6 00 00 00    	jbe    802380 <__umoddi3+0x160>
  80228a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80228e:	0f 82 ec 00 00 00    	jb     802380 <__umoddi3+0x160>
  802294:	8b 44 24 14          	mov    0x14(%esp),%eax
  802298:	8b 54 24 18          	mov    0x18(%esp),%edx
  80229c:	83 c4 20             	add    $0x20,%esp
  80229f:	5e                   	pop    %esi
  8022a0:	5f                   	pop    %edi
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    
  8022a3:	90                   	nop
  8022a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	85 ff                	test   %edi,%edi
  8022aa:	89 fd                	mov    %edi,%ebp
  8022ac:	75 0b                	jne    8022b9 <__umoddi3+0x99>
  8022ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f7                	div    %edi
  8022b7:	89 c5                	mov    %eax,%ebp
  8022b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022bd:	31 d2                	xor    %edx,%edx
  8022bf:	f7 f5                	div    %ebp
  8022c1:	89 c8                	mov    %ecx,%eax
  8022c3:	f7 f5                	div    %ebp
  8022c5:	eb 95                	jmp    80225c <__umoddi3+0x3c>
  8022c7:	89 f6                	mov    %esi,%esi
  8022c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	83 c4 20             	add    $0x20,%esp
  8022d7:	5e                   	pop    %esi
  8022d8:	5f                   	pop    %edi
  8022d9:	5d                   	pop    %ebp
  8022da:	c3                   	ret    
  8022db:	90                   	nop
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022e5:	89 e9                	mov    %ebp,%ecx
  8022e7:	29 e8                	sub    %ebp,%eax
  8022e9:	d3 e2                	shl    %cl,%edx
  8022eb:	89 c7                	mov    %eax,%edi
  8022ed:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 c1                	mov    %eax,%ecx
  8022fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022ff:	09 d1                	or     %edx,%ecx
  802301:	89 fa                	mov    %edi,%edx
  802303:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802307:	89 e9                	mov    %ebp,%ecx
  802309:	d3 e0                	shl    %cl,%eax
  80230b:	89 f9                	mov    %edi,%ecx
  80230d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802311:	89 f0                	mov    %esi,%eax
  802313:	d3 e8                	shr    %cl,%eax
  802315:	89 e9                	mov    %ebp,%ecx
  802317:	89 c7                	mov    %eax,%edi
  802319:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80231d:	d3 e6                	shl    %cl,%esi
  80231f:	89 d1                	mov    %edx,%ecx
  802321:	89 fa                	mov    %edi,%edx
  802323:	d3 e8                	shr    %cl,%eax
  802325:	89 e9                	mov    %ebp,%ecx
  802327:	09 f0                	or     %esi,%eax
  802329:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80232d:	f7 74 24 10          	divl   0x10(%esp)
  802331:	d3 e6                	shl    %cl,%esi
  802333:	89 d1                	mov    %edx,%ecx
  802335:	f7 64 24 0c          	mull   0xc(%esp)
  802339:	39 d1                	cmp    %edx,%ecx
  80233b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80233f:	89 d7                	mov    %edx,%edi
  802341:	89 c6                	mov    %eax,%esi
  802343:	72 0a                	jb     80234f <__umoddi3+0x12f>
  802345:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802349:	73 10                	jae    80235b <__umoddi3+0x13b>
  80234b:	39 d1                	cmp    %edx,%ecx
  80234d:	75 0c                	jne    80235b <__umoddi3+0x13b>
  80234f:	89 d7                	mov    %edx,%edi
  802351:	89 c6                	mov    %eax,%esi
  802353:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802357:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80235b:	89 ca                	mov    %ecx,%edx
  80235d:	89 e9                	mov    %ebp,%ecx
  80235f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802363:	29 f0                	sub    %esi,%eax
  802365:	19 fa                	sbb    %edi,%edx
  802367:	d3 e8                	shr    %cl,%eax
  802369:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80236e:	89 d7                	mov    %edx,%edi
  802370:	d3 e7                	shl    %cl,%edi
  802372:	89 e9                	mov    %ebp,%ecx
  802374:	09 f8                	or     %edi,%eax
  802376:	d3 ea                	shr    %cl,%edx
  802378:	83 c4 20             	add    $0x20,%esp
  80237b:	5e                   	pop    %esi
  80237c:	5f                   	pop    %edi
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    
  80237f:	90                   	nop
  802380:	8b 74 24 10          	mov    0x10(%esp),%esi
  802384:	29 f9                	sub    %edi,%ecx
  802386:	19 c6                	sbb    %eax,%esi
  802388:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80238c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802390:	e9 ff fe ff ff       	jmp    802294 <__umoddi3+0x74>
