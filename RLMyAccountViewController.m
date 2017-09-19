//
//  RLMyAccountViewController.m
//  Relaced
//
//  Created by Benjamin Madueme on 1/26/15.
//
//

#import "Stripe.h"
#import "BFTask.h"
#import "UICountingLabel.h"
#import "FBShimmeringView.h"
#import "BButton.h"
#import "RLMyAccountViewController.h"
#import "RLCreditCardRefillViewController.h"
#import "RLApplePayOrCreditCardViewController.h"
#import "RLUtils.h"

@interface RLMyAccountViewController () {
    float usersBalance;
    BOOL usersBalanceInitialized;
    CGPoint originalRefillButtonCenter;
}

@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (weak, nonatomic) IBOutlet UICountingLabel *relacedBalance;
@property (weak, nonatomic) IBOutlet BButton *refillButton;
@property (weak, nonatomic) IBOutlet BButton *withdrawButton;

@end

@implementation RLMyAccountViewController

@synthesize shimmeringView;
@synthesize relacedBalance;
@synthesize refillButton;
@synthesize withdrawButton;

-(void)viewDidAppear:(BOOL)animated
{
    if (usersBalanceInitialized) {
        shimmeringView.shimmering = YES;
        PFQuery * usersCreditsQuery = [PFQuery queryWithClassName:kRLCreditsClass];
        [usersCreditsQuery whereKey:kRLUserKey equalTo:[PFUser currentUser]];
        [usersCreditsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                [RLUtils displayAlertWithTitle:kRLNetworkErrorMsgTitle message:kRLNetworkErrorMsg postDismissalBlock:nil];
            }
            else {
                if (objects.count) {  //Don't do anything if no results were returned, though we should technically never be in this case
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        usersBalance = [[[objects objectAtIndex:0] objectForKey:kRLBalanceKey] floatValue];
                        [self animateRelacedBalanceCounter];
                    });
                }
            }
        }];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Balance";
    
    originalRefillButtonCenter = refillButton.center;
    
    shimmeringView.shimmeringAnimationOpacity = 0.4;
    shimmeringView.shimmering = YES;
    
    [refillButton setStyle:BButtonStyleBootstrapV3];
    [refillButton setType:BButtonTypePrimary];
    [refillButton addAwesomeIcon:FAMoney beforeTitle:NO];
    
    [withdrawButton setStyle:BButtonStyleBootstrapV3];
    [withdrawButton setType:BButtonTypeDanger];
    [withdrawButton addAwesomeIcon:FABank beforeTitle:NO];
    
    shimmeringView.contentView = relacedBalance;
    
    PFQuery * usersCreditsQuery = [PFQuery queryWithClassName:kRLCreditsClass];
    [usersCreditsQuery whereKey:kRLUserKey equalTo:[PFUser currentUser]];
    BFTask * queryUserCreditsTask = [usersCreditsQuery findObjectsInBackground];
    [queryUserCreditsTask continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            [RLUtils displayAlertWithTitle:kRLNetworkErrorMsgTitle message:kRLNetworkErrorMsg postDismissalBlock:nil];
        }
        else {
            NSArray * result = task.result;
            if (result.count == 0) {
                
                //Initialize a new user in the credits table, whose initial credit balance is zero

                //Oooo, a sneaker reference :P
                PFObject * newBalance = [PFObject objectWithClassName:kRLCreditsClass];
                newBalance[kRLUserKey] = [PFUser currentUser];
                newBalance[kRLBalanceKey] = [NSNumber numberWithInt:0];
                [newBalance saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error != nil) {
                        [RLUtils displayAlertWithTitle:kRLNetworkErrorMsgTitle message:kRLNetworkErrorMsg postDismissalBlock:nil];
                    }
                    else {
                        usersBalance = 0;
                        [self animateRelacedBalanceCounter];
                    }
                }];
            }
            else {
                //Needed to delay this code here for shimmering to stop correctly
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    usersBalance = [[[result objectAtIndex:0] objectForKey:kRLBalanceKey] floatValue];
                    [self animateRelacedBalanceCounter];
                });
            }
        }
        usersBalanceInitialized = YES;
        return nil;
    }];
}

- (void)animateRelacedBalanceCounter
{
    shimmeringView.shimmering = NO;
    [relacedBalance setTextColor:[RLUtils relacedRed]];
    [relacedBalance setFormat:@"$%.2f"];
    [relacedBalance setAnimationDuration:1.5];
    
    if (usersBalanceInitialized) {
        [relacedBalance countFromCurrentValueTo:usersBalance];
    } else {
        [relacedBalance countFromZeroTo:usersBalance];
    }
    
    refillButton.hidden = NO;
    
    //If this user has a balance of 0; they cannot withdraw, only refill
    if (usersBalance > 0) {
        withdrawButton.hidden = NO;
        refillButton.center = originalRefillButtonCenter;
    }
    else {
        CGPoint refillButtonCenteredX = refillButton.center;
        refillButtonCenteredX.x = self.view.center.x;
        refillButton.center = refillButtonCenteredX;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)refillCreditsPressed:(id)sender {
    //Run test to see if apple pay is available here
    
#if DEBUG
    bool applePayIsAvailable = YES;
#else
    bool applePayIsAvailable = [PKPaymentAuthorizationViewController canMakePayments];
#endif
    
    if (applePayIsAvailable) {
        RLApplePayOrCreditCardViewController * applePayOrCreditCardViewController = [RLApplePayOrCreditCardViewController new];
        [self.navigationController pushViewController:applePayOrCreditCardViewController animated:YES];
    }
    else {
        RLCreditCardRefillViewController * paymentViewController = [RLCreditCardRefillViewController new];
        [self.navigationController pushViewController:paymentViewController animated:YES];
    }
}


@end
