//
//  PAPHomeViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/2/12.
//

#import "PAPHomeViewController.h"
#import "PAPSettingsButtonItem.h"
#import "PAPFindFriendsViewController.h"
#import "MBProgressHUD.h"
#import "DELocationManager.h"
#import "MHTabBarController.h"
#import "PAPConversationsViewController.h"
#import "RLUtils.h"

@interface PAPHomeViewController ()
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation PAPHomeViewController
@synthesize firstLaunch;
@synthesize blankTimelineView;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    self.navigationController.navigationBar.translucent = NO;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"activityFeedBlank.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(24.0f, 113.0f, 271.0f, 140.0f)];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
    
    [[DELocationManager sharedManager] startUpdatingLocation];
    
    // Get users whom are following by current user
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followingActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followingActivitiesQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingActivitiesQuery.limit = 5;
    

    // If the current user is a new user that means no followings then add 'Relaced' as a following by current user
    if ([followingActivitiesQuery countObjects] == 0) {//g5Wh0MigQj
        PFUser *user = [PFQuery getUserObjectWithId:DEFAULT_USERID]; // My campus table user Id
        [PAPUtility followUserEventually:user block:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error adding Relaced");
            }
        }];
    }

    
    // Get the activity class first then add from user is 'CurrentUser' and to user is Follow user and set the type is 'Follow'.(S)
    PFObject *followActivity = [PFObject objectWithClassName:kPAPPhotoUserKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    
    
    PFObject *obj = followingActivitiesQuery.getFirstObject;
    PFUser *user = [PFQuery getUserObjectWithId:obj.objectId];
    NSLog(@"Username here : %@, %@", user.username, obj.objectId);
    
    
    // Get users whom are folloing by current user
    PFQuery *followedActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followedActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followedActivitiesQuery whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
    followedActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followedActivitiesQuery.limit = 1000;
    
    NSLog(@"Count obj: %ld", (long)[followedActivitiesQuery countObjects]);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.tabBarController.navigationController) {
        [self.tabBarController.navigationController setNavigationBarHidden:NO];
    }
}


#pragma mark - PFQueryTableViewController

//- (PFQuery *)queryForTable {
//    if (![PFUser currentUser]) {
//        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
//        [query setLimit:0];
//        return query;
//    }
//
//    // Get users whom are folloing by current user
//    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
//    [followingActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
//    [followingActivitiesQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
//    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
//    followingActivitiesQuery.limit = 1000;
//    
//
//    // Get the photo of those following users
//    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
//    [photosFromFollowedUsersQuery whereKey:kPAPPhotoUserKey matchesKey:kPAPActivityToUserKey inQuery:followingActivitiesQuery];
//    [photosFromFollowedUsersQuery whereKeyExists:kPAPPhotoPictureKey];
//
//    //Get the photo of current users
//    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
//    [photosFromCurrentUserQuery whereKey:kPAPPhotoUserKey equalTo:[PFUser currentUser]];
//    [photosFromCurrentUserQuery whereKeyExists:kPAPPhotoPictureKey];
//
//    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromFollowedUsersQuery, photosFromCurrentUserQuery, nil]];
//    [query includeKey:kPAPPhotoUserKey];
//    [query orderByDescending:@"createdAt"];
//    
//    // A pull-to-refresh should always trigger a network request.
//    [query setCachePolicy:kPFCachePolicyNetworkOnly];
//    
//    // If no objects are loaded in memory, we look to the cache first to fill the table
//    // and then subsequently do a query against the network.
//    //
//    // If there is no network connection, we will hit the cache first.
//    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
//        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
//    }
//    
//    return query;
//}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult] & !self.firstLaunch) {
        self.tableView.scrollEnabled = NO;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.2f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        NSLog(@"%@", self.objects);
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    }    
}

- (void)inviteFriendsButtonAction:(id)sender {
    PAPFindFriendsViewController *detailViewController = [[PAPFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y < 0.0) {
        MHTabBarController *topTabController = (MHTabBarController *)self.parentViewController;
        topTabController.tabButtonsHidden = NO;
    }
    else if (velocity.y > 0.0) {
        MHTabBarController *topTabController = (MHTabBarController *)self.parentViewController;
        topTabController.tabButtonsHidden = YES;
    }
}

@end
