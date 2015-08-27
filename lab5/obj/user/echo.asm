
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
  800051:	68 c0 1e 80 00       	push   $0x801ec0
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
  80008a:	68 c3 1e 80 00       	push   $0x801ec3
  80008f:	6a 01                	push   $0x1
  800091:	e8 91 0a 00 00       	call   800b27 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 75 0a 00 00       	call   800b27 <write>
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
  8000c7:	68 d3 1f 80 00       	push   $0x801fd3
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 54 0a 00 00       	call   800b27 <write>
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
  8000fb:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80012a:	e8 0f 08 00 00       	call   80093e <close_all>
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
  800529:	68 cf 1e 80 00       	push   $0x801ecf
  80052e:	6a 23                	push   $0x23
  800530:	68 ec 1e 80 00       	push   $0x801eec
  800535:	e8 44 0f 00 00       	call   80147e <_panic>

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
  8005aa:	68 cf 1e 80 00       	push   $0x801ecf
  8005af:	6a 23                	push   $0x23
  8005b1:	68 ec 1e 80 00       	push   $0x801eec
  8005b6:	e8 c3 0e 00 00       	call   80147e <_panic>

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
  8005ec:	68 cf 1e 80 00       	push   $0x801ecf
  8005f1:	6a 23                	push   $0x23
  8005f3:	68 ec 1e 80 00       	push   $0x801eec
  8005f8:	e8 81 0e 00 00       	call   80147e <_panic>

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
  80062e:	68 cf 1e 80 00       	push   $0x801ecf
  800633:	6a 23                	push   $0x23
  800635:	68 ec 1e 80 00       	push   $0x801eec
  80063a:	e8 3f 0e 00 00       	call   80147e <_panic>

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
  800670:	68 cf 1e 80 00       	push   $0x801ecf
  800675:	6a 23                	push   $0x23
  800677:	68 ec 1e 80 00       	push   $0x801eec
  80067c:	e8 fd 0d 00 00       	call   80147e <_panic>
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
  8006b2:	68 cf 1e 80 00       	push   $0x801ecf
  8006b7:	6a 23                	push   $0x23
  8006b9:	68 ec 1e 80 00       	push   $0x801eec
  8006be:	e8 bb 0d 00 00       	call   80147e <_panic>

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
  8006f4:	68 cf 1e 80 00       	push   $0x801ecf
  8006f9:	6a 23                	push   $0x23
  8006fb:	68 ec 1e 80 00       	push   $0x801eec
  800700:	e8 79 0d 00 00       	call   80147e <_panic>

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
  800758:	68 cf 1e 80 00       	push   $0x801ecf
  80075d:	6a 23                	push   $0x23
  80075f:	68 ec 1e 80 00       	push   $0x801eec
  800764:	e8 15 0d 00 00       	call   80147e <_panic>

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

00800771 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	05 00 00 00 30       	add    $0x30000000,%eax
  80077c:	c1 e8 0c             	shr    $0xc,%eax
}
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80078c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800791:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007a3:	89 c2                	mov    %eax,%edx
  8007a5:	c1 ea 16             	shr    $0x16,%edx
  8007a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007af:	f6 c2 01             	test   $0x1,%dl
  8007b2:	74 11                	je     8007c5 <fd_alloc+0x2d>
  8007b4:	89 c2                	mov    %eax,%edx
  8007b6:	c1 ea 0c             	shr    $0xc,%edx
  8007b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007c0:	f6 c2 01             	test   $0x1,%dl
  8007c3:	75 09                	jne    8007ce <fd_alloc+0x36>
			*fd_store = fd;
  8007c5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cc:	eb 17                	jmp    8007e5 <fd_alloc+0x4d>
  8007ce:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8007d3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007d8:	75 c9                	jne    8007a3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007da:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8007e0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007ed:	83 f8 1f             	cmp    $0x1f,%eax
  8007f0:	77 36                	ja     800828 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007f2:	c1 e0 0c             	shl    $0xc,%eax
  8007f5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007fa:	89 c2                	mov    %eax,%edx
  8007fc:	c1 ea 16             	shr    $0x16,%edx
  8007ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800806:	f6 c2 01             	test   $0x1,%dl
  800809:	74 24                	je     80082f <fd_lookup+0x48>
  80080b:	89 c2                	mov    %eax,%edx
  80080d:	c1 ea 0c             	shr    $0xc,%edx
  800810:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800817:	f6 c2 01             	test   $0x1,%dl
  80081a:	74 1a                	je     800836 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081f:	89 02                	mov    %eax,(%edx)
	return 0;
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	eb 13                	jmp    80083b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800828:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082d:	eb 0c                	jmp    80083b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80082f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800834:	eb 05                	jmp    80083b <fd_lookup+0x54>
  800836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800846:	ba 78 1f 80 00       	mov    $0x801f78,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80084b:	eb 13                	jmp    800860 <dev_lookup+0x23>
  80084d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800850:	39 08                	cmp    %ecx,(%eax)
  800852:	75 0c                	jne    800860 <dev_lookup+0x23>
			*dev = devtab[i];
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800857:	89 01                	mov    %eax,(%ecx)
			return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
  80085e:	eb 2e                	jmp    80088e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800860:	8b 02                	mov    (%edx),%eax
  800862:	85 c0                	test   %eax,%eax
  800864:	75 e7                	jne    80084d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800866:	a1 04 40 80 00       	mov    0x804004,%eax
  80086b:	8b 40 48             	mov    0x48(%eax),%eax
  80086e:	83 ec 04             	sub    $0x4,%esp
  800871:	51                   	push   %ecx
  800872:	50                   	push   %eax
  800873:	68 fc 1e 80 00       	push   $0x801efc
  800878:	e8 da 0c 00 00       	call   801557 <cprintf>
	*dev = 0;
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800886:	83 c4 10             	add    $0x10,%esp
  800889:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	56                   	push   %esi
  800894:	53                   	push   %ebx
  800895:	83 ec 10             	sub    $0x10,%esp
  800898:	8b 75 08             	mov    0x8(%ebp),%esi
  80089b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80089e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a1:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008a2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008a8:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008ab:	50                   	push   %eax
  8008ac:	e8 36 ff ff ff       	call   8007e7 <fd_lookup>
  8008b1:	83 c4 08             	add    $0x8,%esp
  8008b4:	85 c0                	test   %eax,%eax
  8008b6:	78 05                	js     8008bd <fd_close+0x2d>
	    || fd != fd2)
  8008b8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008bb:	74 0c                	je     8008c9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8008bd:	84 db                	test   %bl,%bl
  8008bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c4:	0f 44 c2             	cmove  %edx,%eax
  8008c7:	eb 41                	jmp    80090a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008cf:	50                   	push   %eax
  8008d0:	ff 36                	pushl  (%esi)
  8008d2:	e8 66 ff ff ff       	call   80083d <dev_lookup>
  8008d7:	89 c3                	mov    %eax,%ebx
  8008d9:	83 c4 10             	add    $0x10,%esp
  8008dc:	85 c0                	test   %eax,%eax
  8008de:	78 1a                	js     8008fa <fd_close+0x6a>
		if (dev->dev_close)
  8008e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8008e6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8008eb:	85 c0                	test   %eax,%eax
  8008ed:	74 0b                	je     8008fa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8008ef:	83 ec 0c             	sub    $0xc,%esp
  8008f2:	56                   	push   %esi
  8008f3:	ff d0                	call   *%eax
  8008f5:	89 c3                	mov    %eax,%ebx
  8008f7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8008fa:	83 ec 08             	sub    $0x8,%esp
  8008fd:	56                   	push   %esi
  8008fe:	6a 00                	push   $0x0
  800900:	e8 00 fd ff ff       	call   800605 <sys_page_unmap>
	return r;
  800905:	83 c4 10             	add    $0x10,%esp
  800908:	89 d8                	mov    %ebx,%eax
}
  80090a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80091a:	50                   	push   %eax
  80091b:	ff 75 08             	pushl  0x8(%ebp)
  80091e:	e8 c4 fe ff ff       	call   8007e7 <fd_lookup>
  800923:	89 c2                	mov    %eax,%edx
  800925:	83 c4 08             	add    $0x8,%esp
  800928:	85 d2                	test   %edx,%edx
  80092a:	78 10                	js     80093c <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80092c:	83 ec 08             	sub    $0x8,%esp
  80092f:	6a 01                	push   $0x1
  800931:	ff 75 f4             	pushl  -0xc(%ebp)
  800934:	e8 57 ff ff ff       	call   800890 <fd_close>
  800939:	83 c4 10             	add    $0x10,%esp
}
  80093c:	c9                   	leave  
  80093d:	c3                   	ret    

0080093e <close_all>:

