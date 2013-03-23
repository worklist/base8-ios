//
//  AppDelegate.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/8/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self customAppearanceStyles];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [AppUserDefaultsHandler getCustomerBalance];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Appearance Styles
- (void)customAppearanceStyles
{
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"black"] forBarMetrics:UIBarMetricsDefault];
}

- (CLLocation *)currentLocation
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
    
    CLLocation *userLocation = [Base8AppDelegate locationManager].location;
    if (!userLocation) {
        userLocation = [[CLLocation alloc] init];
    }
    
    return userLocation;
}

- (void)signOut
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    [AppUserDefaultsHandler setCurrentCustomer:nil];
}

@end
