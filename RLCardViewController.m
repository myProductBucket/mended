//
//  RLCardViewController.m
//  Relaced
//
//  Created by Mybrana on 12/04/15.
//
//

#import "RLCardViewController.h"
#import "RLUtils.h"
#import "RLAddressSelectionViewController.h"
#import <Stripe.h>
#import <MBProgressHUD.h>

@interface RLCardViewController () <RLAddressSelectionViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *cardNumberContainerView;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberTextField;
@property (weak, nonatomic) IBOutlet UIView *cardExpirationMonthContainerView;
@property (weak, nonatomic) IBOutlet UITextField *cardExpirationMonthTextField;
@property (weak, nonatomic) IBOutlet UIView *cardExpirationYearContainerView;
@property (weak, nonatomic) IBOutlet UITextField *cardExpirationYearTextField;
@property (weak, nonatomic) IBOutlet UIView *cardCVCContainerView;
@property (weak, nonatomic) IBOutlet UITextField *cardCVCTextField;

@property (weak, nonatomic) IBOutlet UIView *sameAddressContainerView;
@property (weak, nonatomic) IBOutlet UISwitch *sameAddressSwitch;
@property (weak, nonatomic) IBOutlet UIView *addressFieldsContainerView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *streetAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeTextField;

@property (strong, nonatomic) PFObject *addressObject;

@end

