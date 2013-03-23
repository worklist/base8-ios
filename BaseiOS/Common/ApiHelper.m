//
//  ApiHelper.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "AFNetworking.h"
#define ERROR_HEADER_KEY @"X-Status-Reason"

@implementation ApiHelper

#pragma mark - API Calls
+ (void)downloadTest:(apiCompletion)completion
{
    [self getAPICall:@"downloadtest" parameters:nil andCompletion:completion];
}

+ (void)uploadTest:(id)testData andCompletion:(apiCompletion)completion
{
    NSDictionary *params  = @{@"data": testData};
    [self postAPICall:@"uploadtest" parameters:params andCompletion:completion];
}

+ (void)finishJob:(NSArray *)testData withCompletion:(apiCompletion)completion
{
    [self putAPICall:@"testend" parameters:testData andCompletion:completion];
}

+ (void)getBalance:(apiCompletion)completion
{
    [self jsonAPICall:@"getbalance" withCompletion:completion];
}

+ (void)setTestFail:(apiCompletion)completion
{
    [self putAPICall:@"testfail" parameters:nil andCompletion:completion];
}

+ (void)getTestConfigurationWithCompletion:(apiCompletion)completion
{
    [self jsonAPICall:@"testrequest" withCompletion:completion];
}

+ (void)signInWithTwitterData:(NSDictionary *)twitterData
                andCompletion:(apiCompletion)completion
{    
    [self postAPICall:@"signin" parameters:twitterData andCompletion:completion];
}

#pragma mark - private helpers

+ (void)jsonAPICall:(NSString *)apiMethod withCompletion:(apiCompletion)completion
{
    [self jsonAPICall:apiMethod withParams:nil andCompletion:completion];
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
                                                 completion((NSDictionary *)JSON, nil);
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

    NSURL *apiUrl = [NSURL URLWithString:kApiURL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:apiUrl];
    NSURLRequest *request = [httpClient requestWithMethod:method path:apiMethod parameters:params];
    AFHTTPRequestOperation *operation = [httpClient
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

    [httpClient enqueueHTTPRequestOperation:operation];
}

+ (void)getAPICall:(NSString *)apiMethod
        parameters:(NSDictionary *)params
     andCompletion:(apiCompletion)completion
{
    [self httpApiCallwithMethod:@"GET"
                           path:apiMethod
                     parameters:params andCompletion:completion];
    
}

+ (void)postAPICall:(NSString *)apiMethod
         parameters:(NSDictionary *)params
      andCompletion:(apiCompletion)completion
{
    [self httpApiCallwithMethod:@"POST"
                           path:apiMethod
                     parameters:params andCompletion:completion];

}

+ (void)putAPICall:(NSString *)apiMethod
         parameters:(NSArray *)params
      andCompletion:(apiCompletion)completion
{
    if (params) {
        NSString *urlParams = [params componentsJoinedByString:@"/"];
        apiMethod = [NSString stringWithFormat:@"%@/%@", apiMethod, urlParams];
    }

    [self httpApiCallwithMethod:@"PUT"
                           path:apiMethod
                     parameters:nil
                  andCompletion:completion];

}


@end
