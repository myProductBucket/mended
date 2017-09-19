//
//  AppDelegate.m
//  Anypic
//
//  Created by Héctor Ramos on 5/04/12.
//


#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Stripe.h"
#import "AppDelegate.h"

#import "Reachability.h"
#import "MBProgressHUD.h"
#import "PAPHomeViewController.h"
#import "PAPLogInViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPAccountViewController.h"
#import "PAPWelcomeViewController.h"
#import "PAPActivityFeedViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "MHTabBarController.h"
#import "PAPNearbyFeedViewController.h"
#import "PAPRecentFeedViewController.h"
#import "DELocationManager.h"
#import "PAPSplashViewController.h"
#import "RLSearchViewController.h"
#import "PAPSettingsButtonItem.h"
#import "RLUtils.h"

#import "SideViewController.h"
#import "MFSideMenuContainerViewController.h"

#import "PAPConstants.h"
#import "PAPUtility.h"
#import "PAPCache.h"


#if DEBUG
//NSString * const parseApplicationId = @"68KQC7b1bURgzLm0MBd1GDaDa2g2EoC7qxyXxYbH"; // Test environment
//NSString * const parseClientKey = @"H9HNDRpQIuiP1AQXDUpiAj1eLUsA6g8jQzCpL0z9";
NSString * const parseApplicationId = @"2ZJBIR24EE2uDn7Jx934aD7iSoYAy0viBYlD2dfz"; // Test environment
NSString * const parseClientKey = @"OkuGH9wrmfT18TzINf1OYHZnkeAN8Bh4JSgtl1bu";
#else
//NSString * const parseApplicationId = @"uuASb6z5tcFCWHCAWwjwqNfpnDyuuaBw0ZAAQ58n"; // Production environment
//NSString * const parseClientKey = @"W66KrsD2PLNGNfS1sHUvZlWVnkVLktNLDb0UiL22";//Soldit
NSString * const parseApplicationId = @"2ZJBIR24EE2uDn7Jx934aD7iSoYAy0viBYlD2dfz"; // Production environment
NSString * const parseClientKey = @"OkuGH9wrmfT18TzINf1OYHZnkeAN8Bh4JSgtl1bu";//Mended
#endif

#if DEBUG
NSString * const stripePublishableKey = @"pk_test_vs97a0WOapUs0gsyfBZZV7UL"; // Test environment
#else
NSString * const stripePublishableKey = @"pk_live_9nbIv1VWdKZ9P8QPm5h7FKrn"; // Production environment
#endif

@interface AppDelegate () {
    NSMutableData *_data;
    BOOL firstLaunch;
}

@property (nonatomic, strong) PAPHomeViewController *homeViewController;
@property (nonatomic, strong) MHTabBarController *homeTabViewController;
@property (nonatomic, strong) RLSearchViewController *searchViewController;
@property (nonatomic, strong) PAPAccountViewController *profileViewController;
@property (nonatomic, strong) PAPActivityFeedViewController *activityViewController;
@property (nonatomic, strong) PAPSplashViewController *splashViewController;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;
@end

@implementation AppDelegate

@synthesize window;
@synthesize navController;
@synthesize tabBarController;
@synthesize networkStatus;

@synthesize homeViewController;
@synthesize homeTabViewController;
@synthesize searchViewController;
@synthesize profileViewController;
@synthesize activityViewController;
@synthesize splashViewController;

@synthesize hud;
@synthesize autoFollowTimer;

