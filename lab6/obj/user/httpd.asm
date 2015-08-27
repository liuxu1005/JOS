
obj/user/httpd.debug:     file format elf32-i386


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
  80002c:	e8 bf 07 00 00       	call   8007f0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 40 2d 80 00       	push   $0x802d40
  80003f:	e8 e5 08 00 00       	call   800929 <cprintf>
	exit();
  800044:	e8 ed 07 00 00       	call   800836 <exit>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <send_error>:
	return 0;
}

static int
send_error(struct http_request *req, int code)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	81 ec 0c 02 00 00    	sub    $0x20c,%esp
	char buf[512];
	int r;

	struct error_messages *e = errors;
  80005a:	b9 00 40 80 00       	mov    $0x804000,%ecx
	while (e->code != 0 && e->msg != 0) {
  80005f:	eb 03                	jmp    800064 <send_error+0x16>
		if (e->code == code)
			break;
		e++;
  800061:	83 c1 08             	add    $0x8,%ecx
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  800064:	8b 19                	mov    (%ecx),%ebx
  800066:	85 db                	test   %ebx,%ebx
  800068:	74 0c                	je     800076 <send_error+0x28>
		if (e->code == code)
  80006a:	83 79 04 00          	cmpl   $0x0,0x4(%ecx)
  80006e:	74 0d                	je     80007d <send_error+0x2f>
  800070:	39 d3                	cmp    %edx,%ebx
  800072:	75 ed                	jne    800061 <send_error+0x13>
  800074:	eb 07                	jmp    80007d <send_error+0x2f>
			break;
		e++;
	}

	if (e->code == 0)
		return -1;
  800076:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80007b:	eb 3d                	jmp    8000ba <send_error+0x6c>
  80007d:	89 c6                	mov    %eax,%esi

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  80007f:	8b 41 04             	mov    0x4(%ecx),%eax
  800082:	83 ec 04             	sub    $0x4,%esp
  800085:	50                   	push   %eax
  800086:	53                   	push   %ebx
  800087:	50                   	push   %eax
  800088:	53                   	push   %ebx
  800089:	68 f4 2d 80 00       	push   $0x802df4
  80008e:	68 00 02 00 00       	push   $0x200
  800093:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  800099:	57                   	push   %edi
  80009a:	e8 be 0d 00 00       	call   800e5d <snprintf>
  80009f:	89 c3                	mov    %eax,%ebx
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  8000a1:	83 c4 1c             	add    $0x1c,%esp
  8000a4:	50                   	push   %eax
  8000a5:	57                   	push   %edi
  8000a6:	ff 36                	pushl  (%esi)
  8000a8:	e8 59 18 00 00       	call   801906 <write>
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	39 c3                	cmp    %eax,%ebx
  8000b2:	0f 95 c0             	setne  %al
  8000b5:	0f b6 c0             	movzbl %al,%eax
  8000b8:	f7 d8                	neg    %eax
		return -1;

	return 0;
}
  8000ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
  8000c8:	81 ec 50 07 00 00    	sub    $0x750,%esp
  8000ce:	89 c1                	mov    %eax,%ecx
  8000d0:	89 85 b4 f8 ff ff    	mov    %eax,-0x74c(%ebp)
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000d6:	68 00 02 00 00       	push   $0x200
  8000db:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  8000e1:	50                   	push   %eax
  8000e2:	51                   	push   %ecx
  8000e3:	e8 48 17 00 00       	call   801830 <read>
  8000e8:	83 c4 10             	add    $0x10,%esp
  8000eb:	85 c0                	test   %eax,%eax
  8000ed:	79 17                	jns    800106 <handle_client+0x44>
			panic("failed to read");
  8000ef:	83 ec 04             	sub    $0x4,%esp
  8000f2:	68 44 2d 80 00       	push   $0x802d44
  8000f7:	68 2a 01 00 00       	push   $0x12a
  8000fc:	68 53 2d 80 00       	push   $0x802d53
  800101:	e8 4a 07 00 00       	call   800850 <_panic>

		memset(req, 0, sizeof(req));
  800106:	83 ec 04             	sub    $0x4,%esp
  800109:	6a 04                	push   $0x4
  80010b:	6a 00                	push   $0x0
  80010d:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800110:	50                   	push   %eax
  800111:	e8 df 0e 00 00       	call   800ff5 <memset>

		req->sock = sock;
  800116:	8b 85 b4 f8 ff ff    	mov    -0x74c(%ebp),%eax
  80011c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  80011f:	83 c4 0c             	add    $0xc,%esp
  800122:	6a 04                	push   $0x4
  800124:	68 60 2d 80 00       	push   $0x802d60
  800129:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  80012f:	50                   	push   %eax
  800130:	e8 4b 0e 00 00       	call   800f80 <strncmp>
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	85 c0                	test   %eax,%eax
  80013a:	0f 85 66 02 00 00    	jne    8003a6 <handle_client+0x2e4>
  800140:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  800146:	eb 03                	jmp    80014b <handle_client+0x89>
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
  800148:	83 c3 01             	add    $0x1,%ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  80014b:	f6 03 df             	testb  $0xdf,(%ebx)
  80014e:	75 f8                	jne    800148 <handle_client+0x86>
		request++;
	url_len = request - url;
  800150:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
  800156:	89 de                	mov    %ebx,%esi
  800158:	29 fe                	sub    %edi,%esi

	req->url = malloc(url_len + 1);
  80015a:	83 ec 0c             	sub    $0xc,%esp
  80015d:	8d 46 01             	lea    0x1(%esi),%eax
  800160:	50                   	push   %eax
  800161:	e8 3a 21 00 00       	call   8022a0 <malloc>
  800166:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  800169:	83 c4 0c             	add    $0xc,%esp
  80016c:	56                   	push   %esi
  80016d:	57                   	push   %edi
  80016e:	50                   	push   %eax
  80016f:	e8 ce 0e 00 00       	call   801042 <memmove>
	req->url[url_len] = '\0';
  800174:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800177:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)

	// skip space
	request++;
  80017b:	83 c3 01             	add    $0x1,%ebx
  80017e:	83 c4 10             	add    $0x10,%esp
  800181:	89 d8                	mov    %ebx,%eax
  800183:	eb 03                	jmp    800188 <handle_client+0xc6>

	version = request;
	while (*request && *request != '\n')
		request++;
  800185:	83 c0 01             	add    $0x1,%eax

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  800188:	0f b6 10             	movzbl (%eax),%edx
  80018b:	80 fa 0a             	cmp    $0xa,%dl
  80018e:	74 04                	je     800194 <handle_client+0xd2>
  800190:	84 d2                	test   %dl,%dl
  800192:	75 f1                	jne    800185 <handle_client+0xc3>
		request++;
	version_len = request - version;
  800194:	29 d8                	sub    %ebx,%eax
  800196:	89 c6                	mov    %eax,%esi

	req->version = malloc(version_len + 1);
  800198:	83 ec 0c             	sub    $0xc,%esp
  80019b:	8d 40 01             	lea    0x1(%eax),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 fc 20 00 00       	call   8022a0 <malloc>
  8001a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  8001a7:	83 c4 0c             	add    $0xc,%esp
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	50                   	push   %eax
  8001ad:	e8 90 0e 00 00       	call   801042 <memmove>
	req->version[version_len] = '\0';
  8001b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001b5:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)
	// set file_size to the size of the file

	// LAB 6: Your code here.
	//panic("send_file not implemented");

        if ((fd = open(req->url, O_RDONLY)) < 0) {
  8001b9:	83 c4 08             	add    $0x8,%esp
  8001bc:	6a 00                	push   $0x0
  8001be:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c1:	e8 17 1b 00 00       	call   801cdd <open>
  8001c6:	89 c6                	mov    %eax,%esi
  8001c8:	83 c4 10             	add    $0x10,%esp
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	79 23                	jns    8001f2 <handle_client+0x130>
		cprintf("failed to read %e", fd);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	50                   	push   %eax
  8001d3:	68 65 2d 80 00       	push   $0x802d65
  8001d8:	e8 4c 07 00 00       	call   800929 <cprintf>
                send_error(req, 404);
  8001dd:	ba 94 01 00 00       	mov    $0x194,%edx
  8001e2:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8001e5:	e8 64 fe ff ff       	call   80004e <send_error>
  8001ea:	83 c4 10             	add    $0x10,%esp
  8001ed:	e9 82 01 00 00       	jmp    800374 <handle_client+0x2b2>
                goto end;
        }
        struct Stat filestat;
        if ((r = fstat(fd, &filestat)) < 0) {
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	8d 85 c4 f8 ff ff    	lea    -0x73c(%ebp),%eax
  8001fb:	50                   	push   %eax
  8001fc:	56                   	push   %esi
  8001fd:	e8 42 18 00 00       	call   801a44 <fstat>
  800202:	83 c4 10             	add    $0x10,%esp
  800205:	85 c0                	test   %eax,%eax
  800207:	0f 88 67 01 00 00    	js     800374 <handle_client+0x2b2>
		//cprintf("read file stat error\n");
                goto end;
                 
        }
        if (filestat.st_isdir) {
  80020d:	83 bd 48 f9 ff ff 00 	cmpl   $0x0,-0x6b8(%ebp)
  800214:	74 12                	je     800228 <handle_client+0x166>
		//cprintf("going to send directory error\n");
                send_error(req, 404);
  800216:	ba 94 01 00 00       	mov    $0x194,%edx
  80021b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80021e:	e8 2b fe ff ff       	call   80004e <send_error>
  800223:	e9 4c 01 00 00       	jmp    800374 <handle_client+0x2b2>
                goto end;
        }
        file_size = filestat.st_size;
  800228:	8b bd 44 f9 ff ff    	mov    -0x6bc(%ebp),%edi
}

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
  80022e:	bb 10 40 80 00       	mov    $0x804010,%ebx
  800233:	eb 03                	jmp    800238 <handle_client+0x176>
	while (h->code != 0 && h->header!= 0) {
		if (h->code == code)
			break;
		h++;
  800235:	83 c3 08             	add    $0x8,%ebx

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
  800238:	8b 03                	mov    (%ebx),%eax
  80023a:	85 c0                	test   %eax,%eax
  80023c:	0f 84 32 01 00 00    	je     800374 <handle_client+0x2b2>
		if (h->code == code)
  800242:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  800246:	0f 84 69 01 00 00    	je     8003b5 <handle_client+0x2f3>
  80024c:	3d c8 00 00 00       	cmp    $0xc8,%eax
  800251:	75 e2                	jne    800235 <handle_client+0x173>
  800253:	e9 5d 01 00 00       	jmp    8003b5 <handle_client+0x2f3>
	if (h->code == 0)
		return -1;

	int len = strlen(h->header);
	if (write(req->sock, h->header, len) != len) {
		die("Failed to send bytes to client");
  800258:	b8 70 2e 80 00       	mov    $0x802e70,%eax
  80025d:	e8 d1 fd ff ff       	call   800033 <die>
  800262:	e9 7d 01 00 00       	jmp    8003e4 <handle_client+0x322>
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
	if (r > 63)
		panic("buffer too small!");
  800267:	83 ec 04             	sub    $0x4,%esp
  80026a:	68 77 2d 80 00       	push   $0x802d77
  80026f:	6a 70                	push   $0x70
  800271:	68 53 2d 80 00       	push   $0x802d53
  800276:	e8 d5 05 00 00       	call   800850 <_panic>

	if (write(req->sock, buf, r) != r)
  80027b:	83 ec 04             	sub    $0x4,%esp
  80027e:	53                   	push   %ebx
  80027f:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  800285:	50                   	push   %eax
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	e8 78 16 00 00       	call   801906 <write>
  80028e:	83 c4 10             	add    $0x10,%esp
        }
        file_size = filestat.st_size;
	if ((r = send_header(req, 200)) < 0)
		goto end;

	if ((r = send_size(req, file_size)) < 0)
  800291:	39 c3                	cmp    %eax,%ebx
  800293:	0f 85 db 00 00 00    	jne    800374 <handle_client+0x2b2>

	type = mime_type(req->url);
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
  800299:	68 89 2d 80 00       	push   $0x802d89
  80029e:	68 93 2d 80 00       	push   $0x802d93
  8002a3:	68 80 00 00 00       	push   $0x80
  8002a8:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  8002ae:	50                   	push   %eax
  8002af:	e8 a9 0b 00 00       	call   800e5d <snprintf>
  8002b4:	89 c3                	mov    %eax,%ebx
	if (r > 127)
  8002b6:	83 c4 10             	add    $0x10,%esp
  8002b9:	83 f8 7f             	cmp    $0x7f,%eax
  8002bc:	7e 17                	jle    8002d5 <handle_client+0x213>
		panic("buffer too small!");
  8002be:	83 ec 04             	sub    $0x4,%esp
  8002c1:	68 77 2d 80 00       	push   $0x802d77
  8002c6:	68 8c 00 00 00       	push   $0x8c
  8002cb:	68 53 2d 80 00       	push   $0x802d53
  8002d0:	e8 7b 05 00 00       	call   800850 <_panic>

	if (write(req->sock, buf, r) != r)
  8002d5:	83 ec 04             	sub    $0x4,%esp
  8002d8:	50                   	push   %eax
  8002d9:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  8002df:	50                   	push   %eax
  8002e0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e3:	e8 1e 16 00 00       	call   801906 <write>
  8002e8:	83 c4 10             	add    $0x10,%esp
		goto end;

	if ((r = send_size(req, file_size)) < 0)
		goto end;

	if ((r = send_content_type(req)) < 0)
  8002eb:	39 c3                	cmp    %eax,%ebx
  8002ed:	0f 85 81 00 00 00    	jne    800374 <handle_client+0x2b2>

static int
send_header_fin(struct http_request *req)
{
	const char *fin = "\r\n";
	int fin_len = strlen(fin);
  8002f3:	83 ec 0c             	sub    $0xc,%esp
  8002f6:	68 b9 2d 80 00       	push   $0x802db9
  8002fb:	e8 77 0b 00 00       	call   800e77 <strlen>
  800300:	89 c3                	mov    %eax,%ebx

	if (write(req->sock, fin, fin_len) != fin_len)
  800302:	83 c4 0c             	add    $0xc,%esp
  800305:	50                   	push   %eax
  800306:	68 b9 2d 80 00       	push   $0x802db9
  80030b:	ff 75 dc             	pushl  -0x24(%ebp)
  80030e:	e8 f3 15 00 00       	call   801906 <write>
  800313:	83 c4 10             	add    $0x10,%esp
		goto end;

	if ((r = send_content_type(req)) < 0)
		goto end;

	if ((r = send_header_fin(req)) < 0)
  800316:	39 c3                	cmp    %eax,%ebx
  800318:	75 5a                	jne    800374 <handle_client+0x2b2>
        int r;
       
        
        struct Stat filestat;

        if ((r = fstat(fd, &filestat)) < 0) {
  80031a:	83 ec 08             	sub    $0x8,%esp
  80031d:	8d 85 50 f9 ff ff    	lea    -0x6b0(%ebp),%eax
  800323:	50                   	push   %eax
  800324:	56                   	push   %esi
  800325:	e8 1a 17 00 00       	call   801a44 <fstat>
  80032a:	83 c4 10             	add    $0x10,%esp
  80032d:	85 c0                	test   %eax,%eax
  80032f:	78 43                	js     800374 <handle_client+0x2b2>
		//cprintf("read file stat error\n");
                return r; 
        }
        size_t sizeto = filestat.st_size;
  800331:	8b bd d0 f9 ff ff    	mov    -0x630(%ebp),%edi
  800337:	eb 37                	jmp    800370 <handle_client+0x2ae>
        while(sizeto > 0) {
                size_t tmp = sizeto > 1024 ? 1024 : sizeto;
  800339:	81 ff 00 04 00 00    	cmp    $0x400,%edi
  80033f:	bb 00 04 00 00       	mov    $0x400,%ebx
  800344:	0f 46 df             	cmovbe %edi,%ebx
                read(fd, buf, tmp);
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	53                   	push   %ebx
  80034b:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  800351:	50                   	push   %eax
  800352:	56                   	push   %esi
  800353:	e8 d8 14 00 00       	call   801830 <read>
                write(req->sock, buf, tmp);
  800358:	83 c4 0c             	add    $0xc,%esp
  80035b:	53                   	push   %ebx
  80035c:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  800362:	50                   	push   %eax
  800363:	ff 75 dc             	pushl  -0x24(%ebp)
  800366:	e8 9b 15 00 00       	call   801906 <write>
                sizeto -= tmp; 
  80036b:	29 df                	sub    %ebx,%edi
  80036d:	83 c4 10             	add    $0x10,%esp
        if ((r = fstat(fd, &filestat)) < 0) {
		//cprintf("read file stat error\n");
                return r; 
        }
        size_t sizeto = filestat.st_size;
        while(sizeto > 0) {
  800370:	85 ff                	test   %edi,%edi
  800372:	75 c5                	jne    800339 <handle_client+0x277>
		goto end;

	r = send_data(req, fd);

end:
	close(fd);
  800374:	83 ec 0c             	sub    $0xc,%esp
  800377:	56                   	push   %esi
  800378:	e8 73 13 00 00       	call   8016f0 <close>
  80037d:	83 c4 10             	add    $0x10,%esp
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  800380:	83 ec 0c             	sub    $0xc,%esp
  800383:	ff 75 e0             	pushl  -0x20(%ebp)
  800386:	e8 67 1e 00 00       	call   8021f2 <free>
	free(req->version);
  80038b:	83 c4 04             	add    $0x4,%esp
  80038e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800391:	e8 5c 1e 00 00       	call   8021f2 <free>

		// no keep alive
		break;
	}

	close(sock);
  800396:	83 c4 04             	add    $0x4,%esp
  800399:	ff b5 b4 f8 ff ff    	pushl  -0x74c(%ebp)
  80039f:	e8 4c 13 00 00       	call   8016f0 <close>
  8003a4:	eb 65                	jmp    80040b <handle_client+0x349>

		req->sock = sock;

		r = http_request_parse(req, buffer);
		if (r == -E_BAD_REQ)
			send_error(req, 400);
  8003a6:	ba 90 01 00 00       	mov    $0x190,%edx
  8003ab:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8003ae:	e8 9b fc ff ff       	call   80004e <send_error>
  8003b3:	eb cb                	jmp    800380 <handle_client+0x2be>
	}

	if (h->code == 0)
		return -1;

	int len = strlen(h->header);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 73 04             	pushl  0x4(%ebx)
  8003bb:	e8 b7 0a 00 00       	call   800e77 <strlen>
	if (write(req->sock, h->header, len) != len) {
  8003c0:	83 c4 0c             	add    $0xc,%esp
  8003c3:	89 85 b0 f8 ff ff    	mov    %eax,-0x750(%ebp)
  8003c9:	50                   	push   %eax
  8003ca:	ff 73 04             	pushl  0x4(%ebx)
  8003cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d0:	e8 31 15 00 00       	call   801906 <write>
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	39 85 b0 f8 ff ff    	cmp    %eax,-0x750(%ebp)
  8003de:	0f 85 74 fe ff ff    	jne    800258 <handle_client+0x196>
send_size(struct http_request *req, off_t size)
{
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
  8003e4:	57                   	push   %edi
  8003e5:	68 a6 2d 80 00       	push   $0x802da6
  8003ea:	6a 40                	push   $0x40
  8003ec:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  8003f2:	50                   	push   %eax
  8003f3:	e8 65 0a 00 00       	call   800e5d <snprintf>
  8003f8:	89 c3                	mov    %eax,%ebx
	if (r > 63)
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	83 f8 3f             	cmp    $0x3f,%eax
  800400:	0f 8e 75 fe ff ff    	jle    80027b <handle_client+0x1b9>
  800406:	e9 5c fe ff ff       	jmp    800267 <handle_client+0x1a5>
		// no keep alive
		break;
	}

	close(sock);
}
  80040b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80040e:	5b                   	pop    %ebx
  80040f:	5e                   	pop    %esi
  800410:	5f                   	pop    %edi
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <umain>:

void
umain(int argc, char **argv)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	57                   	push   %edi
  800417:	56                   	push   %esi
  800418:	53                   	push   %ebx
  800419:	83 ec 40             	sub    $0x40,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  80041c:	c7 05 20 40 80 00 bc 	movl   $0x802dbc,0x804020
  800423:	2d 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800426:	6a 06                	push   $0x6
  800428:	6a 01                	push   $0x1
  80042a:	6a 02                	push   $0x2
  80042c:	e8 47 1b 00 00       	call   801f78 <socket>
  800431:	89 c6                	mov    %eax,%esi
  800433:	83 c4 10             	add    $0x10,%esp
  800436:	85 c0                	test   %eax,%eax
  800438:	79 0a                	jns    800444 <umain+0x31>
		die("Failed to create socket");
  80043a:	b8 c3 2d 80 00       	mov    $0x802dc3,%eax
  80043f:	e8 ef fb ff ff       	call   800033 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	6a 10                	push   $0x10
  800449:	6a 00                	push   $0x0
  80044b:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80044e:	53                   	push   %ebx
  80044f:	e8 a1 0b 00 00       	call   800ff5 <memset>
	server.sin_family = AF_INET;			// Internet/IP
  800454:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  800458:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045f:	e8 45 01 00 00       	call   8005a9 <htonl>
  800464:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  800467:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  80046e:	e8 1c 01 00 00       	call   80058f <htons>
  800473:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  800477:	83 c4 0c             	add    $0xc,%esp
  80047a:	6a 10                	push   $0x10
  80047c:	53                   	push   %ebx
  80047d:	56                   	push   %esi
  80047e:	e8 5b 1a 00 00       	call   801ede <bind>
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	85 c0                	test   %eax,%eax
  800488:	79 0a                	jns    800494 <umain+0x81>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  80048a:	b8 90 2e 80 00       	mov    $0x802e90,%eax
  80048f:	e8 9f fb ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	6a 05                	push   $0x5
  800499:	56                   	push   %esi
  80049a:	e8 b4 1a 00 00       	call   801f53 <listen>
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	79 0a                	jns    8004b0 <umain+0x9d>
		die("Failed to listen on server socket");
  8004a6:	b8 b4 2e 80 00       	mov    $0x802eb4,%eax
  8004ab:	e8 83 fb ff ff       	call   800033 <die>

	cprintf("Waiting for http connections...\n");
  8004b0:	83 ec 0c             	sub    $0xc,%esp
  8004b3:	68 d8 2e 80 00       	push   $0x802ed8
  8004b8:	e8 6c 04 00 00       	call   800929 <cprintf>
  8004bd:	83 c4 10             	add    $0x10,%esp

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  8004c0:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  8004c3:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  8004ca:	83 ec 04             	sub    $0x4,%esp
  8004cd:	57                   	push   %edi
  8004ce:	8d 45 c8             	lea    -0x38(%ebp),%eax
  8004d1:	50                   	push   %eax
  8004d2:	56                   	push   %esi
  8004d3:	e8 cf 19 00 00       	call   801ea7 <accept>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	79 0a                	jns    8004eb <umain+0xd8>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  8004e1:	b8 fc 2e 80 00       	mov    $0x802efc,%eax
  8004e6:	e8 48 fb ff ff       	call   800033 <die>
		}
		handle_client(clientsock);
  8004eb:	89 d8                	mov    %ebx,%eax
  8004ed:	e8 d0 fb ff ff       	call   8000c2 <handle_client>
	}
  8004f2:	eb cf                	jmp    8004c3 <umain+0xb0>

