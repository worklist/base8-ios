//
//  AppUserDefaultsHandler.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUserDefaultsHandler : NSObject

+(void)setCurrentCustomer:(Customer *)currentCustomer;
+(Customer *)currentCustomer;

@end
