//
//  PAPEditPhotoViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

#import "PAPEditPhotoViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "IQTextView.h"
#import "IQDropDownTextField.h"
#import "BKCurrencyTextField.h"
#import "RLUtils.h"

@interface PAPEditPhotoViewController ()

{
    UIImageView * activeImageView;
    NSMapTable * shoeImageToInitialized, * shoeImageToDefaultShoeImage, * shoeImageToPFFile;
}

@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;
@property (nonatomic, weak) IBOutlet UITextField * titleTextField;
@property (nonatomic, weak) IBOutlet IQTextView * descriptionTextView;
@property (nonatomic, weak) IBOutlet BKCurrencyTextField * priceTextField;
@property (nonatomic, weak) IBOutlet IQDropDownTextField * categoryTextField;

@property (weak, nonatomic) IBOutlet IQDropDownTextField *colorTextField;//up-
@property (weak, nonatomic) IBOutlet IQDropDownTextField *brandTextField;//up-
@property (weak, nonatomic) IBOutlet IQDropDownTextField *conditionTextField;//up-
@property (weak, nonatomic) IBOutlet IQDropDownTextField *sizeTextField;//up-

@property (nonatomic, retain) IBOutlet UILabel * locationName;
@property (nonatomic, weak) IBOutlet UILabel * sizeLabel;
@property (nonatomic, weak) IBOutlet UISlider * sizeSliderBar;
@property (nonatomic, strong) NSString* selection;

@property (nonatomic, strong) UIImage * initialImage;

@property (nonatomic, weak) IBOutlet UIImageView * mainShoeImage;
@property (nonatomic, weak) IBOutlet UIImageView *shoeImage2;
@property (nonatomic, weak) IBOutlet UIImageView *shoeImage3;
@property (nonatomic, weak) IBOutlet UIImageView *shoeImage4;
@property (nonatomic, weak) IBOutlet UIImageView *shoeImage5;
@property (nonatomic, weak) IBOutlet UIImageView *shoeImage6;

@property (nonatomic, strong) PFFile * mainImageFile;
@property (nonatomic, strong) PFFile * thumbnailFile;
@property (nonatomic, strong) CLLocation * checkinLocation;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@end

@implementation PAPEditPhotoViewController

@synthesize scrollView;
@synthesize initialImage;
@synthesize titleTextField;
@synthesize descriptionTextView;
@synthesize mainImageFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;
@synthesize priceTextField;
@synthesize categoryTextField;
@synthesize colorTextField;//
@synthesize brandTextField;//
@synthesize conditionTextField;//
@synthesize sizeTextField;//

@synthesize mainShoeImage;
@synthesize shoeImage2;
@synthesize shoeImage3;
@synthesize shoeImage4;
@synthesize shoeImage5;
@synthesize shoeImage6;

@synthesize locationName;
@synthesize checkinLocation;

#pragma mark - NSObject

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:@"PAPEditPhotoViewController" bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.initialImage = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
        
        shoeImageToInitialized = [NSMapTable new];
        shoeImageToDefaultShoeImage = [NSMapTable new];
        shoeImageToPFFile = [NSMapTable new];
    }
    return self;
}

- (IBAction)onSizeSliderChange:(id)sender
{
    double newSize = round(self.sizeSliderBar.value * 2.0) / 2.0;
    self.sizeLabel.text = [NSString stringWithFormat:@"Size: %.1f", newSize];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];
    
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 950)];
    [scrollView setDelegate:self];
    //Category
    categoryTextField.isOptionalDropDown = YES;
    [categoryTextField setItemList:[RLUtils categoryFiltersList]];
    //Color
    colorTextField.isOptionalDropDown = YES;
    [colorTextField setItemList:[RLUtils colorFiltersList]];
    //Brand
    brandTextField.isOptionalDropDown = YES;
    [brandTextField setItemList:[RLUtils brandFiltersList]];
    //Condition
    conditionTextField.isOptionalDropDown = YES;
    [conditionTextField setItemList:[RLUtils conditionFiltersList]];
    //Size
    sizeTextField.isOptionalDropDown = YES;
    [sizeTextField setItemList:[RLUtils sizeFiltersList]];
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundLeather.png"]];
    
    [mainShoeImage setImage:self.initialImage];
    [self shoeImagesInitialization];

    self.navigationItem.title = @"Item Details"; // Added by Saleh
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction:)];

    [self shouldUploadImageWithImageView:mainShoeImage isMainImageView:YES];
    
    descriptionTextView.placeholder = @"Item Description";
    
    //Forcibly access the hidden placeHolderLabel in IQTextView so that we can modify its text alignment property
    ((UILabel *)[descriptionTextView valueForKey:@"placeHolderLabel"]).textAlignment = UITextAlignmentCenter;
}

