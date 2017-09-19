//
//  FollowViewController.m
//  Relaced
//
//  Created by A. K. M. Saleh Sultan on 11/30/13.
//
//

#import "FollowViewController.h"
#import "FollowListTableCell.h"
#import "PAPAccountViewController.h"
#import "DejalActivityView.h"
#import "PAPUtility.h"
#import "RLUtils.h"

@interface FollowViewController ()

@end

@implementation FollowViewController

@synthesize currentUser;
@synthesize userListArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @" ";
    [self showDownoadLoadActivity];
    followList = [[NSMutableArray alloc]init];
    
    for (PFUser *user in userListArray) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setValue:@"Following" forKey:@"type"];
        
        //set Not Downloaded initially if the data is being download then in the table cell not reload it again.
        [dictionary setValue:@"0" forKey:@"isDownloaded"];
        [dictionary setValue:user forKey:@"user"];
        [followList addObject:[dictionary copy]];
    }
    [self hideDownloadActivity];
    [followTable reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [followList count]; //Count the number of row in the tableiview
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    FollowListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier] ;
    
    if (!cell) {
        
    }
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"FollowListTableCell" owner:nil options:nil];
    for (UIView *view in views) {
        if([view isKindOfClass:[UITableViewCell class]])
        {
            cell = (FollowListTableCell*)view;
        }
    }
    cell.tag = indexPath.row;
    cell.followButton.layer.cornerRadius = 5.0f;
    [cell.followButton setTitle:[[followList objectAtIndex:indexPath.row] objectForKey:@"type"] forState:UIControlStateNormal];
    [cell.followButton addTarget:self action:@selector(unfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.followButton.tag = indexPath.row+1000;
    
    
    
    PFUser *user = [[followList objectAtIndex:indexPath.row] objectForKey:@"user"];
    if (![[PAPCache sharedCache] followStatusForUser:user]) {
        cell.followButton.backgroundColor = [UIColor grayColor];
        [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [cell.followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [isFollowingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [isFollowingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [isFollowingQuery whereKey:kPAPActivityToUserKey equalTo:user];
    [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        @synchronized(self) {
            // Save the follow status in Cache
            [[PAPCache sharedCache] setFollowStatus:(!error && number > 0) user:(PFUser *)user];
        }
        if (cell.tag == indexPath.row) {
            if (!error && number > 0) {
                cell.followButton.backgroundColor = [RLUtils relacedRed];
                [cell.followButton setTitle:@"Following" forState:UIControlStateNormal];
                [cell.followButton addTarget:self action:@selector(unfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            else {
                cell.followButton.backgroundColor = [UIColor grayColor];
                [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                [cell.followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            [cell.activityIndicator stopAnimating];
        }
    }];
    
    
    
    // if the user information is not downloaded yet then download it otherwise don't
    if ([[[followList objectAtIndex:indexPath.row] objectForKey:@"isDownloaded"] isEqualToString:@"0"])
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue, ^(void) {
            //Get user details information
            PFUser *userDetails = [PFQuery getUserObjectWithId:user.objectId];
            if (userDetails)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (cell.tag == indexPath.row)
                    {
                        cell.userNamelbl.text = [userDetails objectForKey:@"displayName"];
                        PFFile *profilePictureSmall = [userDetails objectForKey:kPAPUserProfilePicSmallKey];
                        [cell.userImageView setFile:profilePictureSmall];
                        //[cell setNeedsLayout];
                        
                        // After download store display name and avater to user later in this view and mark '1' as this index data has been downloaded.
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:[followList objectAtIndex:indexPath.row]];
                        [dic setValue:cell.userNamelbl.text forKey:@"displayName"];
                        [dic setValue:profilePictureSmall forKey:@"avater"];
                        [dic setValue:@"1" forKey:@"isDownloaded"];
                        [followList replaceObjectAtIndex:indexPath.row withObject:dic];
                    }
                });
            }
        });
    }
    else {
        cell.userNamelbl.text = [[followList objectAtIndex:indexPath.row] objectForKey:@"displayName"];
        [cell.userImageView setFile:[[followList objectAtIndex:indexPath.row] objectForKey:@"avater"]];
        [cell.activityIndicator stopAnimating];
    }
    
    return cell;
}



- (void)followButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag]-1000 inSection:0];
    FollowListTableCell *cell = (FollowListTableCell*)[followTable cellForRowAtIndexPath:indexPath];

    
    cell.followButton.backgroundColor = [RLUtils relacedRed];
    [cell.followButton setTitle:@"Following" forState:UIControlStateNormal];
    
    PFUser *user = [[followList objectAtIndex:[sender tag]-1000] objectForKey:@"user"];
    [PAPUtility followUserEventually:user block:^(BOOL succeeded, NSError *error) {
        if (error) {
            cell.followButton.backgroundColor = [UIColor grayColor];
            [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
        [loadingActivityIndicatorView stopAnimating];
    }];
}

- (void)unfollowButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag]-1000 inSection:0];
    FollowListTableCell *cell = (FollowListTableCell*)[followTable cellForRowAtIndexPath:indexPath];

    cell.followButton.backgroundColor = [UIColor grayColor];
    [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    
    PFUser *user = [[followList objectAtIndex:[sender tag]-1000] objectForKey:@"user"];
    [PAPUtility unfollowUserEventually:user];
    [loadingActivityIndicatorView stopAnimating];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath  *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    PFUser *user = [[followList objectAtIndex:indexPath.row] objectForKey:@"user"];
    user = [PFQuery getUserObjectWithId:user.objectId];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}


#pragma mark - Download Activity
- (void)showDownoadLoadActivity
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."];
}

- (void)hideDownloadActivity
{
    [DejalBezelActivityView removeView];
}

@end
