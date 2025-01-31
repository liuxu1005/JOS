#include "ns.h"

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
	binaryname = "ns_input";

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
 
        int r;
        while(1) {
 
                
                 while(( r = sys_recv((void *)RXTEP)) < 0) {
                       if(r != -E_IPC_NOT_RECV)
                               panic("sys_recv fails %e\n", r);
                       sys_yield();
               }
      
               ipc_send(ns_envid, NSREQ_INPUT, (void *)RXTEP, PTE_U | PTE_P); 
        }
}
