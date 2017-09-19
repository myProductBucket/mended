//
//  PAPSearchCell.h
//  Relaced
//
//  Created by Qibo Fu on 8/5/13.
//
//

#import <UIKit/UIKit.h>
@class PFImageView;

@interface PAPSearchCell : UITableViewCell
{
    IBOutlet PFImageView * photoView;
    IBOutlet UILabel * titleLabel;
    IBOutlet UILabel * leftSubtitleLabel;
    IBOutlet UILabel * rightSubtitleLabel;
    IBOutlet UILabel * bottomSubtitleLabel;
}

- (void)generateSearchCell:(PFObject *)result withType:(NSString *)type;

@end
