//
//  RLApplePayRefillViewController.m
//  Relaced
//
//  Created by Benjamin Madueme on 2/8/15.
//
//

#import "Stripe.h"
#import "BKCurrencyTextField.h"
#import "RLApplePayRefillViewController.h"
#import "RLUtils.h"
#import "RLCreditCardRefillViewController.h"
#import "MBProgressHUD.h"

@interface RLApplePayRefillViewController () {
    NSError * cloudCodeError;
}

@property (weak, nonatomic) IBOutlet UIButton *payWithApplePayButton;
@property (weak, nonatomic) IBOutlet BKCurrencyTextField *amountTextField;
@end

@implementation RLApplePayRefillViewController

@synthesize payWithApplePayButton;
@synthesize amountTextField;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Refill Credits";
    [amountTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)payWithApplePayButtonPressed:(id)sender {
    NSDecimalNumber * purchaseAmount = amountTextField.numberValue;
    
    PKPaymentRequest * request = [Stripe paymentRequestWithMerchantIdentifier:kRLMerchantID];
    
    NSString * purchaseLabel = [NSString stringWithFormat:@"Relaced Refill - $%.2f", [purchaseAmount floatValue]];
    request.paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:purchaseLabel
                                                                         amount:purchaseAmount] ];
    request.merchantCapabilities = PKMerchantCapabilityEMV | PKMerchantCapability3DS;
    
    if ([Stripe canSubmitPaymentRequest:request]) {
        PKPaymentAuthorizationViewController * paymentViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        paymentViewController.delegate = self;
        [self presentViewController:paymentViewController animated:YES completion:nil];
    } else {
        [RLUtils displayAlertWithTitle:kRLApplePayUnsupportedMsgTitle message:kRLApplePayUnsupportedMsg postDismissalBlock:^{
            RLCreditCardRefillViewController * paymentViewController = [RLCreditCardRefillViewController new];
            [self.navigationController pushViewController:paymentViewController animated:YES];
        }];
    }
    
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    void(^tokenBlock)(STPToken * token, NSError *error) = ^void(STPToken * token, NSError *error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure);
        }
        else {
            [self createBackendChargeWithToken:token completion:completion];
        }
    };
    
    [Stripe createTokenWithPayment:payment
                    operationQueue:[NSOperationQueue mainQueue]
                        completion:tokenBlock];
}

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    NSDictionary * purchaseInfo = @{  @"username": [[PFUser currentUser] username],
                                      @"token": token.tokenId,
                                      @"amount": amountTextField.numberValue,
                                      @"paymentType" : @"apple_pay" };
    
    [PFCloud callFunctionInBackground:@"refillBalance"
                       withParameters:purchaseInfo
                                block:^(id object, NSError *error) {
                                    if (error) {
                                        cloudCodeError = error;
                                        completion(PKPaymentAuthorizationStatusFailure);
                                    } else {
                                        completion(PKPaymentAuthorizationStatusSuccess);
                                    }
                                }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^{
        if (cloudCodeError) {
            [RLUtils displayAlertWithTitle:@"An Error Occurred" message:[[cloudCodeError userInfo] objectForKey:@"error"] postDismissalBlock:nil];
        }
        else {
            [RLUtils displayAlertWithTitle:@"Wonderful!" message:@"The Apple Pay transaction was successful and your Relaced balance has increased!" postDismissalBlock:^{
                [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
            }];
        }
    }];
}

@end
