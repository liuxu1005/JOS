#include <kern/e1000.h>

// LAB 6: Your driver code here

struct tx_desc *tx_ring;
struct rx_desc *rx_ring;
int nic_init();

int nic_attach(struct pci_func *pcif) {
        pci_func_enable(pcif);
        nic = mmio_map_region(pcif->reg_base[0], pcif->reg_size[0]);
        if(nic_init() < 0)
                panic("No mem failure from nic_attach\n");
        return 0;
}

int nic_init() {
        struct PageInfo *tmpt, *tmpr, *tmpr1;

        //steal 1 page for rxda
        tmpr = page_alloc(ALLOC_ZERO);
        if (tmpr == NULL)
                return -E_NO_MEM;
        tmpr->pp_ref++;
        rx_ring = page2kva(tmpr);
        //recieve init
        int i;
        for(i = 0; i < 128; i++) {
                rx_ring[i].status = 0;
                //temporarily borrow 128 pages for buff
                tmpr1 = page_alloc(ALLOC_ZERO);
                if (tmpr1 == NULL)
                        return -E_NO_MEM;
                tmpr1->pp_ref++;
                rx_ring[i].addr = page2pa(tmpr1) + sizeof(int);         
        }

        nic[E1000_RAL/4] = 0x12005452;
        nic[E1000_RAH/4] = 0x5634 | E1000_RAH_AV;
        for (i = 0; i < 128; i++)
                nic[E1000_MTA/4 + i] = 0;
         

        nic[E1000_RDBAL/4] = page2pa(tmpr);
        nic[E1000_RDBAH/4] = 0;
        nic[E1000_RDLEN/4] = 2048;
        nic[E1000_RDH/4] = 0; 
        nic[E1000_RDT/4] = 127; 
        nic[E1000_RCTL/4] = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SECRC | E1000_RCTL_SZ_2048 | E1000_RCTL_RDMTS_QUAT; 
        nic[E1000_IMS/4] =  E1000_IMS_RXT0 | E1000_IMS_RXDMT0 | E1000_IMS_RXO; 
       // nic[E1000_ICS/4] =  E1000_ICS_RXT0;
        //nic[E1000_ICR/4] =  E1000_ICR_RXT0;
        //nic[E1000_RDTR/4] = 0;

        //steal 1 page for txda
        tmpt = page_alloc(ALLOC_ZERO);
        if (tmpt == NULL)
                return -E_NO_MEM;
        tmpt->pp_ref++;
        tx_ring = page2kva(tmpt);

        //transmit init
        for(i = 0; i < 64; i++) {
                tx_ring[i].status = 1;
                tx_ring[i].cmd = 9;
        }

        nic[E1000_TDBAL/4] = page2pa(tmpt);
        nic[E1000_TDLEN/4] = 1024;
        nic[E1000_TDH/4] = 0;
        nic[E1000_TDT/4] = 0;
        nic[E1000_TCTL/4] = E1000_TCTL_EN | E1000_TCTL_PSP | E1000_TCTL_COLD;
        nic[E1000_TIPG/4] = IPGT | IPGR1 | IPGR2;
        return 0;
}

int transmit(uint64_t buf, uint16_t size) {
 
        uint32_t index = nic[E1000_TDT/4];
        if ((tx_ring[index].status & 1) != 1)
                return -E_IPC_NOT_RECV;
      
        tx_ring[index].cmd = 0x9;
        tx_ring[index].addr = buf;
         
        tx_ring[index].length = size;
        tx_ring[index].status = 0;
        nic[E1000_TDT/4] = (index + 1) % 64;

        return 0;
}

int recv(void *tempage) {

        uint32_t index = (nic[E1000_RDT/4] + 1)%128;
        if ((rx_ring[index].status & 1) == 0) {
                return -E_IPC_NOT_RECV;
        }
        uint32_t tmppa = (uint32_t)rx_ring[index].addr - sizeof(int);
        *(int *)(KADDR(tmppa)) = rx_ring[index].length;
        if(page_insert(curenv->env_pgdir, pa2page(tmppa), tempage, PTE_U|PTE_P) < 0)
                return -E_NO_MEM; 

        struct PageInfo *tmpr = page_alloc(ALLOC_ZERO);
        if (tmpr == NULL)
                return -E_NO_MEM;
        tmpr->pp_ref++; 
        rx_ring[index].addr = page2pa(tmpr) + sizeof(int);
        rx_ring[index].status =  0;
        nic[E1000_RDT/4] = index;
        return 0;

}