008004f4 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	57                   	push   %edi
  8004f8:	56                   	push   %esi
  8004f9:	53                   	push   %ebx
  8004fa:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800503:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  800506:	c7 45 e0 00 50 80 00 	movl   $0x805000,-0x20(%ebp)
  80050d:	0f b6 1f             	movzbl (%edi),%ebx
  800510:	b9 00 00 00 00       	mov    $0x0,%ecx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800515:	0f b6 d3             	movzbl %bl,%edx
  800518:	8d 04 92             	lea    (%edx,%edx,4),%eax
  80051b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
  80051e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800521:	66 c1 e8 0b          	shr    $0xb,%ax
  800525:	89 c2                	mov    %eax,%edx
  800527:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80052a:	01 c0                	add    %eax,%eax
  80052c:	29 c3                	sub    %eax,%ebx
  80052e:	89 d8                	mov    %ebx,%eax
      *ap /= (u8_t)10;
  800530:	89 d3                	mov    %edx,%ebx
      inv[i++] = '0' + rem;
  800532:	8d 71 01             	lea    0x1(%ecx),%esi
  800535:	0f b6 c9             	movzbl %cl,%ecx
  800538:	83 c0 30             	add    $0x30,%eax
  80053b:	88 44 0d ed          	mov    %al,-0x13(%ebp,%ecx,1)
  80053f:	89 f1                	mov    %esi,%ecx
    } while(*ap);
  800541:	84 d2                	test   %dl,%dl
  800543:	75 d0                	jne    800515 <inet_ntoa+0x21>
  800545:	89 f2                	mov    %esi,%edx
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  800547:	89 f3                	mov    %esi,%ebx
  800549:	c6 07 00             	movb   $0x0,(%edi)
  80054c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054f:	eb 0d                	jmp    80055e <inet_ntoa+0x6a>
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  800551:	0f b6 c2             	movzbl %dl,%eax
  800554:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  800559:	88 01                	mov    %al,(%ecx)
  80055b:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80055e:	83 ea 01             	sub    $0x1,%edx
  800561:	80 fa ff             	cmp    $0xff,%dl
  800564:	75 eb                	jne    800551 <inet_ntoa+0x5d>
  800566:	0f b6 db             	movzbl %bl,%ebx
  800569:	03 5d e0             	add    -0x20(%ebp),%ebx
      *rp++ = inv[i];
    *rp++ = '.';
  80056c:	8d 43 01             	lea    0x1(%ebx),%eax
  80056f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800572:	c6 03 2e             	movb   $0x2e,(%ebx)
    ap++;
  800575:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800578:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80057b:	39 c7                	cmp    %eax,%edi
  80057d:	75 8e                	jne    80050d <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  80057f:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  800582:	b8 00 50 80 00       	mov    $0x805000,%eax
  800587:	83 c4 14             	add    $0x14,%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5e                   	pop    %esi
  80058c:	5f                   	pop    %edi
  80058d:	5d                   	pop    %ebp
  80058e:	c3                   	ret    

0080058f <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800592:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800596:	66 c1 c0 08          	rol    $0x8,%ax
}
  80059a:	5d                   	pop    %ebp
  80059b:	c3                   	ret    

0080059c <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80059c:	55                   	push   %ebp
  80059d:	89 e5                	mov    %esp,%ebp
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  80059f:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8005a3:	66 c1 c0 08          	rol    $0x8,%ax
 */
u16_t
ntohs(u16_t n)
{
  return htons(n);
}
  8005a7:	5d                   	pop    %ebp
  8005a8:	c3                   	ret    

008005a9 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8005a9:	55                   	push   %ebp
  8005aa:	89 e5                	mov    %esp,%ebp
  8005ac:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8005af:	89 d1                	mov    %edx,%ecx
  8005b1:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8005b4:	89 d0                	mov    %edx,%eax
  8005b6:	c1 e0 18             	shl    $0x18,%eax
  8005b9:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8005bb:	89 d1                	mov    %edx,%ecx
  8005bd:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8005c3:	c1 e1 08             	shl    $0x8,%ecx
  8005c6:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  8005c8:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8005ce:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8005d1:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	57                   	push   %edi
  8005d9:	56                   	push   %esi
  8005da:	53                   	push   %ebx
  8005db:	83 ec 1c             	sub    $0x1c,%esp
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8005e1:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8005e4:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8005e7:	89 75 d8             	mov    %esi,-0x28(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8005ea:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ed:	80 f9 09             	cmp    $0x9,%cl
  8005f0:	0f 87 a6 01 00 00    	ja     80079c <inet_aton+0x1c7>
      return (0);
    val = 0;
    base = 10;
  8005f6:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
    if (c == '0') {
  8005fd:	83 fa 30             	cmp    $0x30,%edx
  800600:	75 2b                	jne    80062d <inet_aton+0x58>
      c = *++cp;
  800602:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  800606:	89 d1                	mov    %edx,%ecx
  800608:	83 e1 df             	and    $0xffffffdf,%ecx
  80060b:	80 f9 58             	cmp    $0x58,%cl
  80060e:	74 0f                	je     80061f <inet_aton+0x4a>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800610:	83 c0 01             	add    $0x1,%eax
  800613:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800616:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  80061d:	eb 0e                	jmp    80062d <inet_aton+0x58>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80061f:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800623:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800626:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  80062d:	83 c0 01             	add    $0x1,%eax
  800630:	bf 00 00 00 00       	mov    $0x0,%edi
  800635:	eb 03                	jmp    80063a <inet_aton+0x65>
  800637:	83 c0 01             	add    $0x1,%eax
  80063a:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  80063d:	89 d6                	mov    %edx,%esi
  80063f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800642:	80 f9 09             	cmp    $0x9,%cl
  800645:	77 0d                	ja     800654 <inet_aton+0x7f>
        val = (val * base) + (int)(c - '0');
  800647:	0f af 7d e0          	imul   -0x20(%ebp),%edi
  80064b:	8d 7c 3a d0          	lea    -0x30(%edx,%edi,1),%edi
        c = *++cp;
  80064f:	0f be 10             	movsbl (%eax),%edx
  800652:	eb e3                	jmp    800637 <inet_aton+0x62>
      } else if (base == 16 && isxdigit(c)) {
  800654:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  800658:	75 2e                	jne    800688 <inet_aton+0xb3>
  80065a:	8d 4e 9f             	lea    -0x61(%esi),%ecx
  80065d:	88 4d df             	mov    %cl,-0x21(%ebp)
  800660:	89 d1                	mov    %edx,%ecx
  800662:	83 e1 df             	and    $0xffffffdf,%ecx
  800665:	83 e9 41             	sub    $0x41,%ecx
  800668:	80 f9 05             	cmp    $0x5,%cl
  80066b:	77 21                	ja     80068e <inet_aton+0xb9>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  80066d:	c1 e7 04             	shl    $0x4,%edi
  800670:	83 c2 0a             	add    $0xa,%edx
  800673:	80 7d df 1a          	cmpb   $0x1a,-0x21(%ebp)
  800677:	19 c9                	sbb    %ecx,%ecx
  800679:	83 e1 20             	and    $0x20,%ecx
  80067c:	83 c1 41             	add    $0x41,%ecx
  80067f:	29 ca                	sub    %ecx,%edx
  800681:	09 d7                	or     %edx,%edi
        c = *++cp;
  800683:	0f be 10             	movsbl (%eax),%edx
  800686:	eb af                	jmp    800637 <inet_aton+0x62>
  800688:	89 d0                	mov    %edx,%eax
  80068a:	89 f9                	mov    %edi,%ecx
  80068c:	eb 04                	jmp    800692 <inet_aton+0xbd>
  80068e:	89 d0                	mov    %edx,%eax
  800690:	89 f9                	mov    %edi,%ecx
      } else
        break;
    }
    if (c == '.') {
  800692:	83 f8 2e             	cmp    $0x2e,%eax
  800695:	75 23                	jne    8006ba <inet_aton+0xe5>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800697:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069a:	8d 75 f0             	lea    -0x10(%ebp),%esi
  80069d:	39 f0                	cmp    %esi,%eax
  80069f:	0f 84 fe 00 00 00    	je     8007a3 <inet_aton+0x1ce>
        return (0);
      *pp++ = val;
  8006a5:	83 c0 04             	add    $0x4,%eax
  8006a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ab:	89 48 fc             	mov    %ecx,-0x4(%eax)
      c = *++cp;
  8006ae:	8d 43 01             	lea    0x1(%ebx),%eax
  8006b1:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  8006b5:	e9 30 ff ff ff       	jmp    8005ea <inet_aton+0x15>
  8006ba:	89 f9                	mov    %edi,%ecx
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006bc:	85 d2                	test   %edx,%edx
  8006be:	74 29                	je     8006e9 <inet_aton+0x114>
    return (0);
  8006c0:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006c5:	89 f3                	mov    %esi,%ebx
  8006c7:	80 fb 1f             	cmp    $0x1f,%bl
  8006ca:	0f 86 e6 00 00 00    	jbe    8007b6 <inet_aton+0x1e1>
  8006d0:	84 d2                	test   %dl,%dl
  8006d2:	0f 88 d2 00 00 00    	js     8007aa <inet_aton+0x1d5>
  8006d8:	83 fa 20             	cmp    $0x20,%edx
  8006db:	74 0c                	je     8006e9 <inet_aton+0x114>
  8006dd:	83 ea 09             	sub    $0x9,%edx
  8006e0:	83 fa 04             	cmp    $0x4,%edx
  8006e3:	0f 87 cd 00 00 00    	ja     8007b6 <inet_aton+0x1e1>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  8006e9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ef:	29 c2                	sub    %eax,%edx
  8006f1:	c1 fa 02             	sar    $0x2,%edx
  8006f4:	83 c2 01             	add    $0x1,%edx
  switch (n) {
  8006f7:	83 fa 02             	cmp    $0x2,%edx
  8006fa:	74 20                	je     80071c <inet_aton+0x147>
  8006fc:	83 fa 02             	cmp    $0x2,%edx
  8006ff:	7f 0f                	jg     800710 <inet_aton+0x13b>

  case 0:
    return (0);       /* initial nondigit */
  800701:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800706:	85 d2                	test   %edx,%edx
  800708:	0f 84 a8 00 00 00    	je     8007b6 <inet_aton+0x1e1>
  80070e:	eb 71                	jmp    800781 <inet_aton+0x1ac>
  800710:	83 fa 03             	cmp    $0x3,%edx
  800713:	74 24                	je     800739 <inet_aton+0x164>
  800715:	83 fa 04             	cmp    $0x4,%edx
  800718:	74 40                	je     80075a <inet_aton+0x185>
  80071a:	eb 65                	jmp    800781 <inet_aton+0x1ac>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  80071c:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800721:	81 f9 ff ff ff 00    	cmp    $0xffffff,%ecx
  800727:	0f 87 89 00 00 00    	ja     8007b6 <inet_aton+0x1e1>
      return (0);
    val |= parts[0] << 24;
  80072d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800730:	c1 e0 18             	shl    $0x18,%eax
  800733:	89 cf                	mov    %ecx,%edi
  800735:	09 c7                	or     %eax,%edi
    break;
  800737:	eb 48                	jmp    800781 <inet_aton+0x1ac>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800739:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80073e:	81 f9 ff ff 00 00    	cmp    $0xffff,%ecx
  800744:	77 70                	ja     8007b6 <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800746:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800749:	c1 e2 10             	shl    $0x10,%edx
  80074c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80074f:	c1 e0 18             	shl    $0x18,%eax
  800752:	09 d0                	or     %edx,%eax
  800754:	09 c8                	or     %ecx,%eax
  800756:	89 c7                	mov    %eax,%edi
    break;
  800758:	eb 27                	jmp    800781 <inet_aton+0x1ac>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80075a:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80075f:	81 f9 ff 00 00 00    	cmp    $0xff,%ecx
  800765:	77 4f                	ja     8007b6 <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800767:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80076a:	c1 e2 10             	shl    $0x10,%edx
  80076d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800770:	c1 e0 18             	shl    $0x18,%eax
  800773:	09 c2                	or     %eax,%edx
  800775:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800778:	c1 e0 08             	shl    $0x8,%eax
  80077b:	09 d0                	or     %edx,%eax
  80077d:	09 c8                	or     %ecx,%eax
  80077f:	89 c7                	mov    %eax,%edi
    break;
  }
  if (addr)
  800781:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800785:	74 2a                	je     8007b1 <inet_aton+0x1dc>
    addr->s_addr = htonl(val);
  800787:	57                   	push   %edi
  800788:	e8 1c fe ff ff       	call   8005a9 <htonl>
  80078d:	83 c4 04             	add    $0x4,%esp
  800790:	8b 75 0c             	mov    0xc(%ebp),%esi
  800793:	89 06                	mov    %eax,(%esi)
  return (1);
  800795:	b8 01 00 00 00       	mov    $0x1,%eax
  80079a:	eb 1a                	jmp    8007b6 <inet_aton+0x1e1>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	eb 13                	jmp    8007b6 <inet_aton+0x1e1>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a8:	eb 0c                	jmp    8007b6 <inet_aton+0x1e1>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007af:	eb 05                	jmp    8007b6 <inet_aton+0x1e1>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8007b1:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8007b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5f                   	pop    %edi
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  8007c4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	ff 75 08             	pushl  0x8(%ebp)
  8007cb:	e8 05 fe ff ff       	call   8005d5 <inet_aton>
  8007d0:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8007da:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  8007e3:	ff 75 08             	pushl  0x8(%ebp)
  8007e6:	e8 be fd ff ff       	call   8005a9 <htonl>
  8007eb:	83 c4 04             	add    $0x4,%esp
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8007fb:	e8 7b 0a 00 00       	call   80127b <sys_getenvid>
  800800:	25 ff 03 00 00       	and    $0x3ff,%eax
  800805:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800808:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80080d:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800812:	85 db                	test   %ebx,%ebx
  800814:	7e 07                	jle    80081d <libmain+0x2d>
		binaryname = argv[0];
  800816:	8b 06                	mov    (%esi),%eax
  800818:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	e8 ec fb ff ff       	call   800413 <umain>

	// exit gracefully
	exit();
  800827:	e8 0a 00 00 00       	call   800836 <exit>
  80082c:	83 c4 10             	add    $0x10,%esp
}
  80082f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800832:	5b                   	pop    %ebx
  800833:	5e                   	pop    %esi
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80083c:	e8 dc 0e 00 00       	call   80171d <close_all>
	sys_env_destroy(0);
  800841:	83 ec 0c             	sub    $0xc,%esp
  800844:	6a 00                	push   $0x0
  800846:	e8 ef 09 00 00       	call   80123a <sys_env_destroy>
  80084b:	83 c4 10             	add    $0x10,%esp
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	56                   	push   %esi
  800854:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800855:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800858:	8b 35 20 40 80 00    	mov    0x804020,%esi
  80085e:	e8 18 0a 00 00       	call   80127b <sys_getenvid>
  800863:	83 ec 0c             	sub    $0xc,%esp
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	ff 75 08             	pushl  0x8(%ebp)
  80086c:	56                   	push   %esi
  80086d:	50                   	push   %eax
  80086e:	68 50 2f 80 00       	push   $0x802f50
  800873:	e8 b1 00 00 00       	call   800929 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800878:	83 c4 18             	add    $0x18,%esp
  80087b:	53                   	push   %ebx
  80087c:	ff 75 10             	pushl  0x10(%ebp)
  80087f:	e8 54 00 00 00       	call   8008d8 <vcprintf>
	cprintf("\n");
  800884:	c7 04 24 ba 2d 80 00 	movl   $0x802dba,(%esp)
  80088b:	e8 99 00 00 00       	call   800929 <cprintf>
  800890:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800893:	cc                   	int3   
  800894:	eb fd                	jmp    800893 <_panic+0x43>

