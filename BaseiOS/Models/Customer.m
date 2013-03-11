//
//  Customer.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/10/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "Customer.h"

@implementation Customer
-(id)initFromDictionary:(NSDictionary *)userDict
{
    self = [super init];
    if (self) {
        
        self.customerId = [userDict objectForKey:@"id"];
        self.twitterId = [userDict objectForKey:@"twitterId"];
        self.twitterName = [userDict objectForKey:@"twitterName"];
        self.nickname = [userDict objectForKey:@"nickname"];
        self.balance = [userDict objectForKey:@"balance"];
        self.joinDate = [userDict objectForKey:@"joinDate"];
        self.oauthToken = [userDict objectForKey:@"oauthToken"];
        self.oauthSecret = [userDict objectForKey:@"oauthSecret"];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.customerId = [decoder decodeObjectForKey:@"id"];
        self.twitterId = [decoder decodeObjectForKey:@"twitterId"];
        self.twitterName = [decoder decodeObjectForKey:@"twitterName"];
        self.nickname = [decoder decodeObjectForKey:@"nickname"];
        self.balance = [decoder decodeObjectForKey:@"balance"];
        self.joinDate = [decoder decodeObjectForKey:@"joinDate"];
        self.oauthToken = [decoder decodeObjectForKey:@"oauthToken"];
        self.oauthSecret = [decoder decodeObjectForKey:@"oauthSecret"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.customerId forKey:@"id"];
    [encoder encodeObject:self.twitterId forKey:@"twitterId"];
    [encoder encodeObject:self.twitterName forKey:@"twitterName"];
    [encoder encodeObject:self.nickname forKey:@"nickname"];
    [encoder encodeObject:self.balance forKey:@"balance"];
    [encoder encodeObject:self.joinDate forKey:@"joinDate"];
    [encoder encodeObject:self.oauthToken forKey:@"oauthToken"];
    [encoder encodeObject:self.oauthSecret forKey:@"oauthSecret"];
}


@end
