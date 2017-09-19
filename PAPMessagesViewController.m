//
//  PAPMessagesViewController.m
//  Relaced
//
//  Created by Qibo Fu on 8/11/13.
//
//

#import <ParseUI/ParseUI.h>
#import "PAPMessagesViewController.h"
#import "PAPLoadingCell.h"
#import "PAPAccountViewController.h"
#import "MBProgressHUD.h"
#import "ODRefreshControl.h"

#define MESSAGES_PER_PAGE 20

@interface PAPMessagesViewController ()

@property (nonatomic, strong) PFQuery *lastQuery;
@property (weak, nonatomic) IBOutlet UIButton *serviceFeeDisclosureButton;

@end

@implementation PAPMessagesViewController

@synthesize lastQuery;
@synthesize conversation;
@synthesize oppositeUser;

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
    hasMore = YES;
    
    self.navigationItem.title = @"Messages";
    self.navigationController.navigationBar.translucent = NO;
    self.serviceFeeDisclosureButton.transform = CGAffineTransformMakeScale(0.7, 0.7);
    bubbleTable.bubbleDataSource = self;
    bubbleTable.bubbleDelegate = self;
    
    bubbleTable.snapInterval = 120;
    
    bubbleTable.showAvatars = NO;
    bubbleTable.typingBubble = NSBubbleTypingTypeLoading;
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    //texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundLeather.png"]];
    bubbleTable.backgroundView = texturedBackgroundView;
    
    bubbleData = [[NSMutableArray alloc] init];
    [bubbleTable reloadData];
    
    username.text = [oppositeUser objectForKey:kPAPUserDisplayNameKey];
    PFFile *imageFile = [oppositeUser objectForKey:kPAPUserProfilePicSmallKey];
    if (imageFile) {
        [avatarView setFile:imageFile];
        [avatarView loadInBackground];
        //[avatarView = [[PAPProfileImageView alloc] init];
        [avatarView setBackgroundColor:[UIColor clearColor]];
        [avatarView setOpaque:YES];
        
        avatarView.layer.cornerRadius = avatarView.frame.size.width / 2;
        //self.avatarView.layer.masksToBounds = YES;
        avatarView.clipsToBounds = YES;
        avatarView.layer.borderWidth = 1.5f;
        avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    if (conversation == nil) {
        [self loadConversation];
    }
    else {
        [self initViews];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [inputView resignFirstResponder];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.tabBarController.navigationController)
        [self.tabBarController.navigationController setNavigationBarHidden:TRUE];
    else {
        [self.navigationController setNavigationBarHidden:FALSE];
        self.title = @"Message";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.conversation = nil;
    self.oppositeUser = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadConversation
{
    PFQuery *query1 = [PFQuery queryWithClassName:@"Conversation"];
    [query1 whereKey:@"srcUser" equalTo:[PFUser currentUser]];
    [query1 whereKey:@"dstUser" equalTo:oppositeUser];

    PFQuery *query2 = [PFQuery queryWithClassName:@"Conversation"];
    [query2 whereKey:@"srcUser" equalTo:oppositeUser];
    [query2 whereKey:@"dstUser" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.conversation = object;
        [self initViews];
    }];
}


- (void)initViews
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAll) name:kGotNewMessage object:nil];
    
	inputView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    inputView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	inputView.minNumberOfLines = 1;
	inputView.maxNumberOfLines = 3;
	inputView.returnKeyType = UIReturnKeyDefault; //just as an example
	inputView.font = [UIFont systemFontOfSize:15.0f];
	inputView.delegate = self;
    inputView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    inputView.backgroundColor = [UIColor whiteColor];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"messageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"messageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, inputContainer.frame.size.width, inputContainer.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [inputContainer addSubview:imageView];
    [inputContainer addSubview:inputView];
    [inputContainer addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"messageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"messageEntrySendButtonPressed.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
    
    // Send button
	sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sendButton.frame = CGRectMake(inputContainer.frame.size.width - 69, 8, 63, 27);
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[sendButton setTitle:@"Send" forState:UIControlStateNormal];
    
    [sendButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    sendButton.titleLabel.shadowOffset = CGSizeMake (0.0, -0.0);
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [sendButton setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[inputContainer addSubview:sendButton];
    inputContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = inputContainer.frame;
        frame.origin.y = self.view.bounds.size.height - frame.size.height;
        inputContainer.frame = frame;
        frame = bubbleTable.frame;
        frame.size.height -= inputContainer.frame.size.height;
        bubbleTable.frame = frame;
    }];

    refreshControl = [[ODRefreshControl alloc] initInScrollView:bubbleTable];
    [refreshControl addTarget:self action:@selector(refreshAll) forControlEvents:UIControlEventValueChanged];
    
    [refreshControl beginRefreshing];
    [self refreshAll];
    
    UILongPressGestureRecognizer * userHeaderHeldGR = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(userHeaderHeld:)];
    userHeaderHeldGR.minimumPressDuration = 0;
    userHeaderHeldGR.allowableMovement = 2;
    [headerView addGestureRecognizer:userHeaderHeldGR];
}