@synthesize hostReach;
@synthesize internetReach;
@synthesize wifiReach;


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];   

    [Parse setApplicationId:parseApplicationId
                  clientKey:parseClientKey];
    [PFFacebookUtils initializeFacebook];
    [Stripe setDefaultPublishableKey:stripePublishableKey];
    
    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    NSDictionary *dimensions = @{
                                 @"price": @"100-1500",
                                 @"description": @"jordan"
                                 };
    
    
    // Send the dimensions to Parse along with the 'search' event
    [PFAnalytics trackEvent:@"search" dimensions:dimensions];
    
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Set up our app's global UIAppearance
    [self setupAppearance];
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    splashViewController = [[PAPSplashViewController alloc] initWithNibName:@"PAPSplashViewController" bundle:nil];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:splashViewController];
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    [self handlePush:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self handleActionURL:url]) {
        return YES;
    }
    
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    [PFPush storeDeviceToken:newDeviceToken];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    [[PFInstallation currentInstallation] saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if ([error code] != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    if ([PFUser currentUser]) {
        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
            
            NSString *currentBadgeValue = tabBarItem.badgeValue;
            
            if (currentBadgeValue && currentBadgeValue.length > 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            } else {
                tabBarItem.badgeValue = @"1";
            }
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Clear badge and update installation, required for auto-incrementing badges.
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    
    //[[FBSession activeSession] handleDidBecomeActive];
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    // The empty UITabBarItem behind our Camera button should not load a view controller
    return ![viewController isEqual:aTabBarController.viewControllers[PAPEmptyTabBarItemIndex]];
}


#pragma mark - PAPLoginViewController

- (void)didLogInWithFacebook:(PFUser *)user {
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    if (![self shouldProceedToMainInterface:user]) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.navController.presentedViewController.view animated:YES];
        self.hud.labelText = @"Loading...";
        self.hud.dimBackground = YES;
    }
//    if (![self shouldProceedToMainInterface:user]) {
//        self.hud = [MBProgressHUD showHUDAddedTo:self.navController.presentedViewController.view animated:YES];
//        self.hud.labelText = NSLocalizedString(@"Loading", nil);
//        self.hud.dimBackground = YES;
//    }
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            [self facebookRequestDidLoad:result];
        } else {
            [self facebookRequestDidFailWithError:error];
        }
    }];
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [PAPUtility processFacebookProfilePictureData:_data];
}


#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    NSLog(@"%d", self.networkStatus != NotReachable);
    return self.networkStatus != NotReachable;
}

- (void)presentWelcomeViewControllerAnimated:(BOOL)animated
{
    PAPWelcomeViewController *welcomeViewController = [[PAPWelcomeViewController alloc] initWithNibName:@"PAPWelcomeViewController" bundle:nil];
        //welcomeViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //[self.splashViewController presentModalViewController:welcomeViewController animated:YES];
    [self.navController setViewControllers:@[ self.splashViewController, welcomeViewController ] animated:NO];
}

- (void)presentWelcomeViewController
{
    [self presentWelcomeViewControllerAnimated:YES];
}

