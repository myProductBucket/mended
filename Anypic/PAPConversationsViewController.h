//
//  PAPConversationsViewController.h
//  Relaced
//
//  Created by Qibo Fu on 8/11/13.
//
//

#import <UIKit/UIKit.h>
#import "ODRefreshControl.h"

@interface PAPConversationsViewController : UIViewController
{
    IBOutlet UITableView *listView;

    NSMutableArray *conversations;
    BOOL loading;
    BOOL hasMore;
    ODRefreshControl *refreshControl;
}

@end
