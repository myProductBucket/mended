//
//  PAPConversationsViewController.m
//  Relaced
//
//  Created by Qibo Fu on 8/11/13.
//
//

#import "PAPConversationsViewController.h"
#import "PAPMessagesViewController.h"
#import "PAPConversationCell.h"
#import "PAPLoadMoreCell.h"

#define CONVERSATIONS_PER_PAGE 10

@interface PAPConversationsViewController ()

@property (nonatomic, strong) PFQuery *lastQuery;

@end

@implementation PAPConversationsViewController

@synthesize lastQuery;

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

    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundLeather.png"]];
    listView.backgroundView = texturedBackgroundView;

    conversations = [NSMutableArray array];
    refreshControl = [[ODRefreshControl alloc] initInScrollView:listView];
    [refreshControl addTarget:self action:@selector(refreshAll) forControlEvents:UIControlEventValueChanged];
    [self refreshAll];
    
    self.navigationItem.title = @"Chat";
    self.navigationController.navigationBar.translucent = NO;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.tabBarController.navigationController)
        [self.tabBarController.navigationController setNavigationBarHidden:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshAll
{
    [lastQuery cancel];
    PFQuery *mine = [PFQuery queryWithClassName:@"Conversation"];
    [mine whereKey:@"srcUser" equalTo:[PFUser currentUser]];
    
    PFQuery *others = [PFQuery queryWithClassName:@"Conversation"];
    [others whereKey:@"dstUser" equalTo:[PFUser currentUser]];
    
    self.lastQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:mine, others, nil]];
    [lastQuery orderByDescending:@"lastDate"];
    lastQuery.limit = CONVERSATIONS_PER_PAGE + 1;
    [lastQuery includeKey:@"dstUser"];
    [lastQuery includeKey:@"srcUser"];
    [lastQuery includeKey:@"lastMessage"];
    
    loading = YES;
    hasMore = YES;
    [lastQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:[[error userInfo] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            if (objects.count <= CONVERSATIONS_PER_PAGE) {
                hasMore = NO;
            }
            [conversations removeAllObjects];
            [conversations addObjectsFromArray:objects];
            
            [listView reloadData];
        }
        loading = NO;
        [refreshControl endRefreshing];
    }];
}

- (void)loadMore
{
    [lastQuery cancel];
    PFQuery *mine = [PFQuery queryWithClassName:@"Conversation"];
    [mine whereKey:@"srcUser" equalTo:[PFUser currentUser]];
    
    PFQuery *others = [PFQuery queryWithClassName:@"Conversation"];
    [others whereKey:@"dstUser" equalTo:[PFUser currentUser]];
    
    self.lastQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:mine, others, nil]];
    lastQuery.limit = CONVERSATIONS_PER_PAGE + 1;
    lastQuery.skip = conversations.count;
    [lastQuery orderByDescending:@"lastDate"];
    [lastQuery includeKey:@"dstUser"];
    [lastQuery includeKey:@"srcUser"];
    [lastQuery includeKey:@"lastMessage"];
    
    loading = YES;
    [lastQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:[[error userInfo] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            if (objects.count <= CONVERSATIONS_PER_PAGE) {
                hasMore = NO;
            }
            [conversations addObjectsFromArray:objects];
            
            [listView reloadData];
        }
        loading = NO;
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (hasMore)
        return conversations.count + 1;
    
    return conversations.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= conversations.count) {
        return 44.0;
    }
    
    return 72.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= conversations.count) {
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
    
    static NSString *CellIdentifier = @"ConversationCell";
    PAPConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PAPConversationCell" owner:nil options:nil];
        cell = (PAPConversationCell *)[nib objectAtIndex:0];
    }
    
    [cell setObject:[conversations objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= conversations.count) {
        [self loadMore];
        return;
    }
    
    PAPMessagesViewController *messagesController = [[PAPMessagesViewController alloc] initWithNibName:@"PAPMessagesViewController" bundle:nil];
    PFObject *conversation = [conversations objectAtIndex:indexPath.row];
    PFObject *srcUser = [conversation objectForKey:@"srcUser"];
    if ([srcUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
        messagesController.oppositeUser = [conversation objectForKey:@"dstUser"];
        BOOL newFromDst = [[conversation objectForKey:@"newFromDst"] boolValue];
        if (newFromDst) {
            [conversation setObject:[NSNumber numberWithBool:NO] forKey:@"newFromDst"];
            [conversation saveEventually];
        }
    }
    else {
        messagesController.oppositeUser = [conversation objectForKey:@"srcUser"];
        BOOL newFromSrc = [[conversation objectForKey:@"newFromSrc"] boolValue];
        if (newFromSrc) {
            [conversation setObject:[NSNumber numberWithBool:NO] forKey:@"newFromSrc"];
            [conversation saveEventually];
        }
    }
    messagesController.conversation = conversation;
    
    if(self.tabBarController.navigationController)
    {
        //[self.tabBarController.navigationController setNavigationBarHidden:FALSE];
        [self.tabBarController.navigationController pushViewController:messagesController animated:YES];
    }
    else
        [self.navigationController pushViewController:messagesController animated:YES];
}

@end
