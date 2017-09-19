//
//  RLCheckoutOverviewViewController.m
//  Relaced
//
//  Created by Mybrana on 08/04/15.
//
//

#import "RLCheckoutOverviewViewController.h"
#import "RLAddressSelectionViewController.h"
#import "RLCardSelectionViewController.h"
#import "RLUtils.h"
#import <ParseUI.h>
#import <Stripe.h>
#import <STPTestPaymentAuthorizationViewController.h>
#import <MBProgressHUD.h>

@interface RLCheckoutOverviewViewController () <RLAddressSelectionViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate, RLCardSelectionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemSizeLabel;

@property (weak, nonatomic) IBOutlet UILabel *sellerNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *shippingNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingCityLabel;

@property (weak, nonatomic) IBOutlet UILabel *subtotalAmountLabel;
@property (weak, nonatomic) IBOutlet UIButton *serviceFeeDisclosureButton;
@property (weak, nonatomic) IBOutlet UILabel *shippingAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditsAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UIButton *minimumChargeDisclosureButton;

@property (weak, nonatomic) IBOutlet UIButton *applePayButton;
@property (weak, nonatomic) IBOutlet UIButton *creditCardButton;

@property (strong, nonatomic) PFObject *addressObject;
@property (strong, nonatomic) PFObject *creditsObject;

@property (strong, nonatomic) NSString *paymentType;

@property (nonatomic) BOOL wasPaymentSuccessful;

@property (strong, nonatomic) NSNumber *calculatedDeductedCredits;

@end