@implementation RLCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"CARD";
    self.navigationController.navigationBar.translucent = NO;
    
    self.cardNumberContainerView.layer.cornerRadius = 5.0f;
    self.cardExpirationMonthContainerView.layer.cornerRadius = 5.0f;
    self.cardExpirationYearContainerView.layer.cornerRadius = 5.0f;
    self.cardCVCContainerView.layer.cornerRadius = 5.0f;
    self.sameAddressContainerView.layer.cornerRadius = 5.0f;
    self.addressFieldsContainerView.layer.cornerRadius = 5.0f;
    
    [self.cardNumberTextField addTarget:self
                                 action:@selector(reformatAsCardNumber:)
                       forControlEvents:UIControlEventEditingChanged];
    
    self.sameAddressSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    
    [self configureDoneButton];
    [self showBillingAddressIfAvailable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark IBActions

- (IBAction)sameAddressSwitchPressed:(id)sender
{
    if (self.sameAddressSwitch.isOn)
    {
        self.addressObject = self.shippingAddressObject;
        [self fillBillingAddressWithAddressObject:self.shippingAddressObject];
        [self showBillingAddressIfAvailable];
    }
    else
    {
        self.addressObject = nil;
        [self showBillingAddressIfAvailable];
    }
}

- (IBAction)doneButtonPressed:(id)sender
{
    if ([self validateCurrentInformation])
    {
        [self createCardWithCurrentInformation];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing information" message:@"All fields are required" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)selectAddressButtonPressed:(id)sender
{
    RLAddressSelectionViewController *addressSelectionViewController = [[RLAddressSelectionViewController alloc] initWithNibName:@"RLAddressSelectionViewController" bundle:nil];
    addressSelectionViewController.delegate = self;
    [self.navigationController pushViewController:addressSelectionViewController animated:YES];
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

- (void)showBillingAddressIfAvailable
{
    if (self.addressObject != nil)
    {
        self.addressFieldsContainerView.hidden = NO;
    }
    else
    {
        self.addressFieldsContainerView.hidden = YES;
    }
}

- (void)hideBillingAddress
{
    self.addressFieldsContainerView.hidden = YES;
}

- (void)fillBillingAddressWithAddressObject:(PFObject *)addressObject
{
    self.firstNameTextField.text = addressObject[kRLPersonNameKey];
    self.lastNameTextField.text = addressObject[kRLAddressLine1Key];
    self.streetAddressTextField.text = addressObject[kRLAddressLine1Key];
    self.cityTextField.text = addressObject[kRLCityKey];
    self.stateTextField.text = addressObject[kRLStateOrRegionKey];
    self.postalCodeTextField.text = addressObject[kRLPostalCodeKey];
}

- (void)showCardCreationErrorWithText:(NSString *)text
{
    if (!text) {
        text = @"The new card could not be saved, please try again.";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark RLAddressSelectionViewControllerDelegate

- (void)didSelectAddress:(PFObject *)addressObject
{
    self.addressObject = addressObject;

    [self fillBillingAddressWithAddressObject:addressObject];
    [self showBillingAddressIfAvailable];
    [self.sameAddressSwitch setOn:NO animated:YES];
}

#pragma mark Validation

- (BOOL)validateCurrentInformation
{
    if ([self isTextFieldEmpty:self.cardNumberTextField])
    {
        return NO;
    }
    
    if ([self isTextFieldEmpty:self.cardExpirationMonthTextField])
    {
        return NO;
    }
    
    if ([self isTextFieldEmpty:self.cardExpirationYearTextField])
    {
        return NO;
    }
    
    if ([self isTextFieldEmpty:self.cardCVCTextField])
    {
        return NO;
    }
    
    if (self.addressObject == nil)
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

- (void)createCardWithCurrentInformation
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = @"Storing card";
    
    STPCard *newCard = [[STPCard alloc] init];
    
    newCard.number = self.cardNumberTextField.text;
    newCard.expMonth = [self.cardExpirationMonthTextField.text integerValue];
    newCard.expYear = [self.cardExpirationYearTextField.text integerValue];
    newCard.cvc = self.cardCVCTextField.text;
    
    newCard.name = [self.firstNameTextField.text stringByAppendingString:self.lastNameTextField.text];
    newCard.addressLine1 = self.streetAddressTextField.text;
    newCard.addressCity = self.cityTextField.text;
    newCard.addressState = self.stateTextField.text;
    newCard.addressZip = self.postalCodeTextField.text;
        
    [[STPAPIClient sharedClient] createTokenWithCard:newCard completion:^(STPToken *token, NSError *error) {
        
        if (!error)
        {
            // A customer needs to be created in order to be able to store cards and charge them multiple times
            [PFCloud callFunctionInBackground:kRLCreateCustomerFunction withParameters:@{kRLTokenParameterKey:token.tokenId} block:^(NSString *customerToken, NSError *error) {
                
                if (!error)
                {
                    PFObject *newCardObject = [PFObject objectWithClassName:kRLCardClass];
                    newCardObject[kRLCustomerTokenKey] = customerToken;
                    newCardObject[kRLExpirationMonthKey] = [NSString stringWithFormat:@"%d", (int)token.card.expMonth];
                    newCardObject[kRLExpirationYearKey] = [NSString stringWithFormat:@"%d", (int)token.card.expYear];
                    newCardObject[kRLLastFourKey] = token.card.last4;
                    newCardObject[kRLBrandKey] = @(token.card.brand);
                    
                    [newCardObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (!error)
                        {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        else
                        {
                            [self showCardCreationErrorWithText:nil];
                            NSLog(@"Could not create new card: %@", error.description);
                        }
                        
                        [hud hide:YES];
                    }];
                }
                else
                {
                    [hud hide:YES];
                    [self showCardCreationErrorWithText:nil];
                    NSLog(@"Could not create Stripe customer: %@", error.description);
                }
            }];
        }
        else
        {
            [hud hide:YES];
            [self showCardCreationErrorWithText:error.userInfo[STPErrorMessageKey]];
            NSLog(@"Could not generate Stripe card token: %@", error.description);
        }
    }];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Prevent crashing undo bug
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (textField == self.cardNumberTextField)
    {
        NSUInteger targetCursorPosition = 0;
        NSString *cardNumberWithoutSpaces = [self removeNonDigits:textField.text andPreserveCursorPosition:&targetCursorPosition];
        newLength = cardNumberWithoutSpaces.length + [string length] - range.length;
        
        return (newLength > 19) ? NO : YES;
    }
    else if (textField == self.cardExpirationMonthTextField)
    {
        return (newLength > 2) ? NO : YES;
    }
    else if (textField == self.cardExpirationYearTextField)
    {
        return (newLength > 2) ? NO : YES;
    }
    else if (textField == self.cardCVCTextField)
    {
        return (newLength > 3) ? NO : YES;
    }
    
    return YES;
}

// Version 1.2
// Source and explanation: http://stackoverflow.com/a/19161529/1709587
-(void)reformatAsCardNumber:(UITextField *)textField
{
    // In order to make the cursor end up positioned correctly, we need to
    // explicitly reposition it after we inject spaces into the text.
    // targetCursorPosition keeps track of where the cursor needs to end up as
    // we modify the string, and at the end we set the cursor position to it.
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    
    NSString *cardNumberWithoutSpaces =
    [self removeNonDigits:textField.text
andPreserveCursorPosition:&targetCursorPosition];
    
    //    if ([cardNumberWithoutSpaces length] > 19) {
    //        // If the user is trying to enter more than 19 digits, we prevent
    //        // their change, leaving the text field in its previous state.
    //        // While 16 digits is usual, credit card numbers have a hard
    //        // maximum of 19 digits defined by ISO standard 7812-1 in section
    //        // 3.8 and elsewhere. Applying this hard maximum here rather than
    //        // a maximum of 16 ensures that users with unusual card numbers
    //        // will still be able to enter their card number even if the
    //        // resultant formatting is odd.
    ////        [textField setText:previousTextFieldContent];
    ////        textField.selectedTextRange = previousSelection;
    //        return;
    //    }
    
    NSString *cardNumberWithSpaces =
    [self insertSpacesEveryFourDigitsIntoString:cardNumberWithoutSpaces
                      andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = cardNumberWithSpaces;
    UITextPosition *targetPosition =
    [textField positionFromPosition:[textField beginningOfDocument]
                             offset:targetCursorPosition];
    
    [textField setSelectedTextRange:
     [textField textRangeFromPosition:targetPosition
                           toPosition:targetPosition]
     ];
}

/*
 Removes non-digits from the string, decrementing `cursorPosition` as
 appropriate so that, for instance, if we pass in `@"1111 1123 1111"`
 and a cursor position of `8`, the cursor position will be changed to
 `7` (keeping it between the '2' and the '3' after the spaces are removed).
 */
- (NSString *)removeNonDigits:(NSString *)string
    andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSUInteger originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd)) {
            NSString *stringToAdd =
            [NSString stringWithCharacters:&characterToAdd
                                    length:1];
            
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

/*
 Inserts spaces into the string to format it as a credit card number,
 incrementing `cursorPosition` as appropriate so that, for instance, if we
 pass in `@"111111231111"` and a cursor position of `7`, the cursor position
 will be changed to `8` (keeping it between the '2' and the '3' after the
 spaces are added).
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string
                          andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if ((i>0) && ((i % 4) == 0)) {
            [stringWithAddedSpaces appendString:@" "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd =
        [NSString stringWithCharacters:&characterToAdd length:1];
        
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}

@end
