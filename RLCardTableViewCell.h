//
//  RLCardTableViewCell.h
//  Relaced
//
//  Created by Mybrana on 09/04/15.
//
//

#import <UIKit/UIKit.h>

@interface RLCardTableViewCell : UITableViewCell

- (void)configureWithCard:(PFObject *)cardObject;

@end
