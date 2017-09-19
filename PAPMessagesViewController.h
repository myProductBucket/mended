//
//  PAPMessagesViewController.h
//  Relaced
//
//  Created by Qibo Fu on 8/11/13.
//
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "UIBubbleTableView.h"
@class PFImageView;
@class ODRefreshControl;

@interface PAPMessagesViewController : UIViewController <HPGrowingTextViewDelegate, UIBubbleTableViewDataSource, UIBubbleTableViewDelegate>
{
    HPGrowingTextView *inputView;
    IBOutlet UIView *inputContainer;
    IBOutlet UILabel *username;
    IBOutlet PFImageView *avatarView;
    IBOutlet UIView *headerView;
    IBOutlet UIBubbleTableView *bubbleTable;
    
    NSMutableArray *bubbleData;
    UIImageView *entryImageView, *imageView;
    UIButton *sendButton;
    
    BOOL loading;
    BOOL hasMore;
    ODRefreshControl *refreshControl;
}

@property (nonatomic, retain) PFObject *conversation;
@property (nonatomic, retain) PFUser *oppositeUser;

@end
