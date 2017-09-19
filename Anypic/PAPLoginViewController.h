//
//  PAPLoginViewController.h
//  Relaced
//
//  Created by Qibo Fu on 8/27/13.
//
//

#import <UIKit/UIKit.h>
#import "PAPWelcomeViewController.h"
#import "PAPButton.h"

@interface PAPLoginViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
{
    IBOutlet UITextField * email;
    IBOutlet UITextField * password;
   
    
    IBOutlet UIButton * loginButton;
    
    CGFloat animatedDistance;
}

@property (nonatomic, assign) PAPWelcomeViewController *welcomeController;

- (IBAction)login:(id)sender;
- (IBAction)goBack:(id)sender;

@end
