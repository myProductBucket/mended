//
//  FollowListTableCell.m
//  Relaced
//
//  Created by A. K. M. Saleh Sultan on 11/30/13.
//
//

#import "FollowListTableCell.h"

@interface FollowListTableCell ()

@end

@implementation FollowListTableCell

@synthesize followButton;
@synthesize userImageView;
@synthesize userNamelbl;
@synthesize activityIndicator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



@end