- (void)presentTabBarController {
    self.tabBarController = [[PAPTabBarController alloc] init];
    self.homeViewController = [[PAPHomeViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.activityViewController = [[PAPActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.searchViewController = [[RLSearchViewController alloc] initWithNibName:@"RLSearchViewController" bundle:nil];
    self.profileViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.profileViewController setUser:[PFUser currentUser]];
    
    self.homeTabViewController = [[MHTabBarController alloc] init];
    PAPRecentFeedViewController *recentFeedController = [[PAPRecentFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    // PAPFeaturedFeedViewController *featuredFeedController = [[PAPFeaturedFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    PAPNearbyFeedViewController *nearbyFeedController = [[PAPNearbyFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    NSArray *controllers = @[homeViewController, nearbyFeedController, recentFeedController]; //featuredFeedController
    homeViewController.tabBarItem.title = @"Newest";
    nearbyFeedController.tabBarItem.title = @"Featured";
    recentFeedController.tabBarItem.title = @"Following";
    //featuredFeedController.tabBarItem.title = @"Featured";
    homeTabViewController.viewControllers = controllers;
    
    homeTabViewController.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logoNavigationBar.png"]];
    
    homeTabViewController.navigationItem.rightBarButtonItem = [RLUtils sharedSettingsButtonItem];
    
   
    
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeTabViewController];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *exploreNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    
    [[UITabBar appearance] setSelectedImageTintColor:[RLUtils relacedRed]];

    self.tabBarController.tabBar.barStyle = UIBarStyleBlack;
    
    //showing the whole post data for users
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    [homeTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"iconHome.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"iconHome.png"]];
    [homeNavigationController setTabBarItem:homeTabBarItem];
    
    //exploring data for shopping
//    UIStoryboard *sideViewStoryboard = [UIStoryboard storyboardWithName:@"SideViewController" bundle:nil];
//    SideViewController *leftMenuViewController = [sideViewStoryboard instantiateViewControllerWithIdentifier:@"SideViewController"];
    SideViewController *leftMenuViewController = [[SideViewController alloc] initWithMainImage:[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:MY_PORTRAIT]]];
    
    UITabBarItem *exploreTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    [exploreTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"iconExplore.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"iconExplore.png"]];
    [exploreNavigationController setTabBarItem:exploreTabBarItem];
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:exploreNavigationController
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    //Nav - Default
//    AHPagingMenuViewController *container = [[AHPagingMenuViewController alloc]initWithControllers: @[leftMenuViewController, exploreNavigationController] andMenuItens:@[[UIImage imageNamed:@"Setting"], @"Discover", [UIImage imageNamed:@"buttonImageSettings.png"]] andStartWith:1];
    [container setTabBarItem:exploreTabBarItem];
    
    //posting
    emptyNavigationController.tabBarItem.title = @"";
    
    //activity
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    [activityFeedTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"iconTimeline.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"iconTimeline.png"]];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    
    //profile
    UITabBarItem *profileTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    [profileTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"iconProfile.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"iconProfile.png"]];
    [profileNavigationController setTabBarItem:profileTabBarItem];
    
    [[UIBarButtonItem appearance]
     setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000)
     forBarMetrics:UIBarMetricsDefault];
    
    self.tabBarController.delegate = self;

    //in tabbarviewcontroller, five items for tab
    self.tabBarController.viewControllers = @[ container, homeNavigationController, emptyNavigationController, activityFeedNavigationController, profileNavigationController];
    
    [self.navController setViewControllers:@[ self.tabBarController ] animated:YES];//self.splashViewController,
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        // iOS 8 only
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
                                                UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // Download user's profile picture
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[PFUser currentUser] objectForKey:kPAPUserFacebookIDKey]]];
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
}

- (void)logOut {
    // clear cache
    [[PAPCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentWelcomeViewController];
    
    self.homeViewController = nil;

    self.activityViewController = nil;
    
    
}


#pragma mark - ()

- (void)setupAppearance {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    if ([AppDelegate iOSVersion] < 7) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"backgroundNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
        
        UIBarButtonItem *navBarItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
        [navBarItemAppearance setBackgroundImage:[[UIImage imageNamed:@"buttonNavigationBar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [navBarItemAppearance setBackgroundImage:[[UIImage imageNamed:@"buttonNavigationBarSelected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        
        [navBarItemAppearance setBackButtonBackgroundImage:[[UIImage imageNamed:@"buttonBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 16, 10, 10)]
                                                  forState:UIControlStateNormal
                                                barMetrics:UIBarMetricsDefault];
        
        [navBarItemAppearance setBackButtonBackgroundImage:[[UIImage imageNamed:@"buttonBackSelected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 16, 10, 10)]
                                                  forState:UIControlStateSelected
                                                barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                               UITextAttributeTextColor: [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f],
                                                               UITextAttributeTextShadowColor: [UIColor colorWithWhite:0.0f alpha:0.0f],
                                                               UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeMake(0.0f, 0.0f)]
                                                               } forState:UIControlStateNormal];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UINavigationBar appearance] setBarTintColor:[RLUtils relacedRed]];
        
    }
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor: [UIColor whiteColor],
                                                           UITextAttributeTextShadowColor: [UIColor colorWithWhite:0.0f alpha:0.0f],
                                                           UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeMake(0.0f, 0.0f)]
                                                           }];
    
    [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
    
    UITabBarItem *tabBarItemAppearance = [UITabBarItem appearance];
    [tabBarItemAppearance setTitleTextAttributes: @{ UITextAttributeTextColor:[RLUtils relacedRed] } forState:UIControlStateSelected];
    [tabBarItemAppearance setTitleTextAttributes: @{ UITextAttributeTextColor: [UIColor lightGrayColor] } forState:UIControlStateNormal];
}

- (void)monitorReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
}

- (void)handlePush:(NSDictionary *)launchOptions {
    
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser]) {
            return;
        }
        
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
                    self.tabBarController.selectedViewController = homeNavigationController;
                    
                    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
                    accountViewController.user = (PFUser *)user;
                    [homeNavigationController pushViewController:accountViewController animated:YES];
                }
            }];
        }
    }
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
    [self.homeViewController loadObjects];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    if ([PAPUtility userHasValidFacebookData:[PFUser currentUser]]) {
        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
        [self presentTabBarController];
        
        [self.navController dismissModalViewControllerAnimated:YES];
        return YES;
    }
    
    return NO;
}

