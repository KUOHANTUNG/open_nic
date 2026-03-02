#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <math.h>

#include <rte_eal.h>
#include <rte_ethdev.h>
#include <rte_mempool.h>
#include <rte_mbuf.h>
#include <rte_malloc.h>
#include <rte_cycles.h>
#include <rte_errno.h>

// BAR MMIO read
#include <rte_bus_pci.h>
#include <rte_io.h>

#define RX_RING_SIZE        1024
#define TX_RING_SIZE        1024
#define NUM_MBUFS           8192
#define MBUF_CACHE_SIZE     250
#define MAX_BURST           256

static struct rte_mempool *mbuf_pool;
static volatile bool force_quit = false;

static const uint8_t payload[] = {
    0xFF, 0xFF,
    0x00, 0x00,
    0x08, 0x02,
    0x08,
    0x01,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, // key (8B)
    // payload
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA, // 64B
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA, // 128B
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    // 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA, // 256B (partial)
    // 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
    // 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,0xAA, 0xAA,
};
#define PAYLOAD_LEN ((uint16_t)sizeof(payload))

static void handle_signal(int sig) {
    (void)sig;
    force_quit = true;
}

static int cmp_u64(const void *a, const void *b) {
    uint64_t x = *(const uint64_t*)a;
    uint64_t y = *(const uint64_t*)b;
    return (x > y) - (x < y);
}

static uint64_t percentile_higher(const uint64_t *sorted, size_t n, double p) {
    if (n == 0) return 0;
    if (p <= 0.0) return sorted[0];
    if (p >= 100.0) return sorted[n - 1];
    double rank = (p / 100.0) * (double)n;
    size_t idx = (size_t)ceil(rank) - 1;
    if (idx >= n) idx = n - 1;
    return sorted[idx];
}

static inline uint64_t cycles_to_ns(uint64_t cycles, uint64_t hz) {
    long double ns = (long double)cycles * 1000000000.0L / (long double)hz;
    return (uint64_t)ns;
}

static inline void drop_rx_once(uint16_t port_id, uint16_t rxq, uint16_t burst) {
    struct rte_mbuf *rx_pkts[MAX_BURST];
    uint16_t n = rte_eth_rx_burst(port_id, rxq, rx_pkts, burst);
    for (uint16_t i = 0; i < n; i++) rte_pktmbuf_free(rx_pkts[i]);
}

static inline int send_one(uint16_t port_id, uint16_t txq) {
    struct rte_mbuf *m = rte_pktmbuf_alloc(mbuf_pool);
    if (!m) return -1;

    void *p = rte_pktmbuf_append(m, PAYLOAD_LEN);
    if (!p) { rte_pktmbuf_free(m); return -1; }

    uint8_t *data = rte_pktmbuf_mtod(m, uint8_t *);
    rte_memcpy(data, payload, PAYLOAD_LEN);

    uint16_t sent = rte_eth_tx_burst(port_id, txq, &m, 1);
    if (sent != 1) {
        rte_pktmbuf_free(m);
        return -1;
    }
    return 0;
}

static inline int recv_one_wait(uint16_t port_id, uint16_t rxq, uint16_t burst,
                                uint64_t deadline_tsc, uint16_t *out_len) {
    struct rte_mbuf *rx_pkts[MAX_BURST];

    while (!force_quit && rte_rdtsc() < deadline_tsc) {
        uint16_t n = rte_eth_rx_burst(port_id, rxq, rx_pkts, burst);
        if (!n) continue;

        struct rte_mbuf *m = rx_pkts[0];
        uint16_t len = (uint16_t)rte_pktmbuf_pkt_len(m);
        if (out_len) *out_len = len;

        rte_pktmbuf_free(m);
        for (uint16_t i = 1; i < n; i++) rte_pktmbuf_free(rx_pkts[i]);
        return 0;
    }
    return -1; // timeout
}

static void usage(const char *prog) {
    printf("Usage:\n"
           "  %s [EAL args] -- --port <id> --count <N> --timeout-ms <T> [--burst <B>] [--warmup-drop <W>]\n"
           "Example:\n"
           "  sudo %s -l 2 -n 4 -- --port 0 --count 200000 --timeout-ms 50 --burst 32 --warmup-drop 256\n",
           prog, prog);
}

