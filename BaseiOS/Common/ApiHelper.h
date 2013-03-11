//
//  ApiHelper.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiHelper : NSObject

#pragma mark - Sign in
+ (void)signInWithTwitterData:(NSDictionary *)twitterData
              andCompletition:(void(^)(NSDictionary *json, NSError *error))completion;

@end
