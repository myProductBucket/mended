//
//  RLAddressViewController.m
//  Relaced
//
//  Created by Mybrana on 10/04/15.
//
//

#import "RLAddressViewController.h"
#import "RLUtils.h"
#import <Parse/Parse.h>

@interface RLAddressViewController ()

@property (weak, nonatomic) IBOutlet UIView *addressFieldsContainer;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *streetAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeTextField;

@end

@implementation RLAddressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"ADDRESS";
    
    self.addressFieldsContainer.layer.cornerRadius = 5.0f;
        
    [self configureDoneButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UI

- (void)configureDoneButton
{
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    doneButton.titleLabel.textColor = [UIColor whiteColor];
    [doneButton setTitle:@"DONE" forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:13.0];
    doneButton.frame = CGRectMake(0.0, 0.0, 50.0, 25.0f);
    doneButton.backgroundColor = [RLUtils colorFromHexString:@"#33cc66"];
    doneButton.layer.cornerRadius = 5.0f;
    [doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
}

#pragma mark IBActions

- (IBAction)doneButtonPressed:(id)sender
{
    if ([self validateCurrentInformation])
    {
        [self createNewAddressWithCurrentInformation];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing information" message:@"All fields are required" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark Validation

- (BOOL)validateCurrentInformation
{
    if ([self isTextFieldEmpty:self.firstNameTextField])
    {
        return NO;
    }
    
    if ([self isTextFieldEmpty:self.lastNameTextField])
    {
        return NO;
    }
    
    if ([self isTextFieldEmpty:self.streetAddressTextField])
    {
        return NO;
    }
    
    if ([self isTextFieldEmpty:self.cityTextField])
    {
        return NO;
    }
    
    if ([self isTextFieldEmpty:self.stateTextField])
    {
        return NO;
    }
    
    if ([self isTextFieldEmpty:self.postalCodeTextField])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)isTextFieldEmpty:(UITextField *)textField
{
    if (textField.text && (textField.text.length > 0))
    {
        return NO;
    }
    
    return YES;
}

#pragma mark Parse

- (void)createNewAddressWithCurrentInformation
{
    PFObject *newAddressObject = [PFObject objectWithClassName:kRLAddressClass];
    newAddressObject[kRLPersonNameKey] = [self.firstNameTextField.text stringByAppendingFormat:@" %@", self.lastNameTextField.text];
    newAddressObject[kRLAddressLine1Key] = self.streetAddressTextField.text;
    newAddressObject[kRLCityKey] = self.cityTextField.text;
    newAddressObject[kRLStateOrRegionKey] = self.stateTextField.text;
    newAddressObject[kRLPostalCodeKey] = self.postalCodeTextField.text;
    
    [newAddressObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
        if (!error)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"The address could not be saved, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            NSLog(@"Could not save address: %@", error.description);
        }
    }];
}

@end