void
close_all(void)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800945:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80094a:	83 ec 0c             	sub    $0xc,%esp
  80094d:	53                   	push   %ebx
  80094e:	e8 be ff ff ff       	call   800911 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800953:	83 c3 01             	add    $0x1,%ebx
  800956:	83 c4 10             	add    $0x10,%esp
  800959:	83 fb 20             	cmp    $0x20,%ebx
  80095c:	75 ec                	jne    80094a <close_all+0xc>
		close(i);
}
  80095e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	83 ec 2c             	sub    $0x2c,%esp
  80096c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80096f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800972:	50                   	push   %eax
  800973:	ff 75 08             	pushl  0x8(%ebp)
  800976:	e8 6c fe ff ff       	call   8007e7 <fd_lookup>
  80097b:	89 c2                	mov    %eax,%edx
  80097d:	83 c4 08             	add    $0x8,%esp
  800980:	85 d2                	test   %edx,%edx
  800982:	0f 88 c1 00 00 00    	js     800a49 <dup+0xe6>
		return r;
	close(newfdnum);
  800988:	83 ec 0c             	sub    $0xc,%esp
  80098b:	56                   	push   %esi
  80098c:	e8 80 ff ff ff       	call   800911 <close>

	newfd = INDEX2FD(newfdnum);
  800991:	89 f3                	mov    %esi,%ebx
  800993:	c1 e3 0c             	shl    $0xc,%ebx
  800996:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80099c:	83 c4 04             	add    $0x4,%esp
  80099f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009a2:	e8 da fd ff ff       	call   800781 <fd2data>
  8009a7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8009a9:	89 1c 24             	mov    %ebx,(%esp)
  8009ac:	e8 d0 fd ff ff       	call   800781 <fd2data>
  8009b1:	83 c4 10             	add    $0x10,%esp
  8009b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009b7:	89 f8                	mov    %edi,%eax
  8009b9:	c1 e8 16             	shr    $0x16,%eax
  8009bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009c3:	a8 01                	test   $0x1,%al
  8009c5:	74 37                	je     8009fe <dup+0x9b>
  8009c7:	89 f8                	mov    %edi,%eax
  8009c9:	c1 e8 0c             	shr    $0xc,%eax
  8009cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009d3:	f6 c2 01             	test   $0x1,%dl
  8009d6:	74 26                	je     8009fe <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009df:	83 ec 0c             	sub    $0xc,%esp
  8009e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8009e7:	50                   	push   %eax
  8009e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009eb:	6a 00                	push   $0x0
  8009ed:	57                   	push   %edi
  8009ee:	6a 00                	push   $0x0
  8009f0:	e8 ce fb ff ff       	call   8005c3 <sys_page_map>
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	83 c4 20             	add    $0x20,%esp
  8009fa:	85 c0                	test   %eax,%eax
  8009fc:	78 2e                	js     800a2c <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a01:	89 d0                	mov    %edx,%eax
  800a03:	c1 e8 0c             	shr    $0xc,%eax
  800a06:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a0d:	83 ec 0c             	sub    $0xc,%esp
  800a10:	25 07 0e 00 00       	and    $0xe07,%eax
  800a15:	50                   	push   %eax
  800a16:	53                   	push   %ebx
  800a17:	6a 00                	push   $0x0
  800a19:	52                   	push   %edx
  800a1a:	6a 00                	push   $0x0
  800a1c:	e8 a2 fb ff ff       	call   8005c3 <sys_page_map>
  800a21:	89 c7                	mov    %eax,%edi
  800a23:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a26:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a28:	85 ff                	test   %edi,%edi
  800a2a:	79 1d                	jns    800a49 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a2c:	83 ec 08             	sub    $0x8,%esp
  800a2f:	53                   	push   %ebx
  800a30:	6a 00                	push   $0x0
  800a32:	e8 ce fb ff ff       	call   800605 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a37:	83 c4 08             	add    $0x8,%esp
  800a3a:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a3d:	6a 00                	push   $0x0
  800a3f:	e8 c1 fb ff ff       	call   800605 <sys_page_unmap>
	return r;
  800a44:	83 c4 10             	add    $0x10,%esp
  800a47:	89 f8                	mov    %edi,%eax
}
  800a49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	53                   	push   %ebx
  800a55:	83 ec 14             	sub    $0x14,%esp
  800a58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a5e:	50                   	push   %eax
  800a5f:	53                   	push   %ebx
  800a60:	e8 82 fd ff ff       	call   8007e7 <fd_lookup>
  800a65:	83 c4 08             	add    $0x8,%esp
  800a68:	89 c2                	mov    %eax,%edx
  800a6a:	85 c0                	test   %eax,%eax
  800a6c:	78 6d                	js     800adb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a6e:	83 ec 08             	sub    $0x8,%esp
  800a71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a74:	50                   	push   %eax
  800a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a78:	ff 30                	pushl  (%eax)
  800a7a:	e8 be fd ff ff       	call   80083d <dev_lookup>
  800a7f:	83 c4 10             	add    $0x10,%esp
  800a82:	85 c0                	test   %eax,%eax
  800a84:	78 4c                	js     800ad2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a86:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a89:	8b 42 08             	mov    0x8(%edx),%eax
  800a8c:	83 e0 03             	and    $0x3,%eax
  800a8f:	83 f8 01             	cmp    $0x1,%eax
  800a92:	75 21                	jne    800ab5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a94:	a1 04 40 80 00       	mov    0x804004,%eax
  800a99:	8b 40 48             	mov    0x48(%eax),%eax
  800a9c:	83 ec 04             	sub    $0x4,%esp
  800a9f:	53                   	push   %ebx
  800aa0:	50                   	push   %eax
  800aa1:	68 3d 1f 80 00       	push   $0x801f3d
  800aa6:	e8 ac 0a 00 00       	call   801557 <cprintf>
		return -E_INVAL;
  800aab:	83 c4 10             	add    $0x10,%esp
  800aae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ab3:	eb 26                	jmp    800adb <read+0x8a>
	}
	if (!dev->dev_read)
  800ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ab8:	8b 40 08             	mov    0x8(%eax),%eax
  800abb:	85 c0                	test   %eax,%eax
  800abd:	74 17                	je     800ad6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800abf:	83 ec 04             	sub    $0x4,%esp
  800ac2:	ff 75 10             	pushl  0x10(%ebp)
  800ac5:	ff 75 0c             	pushl  0xc(%ebp)
  800ac8:	52                   	push   %edx
  800ac9:	ff d0                	call   *%eax
  800acb:	89 c2                	mov    %eax,%edx
  800acd:	83 c4 10             	add    $0x10,%esp
  800ad0:	eb 09                	jmp    800adb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ad2:	89 c2                	mov    %eax,%edx
  800ad4:	eb 05                	jmp    800adb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800ad6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800adb:	89 d0                	mov    %edx,%eax
  800add:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	83 ec 0c             	sub    $0xc,%esp
  800aeb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800af1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800af6:	eb 21                	jmp    800b19 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800af8:	83 ec 04             	sub    $0x4,%esp
  800afb:	89 f0                	mov    %esi,%eax
  800afd:	29 d8                	sub    %ebx,%eax
  800aff:	50                   	push   %eax
  800b00:	89 d8                	mov    %ebx,%eax
  800b02:	03 45 0c             	add    0xc(%ebp),%eax
  800b05:	50                   	push   %eax
  800b06:	57                   	push   %edi
  800b07:	e8 45 ff ff ff       	call   800a51 <read>
		if (m < 0)
  800b0c:	83 c4 10             	add    $0x10,%esp
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	78 0c                	js     800b1f <readn+0x3d>
			return m;
		if (m == 0)
  800b13:	85 c0                	test   %eax,%eax
  800b15:	74 06                	je     800b1d <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b17:	01 c3                	add    %eax,%ebx
  800b19:	39 f3                	cmp    %esi,%ebx
  800b1b:	72 db                	jb     800af8 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800b1d:	89 d8                	mov    %ebx,%eax
}
  800b1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 14             	sub    $0x14,%esp
  800b2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b34:	50                   	push   %eax
  800b35:	53                   	push   %ebx
  800b36:	e8 ac fc ff ff       	call   8007e7 <fd_lookup>
  800b3b:	83 c4 08             	add    $0x8,%esp
  800b3e:	89 c2                	mov    %eax,%edx
  800b40:	85 c0                	test   %eax,%eax
  800b42:	78 68                	js     800bac <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b44:	83 ec 08             	sub    $0x8,%esp
  800b47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b4a:	50                   	push   %eax
  800b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b4e:	ff 30                	pushl  (%eax)
  800b50:	e8 e8 fc ff ff       	call   80083d <dev_lookup>
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	78 47                	js     800ba3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b5f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b63:	75 21                	jne    800b86 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b65:	a1 04 40 80 00       	mov    0x804004,%eax
  800b6a:	8b 40 48             	mov    0x48(%eax),%eax
  800b6d:	83 ec 04             	sub    $0x4,%esp
  800b70:	53                   	push   %ebx
  800b71:	50                   	push   %eax
  800b72:	68 59 1f 80 00       	push   $0x801f59
  800b77:	e8 db 09 00 00       	call   801557 <cprintf>
		return -E_INVAL;
  800b7c:	83 c4 10             	add    $0x10,%esp
  800b7f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b84:	eb 26                	jmp    800bac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b89:	8b 52 0c             	mov    0xc(%edx),%edx
  800b8c:	85 d2                	test   %edx,%edx
  800b8e:	74 17                	je     800ba7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b90:	83 ec 04             	sub    $0x4,%esp
  800b93:	ff 75 10             	pushl  0x10(%ebp)
  800b96:	ff 75 0c             	pushl  0xc(%ebp)
  800b99:	50                   	push   %eax
  800b9a:	ff d2                	call   *%edx
  800b9c:	89 c2                	mov    %eax,%edx
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	eb 09                	jmp    800bac <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ba3:	89 c2                	mov    %eax,%edx
  800ba5:	eb 05                	jmp    800bac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ba7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800bac:	89 d0                	mov    %edx,%eax
  800bae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <seek>:

int
seek(int fdnum, off_t offset)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bb9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800bbc:	50                   	push   %eax
  800bbd:	ff 75 08             	pushl  0x8(%ebp)
  800bc0:	e8 22 fc ff ff       	call   8007e7 <fd_lookup>
  800bc5:	83 c4 08             	add    $0x8,%esp
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	78 0e                	js     800bda <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800bcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 14             	sub    $0x14,%esp
  800be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800be6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800be9:	50                   	push   %eax
  800bea:	53                   	push   %ebx
  800beb:	e8 f7 fb ff ff       	call   8007e7 <fd_lookup>
  800bf0:	83 c4 08             	add    $0x8,%esp
  800bf3:	89 c2                	mov    %eax,%edx
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	78 65                	js     800c5e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bf9:	83 ec 08             	sub    $0x8,%esp
  800bfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bff:	50                   	push   %eax
  800c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c03:	ff 30                	pushl  (%eax)
  800c05:	e8 33 fc ff ff       	call   80083d <dev_lookup>
  800c0a:	83 c4 10             	add    $0x10,%esp
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	78 44                	js     800c55 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c14:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c18:	75 21                	jne    800c3b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c1a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c1f:	8b 40 48             	mov    0x48(%eax),%eax
  800c22:	83 ec 04             	sub    $0x4,%esp
  800c25:	53                   	push   %ebx
  800c26:	50                   	push   %eax
  800c27:	68 1c 1f 80 00       	push   $0x801f1c
  800c2c:	e8 26 09 00 00       	call   801557 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c39:	eb 23                	jmp    800c5e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c3e:	8b 52 18             	mov    0x18(%edx),%edx
  800c41:	85 d2                	test   %edx,%edx
  800c43:	74 14                	je     800c59 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c45:	83 ec 08             	sub    $0x8,%esp
  800c48:	ff 75 0c             	pushl  0xc(%ebp)
  800c4b:	50                   	push   %eax
  800c4c:	ff d2                	call   *%edx
  800c4e:	89 c2                	mov    %eax,%edx
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	eb 09                	jmp    800c5e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c55:	89 c2                	mov    %eax,%edx
  800c57:	eb 05                	jmp    800c5e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c59:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800c5e:	89 d0                	mov    %edx,%eax
  800c60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c63:	c9                   	leave  
  800c64:	c3                   	ret    