00800896 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	83 ec 04             	sub    $0x4,%esp
  80089d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8008a0:	8b 13                	mov    (%ebx),%edx
  8008a2:	8d 42 01             	lea    0x1(%edx),%eax
  8008a5:	89 03                	mov    %eax,(%ebx)
  8008a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8008ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008b3:	75 1a                	jne    8008cf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	68 ff 00 00 00       	push   $0xff
  8008bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8008c0:	50                   	push   %eax
  8008c1:	e8 37 09 00 00       	call   8011fd <sys_cputs>
		b->idx = 0;
  8008c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8008cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8008cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8008d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8008e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8008e8:	00 00 00 
	b.cnt = 0;
  8008eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8008f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8008f5:	ff 75 0c             	pushl  0xc(%ebp)
  8008f8:	ff 75 08             	pushl  0x8(%ebp)
  8008fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800901:	50                   	push   %eax
  800902:	68 96 08 80 00       	push   $0x800896
  800907:	e8 4f 01 00 00       	call   800a5b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80090c:	83 c4 08             	add    $0x8,%esp
  80090f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800915:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80091b:	50                   	push   %eax
  80091c:	e8 dc 08 00 00       	call   8011fd <sys_cputs>

	return b.cnt;
}
  800921:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80092f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800932:	50                   	push   %eax
  800933:	ff 75 08             	pushl  0x8(%ebp)
  800936:	e8 9d ff ff ff       	call   8008d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	83 ec 1c             	sub    $0x1c,%esp
  800946:	89 c7                	mov    %eax,%edi
  800948:	89 d6                	mov    %edx,%esi
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 d1                	mov    %edx,%ecx
  800952:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800955:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800958:	8b 45 10             	mov    0x10(%ebp),%eax
  80095b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80095e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800961:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800968:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80096b:	72 05                	jb     800972 <printnum+0x35>
  80096d:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800970:	77 3e                	ja     8009b0 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800972:	83 ec 0c             	sub    $0xc,%esp
  800975:	ff 75 18             	pushl  0x18(%ebp)
  800978:	83 eb 01             	sub    $0x1,%ebx
  80097b:	53                   	push   %ebx
  80097c:	50                   	push   %eax
  80097d:	83 ec 08             	sub    $0x8,%esp
  800980:	ff 75 e4             	pushl  -0x1c(%ebp)
  800983:	ff 75 e0             	pushl  -0x20(%ebp)
  800986:	ff 75 dc             	pushl  -0x24(%ebp)
  800989:	ff 75 d8             	pushl  -0x28(%ebp)
  80098c:	e8 df 20 00 00       	call   802a70 <__udivdi3>
  800991:	83 c4 18             	add    $0x18,%esp
  800994:	52                   	push   %edx
  800995:	50                   	push   %eax
  800996:	89 f2                	mov    %esi,%edx
  800998:	89 f8                	mov    %edi,%eax
  80099a:	e8 9e ff ff ff       	call   80093d <printnum>
  80099f:	83 c4 20             	add    $0x20,%esp
  8009a2:	eb 13                	jmp    8009b7 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8009a4:	83 ec 08             	sub    $0x8,%esp
  8009a7:	56                   	push   %esi
  8009a8:	ff 75 18             	pushl  0x18(%ebp)
  8009ab:	ff d7                	call   *%edi
  8009ad:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8009b0:	83 eb 01             	sub    $0x1,%ebx
  8009b3:	85 db                	test   %ebx,%ebx
  8009b5:	7f ed                	jg     8009a4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009b7:	83 ec 08             	sub    $0x8,%esp
  8009ba:	56                   	push   %esi
  8009bb:	83 ec 04             	sub    $0x4,%esp
  8009be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8009c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8009ca:	e8 d1 21 00 00       	call   802ba0 <__umoddi3>
  8009cf:	83 c4 14             	add    $0x14,%esp
  8009d2:	0f be 80 73 2f 80 00 	movsbl 0x802f73(%eax),%eax
  8009d9:	50                   	push   %eax
  8009da:	ff d7                	call   *%edi
  8009dc:	83 c4 10             	add    $0x10,%esp
}
  8009df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5f                   	pop    %edi
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009ea:	83 fa 01             	cmp    $0x1,%edx
  8009ed:	7e 0e                	jle    8009fd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8009ef:	8b 10                	mov    (%eax),%edx
  8009f1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8009f4:	89 08                	mov    %ecx,(%eax)
  8009f6:	8b 02                	mov    (%edx),%eax
  8009f8:	8b 52 04             	mov    0x4(%edx),%edx
  8009fb:	eb 22                	jmp    800a1f <getuint+0x38>
	else if (lflag)
  8009fd:	85 d2                	test   %edx,%edx
  8009ff:	74 10                	je     800a11 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800a01:	8b 10                	mov    (%eax),%edx
  800a03:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a06:	89 08                	mov    %ecx,(%eax)
  800a08:	8b 02                	mov    (%edx),%eax
  800a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0f:	eb 0e                	jmp    800a1f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800a11:	8b 10                	mov    (%eax),%edx
  800a13:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a16:	89 08                	mov    %ecx,(%eax)
  800a18:	8b 02                	mov    (%edx),%eax
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a27:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a2b:	8b 10                	mov    (%eax),%edx
  800a2d:	3b 50 04             	cmp    0x4(%eax),%edx
  800a30:	73 0a                	jae    800a3c <sprintputch+0x1b>
		*b->buf++ = ch;
  800a32:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a35:	89 08                	mov    %ecx,(%eax)
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	88 02                	mov    %al,(%edx)
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800a44:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a47:	50                   	push   %eax
  800a48:	ff 75 10             	pushl  0x10(%ebp)
  800a4b:	ff 75 0c             	pushl  0xc(%ebp)
  800a4e:	ff 75 08             	pushl  0x8(%ebp)
  800a51:	e8 05 00 00 00       	call   800a5b <vprintfmt>
	va_end(ap);
  800a56:	83 c4 10             	add    $0x10,%esp
}
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	83 ec 2c             	sub    $0x2c,%esp
  800a64:	8b 75 08             	mov    0x8(%ebp),%esi
  800a67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6a:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a6d:	eb 12                	jmp    800a81 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a6f:	85 c0                	test   %eax,%eax
  800a71:	0f 84 90 03 00 00    	je     800e07 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800a77:	83 ec 08             	sub    $0x8,%esp
  800a7a:	53                   	push   %ebx
  800a7b:	50                   	push   %eax
  800a7c:	ff d6                	call   *%esi
  800a7e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a81:	83 c7 01             	add    $0x1,%edi
  800a84:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a88:	83 f8 25             	cmp    $0x25,%eax
  800a8b:	75 e2                	jne    800a6f <vprintfmt+0x14>
  800a8d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800a91:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800a98:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a9f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aab:	eb 07                	jmp    800ab4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aad:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800ab0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ab4:	8d 47 01             	lea    0x1(%edi),%eax
  800ab7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800aba:	0f b6 07             	movzbl (%edi),%eax
  800abd:	0f b6 c8             	movzbl %al,%ecx
  800ac0:	83 e8 23             	sub    $0x23,%eax
  800ac3:	3c 55                	cmp    $0x55,%al
  800ac5:	0f 87 21 03 00 00    	ja     800dec <vprintfmt+0x391>
  800acb:	0f b6 c0             	movzbl %al,%eax
  800ace:	ff 24 85 c0 30 80 00 	jmp    *0x8030c0(,%eax,4)
  800ad5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ad8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800adc:	eb d6                	jmp    800ab4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ade:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ae9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800aec:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800af0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800af3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800af6:	83 fa 09             	cmp    $0x9,%edx
  800af9:	77 39                	ja     800b34 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800afb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800afe:	eb e9                	jmp    800ae9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800b00:	8b 45 14             	mov    0x14(%ebp),%eax
  800b03:	8d 48 04             	lea    0x4(%eax),%ecx
  800b06:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b09:	8b 00                	mov    (%eax),%eax
  800b0b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800b11:	eb 27                	jmp    800b3a <vprintfmt+0xdf>
  800b13:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b16:	85 c0                	test   %eax,%eax
  800b18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1d:	0f 49 c8             	cmovns %eax,%ecx
  800b20:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b26:	eb 8c                	jmp    800ab4 <vprintfmt+0x59>
  800b28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b2b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800b32:	eb 80                	jmp    800ab4 <vprintfmt+0x59>
  800b34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b37:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800b3a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b3e:	0f 89 70 ff ff ff    	jns    800ab4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800b44:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b47:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b4a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800b51:	e9 5e ff ff ff       	jmp    800ab4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b56:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b5c:	e9 53 ff ff ff       	jmp    800ab4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b61:	8b 45 14             	mov    0x14(%ebp),%eax
  800b64:	8d 50 04             	lea    0x4(%eax),%edx
  800b67:	89 55 14             	mov    %edx,0x14(%ebp)
  800b6a:	83 ec 08             	sub    $0x8,%esp
  800b6d:	53                   	push   %ebx
  800b6e:	ff 30                	pushl  (%eax)
  800b70:	ff d6                	call   *%esi
			break;
  800b72:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b78:	e9 04 ff ff ff       	jmp    800a81 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b7d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b80:	8d 50 04             	lea    0x4(%eax),%edx
  800b83:	89 55 14             	mov    %edx,0x14(%ebp)
  800b86:	8b 00                	mov    (%eax),%eax
  800b88:	99                   	cltd   
  800b89:	31 d0                	xor    %edx,%eax
  800b8b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b8d:	83 f8 0f             	cmp    $0xf,%eax
  800b90:	7f 0b                	jg     800b9d <vprintfmt+0x142>
  800b92:	8b 14 85 40 32 80 00 	mov    0x803240(,%eax,4),%edx
  800b99:	85 d2                	test   %edx,%edx
  800b9b:	75 18                	jne    800bb5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800b9d:	50                   	push   %eax
  800b9e:	68 8b 2f 80 00       	push   $0x802f8b
  800ba3:	53                   	push   %ebx
  800ba4:	56                   	push   %esi
  800ba5:	e8 94 fe ff ff       	call   800a3e <printfmt>
  800baa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800bb0:	e9 cc fe ff ff       	jmp    800a81 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800bb5:	52                   	push   %edx
  800bb6:	68 75 33 80 00       	push   $0x803375
  800bbb:	53                   	push   %ebx
  800bbc:	56                   	push   %esi
  800bbd:	e8 7c fe ff ff       	call   800a3e <printfmt>
  800bc2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bc8:	e9 b4 fe ff ff       	jmp    800a81 <vprintfmt+0x26>
  800bcd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800bd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800bd3:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800bd6:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd9:	8d 50 04             	lea    0x4(%eax),%edx
  800bdc:	89 55 14             	mov    %edx,0x14(%ebp)
  800bdf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800be1:	85 ff                	test   %edi,%edi
  800be3:	ba 84 2f 80 00       	mov    $0x802f84,%edx
  800be8:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800beb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800bef:	0f 84 92 00 00 00    	je     800c87 <vprintfmt+0x22c>
  800bf5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800bf9:	0f 8e 96 00 00 00    	jle    800c95 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800bff:	83 ec 08             	sub    $0x8,%esp
  800c02:	51                   	push   %ecx
  800c03:	57                   	push   %edi
  800c04:	e8 86 02 00 00       	call   800e8f <strnlen>
  800c09:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800c0c:	29 c1                	sub    %eax,%ecx
  800c0e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800c11:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800c14:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800c18:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800c1e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c20:	eb 0f                	jmp    800c31 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800c22:	83 ec 08             	sub    $0x8,%esp
  800c25:	53                   	push   %ebx
  800c26:	ff 75 e0             	pushl  -0x20(%ebp)
  800c29:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c2b:	83 ef 01             	sub    $0x1,%edi
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	85 ff                	test   %edi,%edi
  800c33:	7f ed                	jg     800c22 <vprintfmt+0x1c7>
  800c35:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800c38:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800c3b:	85 c9                	test   %ecx,%ecx
  800c3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c42:	0f 49 c1             	cmovns %ecx,%eax
  800c45:	29 c1                	sub    %eax,%ecx
  800c47:	89 75 08             	mov    %esi,0x8(%ebp)
  800c4a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c4d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c50:	89 cb                	mov    %ecx,%ebx
  800c52:	eb 4d                	jmp    800ca1 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c54:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c58:	74 1b                	je     800c75 <vprintfmt+0x21a>
  800c5a:	0f be c0             	movsbl %al,%eax
  800c5d:	83 e8 20             	sub    $0x20,%eax
  800c60:	83 f8 5e             	cmp    $0x5e,%eax
  800c63:	76 10                	jbe    800c75 <vprintfmt+0x21a>
					putch('?', putdat);
  800c65:	83 ec 08             	sub    $0x8,%esp
  800c68:	ff 75 0c             	pushl  0xc(%ebp)
  800c6b:	6a 3f                	push   $0x3f
  800c6d:	ff 55 08             	call   *0x8(%ebp)
  800c70:	83 c4 10             	add    $0x10,%esp
  800c73:	eb 0d                	jmp    800c82 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800c75:	83 ec 08             	sub    $0x8,%esp
  800c78:	ff 75 0c             	pushl  0xc(%ebp)
  800c7b:	52                   	push   %edx
  800c7c:	ff 55 08             	call   *0x8(%ebp)
  800c7f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c82:	83 eb 01             	sub    $0x1,%ebx
  800c85:	eb 1a                	jmp    800ca1 <vprintfmt+0x246>
  800c87:	89 75 08             	mov    %esi,0x8(%ebp)
  800c8a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c8d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c90:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800c93:	eb 0c                	jmp    800ca1 <vprintfmt+0x246>
  800c95:	89 75 08             	mov    %esi,0x8(%ebp)
  800c98:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c9b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c9e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ca1:	83 c7 01             	add    $0x1,%edi
  800ca4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ca8:	0f be d0             	movsbl %al,%edx
  800cab:	85 d2                	test   %edx,%edx
  800cad:	74 23                	je     800cd2 <vprintfmt+0x277>
  800caf:	85 f6                	test   %esi,%esi
  800cb1:	78 a1                	js     800c54 <vprintfmt+0x1f9>
  800cb3:	83 ee 01             	sub    $0x1,%esi
  800cb6:	79 9c                	jns    800c54 <vprintfmt+0x1f9>
  800cb8:	89 df                	mov    %ebx,%edi
  800cba:	8b 75 08             	mov    0x8(%ebp),%esi
  800cbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cc0:	eb 18                	jmp    800cda <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800cc2:	83 ec 08             	sub    $0x8,%esp
  800cc5:	53                   	push   %ebx
  800cc6:	6a 20                	push   $0x20
  800cc8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800cca:	83 ef 01             	sub    $0x1,%edi
  800ccd:	83 c4 10             	add    $0x10,%esp
  800cd0:	eb 08                	jmp    800cda <vprintfmt+0x27f>
  800cd2:	89 df                	mov    %ebx,%edi
  800cd4:	8b 75 08             	mov    0x8(%ebp),%esi
  800cd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cda:	85 ff                	test   %edi,%edi
  800cdc:	7f e4                	jg     800cc2 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cde:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ce1:	e9 9b fd ff ff       	jmp    800a81 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ce6:	83 fa 01             	cmp    $0x1,%edx
  800ce9:	7e 16                	jle    800d01 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800ceb:	8b 45 14             	mov    0x14(%ebp),%eax
  800cee:	8d 50 08             	lea    0x8(%eax),%edx
  800cf1:	89 55 14             	mov    %edx,0x14(%ebp)
  800cf4:	8b 50 04             	mov    0x4(%eax),%edx
  800cf7:	8b 00                	mov    (%eax),%eax
  800cf9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cfc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cff:	eb 32                	jmp    800d33 <vprintfmt+0x2d8>
	else if (lflag)
  800d01:	85 d2                	test   %edx,%edx
  800d03:	74 18                	je     800d1d <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800d05:	8b 45 14             	mov    0x14(%ebp),%eax
  800d08:	8d 50 04             	lea    0x4(%eax),%edx
  800d0b:	89 55 14             	mov    %edx,0x14(%ebp)
  800d0e:	8b 00                	mov    (%eax),%eax
  800d10:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d13:	89 c1                	mov    %eax,%ecx
  800d15:	c1 f9 1f             	sar    $0x1f,%ecx
  800d18:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800d1b:	eb 16                	jmp    800d33 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800d1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d20:	8d 50 04             	lea    0x4(%eax),%edx
  800d23:	89 55 14             	mov    %edx,0x14(%ebp)
  800d26:	8b 00                	mov    (%eax),%eax
  800d28:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d2b:	89 c1                	mov    %eax,%ecx
  800d2d:	c1 f9 1f             	sar    $0x1f,%ecx
  800d30:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800d33:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d36:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800d39:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800d3e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d42:	79 74                	jns    800db8 <vprintfmt+0x35d>
				putch('-', putdat);
  800d44:	83 ec 08             	sub    $0x8,%esp
  800d47:	53                   	push   %ebx
  800d48:	6a 2d                	push   $0x2d
  800d4a:	ff d6                	call   *%esi
				num = -(long long) num;
  800d4c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d4f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d52:	f7 d8                	neg    %eax
  800d54:	83 d2 00             	adc    $0x0,%edx
  800d57:	f7 da                	neg    %edx
  800d59:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800d5c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800d61:	eb 55                	jmp    800db8 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800d63:	8d 45 14             	lea    0x14(%ebp),%eax
  800d66:	e8 7c fc ff ff       	call   8009e7 <getuint>
			base = 10;
  800d6b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800d70:	eb 46                	jmp    800db8 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800d72:	8d 45 14             	lea    0x14(%ebp),%eax
  800d75:	e8 6d fc ff ff       	call   8009e7 <getuint>
                        base = 8;
  800d7a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800d7f:	eb 37                	jmp    800db8 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800d81:	83 ec 08             	sub    $0x8,%esp
  800d84:	53                   	push   %ebx
  800d85:	6a 30                	push   $0x30
  800d87:	ff d6                	call   *%esi
			putch('x', putdat);
  800d89:	83 c4 08             	add    $0x8,%esp
  800d8c:	53                   	push   %ebx
  800d8d:	6a 78                	push   $0x78
  800d8f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d91:	8b 45 14             	mov    0x14(%ebp),%eax
  800d94:	8d 50 04             	lea    0x4(%eax),%edx
  800d97:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d9a:	8b 00                	mov    (%eax),%eax
  800d9c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800da1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800da4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800da9:	eb 0d                	jmp    800db8 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800dab:	8d 45 14             	lea    0x14(%ebp),%eax
  800dae:	e8 34 fc ff ff       	call   8009e7 <getuint>
			base = 16;
  800db3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800dbf:	57                   	push   %edi
  800dc0:	ff 75 e0             	pushl  -0x20(%ebp)
  800dc3:	51                   	push   %ecx
  800dc4:	52                   	push   %edx
  800dc5:	50                   	push   %eax
  800dc6:	89 da                	mov    %ebx,%edx
  800dc8:	89 f0                	mov    %esi,%eax
  800dca:	e8 6e fb ff ff       	call   80093d <printnum>
			break;
  800dcf:	83 c4 20             	add    $0x20,%esp
  800dd2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800dd5:	e9 a7 fc ff ff       	jmp    800a81 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800dda:	83 ec 08             	sub    $0x8,%esp
  800ddd:	53                   	push   %ebx
  800dde:	51                   	push   %ecx
  800ddf:	ff d6                	call   *%esi
			break;
  800de1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800de4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800de7:	e9 95 fc ff ff       	jmp    800a81 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800dec:	83 ec 08             	sub    $0x8,%esp
  800def:	53                   	push   %ebx
  800df0:	6a 25                	push   $0x25
  800df2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	eb 03                	jmp    800dfc <vprintfmt+0x3a1>
  800df9:	83 ef 01             	sub    $0x1,%edi
  800dfc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800e00:	75 f7                	jne    800df9 <vprintfmt+0x39e>
  800e02:	e9 7a fc ff ff       	jmp    800a81 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	83 ec 18             	sub    $0x18,%esp
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e1e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e22:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	74 26                	je     800e56 <vsnprintf+0x47>
  800e30:	85 d2                	test   %edx,%edx
  800e32:	7e 22                	jle    800e56 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e34:	ff 75 14             	pushl  0x14(%ebp)
  800e37:	ff 75 10             	pushl  0x10(%ebp)
  800e3a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e3d:	50                   	push   %eax
  800e3e:	68 21 0a 80 00       	push   $0x800a21
  800e43:	e8 13 fc ff ff       	call   800a5b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e4b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e51:	83 c4 10             	add    $0x10,%esp
  800e54:	eb 05                	jmp    800e5b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e5b:	c9                   	leave  
  800e5c:	c3                   	ret    

00800e5d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e63:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e66:	50                   	push   %eax
  800e67:	ff 75 10             	pushl  0x10(%ebp)
  800e6a:	ff 75 0c             	pushl  0xc(%ebp)
  800e6d:	ff 75 08             	pushl  0x8(%ebp)
  800e70:	e8 9a ff ff ff       	call   800e0f <vsnprintf>
	va_end(ap);

	return rc;
}
  800e75:	c9                   	leave  
  800e76:	c3                   	ret    

00800e77 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e82:	eb 03                	jmp    800e87 <strlen+0x10>
		n++;
  800e84:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e87:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e8b:	75 f7                	jne    800e84 <strlen+0xd>
		n++;
	return n;
}
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e95:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e98:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9d:	eb 03                	jmp    800ea2 <strnlen+0x13>
		n++;
  800e9f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ea2:	39 c2                	cmp    %eax,%edx
  800ea4:	74 08                	je     800eae <strnlen+0x1f>
  800ea6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800eaa:	75 f3                	jne    800e9f <strnlen+0x10>
  800eac:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	53                   	push   %ebx
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800eba:	89 c2                	mov    %eax,%edx
  800ebc:	83 c2 01             	add    $0x1,%edx
  800ebf:	83 c1 01             	add    $0x1,%ecx
  800ec2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ec6:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ec9:	84 db                	test   %bl,%bl
  800ecb:	75 ef                	jne    800ebc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ecd:	5b                   	pop    %ebx
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	53                   	push   %ebx
  800ed4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ed7:	53                   	push   %ebx
  800ed8:	e8 9a ff ff ff       	call   800e77 <strlen>
  800edd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ee0:	ff 75 0c             	pushl  0xc(%ebp)
  800ee3:	01 d8                	add    %ebx,%eax
  800ee5:	50                   	push   %eax
  800ee6:	e8 c5 ff ff ff       	call   800eb0 <strcpy>
	return dst;
}
  800eeb:	89 d8                	mov    %ebx,%eax
  800eed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	8b 75 08             	mov    0x8(%ebp),%esi
  800efa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efd:	89 f3                	mov    %esi,%ebx
  800eff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	eb 0f                	jmp    800f15 <strncpy+0x23>
		*dst++ = *src;
  800f06:	83 c2 01             	add    $0x1,%edx
  800f09:	0f b6 01             	movzbl (%ecx),%eax
  800f0c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f0f:	80 39 01             	cmpb   $0x1,(%ecx)
  800f12:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f15:	39 da                	cmp    %ebx,%edx
  800f17:	75 ed                	jne    800f06 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800f19:	89 f0                	mov    %esi,%eax
  800f1b:	5b                   	pop    %ebx
  800f1c:	5e                   	pop    %esi
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	8b 75 08             	mov    0x8(%ebp),%esi
  800f27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2a:	8b 55 10             	mov    0x10(%ebp),%edx
  800f2d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f2f:	85 d2                	test   %edx,%edx
  800f31:	74 21                	je     800f54 <strlcpy+0x35>
  800f33:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800f37:	89 f2                	mov    %esi,%edx
  800f39:	eb 09                	jmp    800f44 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f3b:	83 c2 01             	add    $0x1,%edx
  800f3e:	83 c1 01             	add    $0x1,%ecx
  800f41:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f44:	39 c2                	cmp    %eax,%edx
  800f46:	74 09                	je     800f51 <strlcpy+0x32>
  800f48:	0f b6 19             	movzbl (%ecx),%ebx
  800f4b:	84 db                	test   %bl,%bl
  800f4d:	75 ec                	jne    800f3b <strlcpy+0x1c>
  800f4f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800f51:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f54:	29 f0                	sub    %esi,%eax
}
  800f56:	5b                   	pop    %ebx
  800f57:	5e                   	pop    %esi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f60:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f63:	eb 06                	jmp    800f6b <strcmp+0x11>
		p++, q++;
  800f65:	83 c1 01             	add    $0x1,%ecx
  800f68:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f6b:	0f b6 01             	movzbl (%ecx),%eax
  800f6e:	84 c0                	test   %al,%al
  800f70:	74 04                	je     800f76 <strcmp+0x1c>
  800f72:	3a 02                	cmp    (%edx),%al
  800f74:	74 ef                	je     800f65 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f76:	0f b6 c0             	movzbl %al,%eax
  800f79:	0f b6 12             	movzbl (%edx),%edx
  800f7c:	29 d0                	sub    %edx,%eax
}
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	53                   	push   %ebx
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
  800f87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8a:	89 c3                	mov    %eax,%ebx
  800f8c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800f8f:	eb 06                	jmp    800f97 <strncmp+0x17>
		n--, p++, q++;
  800f91:	83 c0 01             	add    $0x1,%eax
  800f94:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f97:	39 d8                	cmp    %ebx,%eax
  800f99:	74 15                	je     800fb0 <strncmp+0x30>
  800f9b:	0f b6 08             	movzbl (%eax),%ecx
  800f9e:	84 c9                	test   %cl,%cl
  800fa0:	74 04                	je     800fa6 <strncmp+0x26>
  800fa2:	3a 0a                	cmp    (%edx),%cl
  800fa4:	74 eb                	je     800f91 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fa6:	0f b6 00             	movzbl (%eax),%eax
  800fa9:	0f b6 12             	movzbl (%edx),%edx
  800fac:	29 d0                	sub    %edx,%eax
  800fae:	eb 05                	jmp    800fb5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800fb0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800fb5:	5b                   	pop    %ebx
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    

00800fb8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800fc2:	eb 07                	jmp    800fcb <strchr+0x13>
		if (*s == c)
  800fc4:	38 ca                	cmp    %cl,%dl
  800fc6:	74 0f                	je     800fd7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800fc8:	83 c0 01             	add    $0x1,%eax
  800fcb:	0f b6 10             	movzbl (%eax),%edx
  800fce:	84 d2                	test   %dl,%dl
  800fd0:	75 f2                	jne    800fc4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800fd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800fe3:	eb 03                	jmp    800fe8 <strfind+0xf>
  800fe5:	83 c0 01             	add    $0x1,%eax
  800fe8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800feb:	84 d2                	test   %dl,%dl
  800fed:	74 04                	je     800ff3 <strfind+0x1a>
  800fef:	38 ca                	cmp    %cl,%dl
  800ff1:	75 f2                	jne    800fe5 <strfind+0xc>
			break;
	return (char *) s;
}
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ffe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801001:	85 c9                	test   %ecx,%ecx
  801003:	74 36                	je     80103b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801005:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80100b:	75 28                	jne    801035 <memset+0x40>
  80100d:	f6 c1 03             	test   $0x3,%cl
  801010:	75 23                	jne    801035 <memset+0x40>
		c &= 0xFF;
  801012:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801016:	89 d3                	mov    %edx,%ebx
  801018:	c1 e3 08             	shl    $0x8,%ebx
  80101b:	89 d6                	mov    %edx,%esi
  80101d:	c1 e6 18             	shl    $0x18,%esi
  801020:	89 d0                	mov    %edx,%eax
  801022:	c1 e0 10             	shl    $0x10,%eax
  801025:	09 f0                	or     %esi,%eax
  801027:	09 c2                	or     %eax,%edx
  801029:	89 d0                	mov    %edx,%eax
  80102b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80102d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801030:	fc                   	cld    
  801031:	f3 ab                	rep stos %eax,%es:(%edi)
  801033:	eb 06                	jmp    80103b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801035:	8b 45 0c             	mov    0xc(%ebp),%eax
  801038:	fc                   	cld    
  801039:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80103b:	89 f8                	mov    %edi,%eax
  80103d:	5b                   	pop    %ebx
  80103e:	5e                   	pop    %esi
  80103f:	5f                   	pop    %edi
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	8b 45 08             	mov    0x8(%ebp),%eax
  80104a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80104d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801050:	39 c6                	cmp    %eax,%esi
  801052:	73 35                	jae    801089 <memmove+0x47>
  801054:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801057:	39 d0                	cmp    %edx,%eax
  801059:	73 2e                	jae    801089 <memmove+0x47>
		s += n;
		d += n;
  80105b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80105e:	89 d6                	mov    %edx,%esi
  801060:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801062:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801068:	75 13                	jne    80107d <memmove+0x3b>
  80106a:	f6 c1 03             	test   $0x3,%cl
  80106d:	75 0e                	jne    80107d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80106f:	83 ef 04             	sub    $0x4,%edi
  801072:	8d 72 fc             	lea    -0x4(%edx),%esi
  801075:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801078:	fd                   	std    
  801079:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80107b:	eb 09                	jmp    801086 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80107d:	83 ef 01             	sub    $0x1,%edi
  801080:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801083:	fd                   	std    
  801084:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801086:	fc                   	cld    
  801087:	eb 1d                	jmp    8010a6 <memmove+0x64>
  801089:	89 f2                	mov    %esi,%edx
  80108b:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80108d:	f6 c2 03             	test   $0x3,%dl
  801090:	75 0f                	jne    8010a1 <memmove+0x5f>
  801092:	f6 c1 03             	test   $0x3,%cl
  801095:	75 0a                	jne    8010a1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801097:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80109a:	89 c7                	mov    %eax,%edi
  80109c:	fc                   	cld    
  80109d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80109f:	eb 05                	jmp    8010a6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8010a1:	89 c7                	mov    %eax,%edi
  8010a3:	fc                   	cld    
  8010a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8010ad:	ff 75 10             	pushl  0x10(%ebp)
  8010b0:	ff 75 0c             	pushl  0xc(%ebp)
  8010b3:	ff 75 08             	pushl  0x8(%ebp)
  8010b6:	e8 87 ff ff ff       	call   801042 <memmove>
}
  8010bb:	c9                   	leave  
  8010bc:	c3                   	ret    

