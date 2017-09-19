//
//  PAPProfileImageView.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/17/12.
//

#import <ParseUI/ParseUI.h>
#import "PAPProfileImageView.h"

@interface PAPProfileImageView ()
@property (nonatomic, strong) UIImageView *borderImageview;
@end

@implementation PAPProfileImageView

@synthesize borderImageview;
@synthesize profileImageView;
@synthesize profileButton;


#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    
    self.profileImageView = [[PFImageView alloc] initWithFrame:self.frame];
    [self addSubview:self.profileImageView];
    
    self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.profileButton];
    
    if (self.frame.size.width < 35.0f) {
        self.borderImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadowProfilePicture-29.png"]];
    } else if (self.frame.size.width < 43.0f) {
        self.borderImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadowProfilePicture-35.png"]];
    } else {
        self.borderImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadowProfilePicture-43.png"]];
    }
    
    [self addSubview:self.borderImageview];
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:self.borderImageview];
    
    self.profileImageView.frame = CGRectMake( 1.0f, 0.0f, self.frame.size.width - 2.0f, self.frame.size.height - 2.0f);
    self.borderImageview.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.profileButton.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}


#pragma mark - PAPProfileImageView

- (void)setFile:(PFFile *)file {
    if (!file) {
        return;
    }

    self.profileImageView.image = [UIImage imageNamed:@"avatarPlaceholder.png"];
    self.profileImageView.file = file;
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    //self.avatarView.layer.masksToBounds = YES;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 0.5f;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.profileImageView loadInBackground];
}

@end

//
//  PAPProfileImageView.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/17/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

//#import "PAPProfileImageView.h"
//
//#import "ParseUI/ParseUI.h"
//
//@interface PAPProfileImageView ()
//@property (nonatomic, strong) UIImageView *borderImageview;
//@end
//
//@implementation PAPProfileImageView
//
//@synthesize borderImageview;
//@synthesize profileImageView;
//@synthesize profileButton;
//
//
//#pragma mark - NSObject
//
//- (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.backgroundColor = [UIColor clearColor];
//        
//        self.profileImageView = [[PFImageView alloc] initWithFrame:frame];
//        [self addSubview:self.profileImageView];
//        
//        self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self addSubview:self.profileButton];
//        
//        [self addSubview:self.borderImageview];
//    }
//    return self;
//}
//
//
//#pragma mark - UIView
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    [self bringSubviewToFront:self.borderImageview];
//    
//    self.profileImageView.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
//    self.borderImageview.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
//    self.profileButton.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
//}
//
//
//#pragma mark - PAPProfileImageView
//
//- (void)setFile:(PFFile *)file {
//    if (!file) {
//        return;
//    }
//    
//    self.profileImageView.image = [UIImage imageNamed:@"AvatarPlaceholder.png"];
//    self.profileImageView.file = file;
//    [self.profileImageView loadInBackground];
//}
//
//- (void)setImage:(UIImage *)image {
//    self.profileImageView.image = image;
//}
//
//@end
//
