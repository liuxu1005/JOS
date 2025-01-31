#include "ns.h"

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
	binaryname = "ns_output";

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
        envid_t from_envid;
        int perm;
        int r;
        while(1) {
                r = ipc_recv(&from_envid, (void *)TXTEP, &perm);
                if (r < 0)
                        panic("ipc_recv from net fails %e\n", r);
                if (from_envid != ns_envid)
                        continue;
                if (r != NSREQ_OUTPUT)
                        continue;
                while((r = sys_transmit((void *)TXTEP) ) < 0) {
                        if(r != -E_IPC_NOT_RECV)
                                panic("sys_transit fails %e\n", r);
                        sys_yield();
                }
        }
}
