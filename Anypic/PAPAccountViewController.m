//
//  PAPAccountViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/2/12.
//

#import "PAPAccountViewController.h"
#import "PAPPhotoCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPLoadMoreCell.h"
#import "PAPMessagesViewController.h"
#import "PAPSettingsButtonItem.h"
#import "FollowViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "RLUtils.h"

@interface PAPAccountViewController()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIActionSheet *editprofile;
@property (nonatomic, strong) UIActionSheet *editphoto;
@property (nonatomic, strong) UILabel *userDisplayNameLabel;
@property (nonatomic, strong) PFImageView *profilePictureImageView;
@end

@implementation PAPAccountViewController
@synthesize headerView;
@synthesize user;
@synthesize photopr;
@synthesize profimage;

#pragma mark - Initialization

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.user) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }
    
    
    
    //    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logoNavigationBar.png"]];
    //self.navigationItem.title = [self.user objectForKey:@"displayName"];
    self.navigationController.navigationBar.translucent = NO;
    [self.headerView setBackgroundColor:[UIColor lightGrayColor]];
    //self.tableView.backgroundColor = [UIColor blackColor];
    //self.navigationItem.title = [objectForKey:userDisplayNameKey];
    //[userDisplayNameLabel setText:[self.user objectForKey:@"displayName"]];
    //*userDisplayNameLabel
    if (!self.user) {
        
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editMyProfile)];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 140.0f)];
    //[self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView = texturedBackgroundView;
    
    UIView *profilePictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake( 94.0f, 38.0f, 132.0f, 132.0f)];
    [profilePictureBackgroundView setFrame:CGRectMake(10.0f, 15.0f, 100.0f, 100.0f)]; // added by saleh
    [profilePictureBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    profilePictureBackgroundView.alpha = 0.0f;
    CALayer *layer = [profilePictureBackgroundView layer];
    layer.cornerRadius = profilePictureBackgroundView.frame.size.width / 2;
    layer.masksToBounds = YES;
    [self.headerView addSubview:profilePictureBackgroundView];
    
    
    // user profile picture view setup
    PFImageView *profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 94.0f, 38.0f, 132.0f, 132.0f)];
    [profilePictureImageView setFrame:CGRectMake(10.0f, 15.0f, 100.0f, 100.0f)]; // added by saleh
    [self.headerView addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    layer = [profilePictureImageView layer];
    layer.cornerRadius = profilePictureImageView.frame.size.width / 2;
    layer.masksToBounds = YES;
    profilePictureImageView.alpha = 0.0f;
    
    
    
    

    
    
    UIImageView *profilePictureStrokeImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 88.0f, 34.0f, 143.0f, 143.0f)];
    profilePictureStrokeImageView.alpha = 0.0f;
    [profilePictureStrokeImageView setImage:[UIImage imageNamed:@"profilePictureStroke.png"]];
    [self.headerView addSubview:profilePictureStrokeImageView];
    
    PFFile *imageFile = [self.user objectForKey:kPAPUserProfilePicMediumKey];
    if (imageFile) {
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.200f animations:^{
                    profilePictureBackgroundView.alpha = 1.0f;
                    profilePictureStrokeImageView.alpha = 1.0f;
                    profilePictureImageView.alpha = 1.0f;
                }];
            }
        }];
    }
    
    UIImageView *photoCountIconImageView = [[UIImageView alloc] initWithImage:nil];
    [photoCountIconImageView setImage:[UIImage imageNamed:@"iconPics.png"]];
    [photoCountIconImageView setFrame:CGRectMake( 26.0f, 50.0f, 45.0f, 37.0f)];
    [self.headerView addSubview:photoCountIconImageView];
    
    
    
    // Selling new label added by saleh
    UILabel *sellingLabel = [[UILabel alloc] initWithFrame:CGRectMake(-20, 85.0f, self.headerView.bounds.size.width, 22.0f)];
    [sellingLabel setTextAlignment:NSTextAlignmentCenter];
    [sellingLabel setBackgroundColor:[UIColor clearColor]];
    [sellingLabel setTextColor:[UIColor lightGrayColor]];
    [sellingLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [sellingLabel setShadowOffset:CGSizeMake( 0.0f, 0.0f)];
    [sellingLabel setText:@"Selling"];
    [sellingLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [self.headerView addSubview:sellingLabel];
    
    // Number of photo sell
    UILabel *photoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 94.0f, 92.0f, 22.0f)];
    [photoCountLabel setFrame:CGRectMake(120.0f, 58.0f, 40.0f, 25.0f)]; // Added by saleh
    [photoCountLabel setTextAlignment:NSTextAlignmentCenter];
    [photoCountLabel setBackgroundColor:[UIColor clearColor]];
    [photoCountLabel setTextColor:[UIColor lightGrayColor]];
    [photoCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [photoCountLabel setShadowOffset:CGSizeMake( 0.0f, 0.0f)];
    [photoCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    photoCountLabel.tag = 100;
    photoCountLabel.text = @"0";
    [self.headerView addSubview:photoCountLabel];
    
    
    
    // Follower icon
    UIImageView *followersIconImageView = [[UIImageView alloc] initWithImage:nil];
    //[followersIconImageView setImage:[UIImage imageNamed:@"iconFollowers.png"]];
    [followersIconImageView setFrame:CGRectMake( 247.0f, 50.0f, 52.0f, 37.0f)];
    [self.headerView addSubview:followersIconImageView];
    
    
    
    // Followers title under count label, added by Saleh
    UILabel *followerLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 85.0f, self.headerView.bounds.size.width, 22.0f)];
    [followerLabel setTextAlignment:NSTextAlignmentCenter];
    [followerLabel setBackgroundColor:[UIColor clearColor]];
    [followerLabel setTextColor:[UIColor lightGrayColor]];
    [followerLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [followerLabel setShadowOffset:CGSizeMake( 0.0f, 0.0f)];
    [followerLabel setText:@"Followers"];
    [followerLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [self.headerView addSubview:followerLabel];
    
    // Set the followers label
    UILabel *followerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 226.0f, 94.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
    [followerCountLabel setFrame:CGRectMake(185.0f, 58.0f, 40.0f, 25.0f)]; // Added by saleh
    [followerCountLabel setTextAlignment:NSTextAlignmentCenter];
    [followerCountLabel setBackgroundColor:[UIColor clearColor]];
    [followerCountLabel setTextColor:[UIColor lightGrayColor]];
    [followerCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [followerCountLabel setShadowOffset:CGSizeMake( 0.0f, 0.0f)];
    [followerCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    followerCountLabel.tag = 101;
    followerCountLabel.text = @"0";
    [self.headerView addSubview:followerCountLabel];
    
    
    //Button to show Followers list
    UIButton *followerListShowBt = [[UIButton alloc]initWithFrame:CGRectMake(176, 50, 60, 60)];
    [followerListShowBt setBackgroundColor:[UIColor clearColor]];
    [followerListShowBt addTarget:self action:@selector(showFollowerList) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:followerListShowBt];
    
    
    
    
    // Following label
    UILabel *followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 85.0f, self.headerView.bounds.size.width, 22.0f)];
    [followingLabel setTextAlignment:NSTextAlignmentCenter];
    [followingLabel setBackgroundColor:[UIColor clearColor]];
    [followingLabel setTextColor:[UIColor lightGrayColor]];
    [followingLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [followingLabel setShadowOffset:CGSizeMake( 0.0f, 0.0f)];
    [followingLabel setText:@"Following"];
    [followingLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [self.headerView addSubview:followingLabel];
    
    // Set the following label
    UILabel *followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 226.0f, 110.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
    [followingCountLabel setFrame:CGRectMake(259.0f, 58.0f, 40.0f, 25.0f)]; // Added by saleh
    [followingCountLabel setTextAlignment:NSTextAlignmentCenter];
    [followingCountLabel setBackgroundColor:[UIColor clearColor]];
    [followingCountLabel setTextColor:[UIColor lightGrayColor]];
    [followingCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [followingCountLabel setShadowOffset:CGSizeMake( 0.0f, 0.0f)];
    [followingCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    followingCountLabel.tag = 102;
    followingCountLabel.text = @"0";
    [self.headerView addSubview:followingCountLabel];
    
    
    //Button to show followings list
    UIButton *followingListShowBt = [[UIButton alloc]initWithFrame:CGRectMake(250, 50, 60, 60)];
    [followingListShowBt setBackgroundColor:[UIColor clearColor]];
    [followingListShowBt addTarget:self action:@selector(showFollowingsList) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:followingListShowBt];
    
    
    
    
    // User name display label
    _userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 176.0f, self.headerView.bounds.size.width, 22.0f)];
    [_userDisplayNameLabel setFrame:CGRectMake(117, 20.0f, self.headerView.bounds.size.width-120, 22.0f)]; //added by saleh
    [_userDisplayNameLabel setTextAlignment:NSTextAlignmentLeft];
    [_userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [_userDisplayNameLabel setTextColor:[UIColor lightGrayColor]];
    [_userDisplayNameLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [_userDisplayNameLabel setShadowOffset:CGSizeMake( 0.0f, 0.0f)];
    [_userDisplayNameLabel setText:[self.user objectForKey:@"displayName"]];
    [_userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:19.0f]];
    [self.headerView addSubview:_userDisplayNameLabel];    
    
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicatorView startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
        
        // check if the currentUser is following this user
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [queryIsFollowing whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        [queryIsFollowing whereKey:kPAPActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error && [error code] != kPFErrorCacheMiss) {
                NSLog(@"Couldn't determine follow relationship: %@", error);
                self.navigationItem.rightBarButtonItem = nil;
            } else {
                if (number == 0) {
                    [self configureFollowButton];
                } else {
                    [self configureUnfollowButton];
                }
            }
        }];
    }
    else {
        // Add Settings button
        self.navigationItem.rightBarButtonItem = [RLUtils sharedSettingsButtonItem];
        
//          UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];
//        UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:nil];
//        
//        NSArray *actionButtonItems = @[shareItem, cameraItem];
//        self.navigationItem.rightBarButtonItems = actionButtonItems;
    }
    
    if (![self.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        // Message button
        UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 110, 150, 30)];
        [messageButton addTarget:self action:@selector(actionMessage:) forControlEvents:UIControlEventTouchUpInside];
        [messageButton setTitle:@"Message Me" forState:UIControlStateNormal];
        [messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        messageButton.backgroundColor = [UIColor colorWithRed:65.0f/255.0f green:200.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
        messageButton.layer.cornerRadius = 10; // this value vary as per your desire
        messageButton.clipsToBounds = YES;
        
        [headerView addSubview:messageButton];
    }
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //if(self.tabBarController.navigationController)
      //  [self.tabBarController.navigationController setNavigationBarHidden:TRUE];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /* Prove that some users are followed by two times
    PFUser *FrUser = [PFQuery getUserObjectWithId:@"yYbjSMS786"];
    // Get users whom are following by current user
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followingActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followingActivitiesQuery whereKey:kPAPActivityFromUserKey equalTo:self.user];
    [followingActivitiesQuery whereKey:kPAPActivityToUserKey equalTo:FrUser];
    [followingActivitiesQuery setCachePolicy:kPFCachePolicyNetworkOnly];  // A pull-to-refresh should always trigger a network request.
    [followingActivitiesQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            NSLog(@"Count: Franny : %d", number);
        }
    }];
    */
    
    
    // Count number of photo selling or set default to '0'
    PFQuery *queryPhotoCount = [PFQuery queryWithClassName:@"Photo"];
    [queryPhotoCount whereKey:kPAPPhotoUserKey equalTo:self.user];
    [queryPhotoCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryPhotoCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [[PAPCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:self.user];
            [self performSelectorInBackground:@selector(countItemInBackground:) withObject:[NSString stringWithFormat:@"%d", number]];
        }
    }];
    
    
    
    // Count numer of follower
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [self performSelectorInBackground:@selector(countFollowerInBackground:) withObject:[NSString stringWithFormat:@"%d", number]];
        }
    }];
    
    
    // Count numer of Follower
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [self performSelectorInBackground:@selector(countFollowingInBackground:) withObject:[NSString stringWithFormat:@"%d", number]];
        }
    }];
}

