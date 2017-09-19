//
//  PAPSplashViewController.m
//  Relaced
//
//  Created by Qibo Fu on 8/26/13.
//
//

#import "PAPSplashViewController.h"
#import "UIImage+iPhone5.h"
#import "AppDelegate.h"
#import "FBRequestConnection.h"
#import "MBProgressHUD.h"
#import "PAPUtility.h"
#import "PAPConstants.h"

@interface PAPSplashViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageV;

@end

@implementation PAPSplashViewController

@synthesize backgroundImageV;

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
    
//    [self.backgroundImageV setImage:[UIImage imageNamed:@"LaunchImage"]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"%@", backgroundImageV);
//    [MBProgressHUD showHUDAddedTo:backgroundImageV animated:YES];
    
    if (![PFUser currentUser]) {
//        [MBProgressHUD hideHUDForView:backgroundImageV animated:YES];
        
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentWelcomeViewControllerAnimated:YES];
        return;
    }
    
    PFFile *imageFile = [[PFUser currentUser] objectForKey:kPAPUserProfilePicMediumKey];
    
    if (imageFile)
    {
        [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (!error && data) {
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:MY_PORTRAIT];
            }
            // Present Anypic UI
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
        }];
    }
    
    // Refresh current user with server side data -- checks if user is still valid and so on
    [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
//    [self.backgroundImageV setImage:[UIImage imageNamed:@"LaunchImage"]];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [backgroundImageView setImage:[UIImage tallImageNamed:@"Default.png"]];
    self.view = backgroundImageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If not logged in, present login view controller
    
}

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error
{
//    [MBProgressHUD hideHUDForView:backgroundImageV animated:YES];
    
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        NSLog(@"User does not exist.");
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    // Check if user is missing a Facebook ID
    if ([PAPUtility userHasValidFacebookData:[PFUser currentUser]]) {
        // User has Facebook ID.
        
        // refresh Facebook friends on each launch
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidLoad:)]) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:) withObject:result];
                }
            } else {
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidFailWithError:)]) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:) withObject:error];
                }
            }
        }];
    } else {
        NSLog(@"Current user is missing their Facebook ID");
//        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//            if (!error) {
//                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidLoad:)]) {
//                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:) withObject:result];
//                }
//            } else {
//                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidFailWithError:)]) {
//                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:) withObject:error];
//                }
//            }
//        }];
    }
}

@end
