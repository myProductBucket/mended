//
//  PAPPhotoHeaderView.h
//  Relaced
//
//  Created by Qibo Fu on 8/23/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PAPProfileImageView.h"

@class PAPPhotoHeaderView;

@protocol PAPPhotoHeaderViewDelegate <NSObject>
@optional
- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

@end


@interface PAPPhotoHeaderView : UIView

@property (nonatomic, strong) IBOutlet PAPProfileImageView *avatarView;
@property (nonatomic, strong) IBOutlet UIButton *nameButton;
@property (nonatomic, strong) IBOutlet UIButton *locationButton;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, weak) id<PAPPhotoHeaderViewDelegate> delegate;

@end
