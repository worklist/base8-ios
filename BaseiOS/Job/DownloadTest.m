//
//  DownloadTest.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/21/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "DownloadTest.h"

@interface DownloadTest()

@property (nonatomic) int averageTime;

@end

@implementation DownloadTest

- (void)start
{
    [self downloadData];
}

- (void) downloadData
{
    self.currentTest++;
    
    int startTime = CACurrentMediaTime() * 1000;
    [ApiHelper downloadTest:^(id responseObject, NSError *error) {
        int endTime = CACurrentMediaTime() * 1000;
        if (error) {
            [super didFinishWithError:error];
            return;
        }
        self.averageTime = (self.averageTime * (self.currentTest - 1) + (endTime - startTime)) / self.currentTest;
        
        if (self.currentTest >= self.numberOfTests) {
            [self.testDelegate setTestData:responseObject];
            [super didFinishWithTime:self.averageTime];
            
        } else {
            [self downloadData];
        }
    }];
}

@end
