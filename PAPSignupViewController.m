//
//  PAPSignupViewController.m
//  Relaced
//
//  Created by Qibo Fu on 8/27/13.
//
//

#import "PAPSignupViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+ResizeAdditions.h"

@interface PAPSignupViewController ()

@end

@implementation PAPSignupViewController

@synthesize welcomeController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
//    profileImage.clipsToBounds = true
//    profileImage.layer.borderWidth = 2.0
//    profileImage.layer.borderColor = UIColor.whiteColor().CGColor

    profileView.layer.cornerRadius = profileView.frame.size.width / 2;
    profileView.clipsToBounds = YES;
    profileView.layer.borderWidth = 1.0;
    profileView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.title = @"Sign Up";
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:NO];
    UIBarButtonItem *doneBt = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(signup:)];
    self.navigationItem.rightBarButtonItem = doneBt;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [email becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [[KGModal sharedInstance] hideAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signup:(id)sender
{
    if ([username.text isEqualToString:@""] || [password.text isEqualToString:@""] || [email.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mended" message:@"Please fill in all the fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![password.text isEqualToString:confirmPwd.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mended" message:@"Sorry please double check your password/email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // If no valid user found then show an alert message (By Saleh)
    if (!hasValidProfilePic) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mended" message:@"Please add a profile photo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    PFUser *user = [PFUser user];
    NSString *displayName = username.text;
    [user setObject:displayName forKey:kPAPUserDisplayNameKey];
    [user setObject:displayName.lowercaseString forKey:@"lowercaseName"];
    user.email = email.text;
    user.password = password.text;
    user.username = email.text;
    
    if (hasValidProfilePic) {
        UIImage *image = profileView.image;
        UIImage *mediumImage = [image thumbnailImage:304 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
        UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
        
        NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
        NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
        
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        
//        NSArray *array = @[fileMediumImage, fileSmallRoundedImage];
//        NSError *error;
//        [PFObject saveAll:array error:&error];
//        if (!error) {
            [user setObject:fileMediumImage forKey:kPAPUserProfilePicMediumKey];
            [user setObject:fileSmallRoundedImage forKey:kPAPUserProfilePicSmallKey];
//            [[PFUser currentUser] saveEventually];
//        }
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Signed up successfully");
            [welcomeController showHome];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:[[error userInfo] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (IBAction)chooseProfilePic:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a photo", @"Choose from library", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)hideKeyboard:(id)sender
{
    [email resignFirstResponder];
    [username resignFirstResponder];
    [password resignFirstResponder];
    [confirmPwd resignFirstResponder];
}

- (IBAction)takeFromCamera:(id)sender
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (IBAction)chooseFromLibrary:(id)sender
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = YES;
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UITextView Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger index = textField.tag;
    
    if (textField.returnKeyType == UIReturnKeyNext) {
        UITextField *nextField = (UITextField *)[self.view viewWithTag:index + 1];
        [nextField becomeFirstResponder];
    }
    else {
        [self signup:nil];
    }
    return YES;
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint pos = [gestureRecognizer locationInView:self.view];
    UIView *view = [self.view hitTest:pos withEvent:nil];
    if ([view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UITextField class]]) {
        return NO;
    }
    
    return YES;
}

#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self takeFromCamera:nil];
    }
    else if (buttonIndex == 1) {
        [self chooseFromLibrary:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    profileView.image = image;
    hasValidProfilePic = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