- (void) countFollowingInBackground:(NSString *)value{
    UILabel *lbl = (UILabel *)[self.view viewWithTag:102];
    lbl.text = value;
}

- (void) countFollowerInBackground:(NSString *)value{
    UILabel *lbl = (UILabel *)[self.view viewWithTag:101];
    lbl.text = value;
}


- (void) countItemInBackground:(NSString *)value{
    UILabel *lbl = (UILabel *)[self.view viewWithTag:100];
    lbl.text = value;
}

- (void) showFollowerList {
    FollowViewController *follower = [[FollowViewController alloc]initWithNibName:@"FollowViewController" bundle:nil];
    follower.currentUser = self.user;
    
    // Get the photo of those following users
    PFQuery *followersActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followersActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followersActivitiesQuery whereKey:kPAPActivityToUserKey equalTo:self.user];
    [followersActivitiesQuery orderByDescending:@"createdAt"];
    [followersActivitiesQuery setCachePolicy:kPFCachePolicyNetworkOnly];  // A pull-to-refresh should always trigger a network request.
    
    // Get the follower user Id list and send it to the followingList view Controller
    NSArray *objects = [followersActivitiesQuery findObjects];
    NSMutableArray *followerUserIds = [[NSMutableArray alloc]init];
    for (PFObject *queryObject in objects) {
        PFUser *fromUser = [queryObject objectForKey:@"fromUser"];
        [followerUserIds addObject:fromUser];
    }
    
    follower.userListArray = followerUserIds;
    [self.navigationController pushViewController:follower animated:YES];
}

