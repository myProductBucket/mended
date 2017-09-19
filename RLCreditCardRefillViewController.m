//
//  RLPaymentViewController.m
//  Relaced
//
//  Created by Benjamin Madueme on 1/31/15.
//
//

#import "Stripe.h"
#import "RLCreditCardRefillViewController.h"
#import "RLMyAccountViewController.h"
#import "PTKTextField.h"
#import "BKCurrencyTextField.h"
#import "BButton.h"
#import "UICountingLabel.h"
#import "SOLD-Swift.h"
#import "RLUtils.h"
#import "MBProgressHUD.h"

@interface RLCreditCardRefillViewController () {
    UIVisualEffectView * blurEffectView;
    NSTimeInterval counterAnimationDuration;
}

@property (weak, nonatomic) IBOutlet BKCurrencyTextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField * cardHolderNameTextField;
@property IBOutlet PTKView * paymentView;
@property (weak, nonatomic) IBOutlet UILabel *okLabel;
@property (weak, nonatomic) IBOutlet BButton *confirmButton;

@property (strong, nonatomic) IBOutlet SpringView * confirmPaymentView;
@property (weak, nonatomic) IBOutlet SpringLabel *confirmPaymentLabel;
@property (weak, nonatomic) IBOutlet SpringLabel *cardHolderName;
@property (weak, nonatomic) IBOutlet SpringLabel *cardEndingIn;
@property (weak, nonatomic) IBOutlet SpringView *refillAmountContainer;
@property (weak, nonatomic) IBOutlet SpringView *totalAmountContainer;
@property (weak, nonatomic) IBOutlet SpringView *endingRelacedBalanceContainer;
@property (weak, nonatomic) IBOutlet UICountingLabel *refillAmount;
@property (weak, nonatomic) IBOutlet UICountingLabel *totalAmount;
@property (weak, nonatomic) IBOutlet UICountingLabel *endingRelacedBalance;
@property (weak, nonatomic) IBOutlet BButton *looksGoodButton;
@property (weak, nonatomic) IBOutlet BButton *takeMeBackButon;

@end

@implementation RLCreditCardRefillViewController


@synthesize amountTextField;
@synthesize cardHolderNameTextField;
@synthesize paymentView;
@synthesize okLabel;
@synthesize confirmButton;
@synthesize confirmPaymentView;
@synthesize confirmPaymentLabel;
@synthesize cardHolderName;
@synthesize cardEndingIn;
@synthesize refillAmountContainer;
@synthesize totalAmountContainer;
@synthesize endingRelacedBalanceContainer;
@synthesize refillAmount;
@synthesize totalAmount;
@synthesize endingRelacedBalance;
@synthesize looksGoodButton;
@synthesize takeMeBackButon;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Refill Credits";
    paymentView.cardNumberField.placeholder = @"Credit Card Number";
    paymentView.delegate = self;
    amountTextField.delegate = self;
    
    //Set the initial UICountingLabel animation duration to four seconds
    counterAnimationDuration = 4.0;
    
    cardHolderNameTextField.delegate = self;
    cardHolderNameTextField.layer.cornerRadius = 10;
    cardHolderNameTextField.layer.borderColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1].CGColor;
    cardHolderNameTextField.layer.borderWidth = 1.5;

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    cardHolderNameTextField.rightView = paddingView;
    cardHolderNameTextField.rightViewMode = UITextFieldViewModeAlways;
    
    [amountTextField becomeFirstResponder];
    
    [confirmButton setStyle:BButtonStyleBootstrapV3];
    [confirmButton setType:BButtonTypeSuccess];
    [confirmButton addAwesomeIcon:FAArrowCircleRight beforeTitle:NO];
    
    [[NSBundle mainBundle] loadNibNamed:@"RLConfirmPaymentView" owner:self options:nil];
    confirmPaymentView.center = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) paymentView:(PTKView*)localPaymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    NSLog(@"Card number: %@", card.number);
    NSLog(@"Card expiry: %lu/%lu", (unsigned long)card.expMonth, (unsigned long)card.expYear);
    NSLog(@"Card cvc: %@", card.cvc);
    NSLog(@"Address zip: %@", card.addressZip);
    
    if (valid) {
        [localPaymentView resignFirstResponder];
        
        okLabel.hidden = NO;
        [UIView animateWithDuration:1 animations:^{
            okLabel.alpha = 1;
        }];
        
        [UIView animateWithDuration:1.75 animations:^{
            okLabel.alpha = 0;
        }];
    }
    
    [self toggleContinueButton];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self toggleContinueButton];
    return YES;
}

-(void)toggleContinueButton
{
    //TODO: Improve this validation
    if (amountTextField.hasText && cardHolderNameTextField.hasText && paymentView.isValid)
        confirmButton.hidden = NO;
    else confirmButton.hidden = YES;
}