008010bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	56                   	push   %esi
  8010c1:	53                   	push   %ebx
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c8:	89 c6                	mov    %eax,%esi
  8010ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010cd:	eb 1a                	jmp    8010e9 <memcmp+0x2c>
		if (*s1 != *s2)
  8010cf:	0f b6 08             	movzbl (%eax),%ecx
  8010d2:	0f b6 1a             	movzbl (%edx),%ebx
  8010d5:	38 d9                	cmp    %bl,%cl
  8010d7:	74 0a                	je     8010e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8010d9:	0f b6 c1             	movzbl %cl,%eax
  8010dc:	0f b6 db             	movzbl %bl,%ebx
  8010df:	29 d8                	sub    %ebx,%eax
  8010e1:	eb 0f                	jmp    8010f2 <memcmp+0x35>
		s1++, s2++;
  8010e3:	83 c0 01             	add    $0x1,%eax
  8010e6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010e9:	39 f0                	cmp    %esi,%eax
  8010eb:	75 e2                	jne    8010cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    

008010f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8010ff:	89 c2                	mov    %eax,%edx
  801101:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801104:	eb 07                	jmp    80110d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801106:	38 08                	cmp    %cl,(%eax)
  801108:	74 07                	je     801111 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80110a:	83 c0 01             	add    $0x1,%eax
  80110d:	39 d0                	cmp    %edx,%eax
  80110f:	72 f5                	jb     801106 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    

00801113 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	57                   	push   %edi
  801117:	56                   	push   %esi
  801118:	53                   	push   %ebx
  801119:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80111f:	eb 03                	jmp    801124 <strtol+0x11>
		s++;
  801121:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801124:	0f b6 01             	movzbl (%ecx),%eax
  801127:	3c 09                	cmp    $0x9,%al
  801129:	74 f6                	je     801121 <strtol+0xe>
  80112b:	3c 20                	cmp    $0x20,%al
  80112d:	74 f2                	je     801121 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80112f:	3c 2b                	cmp    $0x2b,%al
  801131:	75 0a                	jne    80113d <strtol+0x2a>
		s++;
  801133:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801136:	bf 00 00 00 00       	mov    $0x0,%edi
  80113b:	eb 10                	jmp    80114d <strtol+0x3a>
  80113d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801142:	3c 2d                	cmp    $0x2d,%al
  801144:	75 07                	jne    80114d <strtol+0x3a>
		s++, neg = 1;
  801146:	8d 49 01             	lea    0x1(%ecx),%ecx
  801149:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80114d:	85 db                	test   %ebx,%ebx
  80114f:	0f 94 c0             	sete   %al
  801152:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801158:	75 19                	jne    801173 <strtol+0x60>
  80115a:	80 39 30             	cmpb   $0x30,(%ecx)
  80115d:	75 14                	jne    801173 <strtol+0x60>
  80115f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801163:	0f 85 82 00 00 00    	jne    8011eb <strtol+0xd8>
		s += 2, base = 16;
  801169:	83 c1 02             	add    $0x2,%ecx
  80116c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801171:	eb 16                	jmp    801189 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801173:	84 c0                	test   %al,%al
  801175:	74 12                	je     801189 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801177:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80117c:	80 39 30             	cmpb   $0x30,(%ecx)
  80117f:	75 08                	jne    801189 <strtol+0x76>
		s++, base = 8;
  801181:	83 c1 01             	add    $0x1,%ecx
  801184:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
  80118e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801191:	0f b6 11             	movzbl (%ecx),%edx
  801194:	8d 72 d0             	lea    -0x30(%edx),%esi
  801197:	89 f3                	mov    %esi,%ebx
  801199:	80 fb 09             	cmp    $0x9,%bl
  80119c:	77 08                	ja     8011a6 <strtol+0x93>
			dig = *s - '0';
  80119e:	0f be d2             	movsbl %dl,%edx
  8011a1:	83 ea 30             	sub    $0x30,%edx
  8011a4:	eb 22                	jmp    8011c8 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8011a6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8011a9:	89 f3                	mov    %esi,%ebx
  8011ab:	80 fb 19             	cmp    $0x19,%bl
  8011ae:	77 08                	ja     8011b8 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8011b0:	0f be d2             	movsbl %dl,%edx
  8011b3:	83 ea 57             	sub    $0x57,%edx
  8011b6:	eb 10                	jmp    8011c8 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8011b8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8011bb:	89 f3                	mov    %esi,%ebx
  8011bd:	80 fb 19             	cmp    $0x19,%bl
  8011c0:	77 16                	ja     8011d8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8011c2:	0f be d2             	movsbl %dl,%edx
  8011c5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8011c8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8011cb:	7d 0f                	jge    8011dc <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8011cd:	83 c1 01             	add    $0x1,%ecx
  8011d0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011d4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8011d6:	eb b9                	jmp    801191 <strtol+0x7e>
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	eb 02                	jmp    8011de <strtol+0xcb>
  8011dc:	89 c2                	mov    %eax,%edx

	if (endptr)
  8011de:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011e2:	74 0d                	je     8011f1 <strtol+0xde>
		*endptr = (char *) s;
  8011e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011e7:	89 0e                	mov    %ecx,(%esi)
  8011e9:	eb 06                	jmp    8011f1 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8011eb:	84 c0                	test   %al,%al
  8011ed:	75 92                	jne    801181 <strtol+0x6e>
  8011ef:	eb 98                	jmp    801189 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8011f1:	f7 da                	neg    %edx
  8011f3:	85 ff                	test   %edi,%edi
  8011f5:	0f 45 c2             	cmovne %edx,%eax
}
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	57                   	push   %edi
  801201:	56                   	push   %esi
  801202:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801203:	b8 00 00 00 00       	mov    $0x0,%eax
  801208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120b:	8b 55 08             	mov    0x8(%ebp),%edx
  80120e:	89 c3                	mov    %eax,%ebx
  801210:	89 c7                	mov    %eax,%edi
  801212:	89 c6                	mov    %eax,%esi
  801214:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <sys_cgetc>:

int
sys_cgetc(void)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801221:	ba 00 00 00 00       	mov    $0x0,%edx
  801226:	b8 01 00 00 00       	mov    $0x1,%eax
  80122b:	89 d1                	mov    %edx,%ecx
  80122d:	89 d3                	mov    %edx,%ebx
  80122f:	89 d7                	mov    %edx,%edi
  801231:	89 d6                	mov    %edx,%esi
  801233:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801235:	5b                   	pop    %ebx
  801236:	5e                   	pop    %esi
  801237:	5f                   	pop    %edi
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	57                   	push   %edi
  80123e:	56                   	push   %esi
  80123f:	53                   	push   %ebx
  801240:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801243:	b9 00 00 00 00       	mov    $0x0,%ecx
  801248:	b8 03 00 00 00       	mov    $0x3,%eax
  80124d:	8b 55 08             	mov    0x8(%ebp),%edx
  801250:	89 cb                	mov    %ecx,%ebx
  801252:	89 cf                	mov    %ecx,%edi
  801254:	89 ce                	mov    %ecx,%esi
  801256:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801258:	85 c0                	test   %eax,%eax
  80125a:	7e 17                	jle    801273 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125c:	83 ec 0c             	sub    $0xc,%esp
  80125f:	50                   	push   %eax
  801260:	6a 03                	push   $0x3
  801262:	68 9f 32 80 00       	push   $0x80329f
  801267:	6a 22                	push   $0x22
  801269:	68 bc 32 80 00       	push   $0x8032bc
  80126e:	e8 dd f5 ff ff       	call   800850 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801276:	5b                   	pop    %ebx
  801277:	5e                   	pop    %esi
  801278:	5f                   	pop    %edi
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	57                   	push   %edi
  80127f:	56                   	push   %esi
  801280:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801281:	ba 00 00 00 00       	mov    $0x0,%edx
  801286:	b8 02 00 00 00       	mov    $0x2,%eax
  80128b:	89 d1                	mov    %edx,%ecx
  80128d:	89 d3                	mov    %edx,%ebx
  80128f:	89 d7                	mov    %edx,%edi
  801291:	89 d6                	mov    %edx,%esi
  801293:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    

0080129a <sys_yield>:

void
sys_yield(void)
{      
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	57                   	push   %edi
  80129e:	56                   	push   %esi
  80129f:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8012a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012aa:	89 d1                	mov    %edx,%ecx
  8012ac:	89 d3                	mov    %edx,%ebx
  8012ae:	89 d7                	mov    %edx,%edi
  8012b0:	89 d6                	mov    %edx,%esi
  8012b2:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012b4:	5b                   	pop    %ebx
  8012b5:	5e                   	pop    %esi
  8012b6:	5f                   	pop    %edi
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    

008012b9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	57                   	push   %edi
  8012bd:	56                   	push   %esi
  8012be:	53                   	push   %ebx
  8012bf:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8012c2:	be 00 00 00 00       	mov    $0x0,%esi
  8012c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8012cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d5:	89 f7                	mov    %esi,%edi
  8012d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	7e 17                	jle    8012f4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012dd:	83 ec 0c             	sub    $0xc,%esp
  8012e0:	50                   	push   %eax
  8012e1:	6a 04                	push   $0x4
  8012e3:	68 9f 32 80 00       	push   $0x80329f
  8012e8:	6a 22                	push   $0x22
  8012ea:	68 bc 32 80 00       	push   $0x8032bc
  8012ef:	e8 5c f5 ff ff       	call   800850 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5f                   	pop    %edi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	57                   	push   %edi
  801300:	56                   	push   %esi
  801301:	53                   	push   %ebx
  801302:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801305:	b8 05 00 00 00       	mov    $0x5,%eax
  80130a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130d:	8b 55 08             	mov    0x8(%ebp),%edx
  801310:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801313:	8b 7d 14             	mov    0x14(%ebp),%edi
  801316:	8b 75 18             	mov    0x18(%ebp),%esi
  801319:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80131b:	85 c0                	test   %eax,%eax
  80131d:	7e 17                	jle    801336 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80131f:	83 ec 0c             	sub    $0xc,%esp
  801322:	50                   	push   %eax
  801323:	6a 05                	push   $0x5
  801325:	68 9f 32 80 00       	push   $0x80329f
  80132a:	6a 22                	push   $0x22
  80132c:	68 bc 32 80 00       	push   $0x8032bc
  801331:	e8 1a f5 ff ff       	call   800850 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801336:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5f                   	pop    %edi
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	57                   	push   %edi
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801347:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134c:	b8 06 00 00 00       	mov    $0x6,%eax
  801351:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801354:	8b 55 08             	mov    0x8(%ebp),%edx
  801357:	89 df                	mov    %ebx,%edi
  801359:	89 de                	mov    %ebx,%esi
  80135b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80135d:	85 c0                	test   %eax,%eax
  80135f:	7e 17                	jle    801378 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801361:	83 ec 0c             	sub    $0xc,%esp
  801364:	50                   	push   %eax
  801365:	6a 06                	push   $0x6
  801367:	68 9f 32 80 00       	push   $0x80329f
  80136c:	6a 22                	push   $0x22
  80136e:	68 bc 32 80 00       	push   $0x8032bc
  801373:	e8 d8 f4 ff ff       	call   800850 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801378:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	57                   	push   %edi
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
  801386:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801389:	bb 00 00 00 00       	mov    $0x0,%ebx
  80138e:	b8 08 00 00 00       	mov    $0x8,%eax
  801393:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801396:	8b 55 08             	mov    0x8(%ebp),%edx
  801399:	89 df                	mov    %ebx,%edi
  80139b:	89 de                	mov    %ebx,%esi
  80139d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	7e 17                	jle    8013ba <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013a3:	83 ec 0c             	sub    $0xc,%esp
  8013a6:	50                   	push   %eax
  8013a7:	6a 08                	push   $0x8
  8013a9:	68 9f 32 80 00       	push   $0x80329f
  8013ae:	6a 22                	push   $0x22
  8013b0:	68 bc 32 80 00       	push   $0x8032bc
  8013b5:	e8 96 f4 ff ff       	call   800850 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  8013ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013bd:	5b                   	pop    %ebx
  8013be:	5e                   	pop    %esi
  8013bf:	5f                   	pop    %edi
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	57                   	push   %edi
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8013cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8013d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013db:	89 df                	mov    %ebx,%edi
  8013dd:	89 de                	mov    %ebx,%esi
  8013df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	7e 17                	jle    8013fc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	50                   	push   %eax
  8013e9:	6a 09                	push   $0x9
  8013eb:	68 9f 32 80 00       	push   $0x80329f
  8013f0:	6a 22                	push   $0x22
  8013f2:	68 bc 32 80 00       	push   $0x8032bc
  8013f7:	e8 54 f4 ff ff       	call   800850 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8013fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5f                   	pop    %edi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	57                   	push   %edi
  801408:	56                   	push   %esi
  801409:	53                   	push   %ebx
  80140a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80140d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801412:	b8 0a 00 00 00       	mov    $0xa,%eax
  801417:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80141a:	8b 55 08             	mov    0x8(%ebp),%edx
  80141d:	89 df                	mov    %ebx,%edi
  80141f:	89 de                	mov    %ebx,%esi
  801421:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801423:	85 c0                	test   %eax,%eax
  801425:	7e 17                	jle    80143e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	50                   	push   %eax
  80142b:	6a 0a                	push   $0xa
  80142d:	68 9f 32 80 00       	push   $0x80329f
  801432:	6a 22                	push   $0x22
  801434:	68 bc 32 80 00       	push   $0x8032bc
  801439:	e8 12 f4 ff ff       	call   800850 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80143e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801441:	5b                   	pop    %ebx
  801442:	5e                   	pop    %esi
  801443:	5f                   	pop    %edi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    

00801446 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	57                   	push   %edi
  80144a:	56                   	push   %esi
  80144b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80144c:	be 00 00 00 00       	mov    $0x0,%esi
  801451:	b8 0c 00 00 00       	mov    $0xc,%eax
  801456:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801459:	8b 55 08             	mov    0x8(%ebp),%edx
  80145c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80145f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801462:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5f                   	pop    %edi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    

00801469 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	57                   	push   %edi
  80146d:	56                   	push   %esi
  80146e:	53                   	push   %ebx
  80146f:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801472:	b9 00 00 00 00       	mov    $0x0,%ecx
  801477:	b8 0d 00 00 00       	mov    $0xd,%eax
  80147c:	8b 55 08             	mov    0x8(%ebp),%edx
  80147f:	89 cb                	mov    %ecx,%ebx
  801481:	89 cf                	mov    %ecx,%edi
  801483:	89 ce                	mov    %ecx,%esi
  801485:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801487:	85 c0                	test   %eax,%eax
  801489:	7e 17                	jle    8014a2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80148b:	83 ec 0c             	sub    $0xc,%esp
  80148e:	50                   	push   %eax
  80148f:	6a 0d                	push   $0xd
  801491:	68 9f 32 80 00       	push   $0x80329f
  801496:	6a 22                	push   $0x22
  801498:	68 bc 32 80 00       	push   $0x8032bc
  80149d:	e8 ae f3 ff ff       	call   800850 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a5:	5b                   	pop    %ebx
  8014a6:	5e                   	pop    %esi
  8014a7:	5f                   	pop    %edi
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    

008014aa <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	57                   	push   %edi
  8014ae:	56                   	push   %esi
  8014af:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8014b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b5:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014ba:	89 d1                	mov    %edx,%ecx
  8014bc:	89 d3                	mov    %edx,%ebx
  8014be:	89 d7                	mov    %edx,%edi
  8014c0:	89 d6                	mov    %edx,%esi
  8014c2:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  8014c4:	5b                   	pop    %ebx
  8014c5:	5e                   	pop    %esi
  8014c6:	5f                   	pop    %edi
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    

008014c9 <sys_transmit>:

int
sys_transmit(void *addr)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	57                   	push   %edi
  8014cd:	56                   	push   %esi
  8014ce:	53                   	push   %ebx
  8014cf:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8014d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014d7:	b8 0f 00 00 00       	mov    $0xf,%eax
  8014dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8014df:	89 cb                	mov    %ecx,%ebx
  8014e1:	89 cf                	mov    %ecx,%edi
  8014e3:	89 ce                	mov    %ecx,%esi
  8014e5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	7e 17                	jle    801502 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014eb:	83 ec 0c             	sub    $0xc,%esp
  8014ee:	50                   	push   %eax
  8014ef:	6a 0f                	push   $0xf
  8014f1:	68 9f 32 80 00       	push   $0x80329f
  8014f6:	6a 22                	push   $0x22
  8014f8:	68 bc 32 80 00       	push   $0x8032bc
  8014fd:	e8 4e f3 ff ff       	call   800850 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  801502:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5f                   	pop    %edi
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <sys_recv>:

int
sys_recv(void *addr)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	57                   	push   %edi
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801513:	b9 00 00 00 00       	mov    $0x0,%ecx
  801518:	b8 10 00 00 00       	mov    $0x10,%eax
  80151d:	8b 55 08             	mov    0x8(%ebp),%edx
  801520:	89 cb                	mov    %ecx,%ebx
  801522:	89 cf                	mov    %ecx,%edi
  801524:	89 ce                	mov    %ecx,%esi
  801526:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801528:	85 c0                	test   %eax,%eax
  80152a:	7e 17                	jle    801543 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80152c:	83 ec 0c             	sub    $0xc,%esp
  80152f:	50                   	push   %eax
  801530:	6a 10                	push   $0x10
  801532:	68 9f 32 80 00       	push   $0x80329f
  801537:	6a 22                	push   $0x22
  801539:	68 bc 32 80 00       	push   $0x8032bc
  80153e:	e8 0d f3 ff ff       	call   800850 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  801543:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801546:	5b                   	pop    %ebx
  801547:	5e                   	pop    %esi
  801548:	5f                   	pop    %edi
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80154e:	8b 45 08             	mov    0x8(%ebp),%eax
  801551:	05 00 00 00 30       	add    $0x30000000,%eax
  801556:	c1 e8 0c             	shr    $0xc,%eax
}
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80155e:	8b 45 08             	mov    0x8(%ebp),%eax
  801561:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801566:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80156b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801570:	5d                   	pop    %ebp
  801571:	c3                   	ret    

00801572 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801578:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	c1 ea 16             	shr    $0x16,%edx
  801582:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801589:	f6 c2 01             	test   $0x1,%dl
  80158c:	74 11                	je     80159f <fd_alloc+0x2d>
  80158e:	89 c2                	mov    %eax,%edx
  801590:	c1 ea 0c             	shr    $0xc,%edx
  801593:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80159a:	f6 c2 01             	test   $0x1,%dl
  80159d:	75 09                	jne    8015a8 <fd_alloc+0x36>
			*fd_store = fd;
  80159f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a6:	eb 17                	jmp    8015bf <fd_alloc+0x4d>
  8015a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015b2:	75 c9                	jne    80157d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8015ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    

