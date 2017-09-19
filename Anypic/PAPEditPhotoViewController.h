//
//  PAPEditPhotoViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

#import "CheckInViewController.h"
#import "IQDropDownTextField.h"

@interface PAPEditPhotoViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, CheckInViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (id)initWithImage:(UIImage *)aImage;

- (IBAction)addLocation:(id)sender;

@end
