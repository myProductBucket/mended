//
//  PAPWelcomeViewController.m
//  Relaced
//
//  Created by Qibo Fu on 8/26/13.
//
//

#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "PAPWelcomeViewController.h"
#import "PAPLoginViewController.h"
#import "PAPSignupViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "RLUtils.h"

#define TERMOFPOLICY @"termofpolicy"

@interface PAPWelcomeViewController ()

@end

@implementation PAPWelcomeViewController

@synthesize signUpButton;
@synthesize signInButton;
@synthesize termsLabel;
@synthesize privacyPolicyLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //for terms of policy
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if (![user objectForKey:TERMOFPOLICY]) {
        UIAlertView *alertViewAsk = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"By clicking Agree button, you're agreeing to our terms and rules.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"I Agree", nil) otherButtonTitles:NSLocalizedString(@"Help", nil),nil];
        [alertViewAsk show];
    }
    
//    UILongPressGestureRecognizer * userHoldingTermsLabel = [[UILongPressGestureRecognizer alloc]
//                                                       initWithTarget:self
//                                                       action:@selector(userHeldLabel:)];
//    userHoldingTermsLabel.minimumPressDuration = 0;
//    userHoldingTermsLabel.allowableMovement = 2;
//    [termsLabel addGestureRecognizer:userHoldingTermsLabel];
//    
//    
//    UILongPressGestureRecognizer * userHoldingPrivacyPolicyLabel = [[UILongPressGestureRecognizer alloc]
//                                                            initWithTarget:self
//                                                            action:@selector(userHeldLabel:)];
//    userHoldingPrivacyPolicyLabel.minimumPressDuration = 0;
//    userHoldingPrivacyPolicyLabel.allowableMovement = 2;
//    [privacyPolicyLabel addGestureRecognizer:userHoldingPrivacyPolicyLabel];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"agree" forKey:TERMOFPOLICY];
        NSLog(@"I agree....");
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"agree" forKey:TERMOFPOLICY];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://getrelaced.com/legal/terms.html"]];
        
        NSLog(@"Help....");
    }
}

#pragma mark - Custom Method

-(void)userHeldLabel:(UILongPressGestureRecognizer *)sender
{
    //Change the color of the top header when it's held down
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (sender.view == termsLabel) {
            termsLabel.textColor = [UIColor whiteColor];
        }
        else if (sender.view == privacyPolicyLabel) {
            privacyPolicyLabel.textColor = [UIColor whiteColor];
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        if (sender.view == termsLabel) {
            termsLabel.textColor = [RLUtils relacedRed];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://getrelaced.com/legal/terms.html"]];
        }
        else if (sender.view == privacyPolicyLabel) {
            privacyPolicyLabel.textColor = [RLUtils relacedRed];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://getrelaced.com/legal/policy.html"]];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    PAPLoginViewController *loginController = [[PAPLoginViewController alloc] initWithNibName:@"PAPLoginViewController" bundle:nil];
    //loginController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    loginController.welcomeController = self;
//    [self presentViewController:loginController animated:YES completion:nil];
    [self.navigationController pushViewController:loginController animated:YES];
}

- (IBAction)signup:(id)sender
{
    PAPSignupViewController *signupController = [[PAPSignupViewController alloc] initWithNibName:@"PAPSignupViewController" bundle:nil];
    //signupController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    signupController.welcomeController = self;
//    [self presentViewController:signupController animated:YES completion:nil];
    
    [self.navigationController pushViewController:signupController animated:YES];
}

- (IBAction)loginWithFacebook:(id)sender
{
    NSArray *permissions = [NSArray arrayWithObjects:@"user_about_me", @"read_friendlists", nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!user) {
            if (!error) {
                NSLog(@"The user cancelled the Facebook login");
            }
            else {
                NSLog(@"An error occurred: %@", error);
            }
        }
        else {
            NSLog(@"User with Facebook logged in!");
            
            // user has logged in - we need to fetch all of their Facebook data before we let them in
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate didLogInWithFacebook:user];
            
        }
    }];
}

- (void)termsLabelTouched:(id)sender
{
    
}

- (void)showHome
{
//    [self dismissViewControllerAnimated:YES completion:^{
        // Present Anypic UI
    PFFile *imageFile = [[PFUser currentUser] objectForKey:kPAPUserProfilePicMediumKey];
    
    if (imageFile)
    {
        [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (!error && data) {
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:MY_PORTRAIT];
            }
            // Present Anypic UI
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
        }];
    }
//    }];
}

@end
