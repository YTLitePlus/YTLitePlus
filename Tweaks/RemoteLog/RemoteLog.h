#ifndef _REMOTE_LOG_H_
#define _REMOTE_LOG_H_

#import <netinet/in.h>
#import <sys/socket.h>
#import <unistd.h>
#import <arpa/inet.h>

// change this to match your destination (server) IP address
#define RLOG_IP_ADDRESS "replace with ip"
#define RLOG_PORT 11909

__attribute__((unused)) static void RLogv(NSString* format, va_list args)
{
    #if DEBUG
        NSString* str = [[NSString alloc] initWithFormat:format arguments:args];

        int sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
        if (sd <= 0)
        {
            NSLog(@"[RemoteLog] Error: Could not open socket");
            return;
        }

        int broadcastEnable = 1;
        int ret = setsockopt(sd, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
        if (ret)
        {
            NSLog(@"[RemoteLog] Error: Could not open set socket to broadcast mode");
            close(sd);
            return;
        }

        struct sockaddr_in broadcastAddr;
        memset(&broadcastAddr, 0, sizeof broadcastAddr);
        broadcastAddr.sin_family = AF_INET;
        inet_pton(AF_INET, RLOG_IP_ADDRESS, &broadcastAddr.sin_addr);
        broadcastAddr.sin_port = htons(RLOG_PORT);

        char* request = (char*)[str UTF8String];
        ret = sendto(sd, request, strlen(request), 0, (struct sockaddr*)&broadcastAddr, sizeof broadcastAddr);
        if (ret < 0)
        {
            NSLog(@"[RemoteLog] Error: Could not send broadcast");
            close(sd);
            return;
        }
        close(sd);
    #endif
}

__attribute__((unused)) static void RLog(NSString* format, ...)
{
    #if DEBUG
        va_list args;
        va_start(args, format);
        RLogv(format, args);
        va_end(args);
    #endif
}
#endif