-(void)userHeaderHeld:(UILongPressGestureRecognizer *)sender
{
    CGPoint initialpoint;
    CGFloat y;
    CGFloat x;
    CGPoint tempPoint;

    //Change the color of the top header when it's held down
    if (sender.state == UIGestureRecognizerStateBegan) {
        username.textColor = [UIColor whiteColor];
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
        [headerView.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
        headerView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint currentPoint = [sender locationInView:self.view];
        x = currentPoint.x-initialpoint.x;
        y = currentPoint.y-initialpoint.y;
        tempPoint = CGPointMake( currentPoint.x,  currentPoint.y);
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        username.textColor = [UIColor blackColor];
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
        [headerView.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
        headerView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.5];
        
        //Push a new View Controller with the other user's account information
        PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
        [accountViewController setUser:oppositeUser];
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
}

- (void)initConversation
{
    self.conversation = [PFObject objectWithClassName:@"Conversation"];
    [conversation setObject:[PFUser currentUser] forKey:@"srcUser"];
    [conversation setObject:oppositeUser forKey:@"dstUser"];
    
    PFACL *acl = [PFACL ACLWithUser:[PFUser currentUser]];
    [acl setWriteAccess:YES forUser:oppositeUser];
    [acl setPublicReadAccess:NO];
    [acl setReadAccess:YES forUser:oppositeUser];
    conversation.ACL = acl;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Initiating conversation";
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self sendMessage];
        }
        else {
            [hud hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:[[error userInfo] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)sendMessage
{
	[inputView resignFirstResponder];
    NSString *content = [inputView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([content isEqualToString:@""]) {
        return;
    }
    
    if (conversation == nil) {
        [self initConversation];
        return;
    }
    
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    [message setObject:conversation.objectId forKey:@"conversationId"];
    [message setObject:content forKey:@"message"];
    [message setObject:[PFUser currentUser] forKey:@"sender"];
    [message setObject:oppositeUser forKey:@"receiver"];
//    [message setObject:[NSNumber numberWithBool:NO] forKey:@"read"];
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.navigationController.view];
    if (hud == nil) {
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    hud.labelText = @"Sending message";
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [hud hide:YES];
        if (succeeded) {
            [bubbleData insertObject:[self dataWithMessage:message] atIndex:0];
            [bubbleTable reloadData];
            [bubbleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            
            [conversation setObject:message forKey:@"lastMessage"];
            [conversation setObject:[NSDate date] forKey:@"lastDate"];
            PFObject *srcUser = [conversation objectForKey:@"srcUser"];
            if ([srcUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
                [conversation setObject:[NSNumber numberWithBool:YES] forKey:@"newFromSrc"];
            }
            else {
                [conversation setObject:[NSNumber numberWithBool:YES] forKey:@"newFromDst"];
            }
            [conversation saveEventually];
            
            PFObject *messageActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
            [messageActivity setObject:kPAPActivityTypeMessage forKey:kPAPActivityTypeKey];
            [messageActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
            [messageActivity setObject:oppositeUser forKey:kPAPActivityToUserKey];
            [messageActivity setObject:conversation forKey:kPAPActivityMessageKey];
            
            PFACL *messageACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [messageACL setPublicReadAccess:YES];
            [messageACL setWriteAccess:YES forUser:oppositeUser];
            messageActivity.ACL = messageACL;
            
            [messageActivity saveEventually];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:[[error userInfo] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
    
    //Set null after send button pressed or finished editing.
    [inputView setText:@""];
    inputView.text = @"";
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = inputContainer.frame;
    CGFloat tabbarHeight = 0;
    if (self.tabBarController) {
        tabbarHeight = self.tabBarController.tabBar.frame.size.height;
    }
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height) + tabbarHeight;
    CGRect headerFrame = headerView.frame;
    headerFrame.origin.y = -headerFrame.size.height;
    CGRect tableFrame = bubbleTable.frame;
    tableFrame.origin.y = 0;
    tableFrame.size.height -= keyboardBounds.size.height - tabbarHeight - headerFrame.size.height;
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	inputContainer.frame = containerFrame;
    headerView.frame = headerFrame;
    bubbleTable.frame = tableFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (IBAction)serviceFeeDisclosureButtonPressed:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Service Fee"
                                message:@"The price includes the fee charged by Mended"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = inputContainer.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    CGRect headerFrame = headerView.frame;
    headerFrame.origin.y = 0;
    CGRect tableFrame = bubbleTable.frame;
    tableFrame.origin.y = headerFrame.size.height;
    tableFrame.size.height = self.view.bounds.size.height - headerFrame.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	inputContainer.frame = containerFrame;
    headerView.frame = headerFrame;
    bubbleTable.frame = tableFrame;
	
	// commit animations
	[UIView commitAnimations];
}


#pragma mark - Deleate funcation of Growing Text View

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = inputContainer.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	inputContainer.frame = r;
}


- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}


- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    // Resize the message table view
    CGRect frame = bubbleTable.frame;
    frame.size.height = (self.view.frame.size.height == 568 ? 460.0f :372.0f);
    bubbleTable.frame = frame;
}


#pragma mark -
- (void)refreshAll
{
    if (conversation == nil) {
        [refreshControl endRefreshing];
        hasMore = NO;
        bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
        [bubbleTable reloadData];
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"conversationId" equalTo:conversation.objectId];
    [query orderByDescending:@"createdAt"];
    query.limit = MESSAGES_PER_PAGE + 1;
    
    loading = YES;
    hasMore = YES;
    bubbleTable.typingBubble = NSBubbleTypingTypeLoading;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            // Bubble views
            [bubbleData removeAllObjects];
            
            if (objects.count <= MESSAGES_PER_PAGE) {
                hasMore = NO;
                bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
            }
            for (int i=0; i<objects.count && i<MESSAGES_PER_PAGE; i++) {
                PFObject *message = [objects objectAtIndex:i];
                [bubbleData addObject:[self dataWithMessage:message]];
            }

            [bubbleTable reloadData];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:[[error userInfo] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        loading = NO;
        [refreshControl endRefreshing];
    }];
}

- (void)loadMore
{
    if (conversation == nil) {
        hasMore = NO;
        bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
        [bubbleTable reloadData];
        return;
    }

    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"conversationId" equalTo:conversation.objectId];
    [query orderByDescending:@"createdAt"];
    query.limit = MESSAGES_PER_PAGE + 1;
    query.skip = bubbleData.count;
    
    loading = YES;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Loaded more messages");
            
            // Bubble views
            
            if (objects.count <= MESSAGES_PER_PAGE) {
                hasMore = NO;
                bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
            }
            for (int i=0; i<objects.count && i<MESSAGES_PER_PAGE; i++) {
                PFObject *message = [objects objectAtIndex:i];
                [bubbleData addObject:[self dataWithMessage:message]];
            }
            
            [bubbleTable reloadData];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mended" message:[[error userInfo] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        loading = NO;
        [refreshControl endRefreshing];
    }];
}

- (NSBubbleData *)dataWithMessage:(PFObject *)message
{
    BOOL mine = NO;
    NSString *text = [message objectForKey:@"message"];
    PFObject *sender = [message objectForKey:@"sender"];
    
    if ([sender.objectId isEqualToString:[PFUser currentUser].objectId]) {
        mine = YES;
    }
    
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    size.width = 220;
    CGFloat height = size.height;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.text = (text ? text : @"");
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
    NSDate *date = message.updatedAt;
    
    UIButton *senderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (mine) {
        
    }
    else {
        //        height = height + 20;
        //        senderButton.frame = CGRectMake(10, height - 14, 200, 12);
        //        senderButton.contentMode = UIViewContentModeRight;
        //        [senderButton setTitle:[sender objectForKey:@"username"] forState:UIControlStateNormal];
        //        [senderButton setTitleColor:[UIColor colorWithRed:0.22 green:0.41 blue:0.66 alpha:1.0] forState:UIControlStateNormal];
        //        senderButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        //        [senderButton addTarget:self action:@selector(didClickUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, height)];
    [view addSubview:label];
    
    if (senderButton != nil) {
        [view addSubview:senderButton];
    }
    
    UIEdgeInsets insets = (mine ? imageInsetsMine : imageInsetsSomeone);
    return [NSBubbleData dataWithView:view date:date type:(mine ? BubbleTypeMine : BubbleTypeSomeoneElse) insets:insets];
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark UIBubbleTableViewDelegate Methods

- (void)bubbleTableViewShouldLoadMore:(UIBubbleTableView *)tableView
{
    if (bubbleData.count > 0 && !loading && hasMore) {
        [self loadMore];
    }
}

@end
