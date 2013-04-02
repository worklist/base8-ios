//
//  UploadTest.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/21/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "UploadTest.h"

@interface UploadTest() {
    int averageTime;
}

@end

@implementation UploadTest

- (void)start
{
    [self uploadData];
}

- (void) uploadData
{
    self.currentTest++;
    
    int startTime = CACurrentMediaTime() * 1000;
    [ApiHelper uploadTest:[self.testDelegate testData] andCompletion:^(id response, NSError *error) {
        int endTime = CACurrentMediaTime() * 1000;
        if (error) {
            [super didFinishWithError:error];
            return;
        }
        averageTime = (averageTime * (self.currentTest - 1) + (endTime - startTime)) / self.currentTest;
        
        if (self.currentTest >= self.numberOfTests) {
            [super didFinishWithTime:averageTime];
        } else {
            [self uploadData];
        }
    }];
}

@end
