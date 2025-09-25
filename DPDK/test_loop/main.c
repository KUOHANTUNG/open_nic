#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>

#include <rte_eal.h>
#include <rte_mbuf.h>
#include <rte_ethdev.h>
static volatile bool force_quit;
#define RX_RING_SIZE 1024
#define TX_RING_SIZE 1024
unsigned pid;
#define MAX_PKT_BURST 32
#define NUM_MBUFS 8191
#define MBUF_CACHE_SIZE 250
#define BURST_SIZE 32

struct rte_mempool *mbuf_pool;
struct rte_ether_addr scr_addr;
static const struct rte_eth_conf port_conf_default = {
	.rxmode = {
		.max_rx_pkt_len = RTE_ETHER_MAX_LEN,
	},
};

static void
signal_handler(int signum)
{
	if (signum == SIGINT || signum == SIGTERM) {
		printf("\n\nSignal %d received, preparing to exit...\n",
				signum);
		force_quit = true;
	}
}


// initialize the port

static inline int
port_init(uint16_t port, struct rte_mempool *mbuf_pool){
    int retval;
    uint16_t nb_rxd = RX_RING_SIZE;
	uint16_t nb_txd = TX_RING_SIZE;
    struct rte_eth_dev_info dev_info;
    const uint16_t rx_rings = 1, tx_rings = 1;
    struct rte_eth_conf port_conf = port_conf_default;
    struct rte_eth_txconf txconf;
    uint16_t q;
    if (!rte_eth_dev_is_valid_port(port))
		return -1;
    retval = rte_eth_dev_info_get(port, &dev_info);
    if (retval != 0) {
		printf("Error during getting device (port %u) info: %s\n",
				port, strerror(-retval));
		return retval;
	}

    pid  = port;

    //configure
    retval = rte_eth_dev_configure(port, rx_rings, tx_rings, &port_conf);
	if (retval != 0)
		return retval;
    retval = rte_eth_dev_adjust_nb_rx_tx_desc(port, &nb_rxd, &nb_txd);
	if (retval != 0)
		return retval;
    
        // set rx queue
    for ( q = 0; q < rx_rings; q++) {
		retval = rte_eth_rx_queue_setup(port, q, nb_rxd,
				rte_eth_dev_socket_id(port), NULL, mbuf_pool);
		if (retval < 0)
			return retval;
	}

    txconf = dev_info.default_txconf;
	txconf.offloads = port_conf.txmode.offloads;
	/* Allocate and set up 1 TX queue per Ethernet port. */
	for (q = 0; q < tx_rings; q++) {
		retval = rte_eth_tx_queue_setup(port, q, nb_txd,
				rte_eth_dev_socket_id(port), &txconf);
		if (retval < 0)
			return retval;
	}
    /* Start the Ethernet port. */
	retval = rte_eth_dev_start(port);
	if (retval < 0)
		return retval;
    /* Display the port MAC address. */
	struct rte_ether_addr addr;
	retval = rte_eth_macaddr_get(port, &addr);
    rte_ether_addr_copy(&addr, &scr_addr);
	if (retval != 0)
		return retval;

	printf("Port %u MAC: %02" PRIx8 " %02" PRIx8 " %02" PRIx8
			   " %02" PRIx8 " %02" PRIx8 " %02" PRIx8 "\n",
			port,
			addr.addr_bytes[0], addr.addr_bytes[1],
			addr.addr_bytes[2], addr.addr_bytes[3],
			addr.addr_bytes[4], addr.addr_bytes[5]);
	return 0;
}


static void
mac_present(struct rte_mbuf *m){
    struct rte_ether_hdr *eth;
    struct rte_ether_addr  tmp;

    eth = rte_pktmbuf_mtod(m, struct rte_ether_hdr *);

    printf(" Des MAC address: %02X:%02X:%02X:%02X:%02X:%02X\n\n",
				eth->d_addr.addr_bytes[0],
				eth->d_addr.addr_bytes[1],
				eth->d_addr.addr_bytes[2],
				eth->d_addr.addr_bytes[3],
				eth->d_addr.addr_bytes[4],
				eth->d_addr.addr_bytes[5]);
    printf(" Src MAC address: %02X:%02X:%02X:%02X:%02X:%02X\n\n",
				eth->s_addr.addr_bytes[0],
				eth->s_addr.addr_bytes[1],
				eth->s_addr.addr_bytes[2],
				eth->s_addr.addr_bytes[3],
				eth->s_addr.addr_bytes[4],
				eth->s_addr.addr_bytes[5]);
}


