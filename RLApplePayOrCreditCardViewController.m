//
//  RLApplePayOrCreditCardViewController.m
//  Relaced
//
//  Created by Benjamin Madueme on 2/8/15.
//
//

#import "BButton.h"
#import "FBShimmeringView.h"
#import "RLApplePayOrCreditCardViewController.h"
#import "RLApplePayRefillViewController.h"
#import "RLCreditCardRefillViewController.h"
#import "RLUtils.h"

@interface RLApplePayOrCreditCardViewController ()

@property (weak, nonatomic) IBOutlet BButton *payWithApplePay;
@property (weak, nonatomic) IBOutlet BButton *payWithCreditCard;
@property (weak, nonatomic) IBOutlet FBShimmeringView *applePayShimmeringView;
@property (weak, nonatomic) IBOutlet FBShimmeringView *creditCardShimmeringView;
@end

@implementation RLApplePayOrCreditCardViewController

@synthesize payWithApplePay;
@synthesize payWithCreditCard;
@synthesize applePayShimmeringView;
@synthesize creditCardShimmeringView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Payment Type";
    
    [payWithApplePay setStyle:BButtonStyleBootstrapV3];
    [payWithApplePay setColor:[RLUtils colorFromHexString:@"#a5adb0"]]; //Apple Space Gray
    [payWithApplePay addAwesomeIcon:FAApple beforeTitle:NO];
    
    //[payWithCreditCard setStyle:BButtonStyleBootstrapV3];
    [payWithCreditCard setColor:[RLUtils relacedRed]];
    [payWithCreditCard addAwesomeIcon:FACreditCard beforeTitle:NO];
    
    applePayShimmeringView.contentView = payWithApplePay;
    applePayShimmeringView.shimmering = YES;
    applePayShimmeringView.shimmeringPauseDuration = 1.5;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        creditCardShimmeringView.contentView = payWithCreditCard;
        creditCardShimmeringView.shimmering = YES;
        creditCardShimmeringView.shimmeringPauseDuration = 1.5;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)applePayChosen:(id)sender {
    RLApplePayRefillViewController * paymentViewController = [RLApplePayRefillViewController new];
    [self.navigationController pushViewController:paymentViewController animated:YES];
}

- (IBAction)creditCardChosen:(id)sender {
    RLCreditCardRefillViewController * paymentViewController = [RLCreditCardRefillViewController new];
    [self.navigationController pushViewController:paymentViewController animated:YES];
}
@end
