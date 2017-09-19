//
//  PAPAccountViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

//#import "PAPPhotoTimelineViewController.h"
//
//@interface PAPAccountViewController : PAPPhotoTimelineViewController
//
//@property (nonatomic, strong) PFUser *user;
//
//@end

#import "PAPPhotoTimelineViewController.h"

@interface PAPAccountViewController : PAPPhotoTimelineViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>{
    
    UIImage *photopr;
    UIImage *profimage;
}

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIImage *photopr;
@property (nonatomic, strong) UIImage *profimage;

- (BOOL)shouldPresentPhotoCaptureController;

@end