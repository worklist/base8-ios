//
//  Job.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/20/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "Job.h"
#import "UdpTest.h"
#import "DownloadTest.h"
#import "UploadTest.h"

@interface Job() {
    int numberOfTests;
}

@property (nonatomic, assign) id<JobDelegate> jobDelegate;

@end

@implementation Job

@synthesize testData;

- (id)initWithDelegate:(id<JobDelegate>)delegate
{
    self = [super init];
    if (self && delegate) {
        self.jobDelegate = delegate;
    }

    return self;
}

- (void)start
{
    [ApiHelper getTestConfigurationWithCompletion:^(id response, NSError *error) {
        if (error) {
            if (self.jobDelegate && [(NSObject*)self.jobDelegate respondsToSelector:@selector(onError:)]) {
                [self.jobDelegate onError:error];
            }
        } else {
            numberOfTests = [response[@"test_runs"] integerValue];
            [self startUdpTest];
        }
    }];
}

- (void)startUdpTest
{
    if (self.jobDelegate && [(NSObject*)self.jobDelegate respondsToSelector:@selector(onJobLog:)]) {
        [self.jobDelegate onJobLog:@"ping test"];
    }

    UdpTest *udp = [[UdpTest alloc] initWithDelegate:self andNumberOfTests:numberOfTests];
    [udp performSelectorInBackground:@selector(start) withObject:nil];
    //[udp start];
}

- (void)startDownloadTest
{

    if (self.jobDelegate && [(NSObject*)self.jobDelegate respondsToSelector:@selector(onJobLog:)]) {
        [self.jobDelegate onJobLog:@"download test"];
    }

    DownloadTest *download = [[DownloadTest alloc] initWithDelegate:self andNumberOfTests:numberOfTests];
    [download performSelectorInBackground:@selector(start) withObject:nil];
    //[download start];
}

- (void)startUploadTest
{
    if (self.jobDelegate && [(NSObject*)self.jobDelegate respondsToSelector:@selector(onJobLog:)]) {
        [self.jobDelegate onJobLog:@"upload test"];
    }

    UploadTest *upload = [[UploadTest alloc] initWithDelegate:self andNumberOfTests:numberOfTests];
    [upload performSelectorInBackground:@selector(start) withObject:nil];
    //[upload start];
}

- (void)test:(id)test didFinishWithDeviceTime:(int)deviceAverage andServerTime:(int)serverAverage
{
    if ([test isKindOfClass:[UdpTest class]]) {
        [self logStatus:[NSString stringWithFormat:@"average ping time: %dms (%dms)", deviceAverage, serverAverage]];
        NSArray *testResults = @[
                @"udp",
                [NSNumber numberWithInt:deviceAverage],
                [NSNumber numberWithInt:serverAverage]
        ];

        [ApiHelper finishJob:testResults withCompletion:^(id response, NSError *error) {
            if (!error) {
                [self startDownloadTest];
            }
        }];
    }
}

- (void)test:(id)test didFinishWithTime:(int)average
{
    if ([test isKindOfClass:[DownloadTest class]]) {

        [self logStatus:[NSString stringWithFormat:@"average download time: %dms", average]];
        NSArray *testResults = @[
                @"download",
                [NSNumber numberWithInt:average]
        ];
        [ApiHelper finishJob:testResults  withCompletion:^(id response, NSError *error) {
            if (!error) {
                [self startUploadTest];
            }
        }];
    }

    if ([test isKindOfClass:[UploadTest class]]) {

        [self logStatus:[NSString stringWithFormat:@"average upload time: %dms", average]];
        NSArray *testResults = @[
                @"upload",
                [NSNumber numberWithInt:average],
                @0,
                [NSNumber numberWithDouble:AppUserDefaultsHandler.currentCustomer.location.coordinate.latitude],
                [NSNumber numberWithDouble:AppUserDefaultsHandler.currentCustomer.location.coordinate.longitude]
        ];

        [ApiHelper finishJob:testResults  withCompletion:^(id response, NSError *error) {
            if (!error) {
                if ([(NSObject *)self.jobDelegate respondsToSelector:@selector(didFinish:)]) {
                    [self.jobDelegate didFinish:@"OK"];
                }
            }
        }];
    }
}

- (void)logStatus:(NSString *)logLine
{
    if (self.jobDelegate && [(NSObject*)self.jobDelegate respondsToSelector:@selector(onJobLog:)]) {
        [self.jobDelegate onJobLog:logLine];
    }
}

- (void)test:(id)test didFinishWithError:(NSError *)error
{
    [ApiHelper setTestFail:^(NSDictionary *json, NSError *apiError) {
        if (self.jobDelegate && [(NSObject*)self.jobDelegate respondsToSelector:@selector(onError:)]) {
            [self.jobDelegate onError:error];
        }
        [self logStatus:[NSString stringWithFormat:@"Error occurred: %@", error.localizedDescription]];
    }];
}

@end
