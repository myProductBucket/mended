//
//  PAPLoginViewController.m
//  Relaced
//
//  Created by Qibo Fu on 8/27/13.
//
//

#import "PAPLoginViewController.h"
#import "MBProgressHUD.h"

@interface PAPLoginViewController ()

@end

@implementation PAPLoginViewController

@synthesize welcomeController;

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

    self.title = @"Sign In";
    self.navigationController.navigationBar.translucent = NO;
}



- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [email becomeFirstResponder];
}

- (void)dealloc
{
    self.welcomeController = nil;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)login:(id)sender
{
    [self hideKeyboard:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:email.text];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:@"Invalid credentials" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        PFUser *user = (PFUser *)object;
        [PFUser logInWithUsernameInBackground:user.username password:password.text block:^(PFUser *user, NSError *error) {
            if (user) {
                [welcomeController showHome];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:[[error userInfo] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [email becomeFirstResponder];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetPassword:(NSString *)recoveryEmail isUpperCase:(BOOL)isUpperCase
{
    if (isUpperCase) {
        recoveryEmail = [recoveryEmail uppercaseString];
    }
    else {
        recoveryEmail = [recoveryEmail lowercaseString];
    }
    
    [PFUser requestPasswordResetForEmailInBackground:recoveryEmail block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:@"Instruction mail sent. Please check your mail box" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            
            if (isUpperCase) {
                [self resetPassword:recoveryEmail isUpperCase:NO];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:[[error userInfo ] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
}

- (IBAction)forgotPassword:(id)sender
{
    //Hide any open iOS keyboard first, before bring up the Forgot Password prompt
    //which will itself bring up its own keyboard
    [self.view endEditing:YES];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Send Email", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:(0)] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[alert textFieldAtIndex:(0)] setKeyboardAppearance:UIKeyboardAppearanceDark];
    [alert textFieldAtIndex:(0)].clearButtonMode = UITextFieldViewModeAlways;
    [alert textFieldAtIndex:(0)].placeholder = @"Enter Email";
    [alert show];
    [[alert textFieldAtIndex:(0)] becomeFirstResponder];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString * resetEmail = [[alertView textFieldAtIndex:(0)] text];
        [self resetPassword:resetEmail isUpperCase:YES];
    }
}

- (IBAction)hideKeyboard:(id)sender
{
    [email resignFirstResponder];
    [password resignFirstResponder];
}

#pragma mark - UITextView Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == email) {
        [password becomeFirstResponder];
    }
    else {
        [self login:nil];
    }
    
    return YES;
}

@end
