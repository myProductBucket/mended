//
//  PAPPhotoDetailsHeaderView.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//

#import <ParseUI/ParseUI.h>
#import "PAPPhotoDetailsHeaderView.h"
#import "PAPProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPPhotoFooterView.h"
#import "MKMapView+ZoomLevel.h"
#import "DisplayMap.h"
#import "PAPMessagesViewController.h"
#import "RLUtils.h"
#import <QuartzCore/QuartzCore.h>

#define numLikePics 7.0f

#define likeProfileXBase 46.0f
#define likeProfileXSpace 3.0f
#define likeProfileY 6.0f
#define likeProfileDim 30.0f

@interface PAPPhotoDetailsHeaderView ()
{
    CLLocationCoordinate2D picGeoLoc;
}

// View components
@property (nonatomic, strong) PAPPhotoFooterView *photoFooterView;
@property (nonatomic, strong) IBOutlet UIView *likeBarView;
@property (nonatomic, strong) NSMutableArray *currentLikeAvatars;
@property (nonatomic, strong) UIView *mainView;

@property (nonatomic, strong) IBOutlet PAPProfileImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UIButton *userButton;
@property (nonatomic, strong) IBOutlet UIButton *locationButton;
@property (nonatomic, strong) IBOutlet UIImageView *locationPin;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) IBOutlet UILabel *photoLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyerDisclosureButton;

@property (nonatomic, strong) IBOutlet UILabel *sizeLabel;
@property (nonatomic, strong) IBOutlet UITextView * titleTextView;
@property (nonatomic, strong) IBOutlet UILabel *brandLabel;
@property (nonatomic, strong) IBOutlet MKMapView *loationMapView;
@property (weak, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *imagesPageControl;

@property (nonatomic, weak) IBOutlet UIButton *buyButton;

@end

static TTTTimeIntervalFormatter *timeFormatter;

@implementation PAPPhotoDetailsHeaderView

@synthesize photo;
@synthesize photographer;
@synthesize likeUsers;
@synthesize photoFooterView;
@synthesize likeBarView;
@synthesize likeButton;
@synthesize delegate;
@synthesize currentLikeAvatars;
@synthesize loationMapView;

@synthesize imagesScrollView;
@synthesize imagesPageControl;

@synthesize avatarImageView;
@synthesize userButton;
@synthesize locationButton;
@synthesize timeLabel;
@synthesize priceLabel;
@synthesize mainView;
@synthesize brandLabel;
@synthesize photoLabel;

@synthesize msgSellerBt;
@synthesize locationPin;
@synthesize titleTextView;
@synthesize sizeLabel;

#pragma mark - NSObject


- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        self.photo = aPhoto;
        self.photographer = [self.photo objectForKey:kPAPPhotoUserKey];
        self.likeUsers = nil;
         self.buyerDisclosureButton.transform = CGAffineTransformMakeScale(0.7, 0.7);
        
        self.backgroundColor = [UIColor whiteColor];
        [self createView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        self.photo = aPhoto;
        self.photographer = aPhotographer;
        self.likeUsers = theLikeUsers;
        
        self.backgroundColor = [UIColor lightGrayColor];
        
        if (self.photo && self.photographer && self.likeUsers) {
            [self createView];
        }
        
    }
    return self;
}

#pragma mark - PAPPhotoDetailsHeaderView

