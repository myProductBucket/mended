//
//  RLCardSelectionViewController.m
//  Relaced
//
//  Created by Mybrana on 09/04/15.
//
//

#import "RLCardSelectionViewController.h"
#import "RLCardTableViewCell.h"
#import "RLCardViewController.h"
#import "RLUtils.h"
#import <Stripe.h>

@interface RLCardSelectionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *cardsTableView;

@property (weak, nonatomic) IBOutlet UIButton *confirmPurchaseButton;
@property (weak, nonatomic) IBOutlet UIButton *addCardButton;

@property (strong, nonatomic) NSMutableArray *cardsArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isRefreshing;

@property (strong, nonatomic) PFObject *cardObject;

@end

@implementation RLCardSelectionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.cardsArray = [NSMutableArray new];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"CHOOSE CARD";
    self.navigationController.navigationBar.translucent = NO;
    
    self.addCardButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.addCardButton.layer.cornerRadius = 5.0f;
    
    self.confirmPurchaseButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.confirmPurchaseButton.layer.cornerRadius = 5.0f;
    self.confirmPurchaseButton.hidden = YES;
    
    // Init refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshCards) forControlEvents:UIControlEventValueChanged];
    
    // Create tableviewcontroller to add the refresh control
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.cardsTableView;
    tableViewController.refreshControl = self.refreshControl;
    
    // Register cell xib
    [self.cardsTableView registerNib:[UINib nibWithNibName:@"RLCardTableViewCell" bundle:nil] forCellReuseIdentifier:[self getCellReuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshCards];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Helpers

- (NSString *)getCellReuseIdentifier
{
    return @"RLCardTableViewCell";
}

#pragma mark IBActions

- (IBAction)addCardButtonPressed:(id)sender
{
    RLCardViewController *cardViewController = [[RLCardViewController alloc] initWithNibName:@"RLCardViewController" bundle:nil];
    cardViewController.shippingAddressObject = self.shippingAddressObject;
    [self.navigationController pushViewController:cardViewController animated:YES];
}

- (IBAction)confirmPurchaseButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didConfirmPurchaseWithCard:)])
    {
        [self.delegate didConfirmPurchaseWithCard:self.cardObject];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *cardObject = self.cardsArray[indexPath.row];
    
    if (cardObject.objectId == self.cardObject.objectId)
    {
        [tableView.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
    else
    {
        self.addCardButton.hidden = YES;
        self.confirmPurchaseButton.hidden = NO;
        self.cardObject = cardObject;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.cardObject = nil;
    self.addCardButton.hidden = NO;
    self.confirmPurchaseButton.hidden = YES;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cardsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLCardTableViewCell *cardCell = [tableView dequeueReusableCellWithIdentifier:[self getCellReuseIdentifier]];
    
    PFObject *cardObject = self.cardsArray[indexPath.row];
    
    [cardCell configureWithCard:cardObject];
    
    return cardCell;
}

#pragma mark Parse

- (void)refreshCards
{
    // Start refreshing animation programmatically if needed
    if (![self.refreshControl isRefreshing])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.refreshControl beginRefreshing];
            [self.cardsTableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        });
    }
    
    [self retrieveCardsAndReset:YES];
}

- (void)retrieveCardsAndReset:(BOOL)reset
{
    if (!self.isRefreshing)
    {
        self.isRefreshing = YES;
        
        __weak RLCardSelectionViewController *weakSelf = self;
        
        PFQuery *cardsQuery = [PFQuery queryWithClassName:kRLCardClass];
        [cardsQuery whereKey:kRLUserKey equalTo:[PFUser currentUser]];
        
        [cardsQuery findObjectsInBackgroundWithBlock:^(NSArray *cards, NSError *error) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                if (!error)
                {
                    if (reset)
                    {
                        [weakSelf.cardsArray removeAllObjects];
                    }
                    
                    [weakSelf.cardsArray addObjectsFromArray:cards];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf.cardsTableView reloadData];
                    });
                }
                else
                {
                    NSLog(@"Could not retrieve cards: %@", error.description);
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

@end
