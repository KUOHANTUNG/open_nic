

#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <inttypes.h>
#include <stdbool.h>
#include <arpa/inet.h>

#include <rte_pci.h>
#include <rte_eal.h>
#include <rte_ethdev.h>
#include <rte_mempool.h>
#include <rte_mbuf.h>
#include <rte_malloc.h>
#include <rte_cycles.h>
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_arp.h>
#include <rte_bus_pci.h>

#define RX_RING_SIZE        1024
#define TX_RING_SIZE        1024
#define NUM_MBUFS           8192
#define MBUF_CACHE_SIZE     250
#define BURST_SIZE          32

#define WAIT_RX_TIMEOUT_SEC 5

struct rte_mempool *mbuf_pool;
static volatile bool force_quit = false;

#define PAYLOAD_LEN (sizeof(payload))
static const uint8_t payload[] = {
    0xFF, 0xFF, 0x00, 0x00, 0x26, 0x00,
    0x08, 0x01, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00,
    0xBB, 0xBB, 0xBB, 0xBB, 0x00, 0x00,
    0xCC, 0xCC, 0xAA, 0xAA, 0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,
};

static void handle_signal(int sig)
{
    printf("Signal %d received, exiting...\n", sig);
    force_quit = true;
}

static int send_payload(uint16_t port_id, uint16_t tx_queue_id)
{
    struct rte_mbuf *mbuf = rte_pktmbuf_alloc(mbuf_pool);
    if (mbuf == NULL) {
        printf("mbuf alloc failed\n");
        return -1;
    }

    uint8_t *data = rte_pktmbuf_mtod(mbuf, uint8_t *);
    rte_memcpy(data, payload, PAYLOAD_LEN);

    mbuf->data_len = PAYLOAD_LEN;
    mbuf->pkt_len  = PAYLOAD_LEN;

    uint16_t sent = rte_eth_tx_burst(port_id, tx_queue_id, &mbuf, 1);
    if (sent != 1) {
        printf("tx_burst failed, sent=%u\n", sent);
        rte_pktmbuf_free(mbuf);
        return -1;
    }

    printf("send_payload: sent %u packet(s)\n", sent);
    return 0;
}

static void dump_packet(uint8_t *data, uint16_t len)
{
    printf("---- PACKET DUMP (%u bytes) ----\n", len);

    for (uint16_t i = 0; i < len; i += 16) {
        printf("%04X:  ", i);
        for (uint16_t j = 0; j < 16 && (i + j) < len; j++) {
            printf("%02X ", data[i + j]);
        }

        printf(" | ");

        for (uint16_t j = 0; j < 16 && (i + j) < len; j++) {
            uint8_t c = data[i + j];
            printf("%c", (c >= 32 && c <= 126) ? c : '.');
        }
        printf("\n");
    }

    printf("--------------------------------\n");
}

static int recv_once(uint16_t port_id, uint16_t rx_queue_id)
{
    struct rte_mbuf *rx_pkts[BURST_SIZE];

    const uint64_t hz = rte_get_timer_hz();
    const uint64_t start = rte_get_timer_cycles();
    const uint64_t timeout_cycles = (uint64_t)WAIT_RX_TIMEOUT_SEC * hz;

    printf("Waiting for 1 packet on port %u, queue %u (timeout %d s)...\n",
           port_id, rx_queue_id, WAIT_RX_TIMEOUT_SEC);

    while (!force_quit) {
        uint16_t nb_rx = rte_eth_rx_burst(port_id, rx_queue_id, rx_pkts, BURST_SIZE);

        if (nb_rx == 0) {
            if (rte_get_timer_cycles() - start > timeout_cycles) {
                printf("RX timeout: no packet received within %d seconds.\n",
                       WAIT_RX_TIMEOUT_SEC);
                return -1;
            }
            rte_delay_us_sleep(50);
            continue;
        }

        struct rte_mbuf *m = rx_pkts[0];
        uint8_t *data = rte_pktmbuf_mtod(m, uint8_t *);
        uint16_t len  = rte_pktmbuf_pkt_len(m);

        printf("\n[RX] port=%u queue=%u pkt_len=%u\n", port_id, rx_queue_id, len);
        dump_packet(data, len);
        rte_pktmbuf_free(m);

        for (uint16_t i = 1; i < nb_rx; i++) {
            rte_pktmbuf_free(rx_pkts[i]);
        }

        return 0; 
    }

    return -1;
}

int main(int argc, char **argv)
{
    int ret;
    uint16_t port_id = 0;
    uint16_t txq = 0, rxq = 0;

    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    ret = rte_eal_init(argc, argv);
    if (ret < 0) {
        printf("EAL init failed\n");
        return -1;
    }

    mbuf_pool = rte_pktmbuf_pool_create("MBUF_POOL",
                                        NUM_MBUFS,
                                        MBUF_CACHE_SIZE, 0,
                                        RTE_MBUF_DEFAULT_BUF_SIZE,
                                        rte_socket_id());
    if (mbuf_pool == NULL) {
        rte_panic("Cannot init mbuf pool\n");
    }

    struct rte_eth_conf port_conf;
    memset(&port_conf, 0, sizeof(port_conf));
    port_conf.txmode.mq_mode = ETH_MQ_TX_NONE;
    port_conf.rxmode.mq_mode = ETH_MQ_RX_NONE;

    ret = rte_eth_dev_configure(port_id, 1, 1, &port_conf);
    if (ret < 0)
        rte_exit(EXIT_FAILURE, "Cannot configure device\n");

    ret = rte_eth_rx_queue_setup(port_id, rxq, RX_RING_SIZE,
                                 rte_eth_dev_socket_id(port_id),
                                 NULL, mbuf_pool);
    if (ret < 0)
        rte_exit(EXIT_FAILURE, "RX queue setup failed\n");

    ret = rte_eth_tx_queue_setup(port_id, txq, TX_RING_SIZE,
                                 rte_eth_dev_socket_id(port_id),
                                 NULL);
    if (ret < 0)
        rte_exit(EXIT_FAILURE, "TX queue setup failed\n");

    ret = rte_eth_dev_start(port_id);
    if (ret < 0)
        rte_exit(EXIT_FAILURE, "Device start failed\n");

    printf("Device %u started successfully!\n", port_id);


    if (send_payload(port_id, txq) != 0) {
        printf("Initial send_payload failed\n");
    }


    (void)recv_once(port_id, rxq);


    printf("Stopping port %u...\n", port_id);
    rte_eth_dev_stop(port_id);

    printf("Closing port %u...\n", port_id);
    rte_eth_dev_close(port_id);

    printf("Cleaning up EAL...\n");
    rte_eal_cleanup();

    printf("Exit cleanly.\n");
    return 0;
}
