//
//  FollowViewController.h
//  Relaced
//
//  Created by A. K. M. Saleh Sultan on 11/30/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface FollowViewController : UIViewController
{
    NSMutableArray *followList;
    IBOutlet UITableView *followTable;
}

@property (nonatomic, strong) NSMutableArray *userListArray;
@property (nonatomic, strong) PFUser *currentUser;

@end
