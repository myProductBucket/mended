//
//  PAPSignupViewController.h
//  Relaced
//
//  Created by Qibo Fu on 8/27/13.
//
//

#import <UIKit/UIKit.h>
#import "PAPWelcomeViewController.h"

@interface PAPSignupViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIImageView *profileView;
    IBOutlet UITextField *email;
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UITextField *confirmPwd;
    
    CGFloat animatedDistance;
    BOOL hasValidProfilePic;
}

@property (nonatomic, assign) PAPWelcomeViewController *welcomeController;

- (IBAction)chooseProfilePic:(id)sender;

@end
