//
//  FollowListTableCell.h
//  Relaced
//
//  Created by A. K. M. Saleh Sultan on 11/30/13.
//
//

#import <UIKit/UIKit.h>
#import "PAPProfileImageView.h"

@interface FollowListTableCell : UITableViewCell
{
    
}

@property (nonatomic, strong) IBOutlet PAPProfileImageView *userImageView;
@property (nonatomic, strong) IBOutlet UILabel     *userNamelbl;
@property (nonatomic, strong) IBOutlet UIButton    *followButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
