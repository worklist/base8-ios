//
//  APPUserDefaultsHandler.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APPUserDefaultsHandler : NSObject

+(void)setCurrentUCustomer:(Customer *)currentCustomer;
+(Customer *)currentCustomer;

@end
