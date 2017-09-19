//
//  PAPWelcomeViewController.h
//  Relaced
//
//  Created by Qibo Fu on 8/26/13.
//
//

#import <UIKit/UIKit.h>

@interface PAPWelcomeViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyPolicyLabel;

- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;

- (void)showHome;

@end
