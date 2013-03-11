//
//  APPUserDefaultsHandler.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "APPUserDefaultsHandler.h"

// define a way to quickly grab and set NSUserDefaults
#define DEFAULTS(type, key) ([[NSUserDefaults standardUserDefaults] type##ForKey:key])
#define SET_DEFAULTS(Type, key, val) do {\
[[NSUserDefaults standardUserDefaults] set##Type:val forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];\
} while (0)

@implementation APPUserDefaultsHandler

NSString* const kCurrentCustomer = @"loggedCustomer";

+ (void)setCurrentUCustomer:(Customer *)currentCustomer
{
    // encode the user object
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:currentCustomer];
    
    // store it in user defaults
    SET_DEFAULTS(Object, kCurrentCustomer, encodedUser);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginStateChanged" object:nil];
}

+ (Customer *)currentCustomer
{
    if (DEFAULTS(object, kCurrentCustomer)) {
        
        NSData *myEncodedObject = DEFAULTS(object, kCurrentCustomer);
        Customer *customer = (Customer *)[NSKeyedUnarchiver unarchiveObjectWithData:myEncodedObject];
        if (!customer) {
            return nil;
        }
        return customer;
    }
    return nil;
}

@end