@implementation RLCheckoutOverviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"SUMMARY";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeButtonPressed:)];
    closeButton.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = closeButton;
   
    self.serviceFeeDisclosureButton.transform = CGAffineTransformMakeScale(0.7, 0.7);
    self.minimumChargeDisclosureButton.transform = CGAffineTransformMakeScale(0.7, 0.7);
    
    self.creditCardButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.creditCardButton.layer.cornerRadius = 5.0f;
    
    self.calculatedDeductedCredits = @(0);
    
    [self hideShippingAddress];
    [self tryToFillShippingAddress];
    [self fillItemInformationWithPhotoObject:self.photoObject];
    [self fillShippingAddressWithAddressObject:self.photoObject];
    [self fillReceiptSummaryWithCurrentUserUsingCreditsObject:nil andPhotoObject:self.photoObject];
    [self retrieveAndfillCreditsWithCurrentUser];
    
    bool applePayIsAvailable = [PKPaymentAuthorizationViewController canMakePayments];
    if (!applePayIsAvailable) {
        self.applePayButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark IBActions

- (IBAction)selectShippingAddressButtonPressed:(id)sender
{
    RLAddressSelectionViewController *addressSelectionViewController = [[RLAddressSelectionViewController alloc] initWithNibName:@"RLAddressSelectionViewController" bundle:nil];
    addressSelectionViewController.delegate = self;
    [self.navigationController pushViewController:addressSelectionViewController animated:YES];
}

- (IBAction)applePayButtonPressed:(id)sender
{
    if ([self isCurrentInformationValid])
    {
        self.paymentType = kRLPaymentTypeApplePay;
        
        PKPaymentRequest *request = [Stripe paymentRequestWithMerchantIdentifier:kRLMerchantID];
        
        NSNumber *subtotalAmount = self.photoObject[kRLPriceKey];
        NSDecimalNumber *subtotal = [NSDecimalNumber decimalNumberWithString:[subtotalAmount stringValue]];
        
        NSDecimalNumber *shippingRate = [NSDecimalNumber decimalNumberWithString:[@(kRLShippingRate) stringValue]];
        
        NSNumber *creditsAmount = self.creditsObject[kRLBalanceKey];
        NSDecimalNumber *credits = [NSDecimalNumber decimalNumberWithString:@"0"];
        
        if (creditsAmount)
        {
            credits = [NSDecimalNumber decimalNumberWithString:[@"-" stringByAppendingString:[creditsAmount stringValue]]];
        }
        
        NSNumber *totalAmount = [self calculateAndFillTotalAmountAndCreditsWithCurrentUserAndCreditsObject:self.creditsObject andPhotoObject:self.photoObject];
        NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:[totalAmount stringValue]];
        
        request.paymentSummaryItems = @[
                                        [PKPaymentSummaryItem summaryItemWithLabel:@"Subtotal" amount:subtotal],
                                        [PKPaymentSummaryItem summaryItemWithLabel:@"Shipping" amount:shippingRate],
                                        [PKPaymentSummaryItem summaryItemWithLabel:@"Credits" amount:credits],
                                        [PKPaymentSummaryItem summaryItemWithLabel:kRLBusinessName amount:total]
                                        ];

#if DEBUG
        STPTestPaymentAuthorizationViewController *viewController = [[STPTestPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        viewController.delegate = self;
        [self presentViewController:viewController animated:YES completion:nil];
#else
        if ([Stripe canSubmitPaymentRequest:request])
        {
            PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
            viewController.delegate = self;
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else
        {
            [self showUnavailableApplePayAlert];
        }
#endif
    }
}

- (IBAction)payWithCardButtonPressed:(id)sender
{
    if ([self isCurrentInformationValid])
    {
        self.paymentType = kRLPaymentTypeCreditCard;
        
        RLCardSelectionViewController *cardSelectionViewController = [[RLCardSelectionViewController alloc] initWithNibName:@"RLCardSelectionViewController" bundle:nil];
        cardSelectionViewController.shippingAddressObject = self.addressObject;
        cardSelectionViewController.delegate = self;
        [self.navigationController pushViewController:cardSelectionViewController animated:YES];
    }
}

- (IBAction)closeButtonPressed:(id)sender
{
    [PFCloud callFunctionInBackground:kRLCancelPhotoReservationFunction withParameters:@{kRLPhotoIdParameterKey:self.photoObject.objectId} block:^(id object, NSError *error) {
        
        if (error)
        {
            NSLog(@"Could not cancel photo reservation: %@", error.description);
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)minimumChargeDisclosureButtonPressed:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Minimum charge"
                                message:@"This is the minimum amount allowed as a payment by Relaced when buying items"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (IBAction)serviceFeeDisclosureButtonPressed:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Service Fee"
                                message:@"The price includes the fee charged by Relaced"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark RLAddressSelectionViewControllerDelegate

- (void)didSelectAddress:(PFObject *)addressObject
{
    self.addressObject = addressObject;
    
    [self fillShippingAddressWithAddressObject:addressObject];
    [self showShippingAddress];
}

#pragma mark UI

- (void)fillItemInformationWithPhotoObject:(PFObject *)photoObject
{
    PFFile *imageFile = [self.photoObject objectForKey:kPAPPhotoPictureKey];
    
    if (imageFile)
    {
        self.itemImageView.file = imageFile;
        [self.itemImageView loadInBackground:^(UIImage *image, NSError *error) {
            
            if (!error) {
                self.itemImageView.image = image;
            }
        }];
    }
    
    self.itemNameLabel.text = photoObject[kRLDescriptionKey];
    self.itemBrandLabel.text = photoObject[kRLBrandKey];
    self.itemSizeLabel.text = [photoObject[kRLSizeKey] stringValue];
    
    PFUser *sellerObject = photoObject[kRLUserKey];
    self.sellerNameLabel.text = sellerObject[kRLDisplayNameKey];
}

- (void)hideShippingAddress
{
    self.shippingNameLabel.hidden = YES;
    self.shippingAddressLabel.hidden = YES;
    self.shippingCityLabel.hidden = YES;
}

- (void)showShippingAddress
{
    self.shippingNameLabel.hidden = NO;
    self.shippingAddressLabel.hidden = NO;
    self.shippingCityLabel.hidden = NO;
}

- (void)fillShippingAddressWithAddressObject:(PFObject *)addressObject
{
    self.shippingNameLabel.text = addressObject[kRLPersonNameKey];
    self.shippingAddressLabel.text = addressObject[kRLAddressLine1Key];
    self.shippingCityLabel.text = [NSString stringWithFormat:@"%@, %@ %@", addressObject[kRLCityKey], addressObject[kRLStateOrRegionKey], addressObject[kRLPostalCodeKey]];
}

- (void)fillReceiptSummaryWithCurrentUserUsingCreditsObject:(PFObject *)creditsObject andPhotoObject:(PFObject *)photoObject
{
    NSNumber *itemPrice = photoObject[kRLPriceKey];
    self.subtotalAmountLabel.text = [NSString stringWithFormat:@"$%.2f", [itemPrice floatValue]];
    
    self.shippingAmountLabel.text = [NSString stringWithFormat:@"$%.2f", kRLShippingRate];
    
    [self calculateAndFillTotalAmountAndCreditsWithCurrentUserAndCreditsObject:creditsObject andPhotoObject:photoObject];
}

- (NSNumber *)calculateAndFillTotalAmountAndCreditsWithCurrentUserAndCreditsObject:(PFObject *)creditsObject andPhotoObject:(PFObject *)photoObject
{
    NSNumber *itemPrice = photoObject[kRLPriceKey];
    NSNumber *userBalance = @(0);
    
    if (creditsObject)
    {
        userBalance = creditsObject[kRLBalanceKey];
    }
    
    NSNumber *total = @([itemPrice floatValue] + kRLShippingRate);
    NSNumber *creditsToDeduct = @(0);
    
    if ([userBalance floatValue] <= ([total floatValue] - kRLMinimumPaidDollars)) {
        creditsToDeduct = userBalance;
        total = @([total floatValue] - [userBalance floatValue]);
        self.minimumChargeDisclosureButton.hidden = YES;
    }
    else
    {
        creditsToDeduct = @([total floatValue] - kRLMinimumPaidDollars);
        total = @(kRLMinimumPaidDollars);
        self.minimumChargeDisclosureButton.hidden = NO;
    }
    
    // Truncate to two decimal digits
    float truncatedCreditsToDeduct = creditsToDeduct.floatValue;
    truncatedCreditsToDeduct = floorf(truncatedCreditsToDeduct * 100.0f) / 100.0f;
    self.calculatedDeductedCredits = @(truncatedCreditsToDeduct);
    
    self.creditsAmountLabel.text = [NSString stringWithFormat:@"-$%.2f", [self.calculatedDeductedCredits floatValue]];
    self.totalAmountLabel.text = [NSString stringWithFormat:@"$%.2f", [total floatValue]];
    
    return total;
}

- (void)showUnavailableApplePayAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Apple Pay Notice"
                                message:@"Apple Pay is not available for payments"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark Validation

- (BOOL)isCurrentInformationValid
{
    if (self.addressObject == nil) {
        [self showInvalidInformationErrorAlertWithMessage:@"Missing shipping address"];
        return NO;
    }
    
    return YES;
}

- (void)showInvalidInformationErrorAlertWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Invalid information"
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark Parse

- (void)tryToFillShippingAddress
{
    PFQuery *addressQuery = [PFQuery queryWithClassName:kRLAddressClass];
    [addressQuery whereKey:kRLUserKey equalTo:[PFUser currentUser]];
    
    [addressQuery getFirstObjectInBackgroundWithBlock:^(PFObject *addressObject, NSError *error) {
        
        NSLog(@"%@", addressObject);
        if (addressObject)
        {
            self.addressObject = addressObject;
            [self fillShippingAddressWithAddressObject:addressObject];
            [self showShippingAddress];
        }
    }];
}

- (void)retrieveAndfillCreditsWithCurrentUser
{
    self.creditsAmountLabel.text = @"-";
    
    PFQuery *creditsQuery = [PFQuery queryWithClassName:kRLCreditsClass];
    [creditsQuery whereKey:kRLUserKey equalTo:[PFUser currentUser]];
    
    [creditsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *creditsObject, NSError *error) {
        NSLog(@"%@", creditsObject);
        if (creditsObject)
        {
            self.creditsObject = creditsObject;
            
        }
        
        [self calculateAndFillTotalAmountAndCreditsWithCurrentUserAndCreditsObject:self.creditsObject andPhotoObject:self.photoObject];
    }];
}

#pragma mark PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        if (self.wasPaymentSuccessful)
        {
            [self closeWithSuccessfulPayment];
        }
    }];
}

#pragma mark Payments

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
#if DEBUG
    // Avoids error with token generated by ApplePayStubs:
    // http://stackoverflow.com/questions/27241112/issue-with-apple-pay-stripe-integration
    STPCard *card = [STPCard new];
    card.number = @"4242 4242 4242 4242";
    card.expMonth = 12;
    card.expYear = 2040;
    card.cvc = @"123";
    
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error)
     {
         [self handleTokenCreationResponseWithToken:token error:error andCompletion:completion];
     }];
