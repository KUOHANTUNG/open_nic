// Build: gcc -O2 -march=native -Wall -Wextra -o rtt_test rtt_test.c
// Run:   taskset -c 2 ./rtt_test <server_ip> <server_port> <count> [local_port] [timeout_ms] [max_retry]
//
// Example (match your trace: local_port=5001):
//   taskset -c 2 ./rtt_test 10.0.0.1 5000 500 5001 500 20

#define _GNU_SOURCE
#include <arpa/inet.h>
#include <errno.h>
#include <inttypes.h>
#include <math.h>
#include <netinet/in.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

static inline uint64_t now_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ull + (uint64_t)ts.tv_nsec;
}

static int cmp_u64(const void *a, const void *b) {
    uint64_t x = *(const uint64_t *)a;
    uint64_t y = *(const uint64_t *)b;
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

int main(int argc, char **argv) {
    if (argc < 4) {
        fprintf(stderr,
            "Usage: %s <server_ip> <server_port> <count> [local_port] [timeout_ms] [max_retry]\n"
            "Example: taskset -c 2 %s 10.0.0.1 5000 500 5001 500 20\n",
            argv[0], argv[0]);
        return 1;
    }

    const char *server_ip = argv[1];
    int server_port = atoi(argv[2]);
    long count = atol(argv[3]);
    int local_port = (argc >= 5) ? atoi(argv[4]) : 5001;
    int timeout_ms = (argc >= 6) ? atoi(argv[5]) : 500;
    int max_retry = (argc >= 7) ? atoi(argv[6]) : 20;

    if (server_port <= 0 || server_port > 65535 || count <= 0 ||
        local_port <= 0 || local_port > 65535 || timeout_ms <= 0 || max_retry <= 0) {
        fprintf(stderr, "Invalid args.\n");
        return 1;
    }

    // Fixed payload (request)
    static const uint8_t payload[32] = {
        0xff, 0xff, 0x00, 0x00, 0x00, 0x0A, 0x08, 0x00,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    };

    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) { perror("socket"); return 1; }

    // Bind local port ( source port = 5001)
    struct sockaddr_in local;
    memset(&local, 0, sizeof(local));
    local.sin_family = AF_INET;
    local.sin_addr.s_addr = htonl(INADDR_ANY);
    local.sin_port = htons((uint16_t)local_port);
    if (bind(fd, (struct sockaddr *)&local, sizeof(local)) != 0) {
        perror("bind(local_port)");
        close(fd);
        return 1;
    }

    // recv timeout
    struct timeval tv;
    tv.tv_sec = timeout_ms / 1000;
    tv.tv_usec = (timeout_ms % 1000) * 1000;
    if (setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) != 0) {
        perror("setsockopt(SO_RCVTIMEO)");
        close(fd);
        return 1;
    }

    int buf_sz = 4 * 1024 * 1024;
    setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &buf_sz, sizeof(buf_sz));
    setsockopt(fd, SOL_SOCKET, SO_RCVBUF, &buf_sz, sizeof(buf_sz));

    struct sockaddr_in srv;
    memset(&srv, 0, sizeof(srv));
    srv.sin_family = AF_INET;
    srv.sin_port = htons((uint16_t)server_port);
    if (inet_pton(AF_INET, server_ip, &srv.sin_addr) != 1) {
        fprintf(stderr, "Invalid server_ip: %s\n", server_ip);
        close(fd);
        return 1;
    }

    uint8_t rxbuf[2048];
    uint64_t *rtts_ns = (uint64_t *)malloc((size_t)count * sizeof(uint64_t));
    if (!rtts_ns) { fprintf(stderr, "malloc failed\n"); close(fd); return 1; }

    long ok = 0;
    long failed = 0;

    for (long i = 0; i < count; i++) {
        bool got = false;
        uint64_t t0 = 0;

        for (int retry = 0; retry < max_retry; retry++) {
            t0 = now_ns();
            ssize_t s = sendto(fd, payload, sizeof(payload), 0,
                               (struct sockaddr *)&srv, sizeof(srv));
            if (s != (ssize_t)sizeof(payload)) {
                fprintf(stderr, "sendto error i=%ld retry=%d errno=%d (%s)\n",
                        i, retry, errno, strerror(errno));
                continue;
            }

            struct sockaddr_in from;
            socklen_t fromlen = sizeof(from);
            ssize_t r = recvfrom(fd, rxbuf, sizeof(rxbuf), 0,
                                 (struct sockaddr *)&from, &fromlen);
            if (r < 0) {
                if (errno == EAGAIN || errno == EWOULDBLOCK) {
                    // timeout: retry same request
                    continue;
                }
                fprintf(stderr, "recvfrom error i=%ld retry=%d errno=%d (%s)\n",
                        i, retry, errno, strerror(errno));
                continue;
            }

            if (from.sin_addr.s_addr != srv.sin_addr.s_addr) {
                // ignore and keep waiting/retrying
                continue;
            }

            uint64_t t1 = now_ns();
            rtts_ns[ok++] = (t1 - t0);
            got = true;
            break;
        }

        if (!got) {
            failed++;
        }
    }

    if (ok == 0) {
        fprintf(stderr, "No successful replies. failed=%ld\n", failed);
        free(rtts_ns);
        close(fd);
        return 1;
    }

    qsort(rtts_ns, (size_t)ok, sizeof(uint64_t), cmp_u64);

    long double sum_ns = 0.0L;
    for (long i = 0; i < ok; i++) sum_ns += (long double)rtts_ns[i];

    uint64_t p50  = percentile_higher(rtts_ns, (size_t)ok, 50.0);
    uint64_t p95  = percentile_higher(rtts_ns, (size_t)ok, 95.0);
    uint64_t p99  = percentile_higher(rtts_ns, (size_t)ok, 99.0);
    uint64_t p999 = percentile_higher(rtts_ns, (size_t)ok, 99.9);

    printf("server=%s:%d local_port=%d payload=%zuB count=%ld timeout_ms=%d max_retry=%d\n",
           server_ip, server_port, local_port, sizeof(payload), count, timeout_ms, max_retry);
    printf("ok=%ld failed=%ld fail_rate=%.3f%%\n", ok, failed, 100.0 * (double)failed / (double)(ok + failed));

    printf("min=%.2f us  mean=%.2f us  max=%.2f us\n",
           (double)rtts_ns[0]/1000.0,
           (double)(sum_ns/(long double)ok)/1000.0,
           (double)rtts_ns[ok-1]/1000.0);

    printf("p50=%.2f us  p95=%.2f us  p99=%.2f us  p99.9=%.2f us\n",
           (double)p50/1000.0, (double)p95/1000.0, (double)p99/1000.0, (double)p999/1000.0);

    free(rtts_ns);
    close(fd);
    return 0;
}
