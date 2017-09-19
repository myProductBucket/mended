//
//  PAPSettingsActionSheetDelegate.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//

#import "PAPSettingsActionSheetDelegate.h"
#import "PAPFindFriendsViewController.h"
#import "PAPAccountViewController.h"
#import "AppDelegate.h"
#import "PAPConversationsViewController.h"
#import "RLMyAccountViewController.h"

// ActionSheet button indexes
typedef enum {
	kPAPSettingsFindFriends = 0,
    kPAPSettingsMyMessages,
    kRLAccountSettings,
	kPAPSettingsLogout,
    kPAPSettingsNumberOfButtons
} kPAPSettingsActionSheetButtons;
 
@implementation PAPSettingsActionSheetDelegate

@synthesize navController;

#pragma mark - Initialization

- (id)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        navController = navigationController;
    }
    return self;
}

- (id)init {
    return [self initWithNavigationController:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.navController) {
        [NSException raise:NSInvalidArgumentException format:@"navController cannot be nil"];
        return;
    }
    
    switch ((kPAPSettingsActionSheetButtons)buttonIndex) {
        case kPAPSettingsFindFriends:
        {
            PAPFindFriendsViewController *findFriendsVC = [[PAPFindFriendsViewController alloc] init];
            [navController pushViewController:findFriendsVC animated:YES];
            break;
        }
        case kPAPSettingsMyMessages:
        {
            PAPConversationsViewController *conversationsVC = [[PAPConversationsViewController alloc] initWithNibName:@"PAPConversationsViewController" bundle:nil];
            [navController pushViewController:conversationsVC animated:YES];
            break;
        }
        case kRLAccountSettings:
        {
            RLMyAccountViewController * settingsVC = [[RLMyAccountViewController alloc] initWithNibName:@"RLMyAccountViewController" bundle:nil];
            [navController pushViewController:settingsVC animated:YES];
            break;
        }
        case kPAPSettingsLogout:
            // Log out user and present the login view controller
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            break;
        default:
            break;
    }
}

@end