#else
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken *token, NSError *error) {
        
        [self handleTokenCreationResponseWithToken:token error:error andCompletion:completion];
    }];
#endif
}

- (void)handleTokenCreationResponseWithToken:(STPToken *)token error:(NSError *)error andCompletion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    if (error)
    {
        completion(PKPaymentAuthorizationStatusFailure);
        [self showPaymentErrorAlert];
        
        NSLog(@"Token creation failed: %@", error.description);
    }
    else
    {
        [self createBackendChargeWithToken:token.tokenId isCustomer:NO completion:completion];
    }
}

- (void)createBackendChargeWithToken:(NSString *)token isCustomer:(BOOL)isCustomer completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    NSString *shippingAddress = [NSString stringWithFormat:@"%@, %@, %@", self.shippingNameLabel.text, self.shippingAddressLabel.text, self.shippingCityLabel.text];
    
    NSDictionary *requestParameters;
    
    if (isCustomer)
    {
        requestParameters = @{kRLPhotoIdParameterKey:self.photoObject.objectId,
                              kRLCustomerParameterKey:token,
                              kRLPaymentTypeParameterKey:self.paymentType,
                              kRLShippingAddressParameterKey:shippingAddress,
                              kRLCalculatedCreditsDeductedParameterKey:self.calculatedDeductedCredits};
    }
    else
    {
        requestParameters = @{kRLPhotoIdParameterKey:self.photoObject.objectId,
                              kRLTokenParameterKey:token,
                              kRLPaymentTypeParameterKey:self.paymentType,
                              kRLShippingAddressParameterKey:shippingAddress,
                              kRLCalculatedCreditsDeductedParameterKey:self.calculatedDeductedCredits};
    }
    
    [PFCloud callFunctionInBackground:kRLBuyPhotoFunction withParameters:requestParameters block:^(id object, NSError *error) {
        
        if (!error)
        {
            self.wasPaymentSuccessful = YES;
            completion(PKPaymentAuthorizationStatusSuccess);
        }
        else
        {
            completion(PKPaymentAuthorizationStatusFailure);
            [self showPaymentErrorAlert];
            
            NSLog(@"Could not complete photo purchase: %@", error.description);
        }
    }];
}

- (void)showPaymentErrorAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Payment Unsuccessful!"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)showPaymentSuccessAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Success"
                                message:@"Purchase Successful! The item will be shipped to you shortly."
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)closeWithSuccessfulPayment
{
    self.photoObject[kRLIsSoldKey] = @"1";
    [self closeButtonPressed:self];
    [self showPaymentSuccessAlert];
}

#pragma mark RLCardSelectionViewControllerDelegate

- (void)didConfirmPurchaseWithCard:(PFObject *)cardObject
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = @"Purchasing...";
    
    [self createBackendChargeWithToken:cardObject[kRLCustomerTokenKey] isCustomer:YES completion:^(PKPaymentAuthorizationStatus status) {
        
        if (status == PKPaymentAuthorizationStatusSuccess)
        {
            [self closeWithSuccessfulPayment];
        }
        
        [hud hide:YES];
    }];
}

@end