- (void) showFollowingsList {
    FollowViewController *following = [[FollowViewController alloc]initWithNibName:@"FollowViewController" bundle:nil];
    following.currentUser = self.user;
    
    // Get users whom are following by current user
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followingActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followingActivitiesQuery whereKey:kPAPActivityFromUserKey equalTo:self.user];
    [followingActivitiesQuery orderByDescending:@"createdAt"];
    [followingActivitiesQuery setCachePolicy:kPFCachePolicyNetworkOnly];  // A pull-to-refresh should always trigger a network request.
    
    // Get the following user Id list and send it to the followingList view Controller
    NSArray *objects = [followingActivitiesQuery findObjects];
    NSMutableArray *followingUserIds = [[NSMutableArray alloc]init];
    for (PFObject *queryObject in objects) {
        PFUser *toUser = [queryObject objectForKey:@"toUser"];
        [followingUserIds addObject:toUser];
    }
    
    following.userListArray = followingUserIds;
    [self.navigationController pushViewController:following animated:YES];
}


#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    self.tableView.tableHeaderView = headerView;
}

- (PFQuery *)queryForTable {
    if (!self.user) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:kPAPPhotoUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kPAPPhotoUserKey];
    
    return query;
}


// PAPPhotoTimelineViewController.m

// *this method is not overridden in the PAPHomeViewController