- (IBAction) continueButtonPressed:(id)sender {
    [cardHolderName setText:cardHolderNameTextField.text];
    [cardEndingIn setText:paymentView.cardNumber.last4];
    
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    [self.view addSubview:blurEffectView];
    
    [looksGoodButton setType:BButtonTypePurple];
    [takeMeBackButon setType:BButtonTypeDanger];
    
    [self.view addSubview:confirmPaymentView];
    
    
    [confirmPaymentView animate];
    [self animateCounters];
}

-(void) animateCounters {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(refillAmountContainer.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refillAmount setFormat:@"$%.2f"];
        [refillAmount setAnimationDuration:counterAnimationDuration];
        [refillAmount countFromZeroTo:[amountTextField.numberValue floatValue]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalAmountContainer.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [totalAmount setFormat:@"$%.2f"];
        [totalAmount setAnimationDuration:counterAnimationDuration];
        [totalAmount countFromZeroTo:[amountTextField.numberValue floatValue]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(endingRelacedBalanceContainer.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //We could have passed in this value from RLMyAccountViewController, but we perform the query again in the fringe case that
        //someone starts a refill from a device, completes a different refill on a second device, and attempts to complete the refill
        //on the first device.  In this case, the pre-refill balance value we would have gotten from RLMyAccountViewController would
        //be wrong, and the ending Relaced balance value would consequently be incorrect as well.
        PFQuery * usersCreditsQuery = [PFQuery queryWithClassName:kRLCreditsClass];
        [usersCreditsQuery whereKey:kRLUserKey equalTo:[PFUser currentUser]];
        
        [usersCreditsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error) {
            if (error != nil) {
                [endingRelacedBalance setText:@"Unknown"];
                [RLUtils displayAlertWithTitle:kRLNetworkErrorMsgTitle message:kRLNetworkErrorMsg postDismissalBlock:nil];
            }
            else {
                float preRefillBalance = [[[objects objectAtIndex:0] objectForKey:kRLBalanceKey] floatValue];
                
                float previousBalancePlusRefill = preRefillBalance + [amountTextField.numberValue floatValue];
                [endingRelacedBalance setFormat:@"$%.2f"];
                [endingRelacedBalance setAnimationDuration:counterAnimationDuration/2];
                [endingRelacedBalance countFromZeroTo:previousBalancePlusRefill];
            }
        }];
    });
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)goBackButtonPressed:(id)sender {
    
    //Set the UICountingLabel animation duration to something smaller than what it was initially,
    //so that when the user confirms their payment information again, it animates much faster
    counterAnimationDuration = 1.0;
    
    confirmPaymentView.animation = @"fall";
    confirmPaymentView.force = 3.0;
    confirmPaymentView.duration = 0.75;
    [confirmPaymentView animate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(confirmPaymentView.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [confirmPaymentView removeFromSuperview];
        [blurEffectView removeFromSuperview];
    });
}

- (IBAction)looksGoodButtonPressed:(id)sender {
    
    void(^tokenBlock)(STPToken *token, NSError *error) = ^void(STPToken *token, NSError *error) {
        if (error) {
            NSString * formattedErrorMsg = [NSString stringWithFormat:@"%@ \n Error Code: %ld. Error Message: %@.",
                                            kRLCardPaymentErrorOccurredMsg, (long)error.code, [error.userInfo objectForKey:NSLocalizedDescriptionKey]];

            [RLUtils displayAlertWithTitle:kRLCardPaymentErrorOccurredMsgTitle message:formattedErrorMsg postDismissalBlock:^{
                [self goBackButtonPressed:nil];
            }];
        }
        else {
            [self createBackendChargeWithToken:token];
        }
    };
    
    STPCard * card = [STPCard new];
    card.name = cardHolderNameTextField.text;
    card.number = paymentView.cardNumber.formattedString;
    card.expMonth = paymentView.cardExpiry.month;
    card.expYear = paymentView.cardExpiry.year;
    card.cvc = paymentView.cardCVC.string;
    
    [Stripe createTokenWithCard:card completion:tokenBlock];
}

- (void)createBackendChargeWithToken:(STPToken *)token {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Processing...";
    
    NSDictionary * purchaseInfo = @{
                                        @"username": [[PFUser currentUser] username],
                                        @"token": token.tokenId,
                                        @"amount": amountTextField.numberValue,
                                        @"paymentType" : @"credit_card"
                                    };
    
    [PFCloud callFunctionInBackground:@"refillBalance"
                       withParameters:purchaseInfo
                                block:^(id object, NSError *error) {
                                    [hud hide:YES];
                                    if (error) {
                                        [RLUtils displayAlertWithTitle:@"An Error Occurred" message:[[error userInfo] objectForKey:@"error"] postDismissalBlock:nil];
                                    } else {
                                        [RLUtils displayAlertWithTitle:@"Wonderful!" message:@"The transaction was successful and your Relaced balance has increased!" postDismissalBlock:^{
                                            [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
                                        }];
                                    }
                                }];
}

@end
