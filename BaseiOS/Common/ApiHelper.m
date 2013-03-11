//
//  ApiHelper.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "ApiHelper.h"
#import "AFNetworking.h"

@implementation ApiHelper

#pragma mark - Sign in
+ (void)signInWithTwitterData:(NSDictionary *)twitterData
              andCompletition:(void(^)(NSDictionary *json, NSError *error))completion
{
    
    NSURL *apiUrl = [NSURL URLWithString:kApiURL];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:apiUrl];
    
    [httpClient postPath:@"signin"
             parameters:twitterData
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSError *error;
                    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                                   options:0
                                                                                     error:&error];
                    if (completion) {
                        completion(jsonDictionary, error);
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if (completion) {
                        
                        NSString *customErrorMessage = [[[operation response] allHeaderFields] objectForKey:@"X-Status-Reason"];
                        if (customErrorMessage) {
                            
                            NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                            [userInfo setValue:customErrorMessage forKey:NSLocalizedDescriptionKey];

                            NSError *customError = [NSError errorWithDomain:error.domain
                                                                       code:error.code
                                                                   userInfo:userInfo];
                            
                            completion(nil, customError);
                        } else {
                            completion(nil, error);
                        }
                    }
                }];
}

@end