008015c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015c7:	83 f8 1f             	cmp    $0x1f,%eax
  8015ca:	77 36                	ja     801602 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015cc:	c1 e0 0c             	shl    $0xc,%eax
  8015cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015d4:	89 c2                	mov    %eax,%edx
  8015d6:	c1 ea 16             	shr    $0x16,%edx
  8015d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015e0:	f6 c2 01             	test   $0x1,%dl
  8015e3:	74 24                	je     801609 <fd_lookup+0x48>
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	c1 ea 0c             	shr    $0xc,%edx
  8015ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015f1:	f6 c2 01             	test   $0x1,%dl
  8015f4:	74 1a                	je     801610 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8015fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801600:	eb 13                	jmp    801615 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801602:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801607:	eb 0c                	jmp    801615 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801609:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80160e:	eb 05                	jmp    801615 <fd_lookup+0x54>
  801610:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801620:	ba 00 00 00 00       	mov    $0x0,%edx
  801625:	eb 13                	jmp    80163a <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801627:	39 08                	cmp    %ecx,(%eax)
  801629:	75 0c                	jne    801637 <dev_lookup+0x20>
			*dev = devtab[i];
  80162b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801630:	b8 00 00 00 00       	mov    $0x0,%eax
  801635:	eb 36                	jmp    80166d <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801637:	83 c2 01             	add    $0x1,%edx
  80163a:	8b 04 95 48 33 80 00 	mov    0x803348(,%edx,4),%eax
  801641:	85 c0                	test   %eax,%eax
  801643:	75 e2                	jne    801627 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801645:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80164a:	8b 40 48             	mov    0x48(%eax),%eax
  80164d:	83 ec 04             	sub    $0x4,%esp
  801650:	51                   	push   %ecx
  801651:	50                   	push   %eax
  801652:	68 cc 32 80 00       	push   $0x8032cc
  801657:	e8 cd f2 ff ff       	call   800929 <cprintf>
	*dev = 0;
  80165c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	56                   	push   %esi
  801673:	53                   	push   %ebx
  801674:	83 ec 10             	sub    $0x10,%esp
  801677:	8b 75 08             	mov    0x8(%ebp),%esi
  80167a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80167d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801680:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801681:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801687:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80168a:	50                   	push   %eax
  80168b:	e8 31 ff ff ff       	call   8015c1 <fd_lookup>
  801690:	83 c4 08             	add    $0x8,%esp
  801693:	85 c0                	test   %eax,%eax
  801695:	78 05                	js     80169c <fd_close+0x2d>
	    || fd != fd2)
  801697:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80169a:	74 0c                	je     8016a8 <fd_close+0x39>
		return (must_exist ? r : 0);
  80169c:	84 db                	test   %bl,%bl
  80169e:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a3:	0f 44 c2             	cmove  %edx,%eax
  8016a6:	eb 41                	jmp    8016e9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ae:	50                   	push   %eax
  8016af:	ff 36                	pushl  (%esi)
  8016b1:	e8 61 ff ff ff       	call   801617 <dev_lookup>
  8016b6:	89 c3                	mov    %eax,%ebx
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 1a                	js     8016d9 <fd_close+0x6a>
		if (dev->dev_close)
  8016bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8016c5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	74 0b                	je     8016d9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8016ce:	83 ec 0c             	sub    $0xc,%esp
  8016d1:	56                   	push   %esi
  8016d2:	ff d0                	call   *%eax
  8016d4:	89 c3                	mov    %eax,%ebx
  8016d6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016d9:	83 ec 08             	sub    $0x8,%esp
  8016dc:	56                   	push   %esi
  8016dd:	6a 00                	push   $0x0
  8016df:	e8 5a fc ff ff       	call   80133e <sys_page_unmap>
	return r;
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	89 d8                	mov    %ebx,%eax
}
  8016e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ec:	5b                   	pop    %ebx
  8016ed:	5e                   	pop    %esi
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f9:	50                   	push   %eax
  8016fa:	ff 75 08             	pushl  0x8(%ebp)
  8016fd:	e8 bf fe ff ff       	call   8015c1 <fd_lookup>
  801702:	89 c2                	mov    %eax,%edx
  801704:	83 c4 08             	add    $0x8,%esp
  801707:	85 d2                	test   %edx,%edx
  801709:	78 10                	js     80171b <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	6a 01                	push   $0x1
  801710:	ff 75 f4             	pushl  -0xc(%ebp)
  801713:	e8 57 ff ff ff       	call   80166f <fd_close>
  801718:	83 c4 10             	add    $0x10,%esp
}
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <close_all>:

void
close_all(void)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	53                   	push   %ebx
  801721:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801724:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801729:	83 ec 0c             	sub    $0xc,%esp
  80172c:	53                   	push   %ebx
  80172d:	e8 be ff ff ff       	call   8016f0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801732:	83 c3 01             	add    $0x1,%ebx
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	83 fb 20             	cmp    $0x20,%ebx
  80173b:	75 ec                	jne    801729 <close_all+0xc>
		close(i);
}
  80173d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	57                   	push   %edi
  801746:	56                   	push   %esi
  801747:	53                   	push   %ebx
  801748:	83 ec 2c             	sub    $0x2c,%esp
  80174b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80174e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801751:	50                   	push   %eax
  801752:	ff 75 08             	pushl  0x8(%ebp)
  801755:	e8 67 fe ff ff       	call   8015c1 <fd_lookup>
  80175a:	89 c2                	mov    %eax,%edx
  80175c:	83 c4 08             	add    $0x8,%esp
  80175f:	85 d2                	test   %edx,%edx
  801761:	0f 88 c1 00 00 00    	js     801828 <dup+0xe6>
		return r;
	close(newfdnum);
  801767:	83 ec 0c             	sub    $0xc,%esp
  80176a:	56                   	push   %esi
  80176b:	e8 80 ff ff ff       	call   8016f0 <close>

	newfd = INDEX2FD(newfdnum);
  801770:	89 f3                	mov    %esi,%ebx
  801772:	c1 e3 0c             	shl    $0xc,%ebx
  801775:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80177b:	83 c4 04             	add    $0x4,%esp
  80177e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801781:	e8 d5 fd ff ff       	call   80155b <fd2data>
  801786:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801788:	89 1c 24             	mov    %ebx,(%esp)
  80178b:	e8 cb fd ff ff       	call   80155b <fd2data>
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801796:	89 f8                	mov    %edi,%eax
  801798:	c1 e8 16             	shr    $0x16,%eax
  80179b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017a2:	a8 01                	test   $0x1,%al
  8017a4:	74 37                	je     8017dd <dup+0x9b>
  8017a6:	89 f8                	mov    %edi,%eax
  8017a8:	c1 e8 0c             	shr    $0xc,%eax
  8017ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017b2:	f6 c2 01             	test   $0x1,%dl
  8017b5:	74 26                	je     8017dd <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8017c6:	50                   	push   %eax
  8017c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017ca:	6a 00                	push   $0x0
  8017cc:	57                   	push   %edi
  8017cd:	6a 00                	push   $0x0
  8017cf:	e8 28 fb ff ff       	call   8012fc <sys_page_map>
  8017d4:	89 c7                	mov    %eax,%edi
  8017d6:	83 c4 20             	add    $0x20,%esp
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 2e                	js     80180b <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017e0:	89 d0                	mov    %edx,%eax
  8017e2:	c1 e8 0c             	shr    $0xc,%eax
  8017e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8017f4:	50                   	push   %eax
  8017f5:	53                   	push   %ebx
  8017f6:	6a 00                	push   $0x0
  8017f8:	52                   	push   %edx
  8017f9:	6a 00                	push   $0x0
  8017fb:	e8 fc fa ff ff       	call   8012fc <sys_page_map>
  801800:	89 c7                	mov    %eax,%edi
  801802:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801805:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801807:	85 ff                	test   %edi,%edi
  801809:	79 1d                	jns    801828 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	53                   	push   %ebx
  80180f:	6a 00                	push   $0x0
  801811:	e8 28 fb ff ff       	call   80133e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801816:	83 c4 08             	add    $0x8,%esp
  801819:	ff 75 d4             	pushl  -0x2c(%ebp)
  80181c:	6a 00                	push   $0x0
  80181e:	e8 1b fb ff ff       	call   80133e <sys_page_unmap>
	return r;
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	89 f8                	mov    %edi,%eax
}
  801828:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5e                   	pop    %esi
  80182d:	5f                   	pop    %edi
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	53                   	push   %ebx
  801834:	83 ec 14             	sub    $0x14,%esp
  801837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183d:	50                   	push   %eax
  80183e:	53                   	push   %ebx
  80183f:	e8 7d fd ff ff       	call   8015c1 <fd_lookup>
  801844:	83 c4 08             	add    $0x8,%esp
  801847:	89 c2                	mov    %eax,%edx
  801849:	85 c0                	test   %eax,%eax
  80184b:	78 6d                	js     8018ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184d:	83 ec 08             	sub    $0x8,%esp
  801850:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801853:	50                   	push   %eax
  801854:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801857:	ff 30                	pushl  (%eax)
  801859:	e8 b9 fd ff ff       	call   801617 <dev_lookup>
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	85 c0                	test   %eax,%eax
  801863:	78 4c                	js     8018b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801865:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801868:	8b 42 08             	mov    0x8(%edx),%eax
  80186b:	83 e0 03             	and    $0x3,%eax
  80186e:	83 f8 01             	cmp    $0x1,%eax
  801871:	75 21                	jne    801894 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801873:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801878:	8b 40 48             	mov    0x48(%eax),%eax
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	53                   	push   %ebx
  80187f:	50                   	push   %eax
  801880:	68 0d 33 80 00       	push   $0x80330d
  801885:	e8 9f f0 ff ff       	call   800929 <cprintf>
		return -E_INVAL;
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801892:	eb 26                	jmp    8018ba <read+0x8a>
	}
	if (!dev->dev_read)
  801894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801897:	8b 40 08             	mov    0x8(%eax),%eax
  80189a:	85 c0                	test   %eax,%eax
  80189c:	74 17                	je     8018b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	ff 75 10             	pushl  0x10(%ebp)
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	52                   	push   %edx
  8018a8:	ff d0                	call   *%eax
  8018aa:	89 c2                	mov    %eax,%edx
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	eb 09                	jmp    8018ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b1:	89 c2                	mov    %eax,%edx
  8018b3:	eb 05                	jmp    8018ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8018b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8018ba:	89 d0                	mov    %edx,%eax
  8018bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	57                   	push   %edi
  8018c5:	56                   	push   %esi
  8018c6:	53                   	push   %ebx
  8018c7:	83 ec 0c             	sub    $0xc,%esp
  8018ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018d5:	eb 21                	jmp    8018f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018d7:	83 ec 04             	sub    $0x4,%esp
  8018da:	89 f0                	mov    %esi,%eax
  8018dc:	29 d8                	sub    %ebx,%eax
  8018de:	50                   	push   %eax
  8018df:	89 d8                	mov    %ebx,%eax
  8018e1:	03 45 0c             	add    0xc(%ebp),%eax
  8018e4:	50                   	push   %eax
  8018e5:	57                   	push   %edi
  8018e6:	e8 45 ff ff ff       	call   801830 <read>
		if (m < 0)
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 0c                	js     8018fe <readn+0x3d>
			return m;
		if (m == 0)
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	74 06                	je     8018fc <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018f6:	01 c3                	add    %eax,%ebx
  8018f8:	39 f3                	cmp    %esi,%ebx
  8018fa:	72 db                	jb     8018d7 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8018fc:	89 d8                	mov    %ebx,%eax
}
  8018fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801901:	5b                   	pop    %ebx
  801902:	5e                   	pop    %esi
  801903:	5f                   	pop    %edi
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	53                   	push   %ebx
  80190a:	83 ec 14             	sub    $0x14,%esp
  80190d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801910:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	53                   	push   %ebx
  801915:	e8 a7 fc ff ff       	call   8015c1 <fd_lookup>
  80191a:	83 c4 08             	add    $0x8,%esp
  80191d:	89 c2                	mov    %eax,%edx
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 68                	js     80198b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801929:	50                   	push   %eax
  80192a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192d:	ff 30                	pushl  (%eax)
  80192f:	e8 e3 fc ff ff       	call   801617 <dev_lookup>
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	78 47                	js     801982 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80193b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801942:	75 21                	jne    801965 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801944:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801949:	8b 40 48             	mov    0x48(%eax),%eax
  80194c:	83 ec 04             	sub    $0x4,%esp
  80194f:	53                   	push   %ebx
  801950:	50                   	push   %eax
  801951:	68 29 33 80 00       	push   $0x803329
  801956:	e8 ce ef ff ff       	call   800929 <cprintf>
		return -E_INVAL;
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801963:	eb 26                	jmp    80198b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801965:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801968:	8b 52 0c             	mov    0xc(%edx),%edx
  80196b:	85 d2                	test   %edx,%edx
  80196d:	74 17                	je     801986 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80196f:	83 ec 04             	sub    $0x4,%esp
  801972:	ff 75 10             	pushl  0x10(%ebp)
  801975:	ff 75 0c             	pushl  0xc(%ebp)
  801978:	50                   	push   %eax
  801979:	ff d2                	call   *%edx
  80197b:	89 c2                	mov    %eax,%edx
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	eb 09                	jmp    80198b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801982:	89 c2                	mov    %eax,%edx
  801984:	eb 05                	jmp    80198b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801986:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80198b:	89 d0                	mov    %edx,%eax
  80198d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <seek>:

int
seek(int fdnum, off_t offset)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801998:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80199b:	50                   	push   %eax
  80199c:	ff 75 08             	pushl  0x8(%ebp)
  80199f:	e8 1d fc ff ff       	call   8015c1 <fd_lookup>
  8019a4:	83 c4 08             	add    $0x8,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 0e                	js     8019b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8019ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	53                   	push   %ebx
  8019bf:	83 ec 14             	sub    $0x14,%esp
  8019c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	53                   	push   %ebx
  8019ca:	e8 f2 fb ff ff       	call   8015c1 <fd_lookup>
  8019cf:	83 c4 08             	add    $0x8,%esp
  8019d2:	89 c2                	mov    %eax,%edx
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 65                	js     801a3d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019de:	50                   	push   %eax
  8019df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e2:	ff 30                	pushl  (%eax)
  8019e4:	e8 2e fc ff ff       	call   801617 <dev_lookup>
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	78 44                	js     801a34 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019f7:	75 21                	jne    801a1a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019f9:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019fe:	8b 40 48             	mov    0x48(%eax),%eax
  801a01:	83 ec 04             	sub    $0x4,%esp
  801a04:	53                   	push   %ebx
  801a05:	50                   	push   %eax
  801a06:	68 ec 32 80 00       	push   $0x8032ec
  801a0b:	e8 19 ef ff ff       	call   800929 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a18:	eb 23                	jmp    801a3d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801a1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a1d:	8b 52 18             	mov    0x18(%edx),%edx
  801a20:	85 d2                	test   %edx,%edx
  801a22:	74 14                	je     801a38 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a24:	83 ec 08             	sub    $0x8,%esp
  801a27:	ff 75 0c             	pushl  0xc(%ebp)
  801a2a:	50                   	push   %eax
  801a2b:	ff d2                	call   *%edx
  801a2d:	89 c2                	mov    %eax,%edx
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	eb 09                	jmp    801a3d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a34:	89 c2                	mov    %eax,%edx
  801a36:	eb 05                	jmp    801a3d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a38:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801a3d:	89 d0                	mov    %edx,%eax
  801a3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	53                   	push   %ebx
  801a48:	83 ec 14             	sub    $0x14,%esp
  801a4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a51:	50                   	push   %eax
  801a52:	ff 75 08             	pushl  0x8(%ebp)
  801a55:	e8 67 fb ff ff       	call   8015c1 <fd_lookup>
  801a5a:	83 c4 08             	add    $0x8,%esp
  801a5d:	89 c2                	mov    %eax,%edx
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	78 58                	js     801abb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a63:	83 ec 08             	sub    $0x8,%esp
  801a66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a69:	50                   	push   %eax
  801a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6d:	ff 30                	pushl  (%eax)
  801a6f:	e8 a3 fb ff ff       	call   801617 <dev_lookup>
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	85 c0                	test   %eax,%eax
  801a79:	78 37                	js     801ab2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a82:	74 32                	je     801ab6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a84:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a87:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a8e:	00 00 00 
	stat->st_isdir = 0;
  801a91:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a98:	00 00 00 
	stat->st_dev = dev;
  801a9b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801aa1:	83 ec 08             	sub    $0x8,%esp
  801aa4:	53                   	push   %ebx
  801aa5:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa8:	ff 50 14             	call   *0x14(%eax)
  801aab:	89 c2                	mov    %eax,%edx
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	eb 09                	jmp    801abb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab2:	89 c2                	mov    %eax,%edx
  801ab4:	eb 05                	jmp    801abb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ab6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801abb:	89 d0                	mov    %edx,%eax
  801abd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	56                   	push   %esi
  801ac6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ac7:	83 ec 08             	sub    $0x8,%esp
  801aca:	6a 00                	push   $0x0
  801acc:	ff 75 08             	pushl  0x8(%ebp)
  801acf:	e8 09 02 00 00       	call   801cdd <open>
  801ad4:	89 c3                	mov    %eax,%ebx
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	85 db                	test   %ebx,%ebx
  801adb:	78 1b                	js     801af8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801add:	83 ec 08             	sub    $0x8,%esp
  801ae0:	ff 75 0c             	pushl  0xc(%ebp)
  801ae3:	53                   	push   %ebx
  801ae4:	e8 5b ff ff ff       	call   801a44 <fstat>
  801ae9:	89 c6                	mov    %eax,%esi
	close(fd);
  801aeb:	89 1c 24             	mov    %ebx,(%esp)
  801aee:	e8 fd fb ff ff       	call   8016f0 <close>
	return r;
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	89 f0                	mov    %esi,%eax
}
  801af8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afb:	5b                   	pop    %ebx
  801afc:	5e                   	pop    %esi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    

00801aff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	89 c6                	mov    %eax,%esi
  801b06:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b08:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  801b0f:	75 12                	jne    801b23 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b11:	83 ec 0c             	sub    $0xc,%esp
  801b14:	6a 01                	push   $0x1
  801b16:	e8 dd 0e 00 00       	call   8029f8 <ipc_find_env>
  801b1b:	a3 10 50 80 00       	mov    %eax,0x805010
  801b20:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b23:	6a 07                	push   $0x7
  801b25:	68 00 60 80 00       	push   $0x806000
  801b2a:	56                   	push   %esi
  801b2b:	ff 35 10 50 80 00    	pushl  0x805010
  801b31:	e8 6e 0e 00 00       	call   8029a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b36:	83 c4 0c             	add    $0xc,%esp
  801b39:	6a 00                	push   $0x0
  801b3b:	53                   	push   %ebx
  801b3c:	6a 00                	push   $0x0
  801b3e:	e8 f8 0d 00 00       	call   80293b <ipc_recv>
}
  801b43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5e                   	pop    %esi
  801b48:	5d                   	pop    %ebp
  801b49:	c3                   	ret    

00801b4a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	8b 40 0c             	mov    0xc(%eax),%eax
  801b56:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5e:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b63:	ba 00 00 00 00       	mov    $0x0,%edx
  801b68:	b8 02 00 00 00       	mov    $0x2,%eax
  801b6d:	e8 8d ff ff ff       	call   801aff <fsipc>
}
  801b72:	c9                   	leave  
  801b73:	c3                   	ret    

00801b74 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b80:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b85:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8a:	b8 06 00 00 00       	mov    $0x6,%eax
  801b8f:	e8 6b ff ff ff       	call   801aff <fsipc>
}
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 04             	sub    $0x4,%esp
  801b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba6:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bab:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb0:	b8 05 00 00 00       	mov    $0x5,%eax
  801bb5:	e8 45 ff ff ff       	call   801aff <fsipc>
  801bba:	89 c2                	mov    %eax,%edx
  801bbc:	85 d2                	test   %edx,%edx
  801bbe:	78 2c                	js     801bec <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bc0:	83 ec 08             	sub    $0x8,%esp
  801bc3:	68 00 60 80 00       	push   $0x806000
  801bc8:	53                   	push   %ebx
  801bc9:	e8 e2 f2 ff ff       	call   800eb0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bce:	a1 80 60 80 00       	mov    0x806080,%eax
  801bd3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bd9:	a1 84 60 80 00       	mov    0x806084,%eax
  801bde:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bef:	c9                   	leave  
  801bf0:	c3                   	ret    

00801bf1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	57                   	push   %edi
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801c00:	8b 40 0c             	mov    0xc(%eax),%eax
  801c03:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801c08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801c0b:	eb 3d                	jmp    801c4a <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801c0d:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801c13:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801c18:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801c1b:	83 ec 04             	sub    $0x4,%esp
  801c1e:	57                   	push   %edi
  801c1f:	53                   	push   %ebx
  801c20:	68 08 60 80 00       	push   $0x806008
  801c25:	e8 18 f4 ff ff       	call   801042 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801c2a:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801c30:	ba 00 00 00 00       	mov    $0x0,%edx
  801c35:	b8 04 00 00 00       	mov    $0x4,%eax
  801c3a:	e8 c0 fe ff ff       	call   801aff <fsipc>
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	85 c0                	test   %eax,%eax
  801c44:	78 0d                	js     801c53 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801c46:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801c48:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801c4a:	85 f6                	test   %esi,%esi
  801c4c:	75 bf                	jne    801c0d <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801c4e:	89 d8                	mov    %ebx,%eax
  801c50:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5f                   	pop    %edi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	56                   	push   %esi
  801c5f:	53                   	push   %ebx
  801c60:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	8b 40 0c             	mov    0xc(%eax),%eax
  801c69:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c6e:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c74:	ba 00 00 00 00       	mov    $0x0,%edx
  801c79:	b8 03 00 00 00       	mov    $0x3,%eax
  801c7e:	e8 7c fe ff ff       	call   801aff <fsipc>
  801c83:	89 c3                	mov    %eax,%ebx
  801c85:	85 c0                	test   %eax,%eax
  801c87:	78 4b                	js     801cd4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801c89:	39 c6                	cmp    %eax,%esi
  801c8b:	73 16                	jae    801ca3 <devfile_read+0x48>
  801c8d:	68 5c 33 80 00       	push   $0x80335c
  801c92:	68 63 33 80 00       	push   $0x803363
  801c97:	6a 7c                	push   $0x7c
  801c99:	68 78 33 80 00       	push   $0x803378
  801c9e:	e8 ad eb ff ff       	call   800850 <_panic>
	assert(r <= PGSIZE);
  801ca3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ca8:	7e 16                	jle    801cc0 <devfile_read+0x65>
  801caa:	68 83 33 80 00       	push   $0x803383
  801caf:	68 63 33 80 00       	push   $0x803363
  801cb4:	6a 7d                	push   $0x7d
  801cb6:	68 78 33 80 00       	push   $0x803378
  801cbb:	e8 90 eb ff ff       	call   800850 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cc0:	83 ec 04             	sub    $0x4,%esp
  801cc3:	50                   	push   %eax
  801cc4:	68 00 60 80 00       	push   $0x806000
  801cc9:	ff 75 0c             	pushl  0xc(%ebp)
  801ccc:	e8 71 f3 ff ff       	call   801042 <memmove>
	return r;
  801cd1:	83 c4 10             	add    $0x10,%esp
}
  801cd4:	89 d8                	mov    %ebx,%eax
  801cd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd9:	5b                   	pop    %ebx
  801cda:	5e                   	pop    %esi
  801cdb:	5d                   	pop    %ebp
  801cdc:	c3                   	ret    

