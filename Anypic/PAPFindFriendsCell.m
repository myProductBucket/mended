////
////  PAPFindFriendsCell.m
////  Anypic
////
////  Created by Mattieu Gamache-Asselin on 5/31/12.
////
//
//#import "PAPFindFriendsCell.h"
//#import "PAPProfileImageView.h"
//
//@interface PAPFindFriendsCell ()
///*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
//@property (nonatomic, strong) UIButton *nameButton;
//@property (nonatomic, strong) UIButton *avatarImageButton;
//@property (nonatomic, strong) PAPProfileImageView *avatarImageView;
//
//@end
//
//
//@implementation PAPFindFriendsCell
//@synthesize delegate;
//@synthesize user;
//@synthesize avatarImageView;
//@synthesize avatarImageButton;
//@synthesize nameButton;
//@synthesize photoLabel;
//@synthesize followButton;
//
//#pragma mark - NSObject
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        [self.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundFindFriendsCell.png"]]];
//        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
//        
//        self.avatarImageView = [[PAPProfileImageView alloc] init];
//        [self.avatarImageView setFrame:CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f)];
//        [self.contentView addSubview:self.avatarImageView];
//        
//        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.avatarImageButton setBackgroundColor:[UIColor clearColor]];
//        [self.avatarImageButton setFrame:CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f)];
//        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.avatarImageButton];
//        
//        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.nameButton setBackgroundColor:[UIColor clearColor]];
//        [self.nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
//        [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
//        [self.nameButton setTitleColor:[UIColor colorWithRed:87.0f/255.0f green:72.0f/255.0f blue:49.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
//        [self.nameButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
//        [self.nameButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [self.nameButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateSelected];
//        [self.nameButton.titleLabel setShadowOffset:CGSizeMake( 0.0f, 0.0f)];
//        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.nameButton];
//        
//        self.photoLabel = [[UILabel alloc] init];
//        [self.photoLabel setFont:[UIFont systemFontOfSize:11.0f]];
//        [self.photoLabel setTextColor:[UIColor grayColor]];
//        [self.photoLabel setBackgroundColor:[UIColor clearColor]];
//        [self.photoLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.700f]];
//        [self.photoLabel setShadowOffset:CGSizeMake( 0.0f, 0.0f)];
//        [self.contentView addSubview:self.photoLabel];
//        
//        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.followButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
//        [self.followButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f)];
//        [self.followButton setBackgroundImage:[UIImage imageNamed:@"buttonFollow.png"] forState:UIControlStateNormal];
//        [self.followButton setBackgroundImage:[UIImage imageNamed:@"buttonFollowing.png"] forState:UIControlStateSelected];
//        [self.followButton setImage:[UIImage imageNamed:@"iconTick.png"] forState:UIControlStateSelected];
//        [self.followButton setTitle:@"Follow  " forState:UIControlStateNormal]; // space added for centering
//        [self.followButton setTitle:@"Following" forState:UIControlStateSelected];
//        [self.followButton setTitleColor:[UIColor colorWithRed:84.0f/255.0f green:57.0f/255.0f blue:45.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
//        [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//        [self.followButton setTitleShadowColor:[UIColor colorWithRed:232.0f/255.0f green:203.0f/255.0f blue:168.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
//        [self.followButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateSelected];
//        [self.followButton.titleLabel setShadowOffset:CGSizeMake( 0.0f, -0.0f)];
//        [self.followButton addTarget:self action:@selector(didTapFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.followButton];
//    }
//    return self;
//}
//
//
//#pragma mark - PAPFindFriendsCell
//
//- (void)setUser:(PFUser *)aUser {
//    user = aUser;
//    
//    // Configure the cell
//    [avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
//    
//    // Set name 
//    NSString *nameString = [self.user objectForKey:kPAPUserDisplayNameKey];
//    CGSize nameSize = [nameString sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] forWidth:144.0f lineBreakMode:NSLineBreakByTruncatingTail];
//    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateNormal];
//    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateHighlighted];
//
//    [nameButton setFrame:CGRectMake( 60.0f, 17.0f, nameSize.width, nameSize.height)];
//    
//    // Set photo number label
//    CGSize photoLabelSize = [@"selling" sizeWithFont:[UIFont systemFontOfSize:11.0f] forWidth:144.0f lineBreakMode:NSLineBreakByTruncatingTail];
//    [photoLabel setFrame:CGRectMake( 60.0f, 17.0f + nameSize.height, 140.0f, photoLabelSize.height)];
//    
//    // Set follow button
//    [followButton setFrame:CGRectMake( 208.0f, 20.0f, 103.0f, 32.0f)];
//}
//
//#pragma mark - ()
//
//+ (CGFloat)heightForCell {
//    return 67.0f;
//}
//
///* Inform delegate that a user image or name was tapped */
//- (void)didTapUserButtonAction:(id)sender {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
//        [self.delegate cell:self didTapUserButton:self.user];
//    }    
//}
//
///* Inform delegate that the follow button was tapped */
//- (void)didTapFollowButtonAction:(id)sender {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapFollowButton:)]) {
//        [self.delegate cell:self didTapFollowButton:self.user];
//    }        
//}
//
//@end

//
//  PAPFindFriendsCell.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/31/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPFindFriendsCell.h"
#import "PAPProfileImageView.h"
#import "RLUtils.h"

@interface PAPFindFriendsCell ()
/*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *avatarImageButton;
@property (nonatomic, strong) PAPProfileImageView *avatarImageView;

@end


@implementation PAPFindFriendsCell
@synthesize delegate;
@synthesize user;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize photoLabel;
@synthesize followButton;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.avatarImageView = [[PAPProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f);
        //self.avatarImageView.layer.cornerRadius = 23.0f;
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.borderWidth = 2.5f;
        self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:self.avatarImageView];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.avatarImageButton.backgroundColor = [UIColor clearColor];
        self.avatarImageButton.frame = CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f);
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:)
                         forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.avatarImageButton];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nameButton.backgroundColor = [UIColor clearColor];
        self.nameButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        self.nameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.nameButton setTitleColor:[UIColor grayColor]
                              forState:UIControlStateNormal];
        [self.nameButton setTitleColor:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f]
                              forState:UIControlStateHighlighted];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.nameButton];
        
        self.photoLabel = [[UILabel alloc] init];
        self.photoLabel.font = [UIFont systemFontOfSize:11.0f];
        self.photoLabel.textColor = [UIColor grayColor];
        self.photoLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoLabel];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.followButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.followButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f);
        
        
        
        [self.followButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.followButton setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
//        self.followButton.backgroundColor =[UIColor lightGrayColor];// forState:UIControlStateNormal];
//        [self.followButton setBackgroundImage:[UIImage imageNamed:@"ButtonFollowing.png"]
//                                     forState:UIControlStateSelected];
        [self.followButton setImage:[UIImage imageNamed:@"IconTick.png"]
                           forState:UIControlStateSelected];
        [self.followButton setTitle:NSLocalizedString(@"follow  ", @"Follow string, with spaces added for centering")
                           forState:UIControlStateNormal];
        [self.followButton setTitle:@"following"
                           forState:UIControlStateSelected];
        [self.followButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateNormal];
        [self.followButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateSelected];
        
        followButton.backgroundColor = [RLUtils relacedRed];
        followButton.layer.cornerRadius = 10; // this value vary as per your desire
        followButton.clipsToBounds = YES;
        
        [self.followButton addTarget:self action:@selector(didTapFollowButtonAction:)
                    forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.followButton];
    }
    return self;
}


#pragma mark - PAPFindFriendsCell

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Configure the cell
        [avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
    
    // Set name
    NSString *nameString = [self.user objectForKey:kPAPUserDisplayNameKey];
    CGSize nameSize = [nameString boundingRectWithSize:CGSizeMake(144.0f, CGFLOAT_MAX)
                                               options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f]}
                                               context:nil].size;
    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateNormal];
    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateHighlighted];
    
    [nameButton setFrame:CGRectMake( 60.0f, 17.0f, nameSize.width, nameSize.height)];
    
    // Set photo number label
    CGSize photoLabelSize = [@"listings" boundingRectWithSize:CGSizeMake(144.0f, CGFLOAT_MAX)
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                                    context:nil].size;
    [photoLabel setFrame:CGRectMake( 60.0f, 17.0f + nameSize.height, 140.0f, photoLabelSize.height)];
    
    // Set follow button
    [followButton setFrame:CGRectMake( 208.0f, 20.0f, 103.0f, 32.0f)];
}

#pragma mark - ()

+ (CGFloat)heightForCell {
    return 67.0f;
}

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }
}

/* Inform delegate that the follow button was tapped */
- (void)didTapFollowButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapFollowButton:)]) {
        [self.delegate cell:self didTapFollowButton:self.user];
    }
}

@end