00800c65 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	53                   	push   %ebx
  800c69:	83 ec 14             	sub    $0x14,%esp
  800c6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c72:	50                   	push   %eax
  800c73:	ff 75 08             	pushl  0x8(%ebp)
  800c76:	e8 6c fb ff ff       	call   8007e7 <fd_lookup>
  800c7b:	83 c4 08             	add    $0x8,%esp
  800c7e:	89 c2                	mov    %eax,%edx
  800c80:	85 c0                	test   %eax,%eax
  800c82:	78 58                	js     800cdc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c84:	83 ec 08             	sub    $0x8,%esp
  800c87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c8a:	50                   	push   %eax
  800c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c8e:	ff 30                	pushl  (%eax)
  800c90:	e8 a8 fb ff ff       	call   80083d <dev_lookup>
  800c95:	83 c4 10             	add    $0x10,%esp
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	78 37                	js     800cd3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ca3:	74 32                	je     800cd7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ca5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800ca8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800caf:	00 00 00 
	stat->st_isdir = 0;
  800cb2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cb9:	00 00 00 
	stat->st_dev = dev;
  800cbc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800cc2:	83 ec 08             	sub    $0x8,%esp
  800cc5:	53                   	push   %ebx
  800cc6:	ff 75 f0             	pushl  -0x10(%ebp)
  800cc9:	ff 50 14             	call   *0x14(%eax)
  800ccc:	89 c2                	mov    %eax,%edx
  800cce:	83 c4 10             	add    $0x10,%esp
  800cd1:	eb 09                	jmp    800cdc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cd3:	89 c2                	mov    %eax,%edx
  800cd5:	eb 05                	jmp    800cdc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800cd7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800cdc:	89 d0                	mov    %edx,%eax
  800cde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ce8:	83 ec 08             	sub    $0x8,%esp
  800ceb:	6a 00                	push   $0x0
  800ced:	ff 75 08             	pushl  0x8(%ebp)
  800cf0:	e8 09 02 00 00       	call   800efe <open>
  800cf5:	89 c3                	mov    %eax,%ebx
  800cf7:	83 c4 10             	add    $0x10,%esp
  800cfa:	85 db                	test   %ebx,%ebx
  800cfc:	78 1b                	js     800d19 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800cfe:	83 ec 08             	sub    $0x8,%esp
  800d01:	ff 75 0c             	pushl  0xc(%ebp)
  800d04:	53                   	push   %ebx
  800d05:	e8 5b ff ff ff       	call   800c65 <fstat>
  800d0a:	89 c6                	mov    %eax,%esi
	close(fd);
  800d0c:	89 1c 24             	mov    %ebx,(%esp)
  800d0f:	e8 fd fb ff ff       	call   800911 <close>
	return r;
  800d14:	83 c4 10             	add    $0x10,%esp
  800d17:	89 f0                	mov    %esi,%eax
}
  800d19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	89 c6                	mov    %eax,%esi
  800d27:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d29:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d30:	75 12                	jne    800d44 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	6a 01                	push   $0x1
  800d37:	e8 26 0e 00 00       	call   801b62 <ipc_find_env>
  800d3c:	a3 00 40 80 00       	mov    %eax,0x804000
  800d41:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d44:	6a 07                	push   $0x7
  800d46:	68 00 50 80 00       	push   $0x805000
  800d4b:	56                   	push   %esi
  800d4c:	ff 35 00 40 80 00    	pushl  0x804000
  800d52:	e8 b7 0d 00 00       	call   801b0e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d57:	83 c4 0c             	add    $0xc,%esp
  800d5a:	6a 00                	push   $0x0
  800d5c:	53                   	push   %ebx
  800d5d:	6a 00                	push   $0x0
  800d5f:	e8 41 0d 00 00       	call   801aa5 <ipc_recv>
}
  800d64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	8b 40 0c             	mov    0xc(%eax),%eax
  800d77:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d84:	ba 00 00 00 00       	mov    $0x0,%edx
  800d89:	b8 02 00 00 00       	mov    $0x2,%eax
  800d8e:	e8 8d ff ff ff       	call   800d20 <fsipc>
}
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	8b 40 0c             	mov    0xc(%eax),%eax
  800da1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800da6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dab:	b8 06 00 00 00       	mov    $0x6,%eax
  800db0:	e8 6b ff ff ff       	call   800d20 <fsipc>
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 04             	sub    $0x4,%esp
  800dbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	8b 40 0c             	mov    0xc(%eax),%eax
  800dc7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800dcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd1:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd6:	e8 45 ff ff ff       	call   800d20 <fsipc>
  800ddb:	89 c2                	mov    %eax,%edx
  800ddd:	85 d2                	test   %edx,%edx
  800ddf:	78 2c                	js     800e0d <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800de1:	83 ec 08             	sub    $0x8,%esp
  800de4:	68 00 50 80 00       	push   $0x805000
  800de9:	53                   	push   %ebx
  800dea:	e8 88 f3 ff ff       	call   800177 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800def:	a1 80 50 80 00       	mov    0x805080,%eax
  800df4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800dfa:	a1 84 50 80 00       	mov    0x805084,%eax
  800dff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e10:	c9                   	leave  
  800e11:	c3                   	ret    

00800e12 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e21:	8b 40 0c             	mov    0xc(%eax),%eax
  800e24:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800e29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800e2c:	eb 3d                	jmp    800e6b <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800e2e:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800e34:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800e39:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800e3c:	83 ec 04             	sub    $0x4,%esp
  800e3f:	57                   	push   %edi
  800e40:	53                   	push   %ebx
  800e41:	68 08 50 80 00       	push   $0x805008
  800e46:	e8 be f4 ff ff       	call   800309 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800e4b:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800e51:	ba 00 00 00 00       	mov    $0x0,%edx
  800e56:	b8 04 00 00 00       	mov    $0x4,%eax
  800e5b:	e8 c0 fe ff ff       	call   800d20 <fsipc>
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	78 0d                	js     800e74 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800e67:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800e69:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800e6b:	85 f6                	test   %esi,%esi
  800e6d:	75 bf                	jne    800e2e <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800e6f:	89 d8                	mov    %ebx,%eax
  800e71:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800e74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
  800e81:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	8b 40 0c             	mov    0xc(%eax),%eax
  800e8a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e8f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e95:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9f:	e8 7c fe ff ff       	call   800d20 <fsipc>
  800ea4:	89 c3                	mov    %eax,%ebx
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	78 4b                	js     800ef5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800eaa:	39 c6                	cmp    %eax,%esi
  800eac:	73 16                	jae    800ec4 <devfile_read+0x48>
  800eae:	68 88 1f 80 00       	push   $0x801f88
  800eb3:	68 8f 1f 80 00       	push   $0x801f8f
  800eb8:	6a 7c                	push   $0x7c
  800eba:	68 a4 1f 80 00       	push   $0x801fa4
  800ebf:	e8 ba 05 00 00       	call   80147e <_panic>
	assert(r <= PGSIZE);
  800ec4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ec9:	7e 16                	jle    800ee1 <devfile_read+0x65>
  800ecb:	68 af 1f 80 00       	push   $0x801faf
  800ed0:	68 8f 1f 80 00       	push   $0x801f8f
  800ed5:	6a 7d                	push   $0x7d
  800ed7:	68 a4 1f 80 00       	push   $0x801fa4
  800edc:	e8 9d 05 00 00       	call   80147e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ee1:	83 ec 04             	sub    $0x4,%esp
  800ee4:	50                   	push   %eax
  800ee5:	68 00 50 80 00       	push   $0x805000
  800eea:	ff 75 0c             	pushl  0xc(%ebp)
  800eed:	e8 17 f4 ff ff       	call   800309 <memmove>
	return r;
  800ef2:	83 c4 10             	add    $0x10,%esp
}
  800ef5:	89 d8                	mov    %ebx,%eax
  800ef7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	53                   	push   %ebx
  800f02:	83 ec 20             	sub    $0x20,%esp
  800f05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800f08:	53                   	push   %ebx
  800f09:	e8 30 f2 ff ff       	call   80013e <strlen>
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f16:	7f 67                	jg     800f7f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f18:	83 ec 0c             	sub    $0xc,%esp
  800f1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1e:	50                   	push   %eax
  800f1f:	e8 74 f8 ff ff       	call   800798 <fd_alloc>
  800f24:	83 c4 10             	add    $0x10,%esp
		return r;
  800f27:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	78 57                	js     800f84 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f2d:	83 ec 08             	sub    $0x8,%esp
  800f30:	53                   	push   %ebx
  800f31:	68 00 50 80 00       	push   $0x805000
  800f36:	e8 3c f2 ff ff       	call   800177 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f46:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4b:	e8 d0 fd ff ff       	call   800d20 <fsipc>
  800f50:	89 c3                	mov    %eax,%ebx
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	79 14                	jns    800f6d <open+0x6f>
		fd_close(fd, 0);
  800f59:	83 ec 08             	sub    $0x8,%esp
  800f5c:	6a 00                	push   $0x0
  800f5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f61:	e8 2a f9 ff ff       	call   800890 <fd_close>
		return r;
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	89 da                	mov    %ebx,%edx
  800f6b:	eb 17                	jmp    800f84 <open+0x86>
	}

	return fd2num(fd);
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	ff 75 f4             	pushl  -0xc(%ebp)
  800f73:	e8 f9 f7 ff ff       	call   800771 <fd2num>
  800f78:	89 c2                	mov    %eax,%edx
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	eb 05                	jmp    800f84 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f7f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f84:	89 d0                	mov    %edx,%eax
  800f86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    