00801cdd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	53                   	push   %ebx
  801ce1:	83 ec 20             	sub    $0x20,%esp
  801ce4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ce7:	53                   	push   %ebx
  801ce8:	e8 8a f1 ff ff       	call   800e77 <strlen>
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cf5:	7f 67                	jg     801d5e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cf7:	83 ec 0c             	sub    $0xc,%esp
  801cfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	e8 6f f8 ff ff       	call   801572 <fd_alloc>
  801d03:	83 c4 10             	add    $0x10,%esp
		return r;
  801d06:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	78 57                	js     801d63 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d0c:	83 ec 08             	sub    $0x8,%esp
  801d0f:	53                   	push   %ebx
  801d10:	68 00 60 80 00       	push   $0x806000
  801d15:	e8 96 f1 ff ff       	call   800eb0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1d:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d25:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2a:	e8 d0 fd ff ff       	call   801aff <fsipc>
  801d2f:	89 c3                	mov    %eax,%ebx
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	79 14                	jns    801d4c <open+0x6f>
		fd_close(fd, 0);
  801d38:	83 ec 08             	sub    $0x8,%esp
  801d3b:	6a 00                	push   $0x0
  801d3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d40:	e8 2a f9 ff ff       	call   80166f <fd_close>
		return r;
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	89 da                	mov    %ebx,%edx
  801d4a:	eb 17                	jmp    801d63 <open+0x86>
	}

	return fd2num(fd);
  801d4c:	83 ec 0c             	sub    $0xc,%esp
  801d4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d52:	e8 f4 f7 ff ff       	call   80154b <fd2num>
  801d57:	89 c2                	mov    %eax,%edx
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	eb 05                	jmp    801d63 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d5e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d63:	89 d0                	mov    %edx,%eax
  801d65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d68:	c9                   	leave  
  801d69:	c3                   	ret    

00801d6a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d70:	ba 00 00 00 00       	mov    $0x0,%edx
  801d75:	b8 08 00 00 00       	mov    $0x8,%eax
  801d7a:	e8 80 fd ff ff       	call   801aff <fsipc>
}
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    

00801d81 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d87:	68 8f 33 80 00       	push   $0x80338f
  801d8c:	ff 75 0c             	pushl  0xc(%ebp)
  801d8f:	e8 1c f1 ff ff       	call   800eb0 <strcpy>
	return 0;
}
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	53                   	push   %ebx
  801d9f:	83 ec 10             	sub    $0x10,%esp
  801da2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801da5:	53                   	push   %ebx
  801da6:	e8 85 0c 00 00       	call   802a30 <pageref>
  801dab:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801dae:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801db3:	83 f8 01             	cmp    $0x1,%eax
  801db6:	75 10                	jne    801dc8 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801db8:	83 ec 0c             	sub    $0xc,%esp
  801dbb:	ff 73 0c             	pushl  0xc(%ebx)
  801dbe:	e8 ca 02 00 00       	call   80208d <nsipc_close>
  801dc3:	89 c2                	mov    %eax,%edx
  801dc5:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801dc8:	89 d0                	mov    %edx,%eax
  801dca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801dd5:	6a 00                	push   $0x0
  801dd7:	ff 75 10             	pushl  0x10(%ebp)
  801dda:	ff 75 0c             	pushl  0xc(%ebp)
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	ff 70 0c             	pushl  0xc(%eax)
  801de3:	e8 82 03 00 00       	call   80216a <nsipc_send>
}
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801df0:	6a 00                	push   $0x0
  801df2:	ff 75 10             	pushl  0x10(%ebp)
  801df5:	ff 75 0c             	pushl  0xc(%ebp)
  801df8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfb:	ff 70 0c             	pushl  0xc(%eax)
  801dfe:	e8 fb 02 00 00       	call   8020fe <nsipc_recv>
}
  801e03:	c9                   	leave  
  801e04:	c3                   	ret    

00801e05 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e0b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e0e:	52                   	push   %edx
  801e0f:	50                   	push   %eax
  801e10:	e8 ac f7 ff ff       	call   8015c1 <fd_lookup>
  801e15:	83 c4 10             	add    $0x10,%esp
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	78 17                	js     801e33 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1f:	8b 0d 40 40 80 00    	mov    0x804040,%ecx
  801e25:	39 08                	cmp    %ecx,(%eax)
  801e27:	75 05                	jne    801e2e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e29:	8b 40 0c             	mov    0xc(%eax),%eax
  801e2c:	eb 05                	jmp    801e33 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e2e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    

00801e35 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	56                   	push   %esi
  801e39:	53                   	push   %ebx
  801e3a:	83 ec 1c             	sub    $0x1c,%esp
  801e3d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e42:	50                   	push   %eax
  801e43:	e8 2a f7 ff ff       	call   801572 <fd_alloc>
  801e48:	89 c3                	mov    %eax,%ebx
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 1b                	js     801e6c <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e51:	83 ec 04             	sub    $0x4,%esp
  801e54:	68 07 04 00 00       	push   $0x407
  801e59:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5c:	6a 00                	push   $0x0
  801e5e:	e8 56 f4 ff ff       	call   8012b9 <sys_page_alloc>
  801e63:	89 c3                	mov    %eax,%ebx
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	79 10                	jns    801e7c <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801e6c:	83 ec 0c             	sub    $0xc,%esp
  801e6f:	56                   	push   %esi
  801e70:	e8 18 02 00 00       	call   80208d <nsipc_close>
		return r;
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	89 d8                	mov    %ebx,%eax
  801e7a:	eb 24                	jmp    801ea0 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e7c:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e85:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e87:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e8a:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801e91:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801e94:	83 ec 0c             	sub    $0xc,%esp
  801e97:	52                   	push   %edx
  801e98:	e8 ae f6 ff ff       	call   80154b <fd2num>
  801e9d:	83 c4 10             	add    $0x10,%esp
}
  801ea0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ead:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb0:	e8 50 ff ff ff       	call   801e05 <fd2sockid>
		return r;
  801eb5:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 1f                	js     801eda <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ebb:	83 ec 04             	sub    $0x4,%esp
  801ebe:	ff 75 10             	pushl  0x10(%ebp)
  801ec1:	ff 75 0c             	pushl  0xc(%ebp)
  801ec4:	50                   	push   %eax
  801ec5:	e8 1c 01 00 00       	call   801fe6 <nsipc_accept>
  801eca:	83 c4 10             	add    $0x10,%esp
		return r;
  801ecd:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	78 07                	js     801eda <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ed3:	e8 5d ff ff ff       	call   801e35 <alloc_sockfd>
  801ed8:	89 c1                	mov    %eax,%ecx
}
  801eda:	89 c8                	mov    %ecx,%eax
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee7:	e8 19 ff ff ff       	call   801e05 <fd2sockid>
  801eec:	89 c2                	mov    %eax,%edx
  801eee:	85 d2                	test   %edx,%edx
  801ef0:	78 12                	js     801f04 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801ef2:	83 ec 04             	sub    $0x4,%esp
  801ef5:	ff 75 10             	pushl  0x10(%ebp)
  801ef8:	ff 75 0c             	pushl  0xc(%ebp)
  801efb:	52                   	push   %edx
  801efc:	e8 35 01 00 00       	call   802036 <nsipc_bind>
  801f01:	83 c4 10             	add    $0x10,%esp
}
  801f04:	c9                   	leave  
  801f05:	c3                   	ret    

00801f06 <shutdown>:

int
shutdown(int s, int how)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0f:	e8 f1 fe ff ff       	call   801e05 <fd2sockid>
  801f14:	89 c2                	mov    %eax,%edx
  801f16:	85 d2                	test   %edx,%edx
  801f18:	78 0f                	js     801f29 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	ff 75 0c             	pushl  0xc(%ebp)
  801f20:	52                   	push   %edx
  801f21:	e8 45 01 00 00       	call   80206b <nsipc_shutdown>
  801f26:	83 c4 10             	add    $0x10,%esp
}
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    

00801f2b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f31:	8b 45 08             	mov    0x8(%ebp),%eax
  801f34:	e8 cc fe ff ff       	call   801e05 <fd2sockid>
  801f39:	89 c2                	mov    %eax,%edx
  801f3b:	85 d2                	test   %edx,%edx
  801f3d:	78 12                	js     801f51 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801f3f:	83 ec 04             	sub    $0x4,%esp
  801f42:	ff 75 10             	pushl  0x10(%ebp)
  801f45:	ff 75 0c             	pushl  0xc(%ebp)
  801f48:	52                   	push   %edx
  801f49:	e8 59 01 00 00       	call   8020a7 <nsipc_connect>
  801f4e:	83 c4 10             	add    $0x10,%esp
}
  801f51:	c9                   	leave  
  801f52:	c3                   	ret    

00801f53 <listen>:

int
listen(int s, int backlog)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f59:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5c:	e8 a4 fe ff ff       	call   801e05 <fd2sockid>
  801f61:	89 c2                	mov    %eax,%edx
  801f63:	85 d2                	test   %edx,%edx
  801f65:	78 0f                	js     801f76 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801f67:	83 ec 08             	sub    $0x8,%esp
  801f6a:	ff 75 0c             	pushl  0xc(%ebp)
  801f6d:	52                   	push   %edx
  801f6e:	e8 69 01 00 00       	call   8020dc <nsipc_listen>
  801f73:	83 c4 10             	add    $0x10,%esp
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f7e:	ff 75 10             	pushl  0x10(%ebp)
  801f81:	ff 75 0c             	pushl  0xc(%ebp)
  801f84:	ff 75 08             	pushl  0x8(%ebp)
  801f87:	e8 3c 02 00 00       	call   8021c8 <nsipc_socket>
  801f8c:	89 c2                	mov    %eax,%edx
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	85 d2                	test   %edx,%edx
  801f93:	78 05                	js     801f9a <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801f95:	e8 9b fe ff ff       	call   801e35 <alloc_sockfd>
}
  801f9a:	c9                   	leave  
  801f9b:	c3                   	ret    

00801f9c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	53                   	push   %ebx
  801fa0:	83 ec 04             	sub    $0x4,%esp
  801fa3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fa5:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  801fac:	75 12                	jne    801fc0 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fae:	83 ec 0c             	sub    $0xc,%esp
  801fb1:	6a 02                	push   $0x2
  801fb3:	e8 40 0a 00 00       	call   8029f8 <ipc_find_env>
  801fb8:	a3 14 50 80 00       	mov    %eax,0x805014
  801fbd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fc0:	6a 07                	push   $0x7
  801fc2:	68 00 70 80 00       	push   $0x807000
  801fc7:	53                   	push   %ebx
  801fc8:	ff 35 14 50 80 00    	pushl  0x805014
  801fce:	e8 d1 09 00 00       	call   8029a4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fd3:	83 c4 0c             	add    $0xc,%esp
  801fd6:	6a 00                	push   $0x0
  801fd8:	6a 00                	push   $0x0
  801fda:	6a 00                	push   $0x0
  801fdc:	e8 5a 09 00 00       	call   80293b <ipc_recv>
}
  801fe1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    

00801fe6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	56                   	push   %esi
  801fea:	53                   	push   %ebx
  801feb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ff6:	8b 06                	mov    (%esi),%eax
  801ff8:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ffd:	b8 01 00 00 00       	mov    $0x1,%eax
  802002:	e8 95 ff ff ff       	call   801f9c <nsipc>
  802007:	89 c3                	mov    %eax,%ebx
  802009:	85 c0                	test   %eax,%eax
  80200b:	78 20                	js     80202d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80200d:	83 ec 04             	sub    $0x4,%esp
  802010:	ff 35 10 70 80 00    	pushl  0x807010
  802016:	68 00 70 80 00       	push   $0x807000
  80201b:	ff 75 0c             	pushl  0xc(%ebp)
  80201e:	e8 1f f0 ff ff       	call   801042 <memmove>
		*addrlen = ret->ret_addrlen;
  802023:	a1 10 70 80 00       	mov    0x807010,%eax
  802028:	89 06                	mov    %eax,(%esi)
  80202a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80202d:	89 d8                	mov    %ebx,%eax
  80202f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802032:	5b                   	pop    %ebx
  802033:	5e                   	pop    %esi
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    

00802036 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	53                   	push   %ebx
  80203a:	83 ec 08             	sub    $0x8,%esp
  80203d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802040:	8b 45 08             	mov    0x8(%ebp),%eax
  802043:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802048:	53                   	push   %ebx
  802049:	ff 75 0c             	pushl  0xc(%ebp)
  80204c:	68 04 70 80 00       	push   $0x807004
  802051:	e8 ec ef ff ff       	call   801042 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802056:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80205c:	b8 02 00 00 00       	mov    $0x2,%eax
  802061:	e8 36 ff ff ff       	call   801f9c <nsipc>
}
  802066:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802069:	c9                   	leave  
  80206a:	c3                   	ret    

0080206b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802071:	8b 45 08             	mov    0x8(%ebp),%eax
  802074:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802079:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802081:	b8 03 00 00 00       	mov    $0x3,%eax
  802086:	e8 11 ff ff ff       	call   801f9c <nsipc>
}
  80208b:	c9                   	leave  
  80208c:	c3                   	ret    

0080208d <nsipc_close>:

int
nsipc_close(int s)
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802093:	8b 45 08             	mov    0x8(%ebp),%eax
  802096:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80209b:	b8 04 00 00 00       	mov    $0x4,%eax
  8020a0:	e8 f7 fe ff ff       	call   801f9c <nsipc>
}
  8020a5:	c9                   	leave  
  8020a6:	c3                   	ret    

008020a7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	53                   	push   %ebx
  8020ab:	83 ec 08             	sub    $0x8,%esp
  8020ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b4:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020b9:	53                   	push   %ebx
  8020ba:	ff 75 0c             	pushl  0xc(%ebp)
  8020bd:	68 04 70 80 00       	push   $0x807004
  8020c2:	e8 7b ef ff ff       	call   801042 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020c7:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8020cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8020d2:	e8 c5 fe ff ff       	call   801f9c <nsipc>
}
  8020d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020da:	c9                   	leave  
  8020db:	c3                   	ret    

008020dc <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ed:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8020f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8020f7:	e8 a0 fe ff ff       	call   801f9c <nsipc>
}
  8020fc:	c9                   	leave  
  8020fd:	c3                   	ret    

008020fe <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	56                   	push   %esi
  802102:	53                   	push   %ebx
  802103:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802106:	8b 45 08             	mov    0x8(%ebp),%eax
  802109:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80210e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802114:	8b 45 14             	mov    0x14(%ebp),%eax
  802117:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80211c:	b8 07 00 00 00       	mov    $0x7,%eax
  802121:	e8 76 fe ff ff       	call   801f9c <nsipc>
  802126:	89 c3                	mov    %eax,%ebx
  802128:	85 c0                	test   %eax,%eax
  80212a:	78 35                	js     802161 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80212c:	39 f0                	cmp    %esi,%eax
  80212e:	7f 07                	jg     802137 <nsipc_recv+0x39>
  802130:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802135:	7e 16                	jle    80214d <nsipc_recv+0x4f>
  802137:	68 9b 33 80 00       	push   $0x80339b
  80213c:	68 63 33 80 00       	push   $0x803363
  802141:	6a 62                	push   $0x62
  802143:	68 b0 33 80 00       	push   $0x8033b0
  802148:	e8 03 e7 ff ff       	call   800850 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80214d:	83 ec 04             	sub    $0x4,%esp
  802150:	50                   	push   %eax
  802151:	68 00 70 80 00       	push   $0x807000
  802156:	ff 75 0c             	pushl  0xc(%ebp)
  802159:	e8 e4 ee ff ff       	call   801042 <memmove>
  80215e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802161:	89 d8                	mov    %ebx,%eax
  802163:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802166:	5b                   	pop    %ebx
  802167:	5e                   	pop    %esi
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    

0080216a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	53                   	push   %ebx
  80216e:	83 ec 04             	sub    $0x4,%esp
  802171:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802174:	8b 45 08             	mov    0x8(%ebp),%eax
  802177:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80217c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802182:	7e 16                	jle    80219a <nsipc_send+0x30>
  802184:	68 bc 33 80 00       	push   $0x8033bc
  802189:	68 63 33 80 00       	push   $0x803363
  80218e:	6a 6d                	push   $0x6d
  802190:	68 b0 33 80 00       	push   $0x8033b0
  802195:	e8 b6 e6 ff ff       	call   800850 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80219a:	83 ec 04             	sub    $0x4,%esp
  80219d:	53                   	push   %ebx
  80219e:	ff 75 0c             	pushl  0xc(%ebp)
  8021a1:	68 0c 70 80 00       	push   $0x80700c
  8021a6:	e8 97 ee ff ff       	call   801042 <memmove>
	nsipcbuf.send.req_size = size;
  8021ab:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8021b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8021b4:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8021b9:	b8 08 00 00 00       	mov    $0x8,%eax
  8021be:	e8 d9 fd ff ff       	call   801f9c <nsipc>
}
  8021c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c6:	c9                   	leave  
  8021c7:	c3                   	ret    

008021c8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8021d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d9:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8021de:	8b 45 10             	mov    0x10(%ebp),%eax
  8021e1:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8021e6:	b8 09 00 00 00       	mov    $0x9,%eax
  8021eb:	e8 ac fd ff ff       	call   801f9c <nsipc>
}
  8021f0:	c9                   	leave  
  8021f1:	c3                   	ret    

008021f2 <free>:
	return v;
}

void
free(void *v)
{
  8021f2:	55                   	push   %ebp
  8021f3:	89 e5                	mov    %esp,%ebp
  8021f5:	53                   	push   %ebx
  8021f6:	83 ec 04             	sub    $0x4,%esp
  8021f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  8021fc:	85 db                	test   %ebx,%ebx
  8021fe:	0f 84 97 00 00 00    	je     80229b <free+0xa9>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  802204:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  80220a:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  80220f:	76 16                	jbe    802227 <free+0x35>
  802211:	68 c8 33 80 00       	push   $0x8033c8
  802216:	68 63 33 80 00       	push   $0x803363
  80221b:	6a 7a                	push   $0x7a
  80221d:	68 f8 33 80 00       	push   $0x8033f8
  802222:	e8 29 e6 ff ff       	call   800850 <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  802227:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  80222d:	eb 3a                	jmp    802269 <free+0x77>
		sys_page_unmap(0, c);
  80222f:	83 ec 08             	sub    $0x8,%esp
  802232:	53                   	push   %ebx
  802233:	6a 00                	push   $0x0
  802235:	e8 04 f1 ff ff       	call   80133e <sys_page_unmap>
		c += PGSIZE;
  80223a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802240:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
		assert(mbegin <= c && c < mend);
  802246:	83 c4 10             	add    $0x10,%esp
  802249:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  80224e:	76 19                	jbe    802269 <free+0x77>
  802250:	68 05 34 80 00       	push   $0x803405
  802255:	68 63 33 80 00       	push   $0x803363
  80225a:	68 81 00 00 00       	push   $0x81
  80225f:	68 f8 33 80 00       	push   $0x8033f8
  802264:	e8 e7 e5 ff ff       	call   800850 <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  802269:	89 d8                	mov    %ebx,%eax
  80226b:	c1 e8 0c             	shr    $0xc,%eax
  80226e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802275:	f6 c4 02             	test   $0x2,%ah
  802278:	75 b5                	jne    80222f <free+0x3d>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  80227a:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  802280:	83 e8 01             	sub    $0x1,%eax
  802283:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  802289:	85 c0                	test   %eax,%eax
  80228b:	75 0e                	jne    80229b <free+0xa9>
		sys_page_unmap(0, c);
  80228d:	83 ec 08             	sub    $0x8,%esp
  802290:	53                   	push   %ebx
  802291:	6a 00                	push   $0x0
  802293:	e8 a6 f0 ff ff       	call   80133e <sys_page_unmap>
  802298:	83 c4 10             	add    $0x10,%esp
}
  80229b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80229e:	c9                   	leave  
  80229f:	c3                   	ret    

008022a0 <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	57                   	push   %edi
  8022a4:	56                   	push   %esi
  8022a5:	53                   	push   %ebx
  8022a6:	83 ec 1c             	sub    $0x1c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  8022a9:	a1 18 50 80 00       	mov    0x805018,%eax
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	75 22                	jne    8022d4 <malloc+0x34>
		mptr = mbegin;
  8022b2:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8022b9:	00 00 08 

	n = ROUNDUP(n, 4);
  8022bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bf:	83 c0 03             	add    $0x3,%eax
  8022c2:	83 e0 fc             	and    $0xfffffffc,%eax
  8022c5:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if (n >= MAXMALLOC)
  8022c8:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  8022cd:	76 75                	jbe    802344 <malloc+0xa4>
  8022cf:	e9 77 01 00 00       	jmp    80244b <malloc+0x1ab>
	void *v;

	if (mptr == 0)
		mptr = mbegin;

	n = ROUNDUP(n, 4);
  8022d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8022d7:	8d 53 03             	lea    0x3(%ebx),%edx
  8022da:	83 e2 fc             	and    $0xfffffffc,%edx
  8022dd:	89 55 e0             	mov    %edx,-0x20(%ebp)

	if (n >= MAXMALLOC)
  8022e0:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  8022e6:	0f 87 66 01 00 00    	ja     802452 <malloc+0x1b2>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  8022ec:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8022f1:	74 51                	je     802344 <malloc+0xa4>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  8022f3:	89 c1                	mov    %eax,%ecx
  8022f5:	c1 e9 0c             	shr    $0xc,%ecx
  8022f8:	89 d3                	mov    %edx,%ebx
  8022fa:	8d 54 10 03          	lea    0x3(%eax,%edx,1),%edx
  8022fe:	c1 ea 0c             	shr    $0xc,%edx
  802301:	39 d1                	cmp    %edx,%ecx
  802303:	75 1f                	jne    802324 <malloc+0x84>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  802305:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80230b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  802311:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			v = mptr;
			mptr += n;
  802315:	89 da                	mov    %ebx,%edx
  802317:	01 c2                	add    %eax,%edx
  802319:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  80231f:	e9 33 01 00 00       	jmp    802457 <malloc+0x1b7>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  802324:	83 ec 0c             	sub    $0xc,%esp
  802327:	50                   	push   %eax
  802328:	e8 c5 fe ff ff       	call   8021f2 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  80232d:	a1 18 50 80 00       	mov    0x805018,%eax
  802332:	05 00 10 00 00       	add    $0x1000,%eax
  802337:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80233c:	a3 18 50 80 00       	mov    %eax,0x805018
  802341:	83 c4 10             	add    $0x10,%esp
  802344:	8b 35 18 50 80 00    	mov    0x805018,%esi
	return 1;
}

