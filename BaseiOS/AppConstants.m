//
//  AppConstants.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/9/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

@implementation AppConstants

#ifdef PRODUCTION
NSString* const kApiURL = @"http://base8.highfidelity.co/api/";
#else

NSString* const kApiURL = @"https://dev.worklist.net/~stojce/base8/api/";

NSString* const kTwitterCounsumerKey = @"nBeBItOYtfBGlIuC1I3Daw";
NSString* const kTwitterCounsumerSecret = @"kuUVGqaHQ9kIAZzMWdP2QFJK56DE6kxSqRa5x04CQEk";

NSString* const kUdpServer = @"54.241.126.160";
uint16_t const kUdpPort = 55110;

#endif

@end
