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
@property (weak, nonatomic) IBOutlet UIButton *buttonStartJob;
@property (weak, nonatomic) IBOutlet UITextView *textViewLog;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorJob;

@end

@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userStateChanged)
                                                 name:@"LoginStateChanged"
                                               object:nil];

    UILabel* labelNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 190, 40)];
    labelNavTitle.textColor = [UIColor whiteColor];
    labelNavTitle.backgroundColor = [UIColor clearColor];

    labelNavTitle.textAlignment = NSTextAlignmentLeft;
    Customer *currentCustomer = AppUserDefaultsHandler.currentCustomer;

    if (currentCustomer) {
        labelNavTitle.text = [NSString stringWithFormat:@"@%@", currentCustomer.twitterName];
        
        CLLocation *userLocation = [Base8AppDelegate locationManager].location;
        if (!userLocation) {
            userLocation = [[CLLocation alloc] init];
        }
        
    } else {

        labelNavTitle.text = @"";
        TwitterLoginViewController *viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                                bundle:nil]
                instantiateViewControllerWithIdentifier:@"loginView"];
        [self presentViewController:viewController animated:NO completion:nil];
    }
    
    [self updateCustomerBalanceLabel];
    self.navigationItem.titleView = labelNavTitle;
    self.textViewLog.text = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userStateChanged
{
    if (!AppUserDefaultsHandler.currentCustomer) {
        TwitterLoginViewController *viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                                bundle:nil]
                instantiateViewControllerWithIdentifier:@"loginView"];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        [self updateCustomerBalanceLabel];
    }
}

- (void)updateCustomerBalanceLabel
{
    Customer *currentCustomer = AppUserDefaultsHandler.currentCustomer;
    
    if (currentCustomer) {
        NSString *balanceText = [NSString stringWithFormat:@"%.2f pc", currentCustomer.balance];
        self.labelBalance.text = balanceText;
    } else {
        self.labelBalance.text = @"";
    }
}

- (IBAction)buttonLogoutTapped:(id *)sender
{
    [Base8AppDelegate signOut];
}

- (IBAction)startJobTapped:(UIButton *)sender
{
    self.textViewLog.text = @"";
    sender.enabled = NO;
    Job *job = [[Job alloc] initWithDelegate:self];
    [job start];
    [self.indicatorJob startAnimating];
    self.buttonStartJob.alpha = 0;
}

-(void)logCall:(NSString *)logLine
{
    self.textViewLog.text = [NSString stringWithFormat:@"%@\n%@",  self.textViewLog.text, logLine];
}

#pragma mark JobDelegate
-(void)didFinish:(NSString *)status
{
    [self logCall:status];
    self.buttonStartJob.enabled = YES;
    self.buttonStartJob.alpha = 1;
    [self.indicatorJob stopAnimating];
    
    [AppUserDefaultsHandler getCustomerBalance];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Job done"
                                                    message:@"You have been credited with 1PC"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)onError:(NSError *)error
{
    self.buttonStartJob.enabled = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)onJobLog:(NSString *)logLine
{
    [self logCall:logLine];
}

@end
