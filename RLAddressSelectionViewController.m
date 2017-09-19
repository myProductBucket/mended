//
//  RLAddressSelectionViewController.m
//  Relaced
//
//  Created by Mybrana on 09/04/15.
//
//

#import "RLAddressSelectionViewController.h"
#import "RLAddressTableViewCell.h"
#import "RLAddressViewController.h"
#import "RLUtils.h"

@interface RLAddressSelectionViewController () <UITabBarControllerDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *addressesTableView;

@property (weak, nonatomic) IBOutlet UIButton *addAddressButton;

@property (strong, nonatomic) NSMutableArray *addressesArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isRefreshing;

@end

@implementation RLAddressSelectionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.addressesArray = [NSMutableArray new];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"CHOOSE ADDRESS";

    self.addAddressButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.addAddressButton.layer.cornerRadius = 5.0f;
    self.navigationController.navigationBar.translucent = NO;
        
    // Init refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshAddresses) forControlEvents:UIControlEventValueChanged];
    
    // Create tableviewcontroller to add the refresh control
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.addressesTableView;
    tableViewController.refreshControl = self.refreshControl;
    
    // Register cell xib
    [self.addressesTableView registerNib:[UINib nibWithNibName:@"RLAddressTableViewCell" bundle:nil] forCellReuseIdentifier:[self getCellReuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshAddresses];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Class methods

- (NSString *)getCellReuseIdentifier
{
    return @"RLAddressTableViewCell";
}

#pragma mark Parse

- (void)refreshAddresses
{
    // Start refreshing animation programmatically if needed
    if (![self.refreshControl isRefreshing])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.refreshControl beginRefreshing];
            [self.addressesTableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        });
    }
    
    [self retrieveAddressesAndReset:YES];
}

- (void)retrieveAddressesAndReset:(BOOL)reset
{
    if (!self.isRefreshing)
    {
        self.isRefreshing = YES;
        
        __weak RLAddressSelectionViewController *weakSelf = self;
        
        PFQuery *addressesQuery = [PFQuery queryWithClassName:kRLAddressClass];
        [addressesQuery whereKey:kRLUserKey equalTo:[PFUser currentUser]];
        
        [addressesQuery findObjectsInBackgroundWithBlock:^(NSArray *addresses, NSError *error) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                if (!error)
                {
                    if (reset)
                    {
                        [weakSelf.addressesArray removeAllObjects];
                    }
                    NSLog(@"%@", addresses);
                    [weakSelf.addressesArray addObjectsFromArray:addresses];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf.addressesTableView reloadData];
                    });
                }
                else
                {
                    NSLog(@"Could not retrieve addresses: %@", error.description);
                }
                
                weakSelf.isRefreshing = NO;
                
                // Stop the spinning animations
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf.refreshControl endRefreshing];
                });
            });
        }];
    }
}

#pragma mark IBActions

- (IBAction)addAddressButtonPressed:(id)sender
{
    RLAddressViewController *addressViewController = [[RLAddressViewController alloc] initWithNibName:@"RLAddressViewController" bundle:nil];
    [self.navigationController pushViewController:addressViewController animated:YES];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didSelectAddress:self.addressesArray[indexPath.row]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.addressesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLAddressTableViewCell *addressCell = [tableView dequeueReusableCellWithIdentifier:[self getCellReuseIdentifier]];
    
    PFObject *addressObject = self.addressesArray[indexPath.row];
    
    [addressCell configureWithAddress:addressObject];
    
    return addressCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        PFObject *address = self.addressesArray[indexPath.row];
        [address deleteEventually];
        
        [self.addressesArray removeObject:address];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