static int
mac_swap(__rte_unused void *arg){
    unsigned lcore_id, nb_rx, nb_tx, j;
    struct rte_mbuf *m;
    struct rte_ether_hdr *eth;
    void *tmp;
	lcore_id = rte_lcore_id();
	printf("running in core %u\n", lcore_id);
    struct rte_mbuf *pkts_burst[1];
    //create a packet demo
    m = rte_pktmbuf_alloc(mbuf_pool);
    if (m == NULL) {
        printf("mbuf alloc failed\n");
        return -1;
    }
    
    eth = (struct rte_ether_hdr *) rte_pktmbuf_append(m, sizeof(struct rte_ether_hdr));
    tmp = &eth->d_addr.addr_bytes[0];
    *((uint64_t *)tmp) = 0x000000000002 + ((uint64_t)lcore_id << 40);
    rte_ether_addr_copy(&scr_addr, &eth->s_addr);
    nb_tx = rte_eth_tx_burst(pid, 0, &m, 1);
    if (nb_tx < 1) {
        rte_pktmbuf_free(m); 
        return -1;
    }
    if(nb_tx == 0)
        printf("opps----\r\n");

    while (!force_quit) {
        // read the packet
        nb_rx = rte_eth_rx_burst(pid, 0,
						 pkts_burst, 1);
        for (j = 0; j < nb_rx; j++) {
			m = pkts_burst[0];
			rte_prefetch0(rte_pktmbuf_mtod(m, void *));
            mac_present(m);
		}
        // send packet first
        if(nb_rx !=0)
            nb_tx = rte_eth_tx_burst(pid, 0,
             pkts_burst, 
             1);
    }
    rte_pktmbuf_free(m); 
    return 0;
}

int main(int argc, char** argv){
    int ret;
    unsigned lcore_id;
    uint16_t nb_ports;
    uint16_t portid;

    ret = rte_eal_init(argc,argv);
    if (ret < 0)
		rte_panic("Cannot init EAL\n");
    force_quit = false;
	signal(SIGINT, signal_handler);
	signal(SIGTERM, signal_handler);

    //obtain numbers of ports
    nb_ports = rte_eth_dev_count_avail();
    printf("Available ports: %u\n", nb_ports);

    // Create a new mempool in memory
    mbuf_pool = rte_pktmbuf_pool_create("MBUF_POOL", NUM_MBUFS * nb_ports,
		MBUF_CACHE_SIZE, 0, RTE_MBUF_DEFAULT_BUF_SIZE, rte_socket_id());
    if (mbuf_pool == NULL)
		rte_exit(EXIT_FAILURE, "Cannot create mbuf pool\n");   
    
    	/* Initialize all ports. */
	RTE_ETH_FOREACH_DEV(portid)
		if (port_init(portid, mbuf_pool) != 0)
			rte_exit(EXIT_FAILURE, "Cannot init port %"PRIu16 "\n",
					portid);
    if (rte_lcore_count() > 2)
		printf("\nWARNING: Too many lcores enabled. Only 1 used.\n");   
    ret = 0;
    rte_eal_mp_remote_launch(mac_swap, NULL, SKIP_MAIN);
    RTE_LCORE_FOREACH_WORKER(lcore_id) {
        if(rte_eal_wait_lcore(lcore_id) < 0){
            ret = -1;
            break;
        }
    }
    //free packets
    RTE_ETH_FOREACH_DEV(portid) {
        printf("Closing port %d...", portid);
        ret = rte_eth_dev_stop(portid);
        if (ret != 0)
			printf("rte_eth_dev_stop: err=%d, port=%d\n",
			ret, portid);
        rte_eth_dev_close(portid);
        printf(" Done\n");
    }
    printf("Bye...\n");
    return 0;
}