00800f8b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f91:	ba 00 00 00 00       	mov    $0x0,%edx
  800f96:	b8 08 00 00 00       	mov    $0x8,%eax
  800f9b:	e8 80 fd ff ff       	call   800d20 <fsipc>
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	ff 75 08             	pushl  0x8(%ebp)
  800fb0:	e8 cc f7 ff ff       	call   800781 <fd2data>
  800fb5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800fb7:	83 c4 08             	add    $0x8,%esp
  800fba:	68 bb 1f 80 00       	push   $0x801fbb
  800fbf:	53                   	push   %ebx
  800fc0:	e8 b2 f1 ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800fc5:	8b 56 04             	mov    0x4(%esi),%edx
  800fc8:	89 d0                	mov    %edx,%eax
  800fca:	2b 06                	sub    (%esi),%eax
  800fcc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800fd2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800fd9:	00 00 00 
	stat->st_dev = &devpipe;
  800fdc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800fe3:	30 80 00 
	return 0;
}
  800fe6:	b8 00 00 00 00       	mov    $0x0,%eax
  800feb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	53                   	push   %ebx
  800ff6:	83 ec 0c             	sub    $0xc,%esp
  800ff9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ffc:	53                   	push   %ebx
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 01 f6 ff ff       	call   800605 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801004:	89 1c 24             	mov    %ebx,(%esp)
  801007:	e8 75 f7 ff ff       	call   800781 <fd2data>
  80100c:	83 c4 08             	add    $0x8,%esp
  80100f:	50                   	push   %eax
  801010:	6a 00                	push   $0x0
  801012:	e8 ee f5 ff ff       	call   800605 <sys_page_unmap>
}
  801017:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	53                   	push   %ebx
  801022:	83 ec 1c             	sub    $0x1c,%esp
  801025:	89 c6                	mov    %eax,%esi
  801027:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80102a:	a1 04 40 80 00       	mov    0x804004,%eax
  80102f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	56                   	push   %esi
  801036:	e8 5f 0b 00 00       	call   801b9a <pageref>
  80103b:	89 c7                	mov    %eax,%edi
  80103d:	83 c4 04             	add    $0x4,%esp
  801040:	ff 75 e4             	pushl  -0x1c(%ebp)
  801043:	e8 52 0b 00 00       	call   801b9a <pageref>
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	39 c7                	cmp    %eax,%edi
  80104d:	0f 94 c2             	sete   %dl
  801050:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801053:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801059:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80105c:	39 fb                	cmp    %edi,%ebx
  80105e:	74 19                	je     801079 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801060:	84 d2                	test   %dl,%dl
  801062:	74 c6                	je     80102a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801064:	8b 51 58             	mov    0x58(%ecx),%edx
  801067:	50                   	push   %eax
  801068:	52                   	push   %edx
  801069:	53                   	push   %ebx
  80106a:	68 c2 1f 80 00       	push   $0x801fc2
  80106f:	e8 e3 04 00 00       	call   801557 <cprintf>
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	eb b1                	jmp    80102a <_pipeisclosed+0xe>
	}
}
  801079:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	57                   	push   %edi
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	83 ec 28             	sub    $0x28,%esp
  80108a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80108d:	56                   	push   %esi
  80108e:	e8 ee f6 ff ff       	call   800781 <fd2data>
  801093:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	bf 00 00 00 00       	mov    $0x0,%edi
  80109d:	eb 4b                	jmp    8010ea <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80109f:	89 da                	mov    %ebx,%edx
  8010a1:	89 f0                	mov    %esi,%eax
  8010a3:	e8 74 ff ff ff       	call   80101c <_pipeisclosed>
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	75 48                	jne    8010f4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8010ac:	e8 b0 f4 ff ff       	call   800561 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8010b4:	8b 0b                	mov    (%ebx),%ecx
  8010b6:	8d 51 20             	lea    0x20(%ecx),%edx
  8010b9:	39 d0                	cmp    %edx,%eax
  8010bb:	73 e2                	jae    80109f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010c4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010c7:	89 c2                	mov    %eax,%edx
  8010c9:	c1 fa 1f             	sar    $0x1f,%edx
  8010cc:	89 d1                	mov    %edx,%ecx
  8010ce:	c1 e9 1b             	shr    $0x1b,%ecx
  8010d1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8010d4:	83 e2 1f             	and    $0x1f,%edx
  8010d7:	29 ca                	sub    %ecx,%edx
  8010d9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8010dd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8010e1:	83 c0 01             	add    $0x1,%eax
  8010e4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010e7:	83 c7 01             	add    $0x1,%edi
  8010ea:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010ed:	75 c2                	jne    8010b1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8010ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f2:	eb 05                	jmp    8010f9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010f4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	57                   	push   %edi
  801105:	56                   	push   %esi
  801106:	53                   	push   %ebx
  801107:	83 ec 18             	sub    $0x18,%esp
  80110a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80110d:	57                   	push   %edi
  80110e:	e8 6e f6 ff ff       	call   800781 <fd2data>
  801113:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111d:	eb 3d                	jmp    80115c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80111f:	85 db                	test   %ebx,%ebx
  801121:	74 04                	je     801127 <devpipe_read+0x26>
				return i;
  801123:	89 d8                	mov    %ebx,%eax
  801125:	eb 44                	jmp    80116b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801127:	89 f2                	mov    %esi,%edx
  801129:	89 f8                	mov    %edi,%eax
  80112b:	e8 ec fe ff ff       	call   80101c <_pipeisclosed>
  801130:	85 c0                	test   %eax,%eax
  801132:	75 32                	jne    801166 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801134:	e8 28 f4 ff ff       	call   800561 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801139:	8b 06                	mov    (%esi),%eax
  80113b:	3b 46 04             	cmp    0x4(%esi),%eax
  80113e:	74 df                	je     80111f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801140:	99                   	cltd   
  801141:	c1 ea 1b             	shr    $0x1b,%edx
  801144:	01 d0                	add    %edx,%eax
  801146:	83 e0 1f             	and    $0x1f,%eax
  801149:	29 d0                	sub    %edx,%eax
  80114b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801150:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801153:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801156:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801159:	83 c3 01             	add    $0x1,%ebx
  80115c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80115f:	75 d8                	jne    801139 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801161:	8b 45 10             	mov    0x10(%ebp),%eax
  801164:	eb 05                	jmp    80116b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801166:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80116b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80117b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	e8 14 f6 ff ff       	call   800798 <fd_alloc>
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	89 c2                	mov    %eax,%edx
  801189:	85 c0                	test   %eax,%eax
  80118b:	0f 88 2c 01 00 00    	js     8012bd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801191:	83 ec 04             	sub    $0x4,%esp
  801194:	68 07 04 00 00       	push   $0x407
  801199:	ff 75 f4             	pushl  -0xc(%ebp)
  80119c:	6a 00                	push   $0x0
  80119e:	e8 dd f3 ff ff       	call   800580 <sys_page_alloc>
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	89 c2                	mov    %eax,%edx
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	0f 88 0d 01 00 00    	js     8012bd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011b0:	83 ec 0c             	sub    $0xc,%esp
  8011b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	e8 dc f5 ff ff       	call   800798 <fd_alloc>
  8011bc:	89 c3                	mov    %eax,%ebx
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	0f 88 e2 00 00 00    	js     8012ab <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011c9:	83 ec 04             	sub    $0x4,%esp
  8011cc:	68 07 04 00 00       	push   $0x407
  8011d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8011d4:	6a 00                	push   $0x0
  8011d6:	e8 a5 f3 ff ff       	call   800580 <sys_page_alloc>
  8011db:	89 c3                	mov    %eax,%ebx
  8011dd:	83 c4 10             	add    $0x10,%esp
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	0f 88 c3 00 00 00    	js     8012ab <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8011e8:	83 ec 0c             	sub    $0xc,%esp
  8011eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ee:	e8 8e f5 ff ff       	call   800781 <fd2data>
  8011f3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f5:	83 c4 0c             	add    $0xc,%esp
  8011f8:	68 07 04 00 00       	push   $0x407
  8011fd:	50                   	push   %eax
  8011fe:	6a 00                	push   $0x0
  801200:	e8 7b f3 ff ff       	call   800580 <sys_page_alloc>
  801205:	89 c3                	mov    %eax,%ebx
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	85 c0                	test   %eax,%eax
  80120c:	0f 88 89 00 00 00    	js     80129b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801212:	83 ec 0c             	sub    $0xc,%esp
  801215:	ff 75 f0             	pushl  -0x10(%ebp)
  801218:	e8 64 f5 ff ff       	call   800781 <fd2data>
  80121d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801224:	50                   	push   %eax
  801225:	6a 00                	push   $0x0
  801227:	56                   	push   %esi
  801228:	6a 00                	push   $0x0
  80122a:	e8 94 f3 ff ff       	call   8005c3 <sys_page_map>
  80122f:	89 c3                	mov    %eax,%ebx
  801231:	83 c4 20             	add    $0x20,%esp
  801234:	85 c0                	test   %eax,%eax
  801236:	78 55                	js     80128d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801238:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80123e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801241:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801243:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801246:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80124d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801253:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801256:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801258:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	ff 75 f4             	pushl  -0xc(%ebp)
  801268:	e8 04 f5 ff ff       	call   800771 <fd2num>
  80126d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801270:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801272:	83 c4 04             	add    $0x4,%esp
  801275:	ff 75 f0             	pushl  -0x10(%ebp)
  801278:	e8 f4 f4 ff ff       	call   800771 <fd2num>
  80127d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801280:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	ba 00 00 00 00       	mov    $0x0,%edx
  80128b:	eb 30                	jmp    8012bd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	56                   	push   %esi
  801291:	6a 00                	push   $0x0
  801293:	e8 6d f3 ff ff       	call   800605 <sys_page_unmap>
  801298:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a1:	6a 00                	push   $0x0
  8012a3:	e8 5d f3 ff ff       	call   800605 <sys_page_unmap>
  8012a8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b1:	6a 00                	push   $0x0
  8012b3:	e8 4d f3 ff ff       	call   800605 <sys_page_unmap>
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8012bd:	89 d0                	mov    %edx,%eax
  8012bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5e                   	pop    %esi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	ff 75 08             	pushl  0x8(%ebp)
  8012d3:	e8 0f f5 ff ff       	call   8007e7 <fd_lookup>
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	85 d2                	test   %edx,%edx
  8012df:	78 18                	js     8012f9 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8012e1:	83 ec 0c             	sub    $0xc,%esp
  8012e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e7:	e8 95 f4 ff ff       	call   800781 <fd2data>
	return _pipeisclosed(fd, p);
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f1:	e8 26 fd ff ff       	call   80101c <_pipeisclosed>
  8012f6:	83 c4 10             	add    $0x10,%esp
}
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80130b:	68 da 1f 80 00       	push   $0x801fda
  801310:	ff 75 0c             	pushl  0xc(%ebp)
  801313:	e8 5f ee ff ff       	call   800177 <strcpy>
	return 0;
}
  801318:	b8 00 00 00 00       	mov    $0x0,%eax
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	57                   	push   %edi
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
  801325:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80132b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801330:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801336:	eb 2d                	jmp    801365 <devcons_write+0x46>
		m = n - tot;
  801338:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80133d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801340:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801345:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801348:	83 ec 04             	sub    $0x4,%esp
  80134b:	53                   	push   %ebx
  80134c:	03 45 0c             	add    0xc(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	57                   	push   %edi
  801351:	e8 b3 ef ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  801356:	83 c4 08             	add    $0x8,%esp
  801359:	53                   	push   %ebx
  80135a:	57                   	push   %edi
  80135b:	e8 64 f1 ff ff       	call   8004c4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801360:	01 de                	add    %ebx,%esi
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	89 f0                	mov    %esi,%eax
  801367:	3b 75 10             	cmp    0x10(%ebp),%esi
  80136a:	72 cc                	jb     801338 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80136c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80137a:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80137f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801383:	75 07                	jne    80138c <devcons_read+0x18>
  801385:	eb 28                	jmp    8013af <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801387:	e8 d5 f1 ff ff       	call   800561 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80138c:	e8 51 f1 ff ff       	call   8004e2 <sys_cgetc>
  801391:	85 c0                	test   %eax,%eax
  801393:	74 f2                	je     801387 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801395:	85 c0                	test   %eax,%eax
  801397:	78 16                	js     8013af <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801399:	83 f8 04             	cmp    $0x4,%eax
  80139c:	74 0c                	je     8013aa <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80139e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a1:	88 02                	mov    %al,(%edx)
	return 1;
  8013a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8013a8:	eb 05                	jmp    8013af <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013aa:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013bd:	6a 01                	push   $0x1
  8013bf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	e8 fc f0 ff ff       	call   8004c4 <sys_cputs>
  8013c8:	83 c4 10             	add    $0x10,%esp
}
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <getchar>:

int
getchar(void)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8013d3:	6a 01                	push   $0x1
  8013d5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 71 f6 ff ff       	call   800a51 <read>
	if (r < 0)
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 0f                	js     8013f6 <getchar+0x29>
		return r;
	if (r < 1)
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	7e 06                	jle    8013f1 <getchar+0x24>
		return -E_EOF;
	return c;
  8013eb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8013ef:	eb 05                	jmp    8013f6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8013f1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	ff 75 08             	pushl  0x8(%ebp)
  801405:	e8 dd f3 ff ff       	call   8007e7 <fd_lookup>
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 11                	js     801422 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801411:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801414:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80141a:	39 10                	cmp    %edx,(%eax)
  80141c:	0f 94 c0             	sete   %al
  80141f:	0f b6 c0             	movzbl %al,%eax
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <opencons>:

int
opencons(void)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	e8 65 f3 ff ff       	call   800798 <fd_alloc>
  801433:	83 c4 10             	add    $0x10,%esp
		return r;
  801436:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 3e                	js     80147a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80143c:	83 ec 04             	sub    $0x4,%esp
  80143f:	68 07 04 00 00       	push   $0x407
  801444:	ff 75 f4             	pushl  -0xc(%ebp)
  801447:	6a 00                	push   $0x0
  801449:	e8 32 f1 ff ff       	call   800580 <sys_page_alloc>
  80144e:	83 c4 10             	add    $0x10,%esp
		return r;
  801451:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801453:	85 c0                	test   %eax,%eax
  801455:	78 23                	js     80147a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801457:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80145d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801460:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801462:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801465:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	50                   	push   %eax
  801470:	e8 fc f2 ff ff       	call   800771 <fd2num>
  801475:	89 c2                	mov    %eax,%edx
  801477:	83 c4 10             	add    $0x10,%esp
}
  80147a:	89 d0                	mov    %edx,%eax
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	56                   	push   %esi
  801482:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801483:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801486:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80148c:	e8 b1 f0 ff ff       	call   800542 <sys_getenvid>
  801491:	83 ec 0c             	sub    $0xc,%esp
  801494:	ff 75 0c             	pushl  0xc(%ebp)
  801497:	ff 75 08             	pushl  0x8(%ebp)
  80149a:	56                   	push   %esi
  80149b:	50                   	push   %eax
  80149c:	68 e8 1f 80 00       	push   $0x801fe8
  8014a1:	e8 b1 00 00 00       	call   801557 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014a6:	83 c4 18             	add    $0x18,%esp
  8014a9:	53                   	push   %ebx
  8014aa:	ff 75 10             	pushl  0x10(%ebp)
  8014ad:	e8 54 00 00 00       	call   801506 <vcprintf>
	cprintf("\n");
  8014b2:	c7 04 24 d3 1f 80 00 	movl   $0x801fd3,(%esp)
  8014b9:	e8 99 00 00 00       	call   801557 <cprintf>
  8014be:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014c1:	cc                   	int3   
  8014c2:	eb fd                	jmp    8014c1 <_panic+0x43>

008014c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 04             	sub    $0x4,%esp
  8014cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014ce:	8b 13                	mov    (%ebx),%edx
  8014d0:	8d 42 01             	lea    0x1(%edx),%eax
  8014d3:	89 03                	mov    %eax,(%ebx)
  8014d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014d8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8014dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8014e1:	75 1a                	jne    8014fd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	68 ff 00 00 00       	push   $0xff
  8014eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8014ee:	50                   	push   %eax
  8014ef:	e8 d0 ef ff ff       	call   8004c4 <sys_cputs>
		b->idx = 0;
  8014f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8014fa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8014fd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801501:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80150f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801516:	00 00 00 
	b.cnt = 0;
  801519:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801520:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801523:	ff 75 0c             	pushl  0xc(%ebp)
  801526:	ff 75 08             	pushl  0x8(%ebp)
  801529:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80152f:	50                   	push   %eax
  801530:	68 c4 14 80 00       	push   $0x8014c4
  801535:	e8 4f 01 00 00       	call   801689 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80153a:	83 c4 08             	add    $0x8,%esp
  80153d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801543:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	e8 75 ef ff ff       	call   8004c4 <sys_cputs>

	return b.cnt;
}
  80154f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801555:	c9                   	leave  
  801556:	c3                   	ret    

00801557 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80155d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801560:	50                   	push   %eax
  801561:	ff 75 08             	pushl  0x8(%ebp)
  801564:	e8 9d ff ff ff       	call   801506 <vcprintf>
	va_end(ap);

	return cnt;
}
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	57                   	push   %edi
  80156f:	56                   	push   %esi
  801570:	53                   	push   %ebx
  801571:	83 ec 1c             	sub    $0x1c,%esp
  801574:	89 c7                	mov    %eax,%edi
  801576:	89 d6                	mov    %edx,%esi
  801578:	8b 45 08             	mov    0x8(%ebp),%eax
  80157b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157e:	89 d1                	mov    %edx,%ecx
  801580:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801583:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801586:	8b 45 10             	mov    0x10(%ebp),%eax
  801589:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80158c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80158f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801596:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801599:	72 05                	jb     8015a0 <printnum+0x35>
  80159b:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80159e:	77 3e                	ja     8015de <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015a0:	83 ec 0c             	sub    $0xc,%esp
  8015a3:	ff 75 18             	pushl  0x18(%ebp)
  8015a6:	83 eb 01             	sub    $0x1,%ebx
  8015a9:	53                   	push   %ebx
  8015aa:	50                   	push   %eax
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8015b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8015ba:	e8 21 06 00 00       	call   801be0 <__udivdi3>
  8015bf:	83 c4 18             	add    $0x18,%esp
  8015c2:	52                   	push   %edx
  8015c3:	50                   	push   %eax
  8015c4:	89 f2                	mov    %esi,%edx
  8015c6:	89 f8                	mov    %edi,%eax
  8015c8:	e8 9e ff ff ff       	call   80156b <printnum>
  8015cd:	83 c4 20             	add    $0x20,%esp
  8015d0:	eb 13                	jmp    8015e5 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	56                   	push   %esi
  8015d6:	ff 75 18             	pushl  0x18(%ebp)
  8015d9:	ff d7                	call   *%edi
  8015db:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8015de:	83 eb 01             	sub    $0x1,%ebx
  8015e1:	85 db                	test   %ebx,%ebx
  8015e3:	7f ed                	jg     8015d2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8015e5:	83 ec 08             	sub    $0x8,%esp
  8015e8:	56                   	push   %esi
  8015e9:	83 ec 04             	sub    $0x4,%esp
  8015ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8015f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8015f8:	e8 13 07 00 00       	call   801d10 <__umoddi3>
  8015fd:	83 c4 14             	add    $0x14,%esp
  801600:	0f be 80 0b 20 80 00 	movsbl 0x80200b(%eax),%eax
  801607:	50                   	push   %eax
  801608:	ff d7                	call   *%edi
  80160a:	83 c4 10             	add    $0x10,%esp
}
  80160d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5f                   	pop    %edi
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    

