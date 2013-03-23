//
//  UdpTest.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/21/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "UdpTest.h"
#import "GCDAsyncUdpSocket.h"

@interface UdpTest() {
    GCDAsyncUdpSocket *udpSocket;
    double serverStartTime;
    double clientStartTime;
    int averageDeviceTime;
    int averageServerTime;
}

@end

@implementation UdpTest

- (void)start
{
    if (!udpSocket) {
		[self setupSocket];
	}

    // first ping is not calculated, used for establishing UDP connection
    self.currentTest = -1;
    [self sendData];
}

- (void)sendData
{
    self.currentTest ++;
    NSString *stringData = [NSString stringWithFormat:@"P%f", clientStartTime];
    NSData *data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:kUdpServer port:kUdpPort withTimeout:10 tag:0];
}

#pragma mark GCDAsyncUdpSocketDelegate
- (void)setupSocket
{
	udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	NSError *error = nil;
	
	if (![udpSocket bindToPort:0 error:&error])	{
		NSLog(@"Error binding: %@", error);
		return;
	}
	if (![udpSocket beginReceiving:&error]) {
		NSLog(@"Error receiving: %@", error);
		return;
	}
}

- (void)udpSocket:(GCDAsyncUdpSocket *)socket didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.testDelegate && [(NSObject*)self.testDelegate respondsToSelector:@selector(onTestError:)]) {
        [self.testDelegate onTestError:error];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
	if (msg && [msg hasPrefix:@"R"]) {

        double serverTime = ([[msg substringFromIndex:1] doubleValue] * 1000);
        double clientTime = ([[NSDate date] timeIntervalSince1970] * 1000);

        if (serverStartTime > 0) {
            int clientRTT = (int) (clientTime - clientStartTime);
            int serverRTT = (int) (serverTime - serverStartTime);
            
            averageDeviceTime = (averageDeviceTime * (self.currentTest - 1) + clientRTT) / self.currentTest;
            averageServerTime = (averageServerTime * (self.currentTest - 1) + serverRTT) / self.currentTest;
        }
        
        serverStartTime = serverTime;
        clientStartTime = clientTime;
	} else {
		NSString *host = nil;
		uint16_t port = 0;
		[GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
		
		NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
	}
    
    if (self.currentTest >= self.numberOfTests) {
        if (self.testDelegate && [(NSObject*)self.testDelegate respondsToSelector:@selector(test:didFinishWithDeviceTime:andServerTime:)]) {
            [self.testDelegate test:self didFinishWithDeviceTime:averageDeviceTime andServerTime:averageServerTime];
            [udpSocket close];
        }
    } else {
        [self sendData];
    }
}

@end