-(void)shoeImagesInitialization
{
    NSArray * inactiveImages = @[shoeImage2, shoeImage3, shoeImage4, shoeImage5, shoeImage6];
    
    for (UIImageView * imageView in inactiveImages) {
        CAShapeLayer * border = [CAShapeLayer layer];
        border.strokeColor = [UIColor lightGrayColor].CGColor;
        border.fillColor = nil;
        border.lineWidth = 1.5f;
        border.lineDashPattern = @[@6, @2];
        border.path = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:6.0f].CGPath;
        border.frame = imageView.bounds;
        [imageView.layer addSublayer:border];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shoeImageClicked:)];
        [tap setNumberOfTapsRequired:1];
        [tap setNumberOfTouchesRequired:1];
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:tap];
        
        [shoeImageToInitialized setObject:@NO forKey:imageView];
    }
    
    [shoeImageToDefaultShoeImage setObject:@"placeholder-shoe-top" forKey:shoeImage2];
    [shoeImageToDefaultShoeImage setObject:@"placeholder-shoe-left-profile" forKey:shoeImage3];
    [shoeImageToDefaultShoeImage setObject:@"placeholder-shoe-right-profile" forKey:shoeImage4];
    [shoeImageToDefaultShoeImage setObject:@"placeholder-shoe-side" forKey:shoeImage5];
    [shoeImageToDefaultShoeImage setObject:@"placeholder-shoe-bottom" forKey:shoeImage6];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)addLocation:(id)sender
{
    CheckInViewController *viewController = [[CheckInViewController alloc] initWithNibName:@"CheckInViewController" bundle:nil];
    viewController.delegate = self;
    viewController.view_type = VIEW_NORMAL;
    [self.navigationController pushViewController:viewController animated:TRUE];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)localScrollView
{
    [self.view endEditing:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == titleTextField) {
        [priceTextField becomeFirstResponder];
    }
    else if (textField == conditionTextField) {
        [self doneButtonAction:textField];
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - CheckInViewDelegate Methods

- (void)checkinDidFinishWithVenue:(VenueModel *)locationVenue
{
    if (locationVenue) {
        locationName.text = locationVenue.name;
        self.checkinLocation = [[CLLocation alloc] initWithLatitude:locationVenue.latitude longitude:locationVenue.longitude];
    }
}

- (void)checkinDidFinish:(NSString *)name longitude:(double)longitude latitude:(double)latitude
{
    locationName.text = name;
    self.checkinLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

#pragma mark - Saving data to Parse

- (void)shouldUploadImageWithImageView:(UIImageView *)imageView isMainImageView:(BOOL)isMainImage {
    
    if (isMainImage) {
        UIImage *resizedImage = [imageView.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
        UIImage *thumbnailImage = [imageView.image thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:0.0f interpolationQuality:kCGInterpolationDefault];
        
        // JPEG to decrease file size and enable faster uploads & downloads
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
        NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
        
        if (!imageData || !thumbnailImageData) {
            return;
        }
        
        self.mainImageFile = [PFFile fileWithData:imageData];
        self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        }];
        
        NSLog(@"Requested background expiration task with id %lu for Relaced photo upload", (unsigned long)self.fileUploadBackgroundTaskId);
        [self.mainImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Photo uploaded successfully");
                [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Thumbnail uploaded successfully");
                    }
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
                }];
            } else {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
            }
        }];
    }
    else {
        UIImage *resizedImage = [imageView.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
        // JPEG to decrease file size and enable faster uploads & downloads
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);

        if (!imageData) return;
        
        PFFile * shoeImageFile = [PFFile fileWithData:imageData];
        [shoeImageToPFFile setObject:shoeImageFile forKey:imageView];
        
        __block UIBackgroundTaskIdentifier backgroundTask = UIBackgroundTaskInvalid;
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
            backgroundTask = UIBackgroundTaskInvalid;
        }];
        
        [shoeImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
            backgroundTask = UIBackgroundTaskInvalid;
        }];

        
    }
}

