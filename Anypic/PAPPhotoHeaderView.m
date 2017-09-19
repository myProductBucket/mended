//
//  PAPPhotoHeaderView.m
//  Relaced
//
//  Created by Qibo Fu on 8/23/13.
//
//

#import "PAPPhotoHeaderView.h"
#import "TTTTimeIntervalFormatter.h"
#import <QuartzCore/QuartzCore.h>

@implementation PAPPhotoHeaderView



@synthesize avatarView;
@synthesize nameButton;
@synthesize locationButton;
@synthesize timeLabel;


@synthesize photo;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    self.avatarView = nil;
    self.nameButton = nil;
    self.locationButton = nil;
    self.timeLabel = nil;
    self.photo = nil;
    self.delegate = nil;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)setPhoto:(PFObject *)object
{
    photo = object;
    
    PFUser *user = [photo objectForKey:kPAPPhotoUserKey];
    PFFile *profilePictureSmall = [user objectForKey:kPAPUserProfilePicSmallKey];
    [avatarView setFile:profilePictureSmall];
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    //self.avatarView.layer.masksToBounds = YES;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.borderWidth = 0.5f;
    self.avatarView.layer.borderColor = [UIColor whiteColor].CGColor;

    
    
    NSString *authorName = [user objectForKey:kPAPUserDisplayNameKey];
    [nameButton setTitle:authorName forState:UIControlStateNormal];
    
    NSString *locationName = [photo objectForKey:kPAPPhotoLocationNameKey];
    [locationButton setTitle:locationName forState:UIControlStateNormal];
    
    NSTimeInterval timeInterval = [[photo createdAt] timeIntervalSinceNow];
    TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    NSString *timestamp = [timeFormatter stringForTimeInterval:timeInterval];
    [timeLabel setText:timestamp];
    
    [avatarView.profileButton addTarget:self action:@selector(didSelectUser:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)didSelectUser:(id)sender
{
    if ([delegate respondsToSelector:@selector(photoHeaderView:didTapUserButton:user:)]) {
        [delegate photoHeaderView:self didTapUserButton:sender user:[self.photo objectForKey:kPAPPhotoUserKey]];
    }
}

- (IBAction)didSelectLocation:(id)sender
{
    
}

@end