00801615 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801618:	83 fa 01             	cmp    $0x1,%edx
  80161b:	7e 0e                	jle    80162b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80161d:	8b 10                	mov    (%eax),%edx
  80161f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801622:	89 08                	mov    %ecx,(%eax)
  801624:	8b 02                	mov    (%edx),%eax
  801626:	8b 52 04             	mov    0x4(%edx),%edx
  801629:	eb 22                	jmp    80164d <getuint+0x38>
	else if (lflag)
  80162b:	85 d2                	test   %edx,%edx
  80162d:	74 10                	je     80163f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80162f:	8b 10                	mov    (%eax),%edx
  801631:	8d 4a 04             	lea    0x4(%edx),%ecx
  801634:	89 08                	mov    %ecx,(%eax)
  801636:	8b 02                	mov    (%edx),%eax
  801638:	ba 00 00 00 00       	mov    $0x0,%edx
  80163d:	eb 0e                	jmp    80164d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80163f:	8b 10                	mov    (%eax),%edx
  801641:	8d 4a 04             	lea    0x4(%edx),%ecx
  801644:	89 08                	mov    %ecx,(%eax)
  801646:	8b 02                	mov    (%edx),%eax
  801648:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801655:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801659:	8b 10                	mov    (%eax),%edx
  80165b:	3b 50 04             	cmp    0x4(%eax),%edx
  80165e:	73 0a                	jae    80166a <sprintputch+0x1b>
		*b->buf++ = ch;
  801660:	8d 4a 01             	lea    0x1(%edx),%ecx
  801663:	89 08                	mov    %ecx,(%eax)
  801665:	8b 45 08             	mov    0x8(%ebp),%eax
  801668:	88 02                	mov    %al,(%edx)
}
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801672:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801675:	50                   	push   %eax
  801676:	ff 75 10             	pushl  0x10(%ebp)
  801679:	ff 75 0c             	pushl  0xc(%ebp)
  80167c:	ff 75 08             	pushl  0x8(%ebp)
  80167f:	e8 05 00 00 00       	call   801689 <vprintfmt>
	va_end(ap);
  801684:	83 c4 10             	add    $0x10,%esp
}
  801687:	c9                   	leave  
  801688:	c3                   	ret    

00801689 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	57                   	push   %edi
  80168d:	56                   	push   %esi
  80168e:	53                   	push   %ebx
  80168f:	83 ec 2c             	sub    $0x2c,%esp
  801692:	8b 75 08             	mov    0x8(%ebp),%esi
  801695:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801698:	8b 7d 10             	mov    0x10(%ebp),%edi
  80169b:	eb 12                	jmp    8016af <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80169d:	85 c0                	test   %eax,%eax
  80169f:	0f 84 90 03 00 00    	je     801a35 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	53                   	push   %ebx
  8016a9:	50                   	push   %eax
  8016aa:	ff d6                	call   *%esi
  8016ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016af:	83 c7 01             	add    $0x1,%edi
  8016b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016b6:	83 f8 25             	cmp    $0x25,%eax
  8016b9:	75 e2                	jne    80169d <vprintfmt+0x14>
  8016bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8016d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d9:	eb 07                	jmp    8016e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016db:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8016de:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e2:	8d 47 01             	lea    0x1(%edi),%eax
  8016e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e8:	0f b6 07             	movzbl (%edi),%eax
  8016eb:	0f b6 c8             	movzbl %al,%ecx
  8016ee:	83 e8 23             	sub    $0x23,%eax
  8016f1:	3c 55                	cmp    $0x55,%al
  8016f3:	0f 87 21 03 00 00    	ja     801a1a <vprintfmt+0x391>
  8016f9:	0f b6 c0             	movzbl %al,%eax
  8016fc:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  801703:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801706:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80170a:	eb d6                	jmp    8016e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80170f:	b8 00 00 00 00       	mov    $0x0,%eax
  801714:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801717:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80171a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80171e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801721:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801724:	83 fa 09             	cmp    $0x9,%edx
  801727:	77 39                	ja     801762 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801729:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80172c:	eb e9                	jmp    801717 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80172e:	8b 45 14             	mov    0x14(%ebp),%eax
  801731:	8d 48 04             	lea    0x4(%eax),%ecx
  801734:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801737:	8b 00                	mov    (%eax),%eax
  801739:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80173c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80173f:	eb 27                	jmp    801768 <vprintfmt+0xdf>
  801741:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801744:	85 c0                	test   %eax,%eax
  801746:	b9 00 00 00 00       	mov    $0x0,%ecx
  80174b:	0f 49 c8             	cmovns %eax,%ecx
  80174e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801754:	eb 8c                	jmp    8016e2 <vprintfmt+0x59>
  801756:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801759:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801760:	eb 80                	jmp    8016e2 <vprintfmt+0x59>
  801762:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801765:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801768:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80176c:	0f 89 70 ff ff ff    	jns    8016e2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801772:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801775:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801778:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80177f:	e9 5e ff ff ff       	jmp    8016e2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801784:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80178a:	e9 53 ff ff ff       	jmp    8016e2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80178f:	8b 45 14             	mov    0x14(%ebp),%eax
  801792:	8d 50 04             	lea    0x4(%eax),%edx
  801795:	89 55 14             	mov    %edx,0x14(%ebp)
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	53                   	push   %ebx
  80179c:	ff 30                	pushl  (%eax)
  80179e:	ff d6                	call   *%esi
			break;
  8017a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017a6:	e9 04 ff ff ff       	jmp    8016af <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ae:	8d 50 04             	lea    0x4(%eax),%edx
  8017b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8017b4:	8b 00                	mov    (%eax),%eax
  8017b6:	99                   	cltd   
  8017b7:	31 d0                	xor    %edx,%eax
  8017b9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017bb:	83 f8 0f             	cmp    $0xf,%eax
  8017be:	7f 0b                	jg     8017cb <vprintfmt+0x142>
  8017c0:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8017c7:	85 d2                	test   %edx,%edx
  8017c9:	75 18                	jne    8017e3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8017cb:	50                   	push   %eax
  8017cc:	68 23 20 80 00       	push   $0x802023
  8017d1:	53                   	push   %ebx
  8017d2:	56                   	push   %esi
  8017d3:	e8 94 fe ff ff       	call   80166c <printfmt>
  8017d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8017de:	e9 cc fe ff ff       	jmp    8016af <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8017e3:	52                   	push   %edx
  8017e4:	68 a1 1f 80 00       	push   $0x801fa1
  8017e9:	53                   	push   %ebx
  8017ea:	56                   	push   %esi
  8017eb:	e8 7c fe ff ff       	call   80166c <printfmt>
  8017f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017f6:	e9 b4 fe ff ff       	jmp    8016af <vprintfmt+0x26>
  8017fb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8017fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801801:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801804:	8b 45 14             	mov    0x14(%ebp),%eax
  801807:	8d 50 04             	lea    0x4(%eax),%edx
  80180a:	89 55 14             	mov    %edx,0x14(%ebp)
  80180d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80180f:	85 ff                	test   %edi,%edi
  801811:	ba 1c 20 80 00       	mov    $0x80201c,%edx
  801816:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801819:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80181d:	0f 84 92 00 00 00    	je     8018b5 <vprintfmt+0x22c>
  801823:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801827:	0f 8e 96 00 00 00    	jle    8018c3 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80182d:	83 ec 08             	sub    $0x8,%esp
  801830:	51                   	push   %ecx
  801831:	57                   	push   %edi
  801832:	e8 1f e9 ff ff       	call   800156 <strnlen>
  801837:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80183a:	29 c1                	sub    %eax,%ecx
  80183c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80183f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801842:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801846:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801849:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80184c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80184e:	eb 0f                	jmp    80185f <vprintfmt+0x1d6>
					putch(padc, putdat);
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	53                   	push   %ebx
  801854:	ff 75 e0             	pushl  -0x20(%ebp)
  801857:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801859:	83 ef 01             	sub    $0x1,%edi
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	85 ff                	test   %edi,%edi
  801861:	7f ed                	jg     801850 <vprintfmt+0x1c7>
  801863:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801866:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801869:	85 c9                	test   %ecx,%ecx
  80186b:	b8 00 00 00 00       	mov    $0x0,%eax
  801870:	0f 49 c1             	cmovns %ecx,%eax
  801873:	29 c1                	sub    %eax,%ecx
  801875:	89 75 08             	mov    %esi,0x8(%ebp)
  801878:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80187b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80187e:	89 cb                	mov    %ecx,%ebx
  801880:	eb 4d                	jmp    8018cf <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801882:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801886:	74 1b                	je     8018a3 <vprintfmt+0x21a>
  801888:	0f be c0             	movsbl %al,%eax
  80188b:	83 e8 20             	sub    $0x20,%eax
  80188e:	83 f8 5e             	cmp    $0x5e,%eax
  801891:	76 10                	jbe    8018a3 <vprintfmt+0x21a>
					putch('?', putdat);
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	ff 75 0c             	pushl  0xc(%ebp)
  801899:	6a 3f                	push   $0x3f
  80189b:	ff 55 08             	call   *0x8(%ebp)
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	eb 0d                	jmp    8018b0 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	ff 75 0c             	pushl  0xc(%ebp)
  8018a9:	52                   	push   %edx
  8018aa:	ff 55 08             	call   *0x8(%ebp)
  8018ad:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018b0:	83 eb 01             	sub    $0x1,%ebx
  8018b3:	eb 1a                	jmp    8018cf <vprintfmt+0x246>
  8018b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8018b8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018be:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018c1:	eb 0c                	jmp    8018cf <vprintfmt+0x246>
  8018c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8018c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018cc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018cf:	83 c7 01             	add    $0x1,%edi
  8018d2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018d6:	0f be d0             	movsbl %al,%edx
  8018d9:	85 d2                	test   %edx,%edx
  8018db:	74 23                	je     801900 <vprintfmt+0x277>
  8018dd:	85 f6                	test   %esi,%esi
  8018df:	78 a1                	js     801882 <vprintfmt+0x1f9>
  8018e1:	83 ee 01             	sub    $0x1,%esi
  8018e4:	79 9c                	jns    801882 <vprintfmt+0x1f9>
  8018e6:	89 df                	mov    %ebx,%edi
  8018e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8018eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018ee:	eb 18                	jmp    801908 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	53                   	push   %ebx
  8018f4:	6a 20                	push   $0x20
  8018f6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018f8:	83 ef 01             	sub    $0x1,%edi
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	eb 08                	jmp    801908 <vprintfmt+0x27f>
  801900:	89 df                	mov    %ebx,%edi
  801902:	8b 75 08             	mov    0x8(%ebp),%esi
  801905:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801908:	85 ff                	test   %edi,%edi
  80190a:	7f e4                	jg     8018f0 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80190c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80190f:	e9 9b fd ff ff       	jmp    8016af <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801914:	83 fa 01             	cmp    $0x1,%edx
  801917:	7e 16                	jle    80192f <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801919:	8b 45 14             	mov    0x14(%ebp),%eax
  80191c:	8d 50 08             	lea    0x8(%eax),%edx
  80191f:	89 55 14             	mov    %edx,0x14(%ebp)
  801922:	8b 50 04             	mov    0x4(%eax),%edx
  801925:	8b 00                	mov    (%eax),%eax
  801927:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80192a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80192d:	eb 32                	jmp    801961 <vprintfmt+0x2d8>
	else if (lflag)
  80192f:	85 d2                	test   %edx,%edx
  801931:	74 18                	je     80194b <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801933:	8b 45 14             	mov    0x14(%ebp),%eax
  801936:	8d 50 04             	lea    0x4(%eax),%edx
  801939:	89 55 14             	mov    %edx,0x14(%ebp)
  80193c:	8b 00                	mov    (%eax),%eax
  80193e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801941:	89 c1                	mov    %eax,%ecx
  801943:	c1 f9 1f             	sar    $0x1f,%ecx
  801946:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801949:	eb 16                	jmp    801961 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80194b:	8b 45 14             	mov    0x14(%ebp),%eax
  80194e:	8d 50 04             	lea    0x4(%eax),%edx
  801951:	89 55 14             	mov    %edx,0x14(%ebp)
  801954:	8b 00                	mov    (%eax),%eax
  801956:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801959:	89 c1                	mov    %eax,%ecx
  80195b:	c1 f9 1f             	sar    $0x1f,%ecx
  80195e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801961:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801964:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801967:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80196c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801970:	79 74                	jns    8019e6 <vprintfmt+0x35d>
				putch('-', putdat);
  801972:	83 ec 08             	sub    $0x8,%esp
  801975:	53                   	push   %ebx
  801976:	6a 2d                	push   $0x2d
  801978:	ff d6                	call   *%esi
				num = -(long long) num;
  80197a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80197d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801980:	f7 d8                	neg    %eax
  801982:	83 d2 00             	adc    $0x0,%edx
  801985:	f7 da                	neg    %edx
  801987:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80198a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80198f:	eb 55                	jmp    8019e6 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801991:	8d 45 14             	lea    0x14(%ebp),%eax
  801994:	e8 7c fc ff ff       	call   801615 <getuint>
			base = 10;
  801999:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80199e:	eb 46                	jmp    8019e6 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8019a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8019a3:	e8 6d fc ff ff       	call   801615 <getuint>
                        base = 8;
  8019a8:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8019ad:	eb 37                	jmp    8019e6 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8019af:	83 ec 08             	sub    $0x8,%esp
  8019b2:	53                   	push   %ebx
  8019b3:	6a 30                	push   $0x30
  8019b5:	ff d6                	call   *%esi
			putch('x', putdat);
  8019b7:	83 c4 08             	add    $0x8,%esp
  8019ba:	53                   	push   %ebx
  8019bb:	6a 78                	push   $0x78
  8019bd:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c2:	8d 50 04             	lea    0x4(%eax),%edx
  8019c5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019c8:	8b 00                	mov    (%eax),%eax
  8019ca:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019cf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019d2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8019d7:	eb 0d                	jmp    8019e6 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8019dc:	e8 34 fc ff ff       	call   801615 <getuint>
			base = 16;
  8019e1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8019ed:	57                   	push   %edi
  8019ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8019f1:	51                   	push   %ecx
  8019f2:	52                   	push   %edx
  8019f3:	50                   	push   %eax
  8019f4:	89 da                	mov    %ebx,%edx
  8019f6:	89 f0                	mov    %esi,%eax
  8019f8:	e8 6e fb ff ff       	call   80156b <printnum>
			break;
  8019fd:	83 c4 20             	add    $0x20,%esp
  801a00:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a03:	e9 a7 fc ff ff       	jmp    8016af <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a08:	83 ec 08             	sub    $0x8,%esp
  801a0b:	53                   	push   %ebx
  801a0c:	51                   	push   %ecx
  801a0d:	ff d6                	call   *%esi
			break;
  801a0f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a15:	e9 95 fc ff ff       	jmp    8016af <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a1a:	83 ec 08             	sub    $0x8,%esp
  801a1d:	53                   	push   %ebx
  801a1e:	6a 25                	push   $0x25
  801a20:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	eb 03                	jmp    801a2a <vprintfmt+0x3a1>
  801a27:	83 ef 01             	sub    $0x1,%edi
  801a2a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a2e:	75 f7                	jne    801a27 <vprintfmt+0x39e>
  801a30:	e9 7a fc ff ff       	jmp    8016af <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5f                   	pop    %edi
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    