- (BOOL)handleActionURL:(NSURL *)url {
    if ([[url host] isEqualToString:kPAPLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            return [self.tabBarController shouldPresentPhotoCaptureController];
        }
    } else {
        if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
            if (photoObjectId && photoObjectId.length > 0) {
                [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
                return YES;
            }
        }
    }
    
    return NO;
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    networkStatus = [curReach currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        NSLog(@"Network not reachable.");
    }
    
    if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
        // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
        // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
        [self.homeViewController loadObjects];
    }
}

- (void)shouldNavigateToPhoto:(PFObject *)targetPhoto {
    for (PFObject *photo in self.homeViewController.objects) {
        if ([photo.objectId isEqualToString:targetPhoto.objectId]) {
            targetPhoto = photo;
            break;
        }
    }
    
    // if we have a local copy of this photo, this won't result in a network fetch
    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:PAPHomeTabBarItemIndex];
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            PAPPhotoDetailsViewController *detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:object];
            [homeNavigationController pushViewController:detailViewController animated:YES];
        }
    }];
}

- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[PAPCache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if (![user objectForKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey]) {
                self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                firstLaunch = YES;
                
                [user setObject:@YES forKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey];
                NSError *error = nil;
                
                // find common Facebook friends already using Relaced
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookIds];
                
                // auto-follow Parse employees
                PFQuery *autoFollowAccountsQuery = [PFUser query];
                [autoFollowAccountsQuery whereKey:kPAPUserDisplayNameKey containedIn:kPAPParseEmployeeAccounts];
                
                // combined query
                PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:autoFollowAccountsQuery,facebookFriendsQuery, nil]];
                
                NSArray *anypicFriends = [query findObjects:&error];
                
                if (!error) {
                    [anypicFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                        PFObject *joinActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
                        [joinActivity setObject:user forKey:kPAPActivityFromUserKey];
                        [joinActivity setObject:newFriend forKey:kPAPActivityToUserKey];
                        [joinActivity setObject:kPAPActivityTypeJoined forKey:kPAPActivityTypeKey];
                        
                        PFACL *joinACL = [PFACL ACL];
                        [joinACL setPublicReadAccess:YES];
                        joinActivity.ACL = joinACL;
                        
                        // make sure our join activity is always earlier than a follow
                        [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [PAPUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                                // This block will be executed once for each friend that is followed.
                                // We need to refresh the timeline when we are following at least a few friends
                                // Use a timer to avoid refreshing innecessarily
                                if (self.autoFollowTimer) {
                                    [self.autoFollowTimer invalidate];
                                }
                                
                                self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                            }];
                        }];
                    }];
                }
                
                if (![self shouldProceedToMainInterface:user]) {
                    [self logOut];
                    return;
                }
                
                if (!error) {
                    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
                    if (anypicFriends.count > 0) {
                        self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
                        self.hud.dimBackground = YES;
                        self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                    } else {
                        [self.homeViewController loadObjects];
                    }
                }
            }
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [self logOut];
        }
    } else {
        self.hud.labelText = NSLocalizedString(@"Creating Profile", nil);
        
        if (user) {
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:kPAPUserDisplayNameKey];
            } else {
                [user setObject:@"Someone" forKey:kPAPUserDisplayNameKey];
            }
            
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:kPAPUserFacebookIDKey];
            }
            
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [self logOut];
        }
    }
}

+ (NSInteger)iOSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

@end
