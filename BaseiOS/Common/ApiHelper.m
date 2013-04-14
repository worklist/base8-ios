//
//  ApiHelper.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "AFNetworking.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#define ERROR_HEADER_KEY @"X-Status-Reason"

@implementation ApiHelper

#pragma mark - API Calls
+ (void)downloadTest:(apiCompletion)completion
{
    [self httpApiCallwithMethod:@"GET"
                           path:kDownloadTestApiMethod
                     parameters:nil
                  andCompletion:completion];
}

+ (void)uploadTest:(id)testData andCompletion:(apiCompletion)completion
{
    NSDictionary *params  = @{@"data": testData};
    [self httpApiCallwithMethod:@"POST"
                           path:kUploadTestApiMethod
                     parameters:params andCompletion:completion];
}

+ (void)finishJob:(NSDictionary *)testData withCompletion:(apiCompletion)completion
{
    
    NSMutableDictionary *postData  = [testData mutableCopy];
    
    NSURL *url = [NSURL URLWithString:kApiURL];
    
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [url.host UTF8String]);
    
    if (SCNetworkReachabilityGetFlags(reachability, &flags) && (flags & kSCNetworkFlagsReachable) == kSCNetworkFlagsReachable)
    {
        NSString *connectionType = @"WiFi";
        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
            connectionType = @"Mobile network";
        }
        [postData setObject:connectionType forKey:@"device_connection"];
    }
    
    [self httpApiCallwithMethod:@"POST"
                           path:kTestEndApiMethod
                     parameters:postData
                  andCompletion:completion];
}

+ (void)getBalance:(apiCompletion)completion
{
    [self jsonAPICall:kGetBalanceApiMethod withParams:nil andCompletion:completion];
}

+ (void)setTestFail:(apiCompletion)completion
{
    [self jsonAPICall:kTestFailApiMethod withParams:nil andCompletion:completion];
}

+ (void)getTestConfigurationWithCompletion:(apiCompletion)completion
{
    [self jsonAPICall:kTestRequestApiMethod withParams:nil andCompletion:completion];
}

+ (void)signInWithTwitterData:(NSDictionary *)twitterData
                andCompletion:(apiCompletion)completion
{
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    
    NSMutableDictionary *postData  = [twitterData mutableCopy];
    if (carrier) {
        [postData setObject:[carrier carrierName] forKey:@"carrier"];
    }
    
    [self httpApiCallwithMethod:@"POST"
                           path:kSignInApiMethod
                     parameters:postData
                  andCompletion:completion];
}

#pragma mark - private helpers

+ (AFHTTPClient *)sharedHTTPClient
{
    __strong static AFHTTPClient *httpClient = nil;
    if (!httpClient) {
        NSURL *apiUrl = [NSURL URLWithString:kApiURL];
        httpClient = [[AFHTTPClient alloc] initWithBaseURL:apiUrl];
    }
    
    return httpClient;
}

+ (void)jsonAPICall:(NSString *)apiMethod
         withParams:(NSArray *)parameters
      andCompletion:(apiCompletion)completion
{

    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kApiURL, apiMethod];
    if (parameters) {
        NSString *urlParams = [parameters componentsJoinedByString:@"/"];
        urlPath = [NSString stringWithFormat:@"%@/%@", urlPath, urlParams];
    }

    NSURL *url = [NSURL URLWithString:urlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];


    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *apiRequest, NSHTTPURLResponse *response, id JSON) {
                                             if (completion) {
                                                 completion(JSON, nil);
                                             }
                                         }
                                         failure:^(NSURLRequest *apiRequest, NSHTTPURLResponse *response, NSError *error, id JSON) {

                                             if (response.statusCode == 403) {
                                                 [Base8AppDelegate signOut];
                                             }

                                             NSString *customErrorMessage = [response allHeaderFields][ERROR_HEADER_KEY];
                                             
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
                                             
                                         }];
    [operation start];
}

+ (void)httpApiCallwithMethod:(NSString *)method
                         path:(NSString *)apiMethod
                   parameters:(NSDictionary *)params
                andCompletion:(apiCompletion)completion
{
    
    NSURLRequest *request = [[self sharedHTTPClient] requestWithMethod:method path:apiMethod parameters:params];
    AFHTTPRequestOperation *operation = [[self sharedHTTPClient]
            HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation *requestOperation, id responseObject) {

                                        if ([[requestOperation.response allHeaderFields][@"Content-Type"] isEqualToString:@"application/json"]) {

                                            NSError *error;
                                            NSDictionary *jsonDictionary = [NSJSONSerialization
                                                    JSONObjectWithData:responseObject
                                                               options:(NSJSONReadingOptions) 0
                                                                 error:&error];

                                            if (completion) {
                                                completion(jsonDictionary, error);
                                            }
                                        } else {

                                            if (completion) {
                                                completion(responseObject, nil);
                                            }
                                        }

                                    }
                                    failure:^(AFHTTPRequestOperation *requestOperation, NSError *error) {

                                        if (completion) {

                                            NSString *customErrorMessage = [[requestOperation response] allHeaderFields][ERROR_HEADER_KEY];
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

    [[self sharedHTTPClient] enqueueHTTPRequestOperation:operation];
}

@end