void*
malloc(size_t n)
{
  80234a:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  802351:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802354:	8d 78 04             	lea    0x4(%eax),%edi
  802357:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  80235a:	89 fb                	mov    %edi,%ebx
  80235c:	8d 0c 37             	lea    (%edi,%esi,1),%ecx
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  80235f:	89 f0                	mov    %esi,%eax
  802361:	eb 2e                	jmp    802391 <malloc+0xf1>
		if (va >= (uintptr_t) mend
  802363:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  802368:	77 30                	ja     80239a <malloc+0xfa>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  80236a:	89 c2                	mov    %eax,%edx
  80236c:	c1 ea 16             	shr    $0x16,%edx
  80236f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802376:	f6 c2 01             	test   $0x1,%dl
  802379:	74 11                	je     80238c <malloc+0xec>
  80237b:	89 c2                	mov    %eax,%edx
  80237d:	c1 ea 0c             	shr    $0xc,%edx
  802380:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802387:	f6 c2 01             	test   $0x1,%dl
  80238a:	75 0e                	jne    80239a <malloc+0xfa>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  80238c:	05 00 10 00 00       	add    $0x1000,%eax
  802391:	39 c8                	cmp    %ecx,%eax
  802393:	72 ce                	jb     802363 <malloc+0xc3>
  802395:	e9 84 00 00 00       	jmp    80241e <malloc+0x17e>
  80239a:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
  8023a0:	89 c6                	mov    %eax,%esi
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  8023a2:	3d 00 00 00 10       	cmp    $0x10000000,%eax
  8023a7:	75 ae                	jne    802357 <malloc+0xb7>
			mptr = mbegin;
  8023a9:	be 00 00 00 08       	mov    $0x8000000,%esi
			if (++nwrap == 2)
  8023ae:	83 6d dc 01          	subl   $0x1,-0x24(%ebp)
  8023b2:	75 a3                	jne    802357 <malloc+0xb7>
  8023b4:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8023bb:	00 00 08 
				return 0;	/* out of address space */
  8023be:	b8 00 00 00 00       	mov    $0x0,%eax
  8023c3:	e9 8f 00 00 00       	jmp    802457 <malloc+0x1b7>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8023c8:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
  8023ce:	39 df                	cmp    %ebx,%edi
  8023d0:	19 c0                	sbb    %eax,%eax
  8023d2:	25 00 02 00 00       	and    $0x200,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  8023d7:	83 ec 04             	sub    $0x4,%esp
  8023da:	83 c8 07             	or     $0x7,%eax
  8023dd:	50                   	push   %eax
  8023de:	03 15 18 50 80 00    	add    0x805018,%edx
  8023e4:	52                   	push   %edx
  8023e5:	6a 00                	push   $0x0
  8023e7:	e8 cd ee ff ff       	call   8012b9 <sys_page_alloc>
  8023ec:	83 c4 10             	add    $0x10,%esp
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	78 20                	js     802413 <malloc+0x173>
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  8023f3:	89 fe                	mov    %edi,%esi
  8023f5:	eb 34                	jmp    80242b <malloc+0x18b>
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
				sys_page_unmap(0, mptr + i);
  8023f7:	83 ec 08             	sub    $0x8,%esp
  8023fa:	89 f0                	mov    %esi,%eax
  8023fc:	03 05 18 50 80 00    	add    0x805018,%eax
  802402:	50                   	push   %eax
  802403:	6a 00                	push   $0x0
  802405:	e8 34 ef ff ff       	call   80133e <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  80240a:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  802410:	83 c4 10             	add    $0x10,%esp
  802413:	85 f6                	test   %esi,%esi
  802415:	79 e0                	jns    8023f7 <malloc+0x157>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
  802417:	b8 00 00 00 00       	mov    $0x0,%eax
  80241c:	eb 39                	jmp    802457 <malloc+0x1b7>
  80241e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802421:	a3 18 50 80 00       	mov    %eax,0x805018
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  802426:	be 00 00 00 00       	mov    $0x0,%esi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  80242b:	89 f2                	mov    %esi,%edx
  80242d:	39 f3                	cmp    %esi,%ebx
  80242f:	77 97                	ja     8023c8 <malloc+0x128>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  802431:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  802436:	c7 44 30 fc 02 00 00 	movl   $0x2,-0x4(%eax,%esi,1)
  80243d:	00 
	v = mptr;
	mptr += n;
  80243e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802441:	01 c2                	add    %eax,%edx
  802443:	89 15 18 50 80 00    	mov    %edx,0x805018
	return v;
  802449:	eb 0c                	jmp    802457 <malloc+0x1b7>
		mptr = mbegin;

	n = ROUNDUP(n, 4);

	if (n >= MAXMALLOC)
		return 0;
  80244b:	b8 00 00 00 00       	mov    $0x0,%eax
  802450:	eb 05                	jmp    802457 <malloc+0x1b7>
  802452:	b8 00 00 00 00       	mov    $0x0,%eax
	ref = (uint32_t*) (mptr + i - 4);
	*ref = 2;	/* reference for mptr, reference for returned block */
	v = mptr;
	mptr += n;
	return v;
}
  802457:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80245a:	5b                   	pop    %ebx
  80245b:	5e                   	pop    %esi
  80245c:	5f                   	pop    %edi
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    

0080245f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802467:	83 ec 0c             	sub    $0xc,%esp
  80246a:	ff 75 08             	pushl  0x8(%ebp)
  80246d:	e8 e9 f0 ff ff       	call   80155b <fd2data>
  802472:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802474:	83 c4 08             	add    $0x8,%esp
  802477:	68 1d 34 80 00       	push   $0x80341d
  80247c:	53                   	push   %ebx
  80247d:	e8 2e ea ff ff       	call   800eb0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802482:	8b 56 04             	mov    0x4(%esi),%edx
  802485:	89 d0                	mov    %edx,%eax
  802487:	2b 06                	sub    (%esi),%eax
  802489:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80248f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802496:	00 00 00 
	stat->st_dev = &devpipe;
  802499:	c7 83 88 00 00 00 5c 	movl   $0x80405c,0x88(%ebx)
  8024a0:	40 80 00 
	return 0;
}
  8024a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024ab:	5b                   	pop    %ebx
  8024ac:	5e                   	pop    %esi
  8024ad:	5d                   	pop    %ebp
  8024ae:	c3                   	ret    

008024af <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8024af:	55                   	push   %ebp
  8024b0:	89 e5                	mov    %esp,%ebp
  8024b2:	53                   	push   %ebx
  8024b3:	83 ec 0c             	sub    $0xc,%esp
  8024b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8024b9:	53                   	push   %ebx
  8024ba:	6a 00                	push   $0x0
  8024bc:	e8 7d ee ff ff       	call   80133e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8024c1:	89 1c 24             	mov    %ebx,(%esp)
  8024c4:	e8 92 f0 ff ff       	call   80155b <fd2data>
  8024c9:	83 c4 08             	add    $0x8,%esp
  8024cc:	50                   	push   %eax
  8024cd:	6a 00                	push   $0x0
  8024cf:	e8 6a ee ff ff       	call   80133e <sys_page_unmap>
}
  8024d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024d7:	c9                   	leave  
  8024d8:	c3                   	ret    

008024d9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8024d9:	55                   	push   %ebp
  8024da:	89 e5                	mov    %esp,%ebp
  8024dc:	57                   	push   %edi
  8024dd:	56                   	push   %esi
  8024de:	53                   	push   %ebx
  8024df:	83 ec 1c             	sub    $0x1c,%esp
  8024e2:	89 c6                	mov    %eax,%esi
  8024e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8024e7:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8024ec:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8024ef:	83 ec 0c             	sub    $0xc,%esp
  8024f2:	56                   	push   %esi
  8024f3:	e8 38 05 00 00       	call   802a30 <pageref>
  8024f8:	89 c7                	mov    %eax,%edi
  8024fa:	83 c4 04             	add    $0x4,%esp
  8024fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  802500:	e8 2b 05 00 00       	call   802a30 <pageref>
  802505:	83 c4 10             	add    $0x10,%esp
  802508:	39 c7                	cmp    %eax,%edi
  80250a:	0f 94 c2             	sete   %dl
  80250d:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802510:	8b 0d 1c 50 80 00    	mov    0x80501c,%ecx
  802516:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802519:	39 fb                	cmp    %edi,%ebx
  80251b:	74 19                	je     802536 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80251d:	84 d2                	test   %dl,%dl
  80251f:	74 c6                	je     8024e7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802521:	8b 51 58             	mov    0x58(%ecx),%edx
  802524:	50                   	push   %eax
  802525:	52                   	push   %edx
  802526:	53                   	push   %ebx
  802527:	68 24 34 80 00       	push   $0x803424
  80252c:	e8 f8 e3 ff ff       	call   800929 <cprintf>
  802531:	83 c4 10             	add    $0x10,%esp
  802534:	eb b1                	jmp    8024e7 <_pipeisclosed+0xe>
	}
}
  802536:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802539:	5b                   	pop    %ebx
  80253a:	5e                   	pop    %esi
  80253b:	5f                   	pop    %edi
  80253c:	5d                   	pop    %ebp
  80253d:	c3                   	ret    

0080253e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80253e:	55                   	push   %ebp
  80253f:	89 e5                	mov    %esp,%ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	83 ec 28             	sub    $0x28,%esp
  802547:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80254a:	56                   	push   %esi
  80254b:	e8 0b f0 ff ff       	call   80155b <fd2data>
  802550:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802552:	83 c4 10             	add    $0x10,%esp
  802555:	bf 00 00 00 00       	mov    $0x0,%edi
  80255a:	eb 4b                	jmp    8025a7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80255c:	89 da                	mov    %ebx,%edx
  80255e:	89 f0                	mov    %esi,%eax
  802560:	e8 74 ff ff ff       	call   8024d9 <_pipeisclosed>
  802565:	85 c0                	test   %eax,%eax
  802567:	75 48                	jne    8025b1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802569:	e8 2c ed ff ff       	call   80129a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80256e:	8b 43 04             	mov    0x4(%ebx),%eax
  802571:	8b 0b                	mov    (%ebx),%ecx
  802573:	8d 51 20             	lea    0x20(%ecx),%edx
  802576:	39 d0                	cmp    %edx,%eax
  802578:	73 e2                	jae    80255c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80257a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80257d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802581:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802584:	89 c2                	mov    %eax,%edx
  802586:	c1 fa 1f             	sar    $0x1f,%edx
  802589:	89 d1                	mov    %edx,%ecx
  80258b:	c1 e9 1b             	shr    $0x1b,%ecx
  80258e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802591:	83 e2 1f             	and    $0x1f,%edx
  802594:	29 ca                	sub    %ecx,%edx
  802596:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80259a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80259e:	83 c0 01             	add    $0x1,%eax
  8025a1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025a4:	83 c7 01             	add    $0x1,%edi
  8025a7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025aa:	75 c2                	jne    80256e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8025ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8025af:	eb 05                	jmp    8025b6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025b1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8025b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025b9:	5b                   	pop    %ebx
  8025ba:	5e                   	pop    %esi
  8025bb:	5f                   	pop    %edi
  8025bc:	5d                   	pop    %ebp
  8025bd:	c3                   	ret    

008025be <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025be:	55                   	push   %ebp
  8025bf:	89 e5                	mov    %esp,%ebp
  8025c1:	57                   	push   %edi
  8025c2:	56                   	push   %esi
  8025c3:	53                   	push   %ebx
  8025c4:	83 ec 18             	sub    $0x18,%esp
  8025c7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8025ca:	57                   	push   %edi
  8025cb:	e8 8b ef ff ff       	call   80155b <fd2data>
  8025d0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025d2:	83 c4 10             	add    $0x10,%esp
  8025d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025da:	eb 3d                	jmp    802619 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8025dc:	85 db                	test   %ebx,%ebx
  8025de:	74 04                	je     8025e4 <devpipe_read+0x26>
				return i;
  8025e0:	89 d8                	mov    %ebx,%eax
  8025e2:	eb 44                	jmp    802628 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8025e4:	89 f2                	mov    %esi,%edx
  8025e6:	89 f8                	mov    %edi,%eax
  8025e8:	e8 ec fe ff ff       	call   8024d9 <_pipeisclosed>
  8025ed:	85 c0                	test   %eax,%eax
  8025ef:	75 32                	jne    802623 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8025f1:	e8 a4 ec ff ff       	call   80129a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8025f6:	8b 06                	mov    (%esi),%eax
  8025f8:	3b 46 04             	cmp    0x4(%esi),%eax
  8025fb:	74 df                	je     8025dc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8025fd:	99                   	cltd   
  8025fe:	c1 ea 1b             	shr    $0x1b,%edx
  802601:	01 d0                	add    %edx,%eax
  802603:	83 e0 1f             	and    $0x1f,%eax
  802606:	29 d0                	sub    %edx,%eax
  802608:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80260d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802610:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802613:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802616:	83 c3 01             	add    $0x1,%ebx
  802619:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80261c:	75 d8                	jne    8025f6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80261e:	8b 45 10             	mov    0x10(%ebp),%eax
  802621:	eb 05                	jmp    802628 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802623:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80262b:	5b                   	pop    %ebx
  80262c:	5e                   	pop    %esi
  80262d:	5f                   	pop    %edi
  80262e:	5d                   	pop    %ebp
  80262f:	c3                   	ret    

00802630 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802630:	55                   	push   %ebp
  802631:	89 e5                	mov    %esp,%ebp
  802633:	56                   	push   %esi
  802634:	53                   	push   %ebx
  802635:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802638:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80263b:	50                   	push   %eax
  80263c:	e8 31 ef ff ff       	call   801572 <fd_alloc>
  802641:	83 c4 10             	add    $0x10,%esp
  802644:	89 c2                	mov    %eax,%edx
  802646:	85 c0                	test   %eax,%eax
  802648:	0f 88 2c 01 00 00    	js     80277a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80264e:	83 ec 04             	sub    $0x4,%esp
  802651:	68 07 04 00 00       	push   $0x407
  802656:	ff 75 f4             	pushl  -0xc(%ebp)
  802659:	6a 00                	push   $0x0
  80265b:	e8 59 ec ff ff       	call   8012b9 <sys_page_alloc>
  802660:	83 c4 10             	add    $0x10,%esp
  802663:	89 c2                	mov    %eax,%edx
  802665:	85 c0                	test   %eax,%eax
  802667:	0f 88 0d 01 00 00    	js     80277a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80266d:	83 ec 0c             	sub    $0xc,%esp
  802670:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802673:	50                   	push   %eax
  802674:	e8 f9 ee ff ff       	call   801572 <fd_alloc>
  802679:	89 c3                	mov    %eax,%ebx
  80267b:	83 c4 10             	add    $0x10,%esp
  80267e:	85 c0                	test   %eax,%eax
  802680:	0f 88 e2 00 00 00    	js     802768 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802686:	83 ec 04             	sub    $0x4,%esp
  802689:	68 07 04 00 00       	push   $0x407
  80268e:	ff 75 f0             	pushl  -0x10(%ebp)
  802691:	6a 00                	push   $0x0
  802693:	e8 21 ec ff ff       	call   8012b9 <sys_page_alloc>
  802698:	89 c3                	mov    %eax,%ebx
  80269a:	83 c4 10             	add    $0x10,%esp
  80269d:	85 c0                	test   %eax,%eax
  80269f:	0f 88 c3 00 00 00    	js     802768 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8026a5:	83 ec 0c             	sub    $0xc,%esp
  8026a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8026ab:	e8 ab ee ff ff       	call   80155b <fd2data>
  8026b0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026b2:	83 c4 0c             	add    $0xc,%esp
  8026b5:	68 07 04 00 00       	push   $0x407
  8026ba:	50                   	push   %eax
  8026bb:	6a 00                	push   $0x0
  8026bd:	e8 f7 eb ff ff       	call   8012b9 <sys_page_alloc>
  8026c2:	89 c3                	mov    %eax,%ebx
  8026c4:	83 c4 10             	add    $0x10,%esp
  8026c7:	85 c0                	test   %eax,%eax
  8026c9:	0f 88 89 00 00 00    	js     802758 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026cf:	83 ec 0c             	sub    $0xc,%esp
  8026d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8026d5:	e8 81 ee ff ff       	call   80155b <fd2data>
  8026da:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8026e1:	50                   	push   %eax
  8026e2:	6a 00                	push   $0x0
  8026e4:	56                   	push   %esi
  8026e5:	6a 00                	push   $0x0
  8026e7:	e8 10 ec ff ff       	call   8012fc <sys_page_map>
  8026ec:	89 c3                	mov    %eax,%ebx
  8026ee:	83 c4 20             	add    $0x20,%esp
  8026f1:	85 c0                	test   %eax,%eax
  8026f3:	78 55                	js     80274a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8026f5:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8026fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026fe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802700:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802703:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80270a:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802713:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802715:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802718:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80271f:	83 ec 0c             	sub    $0xc,%esp
  802722:	ff 75 f4             	pushl  -0xc(%ebp)
  802725:	e8 21 ee ff ff       	call   80154b <fd2num>
  80272a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80272d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80272f:	83 c4 04             	add    $0x4,%esp
  802732:	ff 75 f0             	pushl  -0x10(%ebp)
  802735:	e8 11 ee ff ff       	call   80154b <fd2num>
  80273a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80273d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802740:	83 c4 10             	add    $0x10,%esp
  802743:	ba 00 00 00 00       	mov    $0x0,%edx
  802748:	eb 30                	jmp    80277a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80274a:	83 ec 08             	sub    $0x8,%esp
  80274d:	56                   	push   %esi
  80274e:	6a 00                	push   $0x0
  802750:	e8 e9 eb ff ff       	call   80133e <sys_page_unmap>
  802755:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802758:	83 ec 08             	sub    $0x8,%esp
  80275b:	ff 75 f0             	pushl  -0x10(%ebp)
  80275e:	6a 00                	push   $0x0
  802760:	e8 d9 eb ff ff       	call   80133e <sys_page_unmap>
  802765:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802768:	83 ec 08             	sub    $0x8,%esp
  80276b:	ff 75 f4             	pushl  -0xc(%ebp)
  80276e:	6a 00                	push   $0x0
  802770:	e8 c9 eb ff ff       	call   80133e <sys_page_unmap>
  802775:	83 c4 10             	add    $0x10,%esp
  802778:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80277a:	89 d0                	mov    %edx,%eax
  80277c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80277f:	5b                   	pop    %ebx
  802780:	5e                   	pop    %esi
  802781:	5d                   	pop    %ebp
  802782:	c3                   	ret    

00802783 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802783:	55                   	push   %ebp
  802784:	89 e5                	mov    %esp,%ebp
  802786:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802789:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80278c:	50                   	push   %eax
  80278d:	ff 75 08             	pushl  0x8(%ebp)
  802790:	e8 2c ee ff ff       	call   8015c1 <fd_lookup>
  802795:	89 c2                	mov    %eax,%edx
  802797:	83 c4 10             	add    $0x10,%esp
  80279a:	85 d2                	test   %edx,%edx
  80279c:	78 18                	js     8027b6 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80279e:	83 ec 0c             	sub    $0xc,%esp
  8027a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8027a4:	e8 b2 ed ff ff       	call   80155b <fd2data>
	return _pipeisclosed(fd, p);
  8027a9:	89 c2                	mov    %eax,%edx
  8027ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ae:	e8 26 fd ff ff       	call   8024d9 <_pipeisclosed>
  8027b3:	83 c4 10             	add    $0x10,%esp
}
  8027b6:	c9                   	leave  
  8027b7:	c3                   	ret    

008027b8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8027b8:	55                   	push   %ebp
  8027b9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8027bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8027c0:	5d                   	pop    %ebp
  8027c1:	c3                   	ret    

008027c2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8027c2:	55                   	push   %ebp
  8027c3:	89 e5                	mov    %esp,%ebp
  8027c5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8027c8:	68 3c 34 80 00       	push   $0x80343c
  8027cd:	ff 75 0c             	pushl  0xc(%ebp)
  8027d0:	e8 db e6 ff ff       	call   800eb0 <strcpy>
	return 0;
}
  8027d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8027da:	c9                   	leave  
  8027db:	c3                   	ret    

008027dc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8027dc:	55                   	push   %ebp
  8027dd:	89 e5                	mov    %esp,%ebp
  8027df:	57                   	push   %edi
  8027e0:	56                   	push   %esi
  8027e1:	53                   	push   %ebx
  8027e2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027e8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027ed:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027f3:	eb 2d                	jmp    802822 <devcons_write+0x46>
		m = n - tot;
  8027f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027f8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8027fa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8027fd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802802:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802805:	83 ec 04             	sub    $0x4,%esp
  802808:	53                   	push   %ebx
  802809:	03 45 0c             	add    0xc(%ebp),%eax
  80280c:	50                   	push   %eax
  80280d:	57                   	push   %edi
  80280e:	e8 2f e8 ff ff       	call   801042 <memmove>
		sys_cputs(buf, m);
  802813:	83 c4 08             	add    $0x8,%esp
  802816:	53                   	push   %ebx
  802817:	57                   	push   %edi
  802818:	e8 e0 e9 ff ff       	call   8011fd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80281d:	01 de                	add    %ebx,%esi
  80281f:	83 c4 10             	add    $0x10,%esp
  802822:	89 f0                	mov    %esi,%eax
  802824:	3b 75 10             	cmp    0x10(%ebp),%esi
  802827:	72 cc                	jb     8027f5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802829:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80282c:	5b                   	pop    %ebx
  80282d:	5e                   	pop    %esi
  80282e:	5f                   	pop    %edi
  80282f:	5d                   	pop    %ebp
  802830:	c3                   	ret    

00802831 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802831:	55                   	push   %ebp
  802832:	89 e5                	mov    %esp,%ebp
  802834:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802837:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80283c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802840:	75 07                	jne    802849 <devcons_read+0x18>
  802842:	eb 28                	jmp    80286c <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802844:	e8 51 ea ff ff       	call   80129a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802849:	e8 cd e9 ff ff       	call   80121b <sys_cgetc>
  80284e:	85 c0                	test   %eax,%eax
  802850:	74 f2                	je     802844 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802852:	85 c0                	test   %eax,%eax
  802854:	78 16                	js     80286c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802856:	83 f8 04             	cmp    $0x4,%eax
  802859:	74 0c                	je     802867 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80285b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80285e:	88 02                	mov    %al,(%edx)
	return 1;
  802860:	b8 01 00 00 00       	mov    $0x1,%eax
  802865:	eb 05                	jmp    80286c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802867:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80286c:	c9                   	leave  
  80286d:	c3                   	ret    

0080286e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80286e:	55                   	push   %ebp
  80286f:	89 e5                	mov    %esp,%ebp
  802871:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802874:	8b 45 08             	mov    0x8(%ebp),%eax
  802877:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80287a:	6a 01                	push   $0x1
  80287c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80287f:	50                   	push   %eax
  802880:	e8 78 e9 ff ff       	call   8011fd <sys_cputs>
  802885:	83 c4 10             	add    $0x10,%esp
}
  802888:	c9                   	leave  
  802889:	c3                   	ret    

0080288a <getchar>:

int
getchar(void)
{
  80288a:	55                   	push   %ebp
  80288b:	89 e5                	mov    %esp,%ebp
  80288d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802890:	6a 01                	push   $0x1
  802892:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802895:	50                   	push   %eax
  802896:	6a 00                	push   $0x0
  802898:	e8 93 ef ff ff       	call   801830 <read>
	if (r < 0)
  80289d:	83 c4 10             	add    $0x10,%esp
  8028a0:	85 c0                	test   %eax,%eax
  8028a2:	78 0f                	js     8028b3 <getchar+0x29>
		return r;
	if (r < 1)
  8028a4:	85 c0                	test   %eax,%eax
  8028a6:	7e 06                	jle    8028ae <getchar+0x24>
		return -E_EOF;
	return c;
  8028a8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8028ac:	eb 05                	jmp    8028b3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8028ae:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8028b3:	c9                   	leave  
  8028b4:	c3                   	ret    

008028b5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8028b5:	55                   	push   %ebp
  8028b6:	89 e5                	mov    %esp,%ebp
  8028b8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8028bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028be:	50                   	push   %eax
  8028bf:	ff 75 08             	pushl  0x8(%ebp)
  8028c2:	e8 fa ec ff ff       	call   8015c1 <fd_lookup>
  8028c7:	83 c4 10             	add    $0x10,%esp
  8028ca:	85 c0                	test   %eax,%eax
  8028cc:	78 11                	js     8028df <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8028ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028d1:	8b 15 78 40 80 00    	mov    0x804078,%edx
  8028d7:	39 10                	cmp    %edx,(%eax)
  8028d9:	0f 94 c0             	sete   %al
  8028dc:	0f b6 c0             	movzbl %al,%eax
}
  8028df:	c9                   	leave  
  8028e0:	c3                   	ret    

008028e1 <opencons>:

int
opencons(void)
{
  8028e1:	55                   	push   %ebp
  8028e2:	89 e5                	mov    %esp,%ebp
  8028e4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028ea:	50                   	push   %eax
  8028eb:	e8 82 ec ff ff       	call   801572 <fd_alloc>
  8028f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8028f3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028f5:	85 c0                	test   %eax,%eax
  8028f7:	78 3e                	js     802937 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028f9:	83 ec 04             	sub    $0x4,%esp
  8028fc:	68 07 04 00 00       	push   $0x407
  802901:	ff 75 f4             	pushl  -0xc(%ebp)
  802904:	6a 00                	push   $0x0
  802906:	e8 ae e9 ff ff       	call   8012b9 <sys_page_alloc>
  80290b:	83 c4 10             	add    $0x10,%esp
		return r;
  80290e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802910:	85 c0                	test   %eax,%eax
  802912:	78 23                	js     802937 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802914:	8b 15 78 40 80 00    	mov    0x804078,%edx
  80291a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80291d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80291f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802922:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802929:	83 ec 0c             	sub    $0xc,%esp
  80292c:	50                   	push   %eax
  80292d:	e8 19 ec ff ff       	call   80154b <fd2num>
  802932:	89 c2                	mov    %eax,%edx
  802934:	83 c4 10             	add    $0x10,%esp
}
  802937:	89 d0                	mov    %edx,%eax
  802939:	c9                   	leave  
  80293a:	c3                   	ret    

0080293b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80293b:	55                   	push   %ebp
  80293c:	89 e5                	mov    %esp,%ebp
  80293e:	56                   	push   %esi
  80293f:	53                   	push   %ebx
  802940:	8b 75 08             	mov    0x8(%ebp),%esi
  802943:	8b 45 0c             	mov    0xc(%ebp),%eax
  802946:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802949:	85 c0                	test   %eax,%eax
  80294b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802950:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802953:	83 ec 0c             	sub    $0xc,%esp
  802956:	50                   	push   %eax
  802957:	e8 0d eb ff ff       	call   801469 <sys_ipc_recv>
  80295c:	83 c4 10             	add    $0x10,%esp
  80295f:	85 c0                	test   %eax,%eax
  802961:	79 16                	jns    802979 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802963:	85 f6                	test   %esi,%esi
  802965:	74 06                	je     80296d <ipc_recv+0x32>
  802967:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  80296d:	85 db                	test   %ebx,%ebx
  80296f:	74 2c                	je     80299d <ipc_recv+0x62>
  802971:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802977:	eb 24                	jmp    80299d <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802979:	85 f6                	test   %esi,%esi
  80297b:	74 0a                	je     802987 <ipc_recv+0x4c>
  80297d:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802982:	8b 40 74             	mov    0x74(%eax),%eax
  802985:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802987:	85 db                	test   %ebx,%ebx
  802989:	74 0a                	je     802995 <ipc_recv+0x5a>
  80298b:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802990:	8b 40 78             	mov    0x78(%eax),%eax
  802993:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802995:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80299a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80299d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029a0:	5b                   	pop    %ebx
  8029a1:	5e                   	pop    %esi
  8029a2:	5d                   	pop    %ebp
  8029a3:	c3                   	ret    

008029a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029a4:	55                   	push   %ebp
  8029a5:	89 e5                	mov    %esp,%ebp
  8029a7:	57                   	push   %edi
  8029a8:	56                   	push   %esi
  8029a9:	53                   	push   %ebx
  8029aa:	83 ec 0c             	sub    $0xc,%esp
  8029ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8029b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8029b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8029b6:	85 db                	test   %ebx,%ebx
  8029b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8029bd:	0f 44 d8             	cmove  %eax,%ebx
  8029c0:	eb 1c                	jmp    8029de <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8029c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029c5:	74 12                	je     8029d9 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8029c7:	50                   	push   %eax
  8029c8:	68 48 34 80 00       	push   $0x803448
  8029cd:	6a 39                	push   $0x39
  8029cf:	68 63 34 80 00       	push   $0x803463
  8029d4:	e8 77 de ff ff       	call   800850 <_panic>
                 sys_yield();
  8029d9:	e8 bc e8 ff ff       	call   80129a <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8029de:	ff 75 14             	pushl  0x14(%ebp)
  8029e1:	53                   	push   %ebx
  8029e2:	56                   	push   %esi
  8029e3:	57                   	push   %edi
  8029e4:	e8 5d ea ff ff       	call   801446 <sys_ipc_try_send>
  8029e9:	83 c4 10             	add    $0x10,%esp
  8029ec:	85 c0                	test   %eax,%eax
  8029ee:	78 d2                	js     8029c2 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8029f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029f3:	5b                   	pop    %ebx
  8029f4:	5e                   	pop    %esi
  8029f5:	5f                   	pop    %edi
  8029f6:	5d                   	pop    %ebp
  8029f7:	c3                   	ret    

008029f8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8029f8:	55                   	push   %ebp
  8029f9:	89 e5                	mov    %esp,%ebp
  8029fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8029fe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a03:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a06:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a0c:	8b 52 50             	mov    0x50(%edx),%edx
  802a0f:	39 ca                	cmp    %ecx,%edx
  802a11:	75 0d                	jne    802a20 <ipc_find_env+0x28>
			return envs[i].env_id;
  802a13:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a16:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802a1b:	8b 40 08             	mov    0x8(%eax),%eax
  802a1e:	eb 0e                	jmp    802a2e <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a20:	83 c0 01             	add    $0x1,%eax
  802a23:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a28:	75 d9                	jne    802a03 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a2a:	66 b8 00 00          	mov    $0x0,%ax
}
  802a2e:	5d                   	pop    %ebp
  802a2f:	c3                   	ret    

00802a30 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a30:	55                   	push   %ebp
  802a31:	89 e5                	mov    %esp,%ebp
  802a33:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a36:	89 d0                	mov    %edx,%eax
  802a38:	c1 e8 16             	shr    $0x16,%eax
  802a3b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802a42:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a47:	f6 c1 01             	test   $0x1,%cl
  802a4a:	74 1d                	je     802a69 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a4c:	c1 ea 0c             	shr    $0xc,%edx
  802a4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a56:	f6 c2 01             	test   $0x1,%dl
  802a59:	74 0e                	je     802a69 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a5b:	c1 ea 0c             	shr    $0xc,%edx
  802a5e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802a65:	ef 
  802a66:	0f b7 c0             	movzwl %ax,%eax
}
  802a69:	5d                   	pop    %ebp
  802a6a:	c3                   	ret    
  802a6b:	66 90                	xchg   %ax,%ax
  802a6d:	66 90                	xchg   %ax,%ax
  802a6f:	90                   	nop

00802a70 <__udivdi3>:
  802a70:	55                   	push   %ebp
  802a71:	57                   	push   %edi
  802a72:	56                   	push   %esi
  802a73:	83 ec 10             	sub    $0x10,%esp
  802a76:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  802a7a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  802a7e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802a82:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802a86:	85 d2                	test   %edx,%edx
  802a88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802a8c:	89 34 24             	mov    %esi,(%esp)
  802a8f:	89 c8                	mov    %ecx,%eax
  802a91:	75 35                	jne    802ac8 <__udivdi3+0x58>
  802a93:	39 f1                	cmp    %esi,%ecx
  802a95:	0f 87 bd 00 00 00    	ja     802b58 <__udivdi3+0xe8>
  802a9b:	85 c9                	test   %ecx,%ecx
  802a9d:	89 cd                	mov    %ecx,%ebp
  802a9f:	75 0b                	jne    802aac <__udivdi3+0x3c>
  802aa1:	b8 01 00 00 00       	mov    $0x1,%eax
  802aa6:	31 d2                	xor    %edx,%edx
  802aa8:	f7 f1                	div    %ecx
  802aaa:	89 c5                	mov    %eax,%ebp
  802aac:	89 f0                	mov    %esi,%eax
  802aae:	31 d2                	xor    %edx,%edx
  802ab0:	f7 f5                	div    %ebp
  802ab2:	89 c6                	mov    %eax,%esi
  802ab4:	89 f8                	mov    %edi,%eax
  802ab6:	f7 f5                	div    %ebp
  802ab8:	89 f2                	mov    %esi,%edx
  802aba:	83 c4 10             	add    $0x10,%esp
  802abd:	5e                   	pop    %esi
  802abe:	5f                   	pop    %edi
  802abf:	5d                   	pop    %ebp
  802ac0:	c3                   	ret    
  802ac1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ac8:	3b 14 24             	cmp    (%esp),%edx
  802acb:	77 7b                	ja     802b48 <__udivdi3+0xd8>
  802acd:	0f bd f2             	bsr    %edx,%esi
  802ad0:	83 f6 1f             	xor    $0x1f,%esi
  802ad3:	0f 84 97 00 00 00    	je     802b70 <__udivdi3+0x100>
  802ad9:	bd 20 00 00 00       	mov    $0x20,%ebp
  802ade:	89 d7                	mov    %edx,%edi
  802ae0:	89 f1                	mov    %esi,%ecx
  802ae2:	29 f5                	sub    %esi,%ebp
  802ae4:	d3 e7                	shl    %cl,%edi
  802ae6:	89 c2                	mov    %eax,%edx
  802ae8:	89 e9                	mov    %ebp,%ecx
  802aea:	d3 ea                	shr    %cl,%edx
  802aec:	89 f1                	mov    %esi,%ecx
  802aee:	09 fa                	or     %edi,%edx
  802af0:	8b 3c 24             	mov    (%esp),%edi
  802af3:	d3 e0                	shl    %cl,%eax
  802af5:	89 54 24 08          	mov    %edx,0x8(%esp)
  802af9:	89 e9                	mov    %ebp,%ecx
  802afb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802aff:	8b 44 24 04          	mov    0x4(%esp),%eax
  802b03:	89 fa                	mov    %edi,%edx
  802b05:	d3 ea                	shr    %cl,%edx
  802b07:	89 f1                	mov    %esi,%ecx
  802b09:	d3 e7                	shl    %cl,%edi
  802b0b:	89 e9                	mov    %ebp,%ecx
  802b0d:	d3 e8                	shr    %cl,%eax
  802b0f:	09 c7                	or     %eax,%edi
  802b11:	89 f8                	mov    %edi,%eax
  802b13:	f7 74 24 08          	divl   0x8(%esp)
  802b17:	89 d5                	mov    %edx,%ebp
  802b19:	89 c7                	mov    %eax,%edi
  802b1b:	f7 64 24 0c          	mull   0xc(%esp)
  802b1f:	39 d5                	cmp    %edx,%ebp
  802b21:	89 14 24             	mov    %edx,(%esp)
  802b24:	72 11                	jb     802b37 <__udivdi3+0xc7>
  802b26:	8b 54 24 04          	mov    0x4(%esp),%edx
  802b2a:	89 f1                	mov    %esi,%ecx
  802b2c:	d3 e2                	shl    %cl,%edx
  802b2e:	39 c2                	cmp    %eax,%edx
  802b30:	73 5e                	jae    802b90 <__udivdi3+0x120>
  802b32:	3b 2c 24             	cmp    (%esp),%ebp
  802b35:	75 59                	jne    802b90 <__udivdi3+0x120>
  802b37:	8d 47 ff             	lea    -0x1(%edi),%eax
  802b3a:	31 f6                	xor    %esi,%esi
  802b3c:	89 f2                	mov    %esi,%edx
  802b3e:	83 c4 10             	add    $0x10,%esp
  802b41:	5e                   	pop    %esi
  802b42:	5f                   	pop    %edi
  802b43:	5d                   	pop    %ebp
  802b44:	c3                   	ret    
  802b45:	8d 76 00             	lea    0x0(%esi),%esi
  802b48:	31 f6                	xor    %esi,%esi
  802b4a:	31 c0                	xor    %eax,%eax
  802b4c:	89 f2                	mov    %esi,%edx
  802b4e:	83 c4 10             	add    $0x10,%esp
  802b51:	5e                   	pop    %esi
  802b52:	5f                   	pop    %edi
  802b53:	5d                   	pop    %ebp
  802b54:	c3                   	ret    
  802b55:	8d 76 00             	lea    0x0(%esi),%esi
  802b58:	89 f2                	mov    %esi,%edx
  802b5a:	31 f6                	xor    %esi,%esi
  802b5c:	89 f8                	mov    %edi,%eax
  802b5e:	f7 f1                	div    %ecx
  802b60:	89 f2                	mov    %esi,%edx
  802b62:	83 c4 10             	add    $0x10,%esp
  802b65:	5e                   	pop    %esi
  802b66:	5f                   	pop    %edi
  802b67:	5d                   	pop    %ebp
  802b68:	c3                   	ret    
  802b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b70:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802b74:	76 0b                	jbe    802b81 <__udivdi3+0x111>
  802b76:	31 c0                	xor    %eax,%eax
  802b78:	3b 14 24             	cmp    (%esp),%edx
  802b7b:	0f 83 37 ff ff ff    	jae    802ab8 <__udivdi3+0x48>
  802b81:	b8 01 00 00 00       	mov    $0x1,%eax
  802b86:	e9 2d ff ff ff       	jmp    802ab8 <__udivdi3+0x48>
  802b8b:	90                   	nop
  802b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b90:	89 f8                	mov    %edi,%eax
  802b92:	31 f6                	xor    %esi,%esi
  802b94:	e9 1f ff ff ff       	jmp    802ab8 <__udivdi3+0x48>
  802b99:	66 90                	xchg   %ax,%ax
  802b9b:	66 90                	xchg   %ax,%ax
  802b9d:	66 90                	xchg   %ax,%ax
  802b9f:	90                   	nop

00802ba0 <__umoddi3>:
  802ba0:	55                   	push   %ebp
  802ba1:	57                   	push   %edi
  802ba2:	56                   	push   %esi
  802ba3:	83 ec 20             	sub    $0x20,%esp
  802ba6:	8b 44 24 34          	mov    0x34(%esp),%eax
  802baa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802bae:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802bb2:	89 c6                	mov    %eax,%esi
  802bb4:	89 44 24 10          	mov    %eax,0x10(%esp)
  802bb8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802bbc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802bc0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802bc4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802bc8:	89 74 24 18          	mov    %esi,0x18(%esp)
  802bcc:	85 c0                	test   %eax,%eax
  802bce:	89 c2                	mov    %eax,%edx
  802bd0:	75 1e                	jne    802bf0 <__umoddi3+0x50>
  802bd2:	39 f7                	cmp    %esi,%edi
  802bd4:	76 52                	jbe    802c28 <__umoddi3+0x88>
  802bd6:	89 c8                	mov    %ecx,%eax
  802bd8:	89 f2                	mov    %esi,%edx
  802bda:	f7 f7                	div    %edi
  802bdc:	89 d0                	mov    %edx,%eax
  802bde:	31 d2                	xor    %edx,%edx
  802be0:	83 c4 20             	add    $0x20,%esp
  802be3:	5e                   	pop    %esi
  802be4:	5f                   	pop    %edi
  802be5:	5d                   	pop    %ebp
  802be6:	c3                   	ret    
  802be7:	89 f6                	mov    %esi,%esi
  802be9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802bf0:	39 f0                	cmp    %esi,%eax
  802bf2:	77 5c                	ja     802c50 <__umoddi3+0xb0>
  802bf4:	0f bd e8             	bsr    %eax,%ebp
  802bf7:	83 f5 1f             	xor    $0x1f,%ebp
  802bfa:	75 64                	jne    802c60 <__umoddi3+0xc0>
  802bfc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802c00:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802c04:	0f 86 f6 00 00 00    	jbe    802d00 <__umoddi3+0x160>
  802c0a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  802c0e:	0f 82 ec 00 00 00    	jb     802d00 <__umoddi3+0x160>
  802c14:	8b 44 24 14          	mov    0x14(%esp),%eax
  802c18:	8b 54 24 18          	mov    0x18(%esp),%edx
  802c1c:	83 c4 20             	add    $0x20,%esp
  802c1f:	5e                   	pop    %esi
  802c20:	5f                   	pop    %edi
  802c21:	5d                   	pop    %ebp
  802c22:	c3                   	ret    
  802c23:	90                   	nop
  802c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c28:	85 ff                	test   %edi,%edi
  802c2a:	89 fd                	mov    %edi,%ebp
  802c2c:	75 0b                	jne    802c39 <__umoddi3+0x99>
  802c2e:	b8 01 00 00 00       	mov    $0x1,%eax
  802c33:	31 d2                	xor    %edx,%edx
  802c35:	f7 f7                	div    %edi
  802c37:	89 c5                	mov    %eax,%ebp
  802c39:	8b 44 24 10          	mov    0x10(%esp),%eax
  802c3d:	31 d2                	xor    %edx,%edx
  802c3f:	f7 f5                	div    %ebp
  802c41:	89 c8                	mov    %ecx,%eax
  802c43:	f7 f5                	div    %ebp
  802c45:	eb 95                	jmp    802bdc <__umoddi3+0x3c>
  802c47:	89 f6                	mov    %esi,%esi
  802c49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802c50:	89 c8                	mov    %ecx,%eax
  802c52:	89 f2                	mov    %esi,%edx
  802c54:	83 c4 20             	add    $0x20,%esp
  802c57:	5e                   	pop    %esi
  802c58:	5f                   	pop    %edi
  802c59:	5d                   	pop    %ebp
  802c5a:	c3                   	ret    
  802c5b:	90                   	nop
  802c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c60:	b8 20 00 00 00       	mov    $0x20,%eax
  802c65:	89 e9                	mov    %ebp,%ecx
  802c67:	29 e8                	sub    %ebp,%eax
  802c69:	d3 e2                	shl    %cl,%edx
  802c6b:	89 c7                	mov    %eax,%edi
  802c6d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802c71:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802c75:	89 f9                	mov    %edi,%ecx
  802c77:	d3 e8                	shr    %cl,%eax
  802c79:	89 c1                	mov    %eax,%ecx
  802c7b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802c7f:	09 d1                	or     %edx,%ecx
  802c81:	89 fa                	mov    %edi,%edx
  802c83:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802c87:	89 e9                	mov    %ebp,%ecx
  802c89:	d3 e0                	shl    %cl,%eax
  802c8b:	89 f9                	mov    %edi,%ecx
  802c8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c91:	89 f0                	mov    %esi,%eax
  802c93:	d3 e8                	shr    %cl,%eax
  802c95:	89 e9                	mov    %ebp,%ecx
  802c97:	89 c7                	mov    %eax,%edi
  802c99:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802c9d:	d3 e6                	shl    %cl,%esi
  802c9f:	89 d1                	mov    %edx,%ecx
  802ca1:	89 fa                	mov    %edi,%edx
  802ca3:	d3 e8                	shr    %cl,%eax
  802ca5:	89 e9                	mov    %ebp,%ecx
  802ca7:	09 f0                	or     %esi,%eax
  802ca9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  802cad:	f7 74 24 10          	divl   0x10(%esp)
  802cb1:	d3 e6                	shl    %cl,%esi
  802cb3:	89 d1                	mov    %edx,%ecx
  802cb5:	f7 64 24 0c          	mull   0xc(%esp)
  802cb9:	39 d1                	cmp    %edx,%ecx
  802cbb:	89 74 24 14          	mov    %esi,0x14(%esp)
  802cbf:	89 d7                	mov    %edx,%edi
  802cc1:	89 c6                	mov    %eax,%esi
  802cc3:	72 0a                	jb     802ccf <__umoddi3+0x12f>
  802cc5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802cc9:	73 10                	jae    802cdb <__umoddi3+0x13b>
  802ccb:	39 d1                	cmp    %edx,%ecx
  802ccd:	75 0c                	jne    802cdb <__umoddi3+0x13b>
  802ccf:	89 d7                	mov    %edx,%edi
  802cd1:	89 c6                	mov    %eax,%esi
  802cd3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802cd7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  802cdb:	89 ca                	mov    %ecx,%edx
  802cdd:	89 e9                	mov    %ebp,%ecx
  802cdf:	8b 44 24 14          	mov    0x14(%esp),%eax
  802ce3:	29 f0                	sub    %esi,%eax
  802ce5:	19 fa                	sbb    %edi,%edx
  802ce7:	d3 e8                	shr    %cl,%eax
  802ce9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  802cee:	89 d7                	mov    %edx,%edi
  802cf0:	d3 e7                	shl    %cl,%edi
  802cf2:	89 e9                	mov    %ebp,%ecx
  802cf4:	09 f8                	or     %edi,%eax
  802cf6:	d3 ea                	shr    %cl,%edx
  802cf8:	83 c4 20             	add    $0x20,%esp
  802cfb:	5e                   	pop    %esi
  802cfc:	5f                   	pop    %edi
  802cfd:	5d                   	pop    %ebp
  802cfe:	c3                   	ret    
  802cff:	90                   	nop
  802d00:	8b 74 24 10          	mov    0x10(%esp),%esi
  802d04:	29 f9                	sub    %edi,%ecx
  802d06:	19 c6                	sbb    %eax,%esi
  802d08:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802d0c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802d10:	e9 ff fe ff ff       	jmp    802c14 <__umoddi3+0x74>