00801a3d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	83 ec 18             	sub    $0x18,%esp
  801a43:	8b 45 08             	mov    0x8(%ebp),%eax
  801a46:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a49:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a4c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a50:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	74 26                	je     801a84 <vsnprintf+0x47>
  801a5e:	85 d2                	test   %edx,%edx
  801a60:	7e 22                	jle    801a84 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a62:	ff 75 14             	pushl  0x14(%ebp)
  801a65:	ff 75 10             	pushl  0x10(%ebp)
  801a68:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a6b:	50                   	push   %eax
  801a6c:	68 4f 16 80 00       	push   $0x80164f
  801a71:	e8 13 fc ff ff       	call   801689 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a76:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a79:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	eb 05                	jmp    801a89 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a91:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a94:	50                   	push   %eax
  801a95:	ff 75 10             	pushl  0x10(%ebp)
  801a98:	ff 75 0c             	pushl  0xc(%ebp)
  801a9b:	ff 75 08             	pushl  0x8(%ebp)
  801a9e:	e8 9a ff ff ff       	call   801a3d <vsnprintf>
	va_end(ap);

	return rc;
}
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	8b 75 08             	mov    0x8(%ebp),%esi
  801aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801aba:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	50                   	push   %eax
  801ac1:	e8 6a ec ff ff       	call   800730 <sys_ipc_recv>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	79 16                	jns    801ae3 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801acd:	85 f6                	test   %esi,%esi
  801acf:	74 06                	je     801ad7 <ipc_recv+0x32>
  801ad1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801ad7:	85 db                	test   %ebx,%ebx
  801ad9:	74 2c                	je     801b07 <ipc_recv+0x62>
  801adb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ae1:	eb 24                	jmp    801b07 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801ae3:	85 f6                	test   %esi,%esi
  801ae5:	74 0a                	je     801af1 <ipc_recv+0x4c>
  801ae7:	a1 04 40 80 00       	mov    0x804004,%eax
  801aec:	8b 40 74             	mov    0x74(%eax),%eax
  801aef:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801af1:	85 db                	test   %ebx,%ebx
  801af3:	74 0a                	je     801aff <ipc_recv+0x5a>
  801af5:	a1 04 40 80 00       	mov    0x804004,%eax
  801afa:	8b 40 78             	mov    0x78(%eax),%eax
  801afd:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801aff:	a1 04 40 80 00       	mov    0x804004,%eax
  801b04:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    

00801b0e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 0c             	sub    $0xc,%esp
  801b17:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801b20:	85 db                	test   %ebx,%ebx
  801b22:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b27:	0f 44 d8             	cmove  %eax,%ebx
  801b2a:	eb 1c                	jmp    801b48 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801b2c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b2f:	74 12                	je     801b43 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801b31:	50                   	push   %eax
  801b32:	68 20 23 80 00       	push   $0x802320
  801b37:	6a 39                	push   $0x39
  801b39:	68 3b 23 80 00       	push   $0x80233b
  801b3e:	e8 3b f9 ff ff       	call   80147e <_panic>
                 sys_yield();
  801b43:	e8 19 ea ff ff       	call   800561 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b48:	ff 75 14             	pushl  0x14(%ebp)
  801b4b:	53                   	push   %ebx
  801b4c:	56                   	push   %esi
  801b4d:	57                   	push   %edi
  801b4e:	e8 ba eb ff ff       	call   80070d <sys_ipc_try_send>
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	85 c0                	test   %eax,%eax
  801b58:	78 d2                	js     801b2c <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5f                   	pop    %edi
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    