- (void)doneButtonAction:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString * trimmedTitle = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * trimmedCategory = [self.categoryTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * trimmedColor = [self.colorTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * trimmedBrand = [self.brandTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * trimmedCondition = [self.conditionTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * trimmedSize = [self.sizeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //The user didn't select a Category; just set the Category to a dash instead
    if (trimmedCategory.length == 0 || [trimmedCategory isEqualToString:@"Select Category"]) {
        trimmedCategory = @"-";
    }
    
    //The user didn't select a Color; just set the Color to a dash instead
    if (trimmedColor.length == 0 || [trimmedColor isEqualToString:@"Select Color"]) {
        trimmedColor = @"-";
    }
    
    //The user didn't select a Brand; just set the Brand to a dash instead
    if (trimmedBrand.length == 0 || [trimmedBrand isEqualToString:@"Select Brand"]) {
        trimmedBrand = @"-";
    }
    
    //The user didn't select a Condition; just set the Condition to a dash instead
    if (trimmedCondition.length == 0 || [trimmedCondition isEqualToString:@"Select Condition"]) {
        trimmedCondition = @"-";
    }
    
    //The user didn't select a Size; just set the Size to a dash instead
    if (trimmedSize.length == 0 || [trimmedSize isEqualToString:@"Select Condition"]) {
        trimmedSize = @"-";
    }
    
    NSString * trimmedDescription = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedTitle.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please input a title" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    if (trimmedTitle.length > 90) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please reduce the length of your title" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    if (trimmedDescription.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please input a description" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    NSString * trimmedPrice = [self.priceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedPrice.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please set the price" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    NSNumber * price = [priceTextField numberValue];
    
    if (!self.mainImageFile || !self.thumbnailFile) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your item" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    // both files have finished uploading
    
    // create a photo object
    PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
    //PFObject *photo3 = [PFObject objectWithClassName:kPAPPhotoClassKey];
   // PFObject *photo4 = [PFObject objectWithClassName:kPAPPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
    [photo setObject:self.mainImageFile forKey:kPAPPhotoPictureKey];
    [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
    [photo setObject:trimmedTitle forKey:kPAPPhotoTitleKey];
    [photo setObject:trimmedCategory forKey:kRLCategoryKey];
    [photo setObject:trimmedColor forKey:kRLColorKey];
    [photo setObject:trimmedBrand forKey:kRLBrandKey];
    [photo setObject:trimmedCondition forKey:kRLConditionKey];
    [photo setObject:trimmedDescription forKey:kPAPPhotoDescriptionKey];
    [photo setObject:trimmedSize forKey:kPAPPhotoSizeKey];
    
    [photo setObject:[trimmedTitle lowercaseString] forKey:kPAPPhotoLowerDescriptionKey];
    [photo setObject:price forKey:kPAPPhotoPriceKey];
    
//    [photo setObject:[NSNumber numberWithFloat:(round(self.sizeSliderBar.value * 2.0) / 2.0)] forKey:kPAPPhotoSizeKey];
    [photo setObject:@"0" forKey:kPAPPhotoIsSoldKey];
        
    [photo setObject:@"NO" forKey:kPAPPhotoIsFeaturedKey];
    
    //Populate the shoe image fields for any additional photos the posting might have
    if ([shoeImageToPFFile objectForKey:shoeImage2] != nil) [photo setObject:[shoeImageToPFFile objectForKey:shoeImage2] forKey:kRLShoeImage2];
    if ([shoeImageToPFFile objectForKey:shoeImage3] != nil) [photo setObject:[shoeImageToPFFile objectForKey:shoeImage3] forKey:kRLShoeImage3];
    if ([shoeImageToPFFile objectForKey:shoeImage4] != nil) [photo setObject:[shoeImageToPFFile objectForKey:shoeImage4] forKey:kRLShoeImage4];
    if ([shoeImageToPFFile objectForKey:shoeImage5] != nil) [photo setObject:[shoeImageToPFFile objectForKey:shoeImage5] forKey:kRLShoeImage5];
    if ([shoeImageToPFFile objectForKey:shoeImage6] != nil) [photo setObject:[shoeImageToPFFile objectForKey:shoeImage6] forKey:kRLShoeImage6];
    
    if (checkinLocation) {
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:checkinLocation];
        [photo setObject:geoPoint forKey:kPAPPhotoLocationKey];
        [photo setObject:locationName.text forKey:kPAPPhotoLocationNameKey];
    }
    
     //photos are public, but may only be modified by the user who uploaded them
    //PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    //[photoACL setPublicReadAccess:YES];
    //photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];

    // save
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
            NSLog(@"Photo uploaded");
            
            [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (trimmedTitle) {
                NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
                
                if (commentText && commentText.length != 0) {
                    // create and save photo caption
                    PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
                    [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
                    [comment setObject:photo forKey:kPAPActivityPhotoKey];
                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
                    [comment setObject:commentText forKey:kPAPActivityContentKey];
                    
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    PFACL *roleACL = [PFACL ACL];
                    [roleACL setPublicReadAccess:YES];
                    
                    comment.ACL = ACL;
                    
                    [comment saveEventually];
                    [[PAPCache sharedCache] incrementCommentCountForPhoto:photo];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
        } else {
            NSLog(@"Photo failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your item" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)takeFromCamera
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = YES;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    pickerController.delegate = self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)chooseFromLibrary
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = YES;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (buttonIndex == 0) {
        if (cameraDeviceAvailable) {
            [self takeFromCamera];
        }
        else {
            [RLUtils displayAlertWithTitle:@"No Camera Available" message:@"The camera is currently unavailable." postDismissalBlock:nil];
        }
    }
    else if (buttonIndex == 1) {
        if (photoLibraryAvailable) {
            [self chooseFromLibrary];
        }
        else {
            [RLUtils displayAlertWithTitle:@"Library Unavailable" message:@"The photo library is currently unavailable." postDismissalBlock:nil];
        }
    }
    else if (buttonIndex == 2) {
        if ([[shoeImageToInitialized objectForKey:activeImageView] boolValue]) {
            UIImage * defaultImage = [UIImage imageNamed:[shoeImageToDefaultShoeImage objectForKey:activeImageView]];
            activeImageView.image = defaultImage;
            
            CAShapeLayer * border = [CAShapeLayer layer];
            border.strokeColor = [UIColor lightGrayColor].CGColor;
            border.fillColor = nil;
            border.lineWidth = 1.5f;
            border.lineDashPattern = @[@6, @2];
            border.path = [UIBezierPath bezierPathWithRoundedRect:activeImageView.bounds cornerRadius:6.0f].CGPath;
            border.frame = activeImageView.bounds;
            [activeImageView.layer addSublayer:border];
            [shoeImageToInitialized setObject:@NO forKey:activeImageView];

        }
    }
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        activeImageView.image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        //The removes the gray, dashed border for indicating placeholder images
        [activeImageView layer].sublayers = nil;
        
        //Prepare for the image to be saved by uploading the image file data to Parse
        [self shouldUploadImageWithImageView:activeImageView isMainImageView:NO];
        [shoeImageToInitialized setObject:@YES forKey:activeImageView];
    }];
}

- (void) shoeImageClicked:(UITapGestureRecognizer *)sender {
    
    NSString * takeOrChangePhotoLabel = @"Take Photo";
    NSString * chooseOrRepickFromLibraryLabel = @"Choose from Library";
    activeImageView = (UIImageView*)sender.view;
    
    if ([[shoeImageToInitialized objectForKey:activeImageView] boolValue]) {
        takeOrChangePhotoLabel = @"Replace with Photo";
        chooseOrRepickFromLibraryLabel = @"Replace with Library Item";
    }
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:takeOrChangePhotoLabel, chooseOrRepickFromLibraryLabel, @"Clear", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}





@end