/*- (PFQuery *)queryForTable {
    // Query for the friends the current user is following
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followingActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followingActivitiesQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    
    // Using the activities from the query above, we find all of the photos taken by
    // the friends the current user is following
    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromFollowedUsersQuery whereKey:kPAPPhotoUserKey matchesKey:kPAPActivityToUserKey inQuery:followingActivitiesQuery];
    [photosFromFollowedUsersQuery whereKeyExists:kPAPPhotoPictureKey];
    
    // We create a second query for the current user's photos
    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromCurrentUserQuery whereKey:kPAPPhotoUserKey equalTo:[PFUser currentUser]];
    [photosFromCurrentUserQuery whereKeyExists:kPAPPhotoPictureKey];
    
    // We create a final compound query that will find all of the photos that were
    // taken by the user's friends or by the user
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromFollowedUsersQuery, photosFromCurrentUserQuery, nil]];
    [query includeKey:kPAPPhotoUserKey];
    [query orderByDescending:@"createdAt"];
    
    return query;
}*/



- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"separatorTimelineDark.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


#pragma mark - ()

- (void)followButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];

    [self configureUnfollowButton];

    [PAPUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self configureFollowButton];
        }
    }];
}

- (void)unfollowButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];

    [self configureFollowButton];

    [PAPUtility unfollowUserEventually:self.user];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureFollowButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followButtonAction:)];
    [[PAPCache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowButtonAction:)];
    [[PAPCache sharedCache] setFollowStatus:YES user:self.user];
}