00801b62 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b6d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b70:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b76:	8b 52 50             	mov    0x50(%edx),%edx
  801b79:	39 ca                	cmp    %ecx,%edx
  801b7b:	75 0d                	jne    801b8a <ipc_find_env+0x28>
			return envs[i].env_id;
  801b7d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b80:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b85:	8b 40 08             	mov    0x8(%eax),%eax
  801b88:	eb 0e                	jmp    801b98 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b8a:	83 c0 01             	add    $0x1,%eax
  801b8d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b92:	75 d9                	jne    801b6d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b94:	66 b8 00 00          	mov    $0x0,%ax
}
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ba0:	89 d0                	mov    %edx,%eax
  801ba2:	c1 e8 16             	shr    $0x16,%eax
  801ba5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb1:	f6 c1 01             	test   $0x1,%cl
  801bb4:	74 1d                	je     801bd3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb6:	c1 ea 0c             	shr    $0xc,%edx
  801bb9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bc0:	f6 c2 01             	test   $0x1,%dl
  801bc3:	74 0e                	je     801bd3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc5:	c1 ea 0c             	shr    $0xc,%edx
  801bc8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bcf:	ef 
  801bd0:	0f b7 c0             	movzwl %ax,%eax
}
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    
  801bd5:	66 90                	xchg   %ax,%ax
  801bd7:	66 90                	xchg   %ax,%ax
  801bd9:	66 90                	xchg   %ax,%ax
  801bdb:	66 90                	xchg   %ax,%ax
  801bdd:	66 90                	xchg   %ax,%ax
  801bdf:	90                   	nop

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	83 ec 10             	sub    $0x10,%esp
  801be6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801bea:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801bee:	8b 74 24 24          	mov    0x24(%esp),%esi
  801bf2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801bf6:	85 d2                	test   %edx,%edx
  801bf8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bfc:	89 34 24             	mov    %esi,(%esp)
  801bff:	89 c8                	mov    %ecx,%eax
  801c01:	75 35                	jne    801c38 <__udivdi3+0x58>
  801c03:	39 f1                	cmp    %esi,%ecx
  801c05:	0f 87 bd 00 00 00    	ja     801cc8 <__udivdi3+0xe8>
  801c0b:	85 c9                	test   %ecx,%ecx
  801c0d:	89 cd                	mov    %ecx,%ebp
  801c0f:	75 0b                	jne    801c1c <__udivdi3+0x3c>
  801c11:	b8 01 00 00 00       	mov    $0x1,%eax
  801c16:	31 d2                	xor    %edx,%edx
  801c18:	f7 f1                	div    %ecx
  801c1a:	89 c5                	mov    %eax,%ebp
  801c1c:	89 f0                	mov    %esi,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f5                	div    %ebp
  801c22:	89 c6                	mov    %eax,%esi
  801c24:	89 f8                	mov    %edi,%eax
  801c26:	f7 f5                	div    %ebp
  801c28:	89 f2                	mov    %esi,%edx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	5e                   	pop    %esi
  801c2e:	5f                   	pop    %edi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    
  801c31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c38:	3b 14 24             	cmp    (%esp),%edx
  801c3b:	77 7b                	ja     801cb8 <__udivdi3+0xd8>
  801c3d:	0f bd f2             	bsr    %edx,%esi
  801c40:	83 f6 1f             	xor    $0x1f,%esi
  801c43:	0f 84 97 00 00 00    	je     801ce0 <__udivdi3+0x100>
  801c49:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c4e:	89 d7                	mov    %edx,%edi
  801c50:	89 f1                	mov    %esi,%ecx
  801c52:	29 f5                	sub    %esi,%ebp
  801c54:	d3 e7                	shl    %cl,%edi
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	89 e9                	mov    %ebp,%ecx
  801c5a:	d3 ea                	shr    %cl,%edx
  801c5c:	89 f1                	mov    %esi,%ecx
  801c5e:	09 fa                	or     %edi,%edx
  801c60:	8b 3c 24             	mov    (%esp),%edi
  801c63:	d3 e0                	shl    %cl,%eax
  801c65:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c69:	89 e9                	mov    %ebp,%ecx
  801c6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c73:	89 fa                	mov    %edi,%edx
  801c75:	d3 ea                	shr    %cl,%edx
  801c77:	89 f1                	mov    %esi,%ecx
  801c79:	d3 e7                	shl    %cl,%edi
  801c7b:	89 e9                	mov    %ebp,%ecx
  801c7d:	d3 e8                	shr    %cl,%eax
  801c7f:	09 c7                	or     %eax,%edi
  801c81:	89 f8                	mov    %edi,%eax
  801c83:	f7 74 24 08          	divl   0x8(%esp)
  801c87:	89 d5                	mov    %edx,%ebp
  801c89:	89 c7                	mov    %eax,%edi
  801c8b:	f7 64 24 0c          	mull   0xc(%esp)
  801c8f:	39 d5                	cmp    %edx,%ebp
  801c91:	89 14 24             	mov    %edx,(%esp)
  801c94:	72 11                	jb     801ca7 <__udivdi3+0xc7>
  801c96:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c9a:	89 f1                	mov    %esi,%ecx
  801c9c:	d3 e2                	shl    %cl,%edx
  801c9e:	39 c2                	cmp    %eax,%edx
  801ca0:	73 5e                	jae    801d00 <__udivdi3+0x120>
  801ca2:	3b 2c 24             	cmp    (%esp),%ebp
  801ca5:	75 59                	jne    801d00 <__udivdi3+0x120>
  801ca7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801caa:	31 f6                	xor    %esi,%esi
  801cac:	89 f2                	mov    %esi,%edx
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	31 f6                	xor    %esi,%esi
  801cba:	31 c0                	xor    %eax,%eax
  801cbc:	89 f2                	mov    %esi,%edx
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    
  801cc5:	8d 76 00             	lea    0x0(%esi),%esi
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	31 f6                	xor    %esi,%esi
  801ccc:	89 f8                	mov    %edi,%eax
  801cce:	f7 f1                	div    %ecx
  801cd0:	89 f2                	mov    %esi,%edx
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ce4:	76 0b                	jbe    801cf1 <__udivdi3+0x111>
  801ce6:	31 c0                	xor    %eax,%eax
  801ce8:	3b 14 24             	cmp    (%esp),%edx
  801ceb:	0f 83 37 ff ff ff    	jae    801c28 <__udivdi3+0x48>
  801cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf6:	e9 2d ff ff ff       	jmp    801c28 <__udivdi3+0x48>
  801cfb:	90                   	nop
  801cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 f8                	mov    %edi,%eax
  801d02:	31 f6                	xor    %esi,%esi
  801d04:	e9 1f ff ff ff       	jmp    801c28 <__udivdi3+0x48>
  801d09:	66 90                	xchg   %ax,%ax
  801d0b:	66 90                	xchg   %ax,%ax
  801d0d:	66 90                	xchg   %ax,%ax
  801d0f:	90                   	nop

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	83 ec 20             	sub    $0x20,%esp
  801d16:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d1a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d22:	89 c6                	mov    %eax,%esi
  801d24:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d28:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d2c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d30:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d34:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d38:	89 74 24 18          	mov    %esi,0x18(%esp)
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	89 c2                	mov    %eax,%edx
  801d40:	75 1e                	jne    801d60 <__umoddi3+0x50>
  801d42:	39 f7                	cmp    %esi,%edi
  801d44:	76 52                	jbe    801d98 <__umoddi3+0x88>
  801d46:	89 c8                	mov    %ecx,%eax
  801d48:	89 f2                	mov    %esi,%edx
  801d4a:	f7 f7                	div    %edi
  801d4c:	89 d0                	mov    %edx,%eax
  801d4e:	31 d2                	xor    %edx,%edx
  801d50:	83 c4 20             	add    $0x20,%esp
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    
  801d57:	89 f6                	mov    %esi,%esi
  801d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d60:	39 f0                	cmp    %esi,%eax
  801d62:	77 5c                	ja     801dc0 <__umoddi3+0xb0>
  801d64:	0f bd e8             	bsr    %eax,%ebp
  801d67:	83 f5 1f             	xor    $0x1f,%ebp
  801d6a:	75 64                	jne    801dd0 <__umoddi3+0xc0>
  801d6c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d70:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d74:	0f 86 f6 00 00 00    	jbe    801e70 <__umoddi3+0x160>
  801d7a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d7e:	0f 82 ec 00 00 00    	jb     801e70 <__umoddi3+0x160>
  801d84:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d88:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d8c:	83 c4 20             	add    $0x20,%esp
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
  801d93:	90                   	nop
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	85 ff                	test   %edi,%edi
  801d9a:	89 fd                	mov    %edi,%ebp
  801d9c:	75 0b                	jne    801da9 <__umoddi3+0x99>
  801d9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f7                	div    %edi
  801da7:	89 c5                	mov    %eax,%ebp
  801da9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801dad:	31 d2                	xor    %edx,%edx
  801daf:	f7 f5                	div    %ebp
  801db1:	89 c8                	mov    %ecx,%eax
  801db3:	f7 f5                	div    %ebp
  801db5:	eb 95                	jmp    801d4c <__umoddi3+0x3c>
  801db7:	89 f6                	mov    %esi,%esi
  801db9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	83 c4 20             	add    $0x20,%esp
  801dc7:	5e                   	pop    %esi
  801dc8:	5f                   	pop    %edi
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    
  801dcb:	90                   	nop
  801dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	b8 20 00 00 00       	mov    $0x20,%eax
  801dd5:	89 e9                	mov    %ebp,%ecx
  801dd7:	29 e8                	sub    %ebp,%eax
  801dd9:	d3 e2                	shl    %cl,%edx
  801ddb:	89 c7                	mov    %eax,%edi
  801ddd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801de1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801de5:	89 f9                	mov    %edi,%ecx
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 c1                	mov    %eax,%ecx
  801deb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801def:	09 d1                	or     %edx,%ecx
  801df1:	89 fa                	mov    %edi,%edx
  801df3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801df7:	89 e9                	mov    %ebp,%ecx
  801df9:	d3 e0                	shl    %cl,%eax
  801dfb:	89 f9                	mov    %edi,%ecx
  801dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e01:	89 f0                	mov    %esi,%eax
  801e03:	d3 e8                	shr    %cl,%eax
  801e05:	89 e9                	mov    %ebp,%ecx
  801e07:	89 c7                	mov    %eax,%edi
  801e09:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e0d:	d3 e6                	shl    %cl,%esi
  801e0f:	89 d1                	mov    %edx,%ecx
  801e11:	89 fa                	mov    %edi,%edx
  801e13:	d3 e8                	shr    %cl,%eax
  801e15:	89 e9                	mov    %ebp,%ecx
  801e17:	09 f0                	or     %esi,%eax
  801e19:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e1d:	f7 74 24 10          	divl   0x10(%esp)
  801e21:	d3 e6                	shl    %cl,%esi
  801e23:	89 d1                	mov    %edx,%ecx
  801e25:	f7 64 24 0c          	mull   0xc(%esp)
  801e29:	39 d1                	cmp    %edx,%ecx
  801e2b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e2f:	89 d7                	mov    %edx,%edi
  801e31:	89 c6                	mov    %eax,%esi
  801e33:	72 0a                	jb     801e3f <__umoddi3+0x12f>
  801e35:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801e39:	73 10                	jae    801e4b <__umoddi3+0x13b>
  801e3b:	39 d1                	cmp    %edx,%ecx
  801e3d:	75 0c                	jne    801e4b <__umoddi3+0x13b>
  801e3f:	89 d7                	mov    %edx,%edi
  801e41:	89 c6                	mov    %eax,%esi
  801e43:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801e47:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801e4b:	89 ca                	mov    %ecx,%edx
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e53:	29 f0                	sub    %esi,%eax
  801e55:	19 fa                	sbb    %edi,%edx
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e5e:	89 d7                	mov    %edx,%edi
  801e60:	d3 e7                	shl    %cl,%edi
  801e62:	89 e9                	mov    %ebp,%ecx
  801e64:	09 f8                	or     %edi,%eax
  801e66:	d3 ea                	shr    %cl,%edx
  801e68:	83 c4 20             	add    $0x20,%esp
  801e6b:	5e                   	pop    %esi
  801e6c:	5f                   	pop    %edi
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    
  801e6f:	90                   	nop
  801e70:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e74:	29 f9                	sub    %edi,%ecx
  801e76:	19 c6                	sbb    %eax,%esi
  801e78:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e7c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e80:	e9 ff fe ff ff       	jmp    801d84 <__umoddi3+0x74>
