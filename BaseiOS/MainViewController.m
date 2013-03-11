//
//  MainViewController.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/10/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "MainViewController.h"
#import "TwitterLoginViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelBalance;

@end

@implementation MainViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UILabel* labelNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 170, 40)];
    labelNavTitle.textColor = [UIColor whiteColor];
    labelNavTitle.backgroundColor = [UIColor clearColor];
    
    labelNavTitle.textAlignment = UITextAlignmentLeft;
    Customer *currentCustomer = [APPUserDefaultsHandler currentCustomer];
    
    if (currentCustomer) {
        labelNavTitle.text = [NSString stringWithFormat:@"@%@", currentCustomer.twitterName];
        self.labelBalance.text = [NSString stringWithFormat:@"%@ pc", currentCustomer.balance];
    } else {
        
        labelNavTitle.text = @"";
        self.labelBalance.text = @"";
        
        TwitterLoginViewController *viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        [self presentViewController:viewController animated:NO completion:nil];
    }
    
    self.navigationItem.titleView = labelNavTitle;
}

- (IBAction)buttonLogoutTapped:(id *)sender
{
    [APPUserDefaultsHandler setCurrentUCustomer:nil];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    TwitterLoginViewController *viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
