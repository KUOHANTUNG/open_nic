#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>

int main(void) {
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("socket");
        return 1;
    }

    int on = 1;
    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(5000);
    addr.sin_addr.s_addr = inet_addr("10.0.0.1");

    if (bind(sock, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("bind");
        close(sock);
        return 1;
    }

    enum { RESP_LEN = 32 };
    unsigned char resp[RESP_LEN];
    resp[0] = 0xCC;
    resp[1] = 0xCC;
    memset(resp + 2, 0xAA, RESP_LEN - 2);

    unsigned char buf[2048];
    struct sockaddr_in peer;
    socklen_t plen = sizeof(peer);

    while (1) {
        int n = recvfrom(sock, buf, sizeof(buf), 0, (struct sockaddr*)&peer, &plen);
        if (n < 0) {
            if (errno == EINTR) continue;
            perror("recvfrom");
            continue;
        }

        int s = sendto(sock, resp, RESP_LEN, 0, (struct sockaddr*)&peer, plen);
        if (s < 0) {
            perror("sendto");
            continue;
        }
    }

    // never reached
    // close(sock);
    // return 0;
}