int main(int argc, char **argv) {
    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    int ret = rte_eal_init(argc, argv);
    if (ret < 0) rte_exit(EXIT_FAILURE, "EAL init failed\n");
    argc -= ret;
    argv += ret;

    uint16_t port_id = 0;
    uint32_t count = 200000;
    uint32_t timeout_ms = 50;
    uint16_t burst = 32;
    uint32_t warmup_drop = 256;

    // parse args after '--'
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--port") && i + 1 < argc) {
            port_id = (uint16_t)atoi(argv[++i]);
        } else if (!strcmp(argv[i], "--count") && i + 1 < argc) {
            count = (uint32_t)strtoul(argv[++i], NULL, 10);
        } else if (!strcmp(argv[i], "--timeout-ms") && i + 1 < argc) {
            timeout_ms = (uint32_t)strtoul(argv[++i], NULL, 10);
        } else if (!strcmp(argv[i], "--burst") && i + 1 < argc) {
            burst = (uint16_t)atoi(argv[++i]);
        } else if (!strcmp(argv[i], "--warmup-drop") && i + 1 < argc) {
            warmup_drop = (uint32_t)strtoul(argv[++i], NULL, 10);
        } else if (!strcmp(argv[i], "--help") || !strcmp(argv[i], "-h")) {
            usage("dpdk_rtt_updates");
            return 0;
        } else {
            printf("Unknown arg: %s\n", argv[i]);
            usage("dpdk_rtt_updates");
            return 1;
        }
    }

    if (!rte_eth_dev_is_valid_port(port_id)) rte_exit(EXIT_FAILURE, "Invalid port %u\n", port_id);
    if (count == 0) rte_exit(EXIT_FAILURE, "--count must be >0\n");
    if (timeout_ms == 0) rte_exit(EXIT_FAILURE, "--timeout-ms must be >0\n");
    if (burst == 0 || burst > MAX_BURST) rte_exit(EXIT_FAILURE, "--burst must be 1..%d\n", MAX_BURST);

    mbuf_pool = rte_pktmbuf_pool_create("MBUF_POOL",
                                        NUM_MBUFS,
                                        MBUF_CACHE_SIZE,
                                        0,
                                        RTE_MBUF_DEFAULT_BUF_SIZE,
                                        rte_socket_id());
    if (!mbuf_pool) rte_exit(EXIT_FAILURE, "Cannot init mbuf pool: %s\n", rte_strerror(rte_errno));

    struct rte_eth_conf port_conf;
    memset(&port_conf, 0, sizeof(port_conf));

    uint16_t rxq = 0, txq = 0;
    ret = rte_eth_dev_configure(port_id, 1, 1, &port_conf);
    if (ret < 0) rte_exit(EXIT_FAILURE, "Cannot configure device: %s\n", rte_strerror(-ret));

    ret = rte_eth_rx_queue_setup(port_id, rxq, RX_RING_SIZE,
                                 rte_eth_dev_socket_id(port_id),
                                 NULL, mbuf_pool);
    if (ret < 0) rte_exit(EXIT_FAILURE, "RX queue setup failed: %s\n", rte_strerror(-ret));

    ret = rte_eth_tx_queue_setup(port_id, txq, TX_RING_SIZE,
                                 rte_eth_dev_socket_id(port_id),
                                 NULL);
    if (ret < 0) rte_exit(EXIT_FAILURE, "TX queue setup failed: %s\n", rte_strerror(-ret));

    ret = rte_eth_dev_start(port_id);
    if (ret < 0) rte_exit(EXIT_FAILURE, "Device start failed: %s\n", rte_strerror(-ret));

    rte_eth_promiscuous_enable(port_id);

    const uint64_t hz = rte_get_tsc_hz();
    printf("Port %u started. payload=%uB count=%u timeout_ms=%u burst=%u warmup_drop=%u tsc_hz=%" PRIu64 "\n",
           port_id, PAYLOAD_LEN, count, timeout_ms, burst, warmup_drop, hz);

    uint64_t *rtts_ns = (uint64_t*)malloc((size_t)count * sizeof(uint64_t));
    if (!rtts_ns) rte_exit(EXIT_FAILURE, "malloc failed\n");

    struct rte_eth_dev_info dev_info;
    memset(&dev_info, 0, sizeof(dev_info));
    rte_eth_dev_info_get(port_id, &dev_info);
    struct rte_pci_device *pci_dev = RTE_DEV_TO_PCI(dev_info.device);


    for (uint32_t i = 0; i < warmup_drop; i++) drop_rx_once(port_id, rxq, burst);

    uint64_t cmd = 0;     
    uint64_t sent = 0;    
    uint64_t ok = 0;      
    uint64_t fail = 0;    

    uint64_t t_begin = rte_rdtsc();

    for (uint32_t i = 0; i < count && !force_quit; i++) {
        cmd++;


        uint64_t t0 = rte_rdtsc();
        if (send_one(port_id, txq) != 0) {
            fail++;
            continue;
        }
        sent++;

        uint64_t deadline = t0 + (uint64_t)timeout_ms * (hz / 1000);
        uint16_t rx_len = 0;
        if (recv_one_wait(port_id, rxq, burst, deadline, &rx_len) == 0) {
            uint64_t t1 = rte_rdtsc();
            rtts_ns[ok++] = cycles_to_ns(t1 - t0, hz);
        } else {
            fail++;
        }
    }

    uint64_t t_end = rte_rdtsc();
    double wall_sec = (double)(t_end - t_begin) / (double)hz;

    // Throughputs
    double cmd_s  = (wall_sec > 0) ? ((double)cmd  / wall_sec) : 0.0; 
    double sent_s = (wall_sec > 0) ? ((double)sent / wall_sec) : 0.0; 
    double ok_s   = (wall_sec > 0) ? ((double)ok   / wall_sec) : 0.0; 

    double ack_rate = (sent > 0) ? (100.0 * (double)ok / (double)sent) : 0.0;
    double fail_rate = (cmd > 0) ? (100.0 * (double)fail / (double)cmd) : 0.0;

    printf("DONE: cmd=%" PRIu64 " sent=%" PRIu64 " ok=%" PRIu64 " fail=%" PRIu64
           " time=%.6fs  cmd/s=%.0f  sent/s=%.0f  ok/s=%.0f  ack_rate=%.3f%%  fail_rate=%.3f%%\n",
           cmd, sent, ok, fail, wall_sec, cmd_s, sent_s, ok_s, ack_rate, fail_rate);
    {
        if (!pci_dev) {
            printf("MMIO: device is not a PCI device (cannot read BAR)\n");
        } else {
            volatile void *bar2 = pci_dev->mem_resource[2].addr; 
            if (!bar2) {
                printf("MMIO: BAR2 not mapped (mem_resource[2].addr is NULL)\n");
            } else {
                uint32_t v0 = rte_read32((volatile void *)((volatile uint8_t*)bar2 + 0x100000));
                uint32_t v1 = rte_read32((volatile void *)((volatile uint8_t*)bar2 + 0x100004));
                printf("MMIO(BAR2): [0x100000]=0x%08" PRIx32 " (%" PRIu32 ")\n", v0, v0);
                printf("MMIO(BAR2): [0x100004]=0x%08" PRIx32 " (%" PRIu32 ")\n", v1, v1);
            }
        }
    }

    if (ok > 0) {
        qsort(rtts_ns, (size_t)ok, sizeof(uint64_t), cmp_u64);

        long double sum = 0;
        for (uint64_t i = 0; i < ok; i++) sum += (long double)rtts_ns[i];

        uint64_t p50  = percentile_higher(rtts_ns, (size_t)ok, 50.0);
        uint64_t p95  = percentile_higher(rtts_ns, (size_t)ok, 95.0);
        uint64_t p99  = percentile_higher(rtts_ns, (size_t)ok, 99.0);
        uint64_t p999 = percentile_higher(rtts_ns, (size_t)ok, 99.9);

        printf("RTT: min=%.2f us  mean=%.2f us  max=%.2f us\n",
               (double)rtts_ns[0]/1000.0,
               (double)(sum / (long double)ok)/1000.0,
               (double)rtts_ns[ok-1]/1000.0);

        printf("RTT: p50=%.2f us  p95=%.2f us  p99=%.2f us  p99.9=%.2f us\n",
               (double)p50/1000.0, (double)p95/1000.0, (double)p99/1000.0, (double)p999/1000.0);
    } else {
        printf("RTT: no successful ACK samples\n");
    }

    free(rtts_ns);

    rte_eth_dev_stop(port_id);
    rte_eth_dev_close(port_id);
    rte_eal_cleanup();
    return 0;
}