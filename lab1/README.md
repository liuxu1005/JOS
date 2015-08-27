Test result:

running JOS: (1.2s) 

  printf: OK 
  
  backtrace count: OK 
  
  backtrace arguments: OK 
  
  backtrace symbols: OK 
  
  backtrace lines: OK 
  
Score: 50/50

Code:
Exercise 8. We have omitted a small fragment of code - the code necessary to print octal numbers using patterns of the form "%o". Find and fill in this code fragment.

case 'o':
	// Replace this with your code.
			
	num = getuint(&ap, lflag);
  base = 8;
        goto number;
                        

Exercise 11. Implement the backtrace function as specified above. 

// Your code here.
        uint32_t *ebp;
        uint32_t eip;
        uint32_t arg0, arg1, arg2, arg3, arg4;
        ebp = (uint32_t *)read_ebp();
        eip = ebp[1];
        arg0 = ebp[2];
        arg1 = ebp[3];
        arg2 = ebp[4];
        arg3 = ebp[5];
        arg4 = ebp[6];
        cprintf("Stack backtrace:\n");
        while(ebp != 0) {
             
             char fn[100];
              
             cprintf("  ebp  %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
                                       ebp, eip, arg0, arg1, arg2, arg3, arg4);
             struct Eipdebuginfo info;
             debuginfo_eip(eip, &info);
            
             snprintf(fn, info.eip_fn_namelen+1, "%s", info.eip_fn_name);
            
             cprintf("         %s:%u: %s+%u\n", info.eip_file, info.eip_line, fn, eip - info.eip_fn_addr);
             ebp = (uint32_t *)ebp[0];
             eip = ebp[1];
             arg0 = ebp[2];
             arg1 = ebp[3];
             arg2 = ebp[4];
             arg3 = ebp[5];
             arg4 = ebp[6];
        }
	return 0;