+ (CGRect)rectForViewWithDescription:(NSString *)description
{
    CGSize contentSize = [description sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(275, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 530 + contentSize.height+300);
}

- (void)setPhoto:(PFObject *)aPhoto {
    photo = aPhoto;
    
    if (self.photo && self.photographer && self.likeUsers) {
        [self createView];
        [self setNeedsDisplay];
    }
}

- (void)setLikeUsers:(NSMutableArray *)anArray {
    likeUsers = [anArray sortedArrayUsingComparator:^NSComparisonResult(PFUser *liker1, PFUser *liker2) {
        NSString *displayName1 = [liker1 objectForKey:kPAPUserDisplayNameKey];
        NSString *displayName2 = [liker2 objectForKey:kPAPUserDisplayNameKey];
        
        if ([[liker1 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedAscending;
        } else if ([[liker2 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedDescending;
        }
        
        return [displayName1 compare:displayName2 options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
    }];;
    
    for (PAPProfileImageView *image in currentLikeAvatars) {
        [image removeFromSuperview];
    }
    
    [likeButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.likeUsers.count] forState:UIControlStateNormal];
    
    self.currentLikeAvatars = [[NSMutableArray alloc] initWithCapacity:likeUsers.count];
    int i;
    int numOfPics = numLikePics > self.likeUsers.count ? (int)self.likeUsers.count : numLikePics;
    
    for (i = 0; i < numOfPics; i++) {
        PAPProfileImageView *profilePic = [[PAPProfileImageView alloc] init];
        [profilePic setFrame:CGRectMake(likeProfileXBase + i * (likeProfileXSpace + likeProfileDim), likeProfileY, likeProfileDim, likeProfileDim)];
        [profilePic.profileButton addTarget:self action:@selector(didTapLikerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        profilePic.profileButton.tag = i;
        [profilePic setFile:[[self.likeUsers objectAtIndex:i] objectForKey:kPAPUserProfilePicSmallKey]];
        [likeBarView addSubview:profilePic];
        [currentLikeAvatars addObject:profilePic];
        
    }
    
    [self setNeedsDisplay];
}

- (void)setLikeButtonState:(BOOL)selected {
    if (selected) {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake( -0.0f, 0.0f, 0.0f, 0.0f)];
        [[likeButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, -0.0f)];
    } else {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [[likeButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 0.0f)];
    }
    [likeButton setSelected:selected];
}

- (void)reloadLikeBar {
    self.likeUsers = [[PAPCache sharedCache] likersForPhoto:self.photo];
    [self setLikeButtonState:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:self.photo]];
    [likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setBuyButtonAndPriceLabel {
    NSNumber *price = [photo objectForKey:kPAPPhotoPriceKey];
    if (price) {
        priceLabel.text = ([[photo objectForKey:kPAPPhotoIsSoldKey]
                            isEqualToString:@"1"] ? @"Sold" : [NSString stringWithFormat:@"$%@ | Buy Now", [photo objectForKey:kPAPPhotoPriceKey]]);
    }
    else {
        priceLabel.text = @"";
    }
    
    PFUser *photoUser = self.photo[kRLUserKey];
    PFUser *currentUser = [PFUser currentUser];
    
    if (![photoUser.objectId isEqualToString: currentUser.objectId])
    {
        self.buyButton.hidden = [[photo objectForKey:kPAPPhotoIsSoldKey] isEqualToString:@"1"];
    }
    else
    {
        self.buyButton.hidden = YES;
        
        
        if (![photoUser.objectId isEqualToString: currentUser.objectId])
        {
            
            self.msgSellerBt.hidden = YES;
        }
    }
}

#pragma mark - ()

- (void)createView
{
    [self loadAllShoeImages];
    imagesPageControl.pageIndicatorTintColor = [UIColor blackColor];
    imagesPageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    
    
    // Load data for header
    [self.photographer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [avatarImageView setFile:[self.photographer objectForKey:kPAPUserProfilePicSmallKey]];
        [avatarImageView.profileButton addTarget:self
                                          action:@selector(didTapUserNameButtonAction:)
                                forControlEvents:UIControlEventTouchUpInside];
        
        // Create name label
        NSString *nameString = [self.photographer objectForKey:kPAPUserDisplayNameKey];
        [userButton setTitle:nameString forState:UIControlStateNormal];
        [[userButton titleLabel] setLineBreakMode:NSLineBreakByWordWrapping];
        
        //BuyButton
        [_buyButton setTitle:[NSString stringWithFormat:@"$%@ | Buy Now", [photo objectForKey:kPAPPhotoPriceKey]] forState:UIControlStateNormal];
        
        // Create photo label
        //photoLabel setText:@"0 listings"];
        //photoLabel.text = [NSString stringWithFormat:@"0 listings", [photo objectForKey:kPAPPhotoSizeKey]];
        
        // Create time label
        NSString *timeString = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[self.photo createdAt]];
        [timeLabel setText:timeString];
        
        [timeLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [timeLabel setTextColor:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f]];
        
        
        
        [self setNeedsDisplay];
    }];
    
    [locationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [locationButton setTitle:[NSString stringWithFormat:@"Meetup locally near %@", [photo objectForKey:kPAPPhotoLocationNameKey]] forState:UIControlStateNormal];
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    //self.avatarView.layer.masksToBounds = YES;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.borderWidth = 0.5f;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    /// Get the location of current post
    PFGeoPoint *point = [photo objectForKey:kPAPPhotoLocationKey];
    loationMapView.clearsContextBeforeDrawing = TRUE ;
    loationMapView.mapType =  MKMapTypeStandard;// MKMapTypeHybrid;
    MKCoordinateRegion region;
    picGeoLoc.latitude = point.latitude;
    picGeoLoc.longitude = point.longitude;
    [loationMapView setCenterCoordinate:picGeoLoc zoomLevel:6 animated:YES];
    region.center.longitude = point.longitude;
    region.center.latitude =  point.latitude;
    
    
    
    // Display pin control
    DisplayMap *ann = [[DisplayMap alloc] init];
    ann.title = @"Meetup Here";
    ann.coordinate = region.center;
    [loationMapView addAnnotation:ann];
    


    
    // Message seller button frame setup
    
    //self.msgSellerBt.layer.borderWidth = 1.0f;
    //self.msgSellerBt.layer.borderColor = [UIColor grayColor].CGColor;
   
    //msgSellerBt.layer.cornerRadius = 10; // this value vary as per your desire
    msgSellerBt.clipsToBounds = YES;

    
    // Like button
    
//    self.likeButton.layer.borderWidth = 1.0f;
//    self.likeButton.layer.borderColor = [UIColor redColor].CGColor;
    
    likeButton.layer.cornerRadius = 10; // this value vary as per your desire
    likeButton.clipsToBounds = YES;
    //self.likeButton.layer.borderWidth = 1.0f;
    //self.likeButton.layer.borderColor = [UIColor grayColor].CGColor;
    
    
    _buyButton.layer.cornerRadius = 10; // this value vary as per your desire
    _buyButton.clipsToBounds = YES;
    //self.buyButton.layer.borderWidth = 1.0f;
    //self.buyButton.layer.borderColor = [UIColor greenColor].CGColor;
    
    msgSellerBt.layer.cornerRadius = 10; // this value vary as per your desire
    msgSellerBt.clipsToBounds = YES;
    //self.msgSellerBt.layer.borderWidth = 1.0f;
    //self.msgSellerBt.layer.borderColor = [UIColor blueColor].CGColor;
    
    
    //[self setBuyButtonAndPriceLabel];
    
    sizeLabel.text = [NSString stringWithFormat:@"Size: %@", [photo objectForKey:kPAPPhotoSizeKey]];
    
    if ([photo objectForKey:kPAPPhotoDescriptionKey] != nil) {
        titleTextView.text = [NSString stringWithFormat:@"%@", [photo objectForKey:kPAPPhotoDescriptionKey]];
    }
    else {
        NSString * userId = ((PFObject *)[photo objectForKey:@"user"]).objectId;
        PFUser * user = [PFQuery getUserObjectWithId:userId];
        NSString * username = [user objectForKey:kPAPUserDisplayNameKey];
        NSString * shoeName = [photo objectForKey:kPAPPhotoTitleKey];
        
        titleTextView.text = [NSString stringWithFormat:@"Message %@ for more information about this item (%@).", username, shoeName];
    }
    if ([photo objectForKey:kRLBrandKey] == nil ||
        [[photo objectForKey:kRLBrandKey] length] == 0 ||
        [[photo objectForKey:kRLBrandKey] isEqualToString:@"-"])
        brandLabel.text = @"Unknown Brand";
    else brandLabel.text = [NSString stringWithFormat:@"%@", [photo objectForKey:kRLBrandKey]];
}

//Some code from http://www.iosdevnotes.com/2011/03/uiscrollview-paging/
-(void)loadAllShoeImages
{
    imagesScrollView.delegate = self;
    
    PFImageView * mainImageView = [PFImageView new];
    mainImageView.image = [UIImage imageNamed:@"placeholderPhoto.png"];
    PFFile * mainImage = [self.photo objectForKey:kPAPPhotoPictureKey];
    
    if (mainImage) {
        mainImageView.file = mainImage;
        [mainImageView loadInBackground:^(UIImage * image, NSError *error){
            //Add this listing's main image as the very first image in the scroll view
            [self addImageViewToScrollView:mainImageView atIndex:0];
        }];
    }
    
    NSMutableArray * otherImages = [NSMutableArray new];
    NSArray * otherImagesKeys = @[kRLShoeImage2, kRLShoeImage3, kRLShoeImage4, kRLShoeImage5, kRLShoeImage6];
    
    for (NSString * key in otherImagesKeys) {
        if ([self.photo objectForKey:key] != nil) {
            [otherImages addObject:[self.photo objectForKey:key]];
        }
    }
    
    NSMutableArray * allImageViews = [NSMutableArray new];
    [allImageViews addObject:mainImageView];
    
    for (int i = 0; i < otherImages.count; i++) {
        PFFile * imageFile = [otherImages objectAtIndex:i];
        PFImageView * imageView = [PFImageView new];
        imageView.image = [UIImage imageNamed:@"placeholderPhoto.png"];
        imageView.file = imageFile;
        [imageView loadInBackground:^(UIImage * image, NSError *error){
            //We add these other images at index i+1 of the scroll view, because the
            //main image is already displayed at index 0
            [self addImageViewToScrollView:imageView atIndex:(i+1)];
        }];
        [allImageViews addObject:imageView];
    }
    
    for (int i = 0; i < allImageViews.count; i++) {
        
        //((PFImageView *)[allImageViews objectAtIndex:i]).frame = frame;
        //[imagesScrollView addSubview:[allImageViews objectAtIndex:i]];
    }
    
    imagesScrollView.contentSize = CGSizeMake(imagesScrollView.frame.size.width * allImageViews.count, imagesScrollView.frame.size.height);
    [imagesPageControl setNumberOfPages:[allImageViews count]];
}

-(void)addImageViewToScrollView:(UIImageView *)imageView atIndex:(int)i {
    CGRect frame;
    frame.origin.x = imagesScrollView.frame.size.width * i;
    frame.origin.y = 0;
    
    double imageWidth = imageView.image.size.width;
    double imageHeight = imageView.image.size.height;
    
    if (imageWidth >= imageHeight) {
        frame.size = CGSizeMake(imagesScrollView.frame.size.width, (imageHeight/imageWidth)*imagesScrollView.frame.size.height);
        double yDelta = imagesScrollView.frame.size.height - (imageHeight/imageWidth)*imagesScrollView.frame.size.height;
        frame.origin.y += yDelta/2;
    }
    else {
        frame.size = CGSizeMake((imageWidth/imageHeight)*imagesScrollView.frame.size.width, imagesScrollView.frame.size.height);
        double xDelta = imagesScrollView.frame.size.width - (imageWidth/imageHeight)*imagesScrollView.frame.size.width;
        frame.origin.x += xDelta/2;
    }
    
    imageView.frame = frame;
    [imagesScrollView addSubview:imageView];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = imagesScrollView.frame.size.width;
    int page = floor((imagesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.imagesPageControl.currentPage = page;
}

- (IBAction)pageControlChanged:(id)sender {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = imagesScrollView.frame.size.width * imagesPageControl.currentPage;
    frame.origin.y = 0;
    frame.size = imagesScrollView.frame.size;
    [imagesScrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)buyerDisclosureButtonPressed:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Minimum charge"
                                message:@"This is the minimum amount allowed as a payment by Relaced when buying items"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (IBAction)didTapLikePhotoButtonAction:(UIButton *)button
{
    BOOL liked = !button.selected;
    [button removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setLikeButtonState:liked];
    
    NSArray *originalLikeUsersArray = [NSArray arrayWithArray:self.likeUsers];
    NSMutableSet *newLikeUsersSet = [NSMutableSet setWithCapacity:[self.likeUsers count]];
    
    for (PFUser *likeUser in self.likeUsers) {
        // add all current likeUsers BUT currentUser
        if (![[likeUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [newLikeUsersSet addObject:likeUser];
        }
    }
    
    if (liked) {
        [[PAPCache sharedCache] incrementLikerCountForPhoto:self.photo];
        [newLikeUsersSet addObject:[PFUser currentUser]];
    } else {
        [[PAPCache sharedCache] decrementLikerCountForPhoto:self.photo];
    }
    
    [[PAPCache sharedCache] setPhotoIsLikedByCurrentUser:self.photo liked:liked];
    
    [self setLikeUsers:[newLikeUsersSet allObjects]];
    
    if (liked) {
        [PAPUtility likePhotoInBackground:self.photo block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:NO];
            }
        }];
    } else {
        [PAPUtility unlikePhotoInBackground:self.photo block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:YES];
            }
        }];
    }
    

    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:self.photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:liked] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
}

- (void)didTapLikerButtonAction:(UIButton *)button {
    PFUser *user = [self.likeUsers objectAtIndex:button.tag];
    if (delegate && [delegate respondsToSelector:@selector(photoDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate photoDetailsHeaderView:self didTapUserButton:button user:user];
    }
}

- (void)setLikeStatus:(NSInteger)status
{
    if (status == -1) { //Unknown
        likeButton.enabled = NO;
    }
    else {
        likeButton.enabled = YES;
        likeButton.selected = status;
    }
}


- (IBAction)didTapUserNameButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(photoDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate photoDetailsHeaderView:self didTapUserButton:button user:self.photographer];
    }
}

- (IBAction)MessageToSellerButton:(UIButton *)sender
{
    if (delegate && [delegate respondsToSelector:@selector(photoDetailsView:didTapBuyOnPhotoButton:)]) {
        [delegate photoDetailsView:self didTapBuyOnPhotoButton:sender];
    }
}

- (IBAction)buyButtonPressed:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(photoDetailsView:didTapBuyButton:)]) {
        [delegate photoDetailsView:self didTapBuyButton:sender];
    }
}

#pragma mark -
#pragma mark - location and Map




@end


