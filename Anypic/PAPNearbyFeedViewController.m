//
//  PAPNearbyFeedViewController.m
//  Relaced
//
//  Created by Qibo Fu on 8/20/13.
//
//

#import "PAPNearbyFeedViewController.h"
#import "DELocationManager.h"
#import "MHTabBarController.h"

@interface PAPNearbyFeedViewController ()

@end

@implementation PAPNearbyFeedViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable
{
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:kPAPPhotoUserKey];
    [query whereKey:@"isFeatured" equalTo:@"YES"];
    [query orderByDescending:@"createdAt"];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y < -0.1) {
        MHTabBarController *topTabController = (MHTabBarController *)self.parentViewController;
        topTabController.tabButtonsHidden = NO;
    }
    else if (velocity.y > 0.1) {
        MHTabBarController *topTabController = (MHTabBarController *)self.parentViewController;
        topTabController.tabButtonsHidden = YES;
    }
}

@end