- (void)editMyProfile {
    
    _editprofile = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Profile Photo", @"Edit Display Name", nil];
    
    [_editprofile showFromTabBar:self.tabBarController.tabBar];
    [self.profilePictureImageView setNeedsDisplay];
}

- (void)editPhoto {
    
    _editphoto = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose album", nil];
    
    [_editphoto showFromTabBar:self.tabBarController.tabBar];
    
    [self.profilePictureImageView setNeedsDisplay];
}

- (void)editName {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter a new display name." message:nil delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet == _editprofile){
        
        if(buttonIndex == 0){
            
            [self editPhoto];
            
        }else if (buttonIndex == 1){
            
            [self editName];
            
        }else if (buttonIndex == 2){
            
            return;
        }
        
    } else if (actionSheet == _editphoto){
        
        if (buttonIndex == 0) {
            
            [self shouldStartCameraController];
            
        }else if (buttonIndex == 1) {
            
            [self shouldStartPhotoLibraryPickerController];
            
        }else if (buttonIndex == 2) {
            
            return;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString * name =  [alertView textFieldAtIndex:0].text;

    if ([name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0) {
        [[PFUser currentUser] setObject:name forKey:kPAPUserDisplayNameKey];
        [[PFUser currentUser] saveEventually];
        
        [_userDisplayNameLabel setText:name];
    }
    else {
        NSString * errorTitle = @"Invalid Display Name";
        NSString * errorMsg = @"Invalid display name - your display name can't be empty or only whitespace.  Please enter a valid display name (for now it wasn't changed).";
        [RLUtils displayAlertWithTitle:errorTitle message:errorMsg postDismissalBlock:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:^{
        photopr = [info objectForKey:UIImagePickerControllerEditedImage];
        
        // Section upload photo profile and resize
        UIImage *image = photopr;
        
        UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
        UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationLow];
        
        NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
        NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
        
        PFFile * fileMediumImage = nil;
        if (mediumImageData.length > 0) {
            fileMediumImage = [PFFile fileWithData:mediumImageData];
            [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [[PFUser currentUser] setObject:fileMediumImage forKey:kPAPUserProfilePicMediumKey];
                    [[PFUser currentUser] saveEventually];
                }
            }];
        }
        
        if (smallRoundedImageData.length > 0) {
            PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
            [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kPAPUserProfilePicSmallKey];
                    [[PFUser currentUser] saveEventually];
                }
            }];
        }
        
        self.profilePictureImageView = [PFImageView new];
        //[self.profilePictureImageView setFile:fileMediumImage];
        //[self.profilePictureImageView loadInBackground];
    }];
    
}

- (BOOL)shouldPresentPhotoCaptureController {
    
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentModalViewController:cameraUI animated:YES];
    
    return YES;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    
    [self shouldPresentPhotoCaptureController];
}


- (IBAction)actionMessage:(id)sender
{
    PAPMessagesViewController *messagesController = [[PAPMessagesViewController alloc] initWithNibName:@"PAPMessagesViewController" bundle:nil];
    messagesController.oppositeUser = self.user;
    
    if (self.tabBarController.navigationController) {
        //[self.tabBarController.navigationController setNavigationBarHidden:FALSE];
        [self.tabBarController.navigationController pushViewController:messagesController animated:YES];
    }
    else {
        [self.navigationController pushViewController:messagesController animated:YES];
    }
}

@end