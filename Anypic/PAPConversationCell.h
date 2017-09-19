//
//  PAPConversationCell.h
//  Relaced
//
//  Created by Qibo Fu on 8/11/13.
//
//

#import <UIKit/UIKit.h>
@class PFImageView;

@interface PAPConversationCell : UITableViewCell
{
    IBOutlet PFImageView *avatarView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *lastMessage;
    IBOutlet UIImageView *newIndicator;
}

@property (nonatomic, strong) PFObject *object;

@end
