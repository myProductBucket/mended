//
//  RLSearchViewController.m
//  Relaced
//
//  Created by Benjamin Madueme on 11/9/14.
//
//

#import <ParseUI/ParseUI.h>

#import "ActionSheetStringPicker.h"

#import "RLSearchViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "PAPAccountViewController.h"
#import "PAPSearchCell.h"
#import "PAPLoadMoreCell.h"
#import "JGActionSheet.h"
#import "M13OrderedDictionary.h"
#import "PAPSettingsButtonItem.h"
#import "RLUtils.h"
#import "MFSideMenu.h"
#import "PAPConstants.h"

@implementation RLSearchViewController

@synthesize searchScope;
@synthesize searchBar;
@synthesize numResultsLabel;
@synthesize resultsTableView;
@synthesize sortButton;
@synthesize filtersButton;
@synthesize filtersScope;
@synthesize additionalFilterScope;
@synthesize filtersTableView;
@synthesize queryTableViewController;
@synthesize workingQuery;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.tabBarController.navigationController)
        [self.tabBarController.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //setup Menu
    //setup menu
    [self setupMenuBarButtonItems];
    
    searchBar.delegate = self;
    resultsTableView.delegate = self;
    resultsTableView.dataSource = self;
    
    queryLimit = 10;
    self.navigationItem.title = @"Discover";
    results = [[NSMutableArray alloc] init];
    currentItemSort = kNewest;
    currentUsernameSort = kAlphabetically;
    
    [self initializeFilterDicts];
    
    self.navigationItem.rightBarButtonItem = [RLUtils sharedSettingsButtonItem];
    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.navigationBarHidden = YES;
    //self.navigationController.hidden = NO;
    
    [additionalFilterScope setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
    [self populateResultsView:YES];
}

#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        //        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"Setting"] style:UIBarButtonItemStyleDone
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

#pragma mark - <----->

- (void)initializeFilterDicts
{
    //Size
    NSArray * sizeFilters = [RLUtils sizeFiltersList];
    NSMutableArray * sizeFiltersIsSelected = [NSMutableArray new];
    while ([sizeFiltersIsSelected count] < [sizeFilters count])
        [sizeFiltersIsSelected addObject:@NO];
    
    sizeFilterToIsSelectedDict = [[M13MutableOrderedDictionary alloc] initWithObjects:sizeFiltersIsSelected pairedWithKeys:sizeFilters];
    
    //Price
    NSArray * priceFilters = [RLUtils priceFiltersList];
    NSMutableArray * priceFiltersIsSelected = [NSMutableArray new];
    while ([priceFiltersIsSelected count] < [priceFilters count])
        [priceFiltersIsSelected addObject:@NO];
    
    priceFilterToIsSelectedDict = [[M13MutableOrderedDictionary alloc] initWithObjects:priceFiltersIsSelected pairedWithKeys:priceFilters];
    
    //Category
    NSArray * categoryFilters = [RLUtils categoryFiltersList];
    NSMutableArray * categoryFiltersIsSelected = [NSMutableArray new];
    while ([categoryFiltersIsSelected count] < [categoryFilters count])
        [categoryFiltersIsSelected addObject:@NO];
    
    categoryFilterToIsSelectedDict = [[M13MutableOrderedDictionary alloc] initWithObjects:categoryFiltersIsSelected pairedWithKeys:categoryFilters];
    
    //Sold
    NSArray * soldFilters = [RLUtils soldFiltersList];
    NSMutableArray * soldFiltersIsSelected = [NSMutableArray new];
    while ([soldFiltersIsSelected count] < [soldFilters count])
        [soldFiltersIsSelected addObject:@NO];
    
    soldFilterToIsSelectedDict = [[M13MutableOrderedDictionary alloc] initWithObjects:soldFiltersIsSelected pairedWithKeys:soldFilters];
    
    //Color
    NSArray * colorFilters = [RLUtils colorFiltersList];
    NSMutableArray * colorFiltersIsSelected = [NSMutableArray new];
    while ([colorFiltersIsSelected count] < [colorFilters count])
        [colorFiltersIsSelected addObject:@NO];
    
    colorFilterToIsSelectedDict = [[M13MutableOrderedDictionary alloc] initWithObjects:colorFiltersIsSelected pairedWithKeys:colorFilters];
    
    //Brand
    NSArray * brandFilters = [RLUtils brandFiltersList];
    NSMutableArray * brandFiltersIsSelected = [NSMutableArray new];
    while ([brandFiltersIsSelected count] < [brandFilters count])
        [brandFiltersIsSelected addObject:@NO];
    
    brandFilterToIsSelectedDict = [[M13MutableOrderedDictionary alloc] initWithObjects:brandFiltersIsSelected pairedWithKeys:brandFilters];
    
    //Condition
    NSArray * conditionFilters = [RLUtils conditionFiltersList];
    NSMutableArray * conditionFiltersIsSelected = [NSMutableArray new];
    while ([conditionFiltersIsSelected count] < [conditionFilters count])
        [conditionFiltersIsSelected addObject:@NO];
    
    conditionFilterToIsSelectedDict = [[M13MutableOrderedDictionary alloc] initWithObjects:conditionFiltersIsSelected pairedWithKeys:conditionFilters];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)delegateSearchBar
{
    [delegateSearchBar resignFirstResponder];
    NSLog(@"Searching...");
    
    [self populateResultsView:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)delegateSearchBar
{
    UITextField *searchBarTextField = nil;
    
    NSArray *views = ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) ? delegateSearchBar.subviews : [[delegateSearchBar.subviews objectAtIndex:0] subviews];
    
    for (UIView *subview in views)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchBarTextField = (UITextField *)subview;
            break;
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

- (IBAction)searchScopeChanged:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self clearResults];
    
    if (searchScope.selectedSegmentIndex == 0) { //We're searching shoes
        filtersButton.hidden = NO; //Show the filters button
    }
    else { //We're searching Users
        filtersButton.hidden = YES; //We don't have any filters for username searches; hide the filters button
    }
    
    [self populateResultsView:YES];
}

- (IBAction)sortButtonPressed:(UIButton *)sender {
    ActionSheetStringPicker * sortPicker;
    if (searchScope.selectedSegmentIndex == 0) { //We're searching shoes
        NSArray * itemSortOptions = [NSArray arrayWithObjects:@"Newest",
                                                            @"Oldest",
                                                            @"Price - Least Expensive",
                                                            @"Price - Most Expensive",
                                                            @"Size - Smallest First",
                                                            @"Size - Largest First", nil];
        
        sortPicker = [[ActionSheetStringPicker alloc]
                                                initWithTitle:@"Sort By"
                                                         rows:itemSortOptions
                                             initialSelection:currentItemSort
                                                    doneBlock:^(ActionSheetStringPicker * picker, NSInteger selectedIndex, id selectedValue) {
                                                        currentItemSort = selectedIndex;
                                                        [self populateResultsView:YES];
                                                    }
                                                  cancelBlock:nil
                                                       origin:sender];
    } else {
        NSArray * usernameSortOptions = [NSArray arrayWithObjects:@"Alphabetically",
                                                           @"Newest Members First",
                                                           @"Oldest Members First",
                                                           nil];
        sortPicker = [[ActionSheetStringPicker alloc]
                                              initWithTitle:@"Sort By"
                                              rows:usernameSortOptions
                                              initialSelection:currentUsernameSort
                                              doneBlock:^(ActionSheetStringPicker * picker, NSInteger selectedIndex, id selectedValue) {
                                                  currentUsernameSort = selectedIndex;
                                                  [self populateResultsView:YES];
                                              }
                                              cancelBlock:nil
                                              origin:sender];        
    }
    
    [sortPicker setDoneButton:[[UIBarButtonItem alloc] initWithTitle:@"Select"  style:UIBarButtonItemStylePlain target:nil action:nil]];
    [sortPicker showActionSheetPicker];
}

- (IBAction)filtersButtonPressed:(UIButton *)sender
{
    [additionalFilterScope setSegmentedControlStyle:UISegmentedControlNoSegment];
    
    //Hide the keyboard, if it isn't hidden
    [searchBar resignFirstResponder];
    
    UIView * filtersView = [[[NSBundle mainBundle] loadNibNamed:@"RLFiltersView" owner:self options:nil] objectAtIndex:0];
    
    JGActionSheetSection * filtersMenu = [JGActionSheetSection sectionWithTitle:@"Filters" message:nil contentView:filtersView];
    
    JGActionSheetSection * doneClearButtons = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Done", @"Clear Filters"] buttonStyle:JGActionSheetButtonStyleDefault];
    
    [doneClearButtons setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:0];
    [doneClearButtons setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:1];
    
    JGActionSheet * filtersActionSheet = [JGActionSheet actionSheetWithSections:@[filtersMenu, doneClearButtons]];
    filtersActionSheet.insets = UIEdgeInsetsMake(10.0f, 0.0f, 42.0f, 0.0f);
    [filtersActionSheet showInView:self.navigationController.view animated:YES];
    
    [filtersActionSheet setOutsidePressBlock:^(JGActionSheet *sheet) {
        [sheet dismissAnimated:YES];
    }];
    
    //<done button> or <clear filter> button event
    [filtersActionSheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        //progressing...
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.labelText = @"Processing";
        
        if (indexPath.row == 1) { //The user opted to clear filters
            [self initializeFilterDicts];
        }
        
        if ([self filtersAreOn]) {
            [filtersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            filtersButton.backgroundColor = [RLUtils relacedRed];
        }
        else {
            [filtersButton setTitleColor:[RLUtils relacedRed] forState:UIControlStateNormal];
            filtersButton.backgroundColor = [UIColor clearColor];
        }
        
        [sheet dismissAnimated:YES];
        [self populateResultsView:YES];
        
        [hud hide:YES];
    }];
}

- (IBAction)filtersScopeChanged:(UISegmentedControl *)sender
{
    [additionalFilterScope setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
    [filtersTableView reloadData];
    [filtersTableView setContentOffset:CGPointZero animated:YES];

}

- (IBAction)additionalFilterScopeChanged:(UISegmentedControl *)sender {
    [filtersScope setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
    [filtersTableView reloadData];
    [filtersTableView setContentOffset:CGPointZero animated:YES];
    
}

- (void)populateResultsView:(BOOL)newSearch
{
    NSString * searchKey = [searchBar.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([searchKey isEqualToString:@""]) {
        searchBar.placeholder = (searchScope.selectedSegmentIndex == 0) ? @"(Searching Everything)" : @"(Searching Everyone)";
    }
    
    if (workingQuery != nil) {
        [workingQuery cancel];
    }
    
    if (searchScope.selectedSegmentIndex == 0) { //We're searching shoes
        workingQuery = [PFQuery queryWithClassName:kRLPhotoClass];
        [self generateFiltersForWorkingQueryWithSearchKey:searchKey];
    }
    else { //We're searching users
        workingQuery = [PFQuery queryWithClassName:kRLUserClass];
        [workingQuery whereKey:kRLLowercaseNameKey containsString:searchKey];
    }
    
    [self generateSortOrderForWorkingQuery];
    
    workingQuery.limit = queryLimit;
    
    loading = YES;
    
    if (newSearch) {
        [self clearResults];
    }
    else {
        workingQuery.skip = [results count];
    }

    totalNumberOfResults = [workingQuery countObjects];
    
    if (totalNumberOfResults == -1)
        numResultsLabel.text = @"Hmmm, an error occurred - try searching again.";
    else
        numResultsLabel.text = [NSString stringWithFormat:@"%ld Results", (long)totalNumberOfResults];
    NSLog(@"%@", numResultsLabel.text);

    if (numResultsLabel.hidden)
        numResultsLabel.hidden = NO;
    
    [workingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        loading = NO;
        if (error) {
            NSLog(@"A Parse error occurred retrieving search results.");
        }
        else {
            [results addObjectsFromArray:objects];
            [resultsTableView reloadData];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //The scroll view is the filters options menu
    if (scrollView.tag) {
        return;
    }
    
    [searchBar resignFirstResponder];
    if (!loading && [self moreResultsExist] && scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height - 40) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSLog(@"Reached Bottom");
        [self populateResultsView:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag) {
        return 45.0;
    }
    return 85.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag)
    {
        NSInteger cellCount = 0;
        if (filtersScope.selectedSegmentIndex == 0) //We're in the size filters sub menu
            cellCount = [sizeFilterToIsSelectedDict count];
        else if (filtersScope.selectedSegmentIndex == 1) //We're in the price filters sub menu
            cellCount = [priceFilterToIsSelectedDict count];
        else if (filtersScope.selectedSegmentIndex == 2) //We're in the sold filters sub menu
            cellCount = [soldFilterToIsSelectedDict count];
        else if (filtersScope.selectedSegmentIndex == 3) //We're in the category filters sub menu
            cellCount = [categoryFilterToIsSelectedDict count];
        else if (additionalFilterScope.selectedSegmentIndex == 0) //We're in the color filters sub menu
            cellCount = [colorFilterToIsSelectedDict count];
        else if (additionalFilterScope.selectedSegmentIndex == 1) //We're in the brand filters sub menu
            cellCount = [brandFilterToIsSelectedDict count];
        else if (additionalFilterScope.selectedSegmentIndex == 2) //We're in the condition filters sub menu
            cellCount = [conditionFilterToIsSelectedDict count];
        
        NSLog(@"%ld", (long)cellCount);
        return cellCount;
    }
    
    return results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;

    if (tableView.tag) {
        if ([filtersScope selectedSegmentIndex] != UISegmentedControlNoSegment) {
            [additionalFilterScope setSelectedSegmentIndex:UISegmentedControlNoSegment];
        }
        
        static NSString * filterCellIdentifier = @"FilterCell";
        cell = [tableView dequeueReusableCellWithIdentifier:filterCellIdentifier];

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:filterCellIdentifier];
        }
        
        M13MutableOrderedDictionary * workingFiltersDict = nil;
        if ([filtersScope selectedSegmentIndex] != UISegmentedControlNoSegment) {
            if (filtersScope.selectedSegmentIndex == 0) //We're in the size filters sub menu
                workingFiltersDict = sizeFilterToIsSelectedDict;
            else if (filtersScope.selectedSegmentIndex == 1) //We're in the price filters sub menu
                workingFiltersDict = priceFilterToIsSelectedDict;
            else if (filtersScope.selectedSegmentIndex == 2) //We're in the sold filters sub menu
                workingFiltersDict = soldFilterToIsSelectedDict;
            else if (filtersScope.selectedSegmentIndex == 3) //We're in the category filters sub menu
                workingFiltersDict = categoryFilterToIsSelectedDict;
        }

        if ([additionalFilterScope selectedSegmentIndex] != UISegmentedControlNoSegment) {
            if (additionalFilterScope.selectedSegmentIndex == 0) //We're in the color filters sub menu
                workingFiltersDict = colorFilterToIsSelectedDict;
            else if (additionalFilterScope.selectedSegmentIndex == 1) //We're in the brand filters sub menu
                workingFiltersDict = brandFilterToIsSelectedDict;
            else if (additionalFilterScope.selectedSegmentIndex == 2) //We're in the condition filters sub menu
                workingFiltersDict = conditionFilterToIsSelectedDict;
        }
        
        if ([[workingFiltersDict objectAtIndex:indexPath.row] isEqual:@YES]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = (NSString*)[workingFiltersDict keyAtIndex:indexPath.row];
        return cell;
    }
    
    static NSString * searchCellIdentifier = @"SearchCell";
    cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    
    if (cell == nil) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"PAPSearchCell" owner:nil options:nil];
        cell = (PAPSearchCell *)[nib objectAtIndex:0];
    }
    
    if (indexPath.row < [results count]) {
        [(PAPSearchCell *)cell generateSearchCell:[results objectAtIndex:indexPath.row] withType:[searchScope titleForSegmentAtIndex:searchScope.selectedSegmentIndex]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag) {
        M13MutableOrderedDictionary * workingFiltersDict = nil;
        if (filtersScope.selectedSegmentIndex == 0) //We're in the size filters sub menu
            workingFiltersDict = sizeFilterToIsSelectedDict;
        else if (filtersScope.selectedSegmentIndex == 1) //We're in the price filters sub menu
            workingFiltersDict = priceFilterToIsSelectedDict;
        else if (filtersScope.selectedSegmentIndex == 2) //We're in the sold filters sub menu
            workingFiltersDict = soldFilterToIsSelectedDict;
        else if (filtersScope.selectedSegmentIndex == 3) //We're in the category filters sub menu
            workingFiltersDict = categoryFilterToIsSelectedDict;
        else if (additionalFilterScope.selectedSegmentIndex == 0) //We're in the color filters sub menu
            workingFiltersDict = colorFilterToIsSelectedDict;
        else if (additionalFilterScope.selectedSegmentIndex == 1) //We're in the brand filters sub menu
            workingFiltersDict = brandFilterToIsSelectedDict;
        else if (additionalFilterScope.selectedSegmentIndex == 2) //We're in the condition filters sub menu
            workingFiltersDict = conditionFilterToIsSelectedDict;
        
        if ([[workingFiltersDict objectAtIndex:indexPath.row]  isEqual:@NO]) {
            [workingFiltersDict setObject:@YES forKey:[workingFiltersDict keyAtIndex:indexPath.row] atIndex:indexPath.row];
        }
        else {
            [workingFiltersDict setObject:@NO forKey:[workingFiltersDict keyAtIndex:indexPath.row] atIndex:indexPath.row];
        }
        
        [tableView reloadData];
        
        return;
    }
    
    [searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController * resultViewController;
    if (searchScope.selectedSegmentIndex == 0) { //The user clicked a shoe result
        resultViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:[results objectAtIndex:indexPath.row]];
        [self.tabBarController.navigationController pushViewController:resultViewController animated:YES];
    }
    else { //The user clicked a user result
        resultViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
        PFUser * user = [results objectAtIndex:indexPath.row];
        [(PAPAccountViewController*)resultViewController setUser:user];
        [self.navigationController pushViewController:resultViewController animated:YES];
    }
}

- (BOOL)moreResultsExist
{
    return results.count < totalNumberOfResults;
}

- (void)clearResults
{
    totalNumberOfResults = 0;
    [results removeAllObjects];
    [resultsTableView reloadData];
}

- (void)generateSortOrderForWorkingQuery
{
    if (searchScope.selectedSegmentIndex == 0) { //We're searching shoes
        //Determine the sort order for the shoe items
        switch (currentItemSort) {
            case kNewest:
                [workingQuery orderByDescending:kRLUpdatedAtKey];
                break;
            case kOldest:
                [workingQuery orderByAscending:kRLUpdatedAtKey];
                break;
            case kPriceAsc:
                [workingQuery orderByAscending:kRLPriceKey];
                break;
            case kPriceDesc:
                [workingQuery orderByDescending:kRLPriceKey];
                break;
            case kSizeAsc:
                [workingQuery orderByAscending:kRLSizeKey];
                break;
            case kSizeDesc:
                [workingQuery orderByDescending:kRLSizeKey];
                break;
            default:
                [workingQuery orderByDescending:kRLUpdatedAtKey];  //Should never reach this case, but we'll make the default sort be by "newest" if we do
                break;
        }
    }
    else { //We're searching users
        switch (currentUsernameSort) {
            case kAlphabetically:
                [workingQuery orderByAscending:kPAPUserDisplayNameKey];
                break;
            case kJoinDateDesc:
                [workingQuery orderByDescending:kRLCreatedAtKey];
                break;
            case kJoinDateAsc:
                [workingQuery orderByAscending:kRLCreatedAtKey];
                break;
            default:
                [workingQuery orderByDescending:kPAPUserDisplayNameKey];  //Should never reach this case, but we'll make the default sort be alphabetical if we do
                break;
        }
    }
}

- (void)generateFiltersForWorkingQueryWithSearchKey:(NSString *) searchKey
{
    NSArray * sizeFilterToIsSelectedDictAllValues = [sizeFilterToIsSelectedDict allObjects];
    NSArray * priceFilterToIsSelectedDictAllValues = [priceFilterToIsSelectedDict allObjects];
    NSArray * soldFilterToIsSelectedDictAllValues = [soldFilterToIsSelectedDict allObjects];
    NSArray * categoryFilterToIsSelectedDictAllValues = [categoryFilterToIsSelectedDict allObjects];
    NSArray * colorFilterToIsSelectedDictAllValues = [colorFilterToIsSelectedDict allObjects];
    NSArray * brandFilterToIsSelectedDictAllValues = [brandFilterToIsSelectedDict allObjects];
    NSArray * conditionFilterToIsSelectedDictAllValues = [conditionFilterToIsSelectedDict allObjects];
    
    
    if ([self filtersAreOn]) {
        
        //Configure the Size Filters
//        NSMutableArray * sizeOrSubQueries = [NSMutableArray new];
//        
//        if ([[sizeFilterToIsSelectedDictAllValues objectAtIndex:6] isEqual:@YES]) {//less than 3
//            PFQuery * lessThan3Query = [PFQuery queryWithClassName:kRLPhotoClass];
//            [lessThan3Query whereKey:kRLSizeKey lessThan:@3];
//            [sizeOrSubQueries addObject:lessThan3Query];
//        }
//        
//        if ([[sizeFilterToIsSelectedDictAllValues objectAtIndex:[sizeFilterToIsSelectedDictAllValues count]-1] isEqual:@YES]) {//greater than 11
//            PFQuery * greaterThan17Query = [PFQuery queryWithClassName:kRLPhotoClass];
//            [greaterThan17Query whereKey:kRLSizeKey greaterThan:@11];
//            [sizeOrSubQueries addObject:greaterThan17Query];
//        }
//        
//        NSMutableArray * between3And17SelectedFilters = [NSMutableArray new];
//        for (NSUInteger i = 1; i < [sizeFilterToIsSelectedDictAllValues count] - 1; i++) {
//            if ([[sizeFilterToIsSelectedDictAllValues objectAtIndex:i] isEqual:@YES]) {
//                NSNumber * selectedSizeNumber = @([(NSString *)[sizeFilterToIsSelectedDict keyAtIndex:i] floatValue]);
//                [between3And17SelectedFilters addObject:selectedSizeNumber];
//            }
//        }
//        
//        if ([between3And17SelectedFilters count]) {
//            PFQuery * between3And17Query = [PFQuery queryWithClassName:kRLPhotoClass];
//            [between3And17Query whereKey:kRLSizeKey containedIn:between3And17SelectedFilters];
//            [sizeOrSubQueries addObject:between3And17Query];
//        }
        NSMutableArray * sizeSubQueries = [NSMutableArray new];
        
        NSMutableArray * sizeSelectedFilters = [NSMutableArray new];
        for (NSUInteger i = 0; i < [sizeFilterToIsSelectedDict count]; i++) {
            if ([[sizeFilterToIsSelectedDictAllValues objectAtIndex:i] isEqual:@YES]) {
                NSString * selectedSize = (NSString *)[sizeFilterToIsSelectedDict keyAtIndex:i];
                [sizeSelectedFilters addObject:selectedSize];
            }
        }
        
        if ([sizeSelectedFilters count]) {
            PFQuery * selectedSizeQuery = [PFQuery queryWithClassName:kRLPhotoClass];
            [selectedSizeQuery whereKey:kRLSizeKey containedIn:sizeSelectedFilters];
            [sizeSubQueries addObject:selectedSizeQuery];
        }
        
        //Configure the Sold Filters
        //For some reason, the order in which these sub queries are added to soldOrSubQueries matters???
        //Unless I'm missing something, this seems like a huge Parse bug
        NSMutableArray * soldOrSubQueries = [NSMutableArray new];
        
        if ([[soldFilterToIsSelectedDictAllValues objectAtIndex:0] isEqual:@YES]) {
            PFQuery * alreadySoldQuery = [PFQuery queryWithClassName:kRLPhotoClass];
            [alreadySoldQuery whereKey:kRLIsSoldKey equalTo:@"1"];
            [soldOrSubQueries addObject:alreadySoldQuery];
        }
        
        if ([[soldFilterToIsSelectedDictAllValues objectAtIndex:1] isEqual:@YES]) {
            PFQuery * notYetSoldQuery = [PFQuery queryWithClassName:kRLPhotoClass];
            [notYetSoldQuery whereKey:kRLIsSoldKey notEqualTo:@"1"];
            [soldOrSubQueries addObject:notYetSoldQuery];
        }
        
        //Configure the Category Filters
        //For some reason, the order in which these sub queries are added to soldOrSubQueries matters???
        //Unless I'm missing something, this seems like a huge Parse bug
        NSMutableArray * categorySubQueries = [NSMutableArray new];
        
        NSMutableArray * categorySelectedFilters = [NSMutableArray new];
        for (NSUInteger i = 0; i < [categoryFilterToIsSelectedDict count]; i++) {
            if ([[categoryFilterToIsSelectedDictAllValues objectAtIndex:i] isEqual:@YES]) {
                NSString * selectedCategory = (NSString *)[categoryFilterToIsSelectedDict keyAtIndex:i];
                [categorySelectedFilters addObject:selectedCategory];
            }
        }
        
        if ([categorySelectedFilters count]) {
            PFQuery * selectedCategoryQuery = [PFQuery queryWithClassName:kRLPhotoClass];
            [selectedCategoryQuery whereKey:kRLCategoryKey containedIn:categorySelectedFilters];
            [categorySubQueries addObject:selectedCategoryQuery];
        }
        
        //Configure the Color Filters
        //For some reason, the order in which these sub queries are added to soldOrSubQueries matters???
        //Unless I'm missing something, this seems like a huge Parse bug
        NSMutableArray * colorSubQueries = [NSMutableArray new];
        
        NSMutableArray * colorSelectedFilters = [NSMutableArray new];
        for (NSUInteger i = 0; i < [colorFilterToIsSelectedDict count]; i++) {
            if ([[colorFilterToIsSelectedDictAllValues objectAtIndex:i] isEqual:@YES]) {
                NSString * selectedColor = (NSString *)[colorFilterToIsSelectedDict keyAtIndex:i];
                [colorSelectedFilters addObject:selectedColor];
            }
        }
        
        if ([colorSelectedFilters count]) {
            PFQuery * selectedColorQuery = [PFQuery queryWithClassName:kRLPhotoClass];
            [selectedColorQuery whereKey:kRLColorKey containedIn:colorSelectedFilters];
            [colorSubQueries addObject:selectedColorQuery];
        }
        
        //Configure the Brand Filters
        //For some reason, the order in which these sub queries are added to soldOrSubQueries matters???
        //Unless I'm missing something, this seems like a huge Parse bug
        NSMutableArray * brandSubQueries = [NSMutableArray new];
        
        NSMutableArray * brandSelectedFilters = [NSMutableArray new];
        for (NSUInteger i = 0; i < [brandFilterToIsSelectedDict count]; i++) {
            if ([[brandFilterToIsSelectedDictAllValues objectAtIndex:i] isEqual:@YES]) {
                NSString * selectedBrand = (NSString *)[brandFilterToIsSelectedDict keyAtIndex:i];
                [brandSelectedFilters addObject:selectedBrand];
            }
        }
        
        if ([brandSelectedFilters count]) {
            PFQuery * selectedBrandQuery = [PFQuery queryWithClassName:kRLPhotoClass];
            [selectedBrandQuery whereKey:kRLBrandKey containedIn:brandSelectedFilters];
            [brandSubQueries addObject:selectedBrandQuery];
        }
        
        //Configure the Condition Filters
        //For some reason, the order in which these sub queries are added to soldOrSubQueries matters???
        //Unless I'm missing something, this seems like a huge Parse bug
        NSMutableArray * conditionSubQueries = [NSMutableArray new];
        
        NSMutableArray * conditionSelectedFilters = [NSMutableArray new];
        for (NSUInteger i = 0; i < [conditionFilterToIsSelectedDict count]; i++) {
            if ([[conditionFilterToIsSelectedDictAllValues objectAtIndex:i] isEqual:@YES]) {
                NSString * selectedCondition = (NSString *)[conditionFilterToIsSelectedDict keyAtIndex:i];
                [conditionSelectedFilters addObject:selectedCondition];
            }
        }
        
        if ([conditionSelectedFilters count]) {
            PFQuery * selectedConditionQuery = [PFQuery queryWithClassName:kRLPhotoClass];
            [selectedConditionQuery whereKey:kRLConditionKey containedIn:conditionSelectedFilters];
            [conditionSubQueries addObject:selectedConditionQuery];
        }
        
        //Configure the Price Filters
        NSMutableArray * priceOrSubQueries = [NSMutableArray new];
        
        if ([[priceFilterToIsSelectedDictAllValues objectAtIndex:0] isEqual:@YES]) {
            PFQuery * lessThan20Dollars = [PFQuery queryWithClassName:kRLPhotoClass];
            [lessThan20Dollars whereKey:kRLPriceKey lessThan:@20];
            [priceOrSubQueries addObject:lessThan20Dollars];
        }
        
        if ([[priceFilterToIsSelectedDictAllValues objectAtIndex:[priceFilterToIsSelectedDictAllValues count]-1] isEqual:@YES]) {
            PFQuery * greaterThanOrEqualTo1000Dollars = [PFQuery queryWithClassName:kRLPhotoClass];
            [greaterThanOrEqualTo1000Dollars whereKey:kRLPriceKey greaterThanOrEqualTo:@1000];
            [priceOrSubQueries addObject:greaterThanOrEqualTo1000Dollars];
        }
        
        for (NSUInteger i = 1; i < [priceFilterToIsSelectedDictAllValues count] - 1; i++) {
            if ([[priceFilterToIsSelectedDictAllValues objectAtIndex:i] isEqual:@YES]) {
                NSString * priceRangeKey = (NSString*)[priceFilterToIsSelectedDict keyAtIndex:i];
                NSArray * priceRangeArray = [[priceRangeKey substringFromIndex:1] componentsSeparatedByString:@" - $"];
                
                NSNumber * lowPrice = @([[priceRangeArray objectAtIndex:0] intValue]);
                NSNumber * highPrice = @([[priceRangeArray objectAtIndex:1] intValue]);
                
                PFQuery * selectedPriceRange = [PFQuery queryWithClassName:kRLPhotoClass];
                [selectedPriceRange whereKey:kRLPriceKey greaterThanOrEqualTo:lowPrice];
                [selectedPriceRange whereKey:kRLPriceKey lessThan:highPrice];
                
                [priceOrSubQueries addObject:selectedPriceRange];
            }
        }
        
        PFQuery * sizeFilterSubQuery = [PFQuery orQueryWithSubqueries:sizeSubQueries];
        PFQuery * soldFilterSubQuery = [PFQuery orQueryWithSubqueries:soldOrSubQueries];
        PFQuery * priceFilterSubQuery = [PFQuery orQueryWithSubqueries:priceOrSubQueries];
        PFQuery * categoryFilterSubQuery = [PFQuery orQueryWithSubqueries:categorySubQueries];
        PFQuery * colorFilterSubQuery = [PFQuery orQueryWithSubqueries:colorSubQueries];//-----color
        PFQuery * brandFilterSubQuery = [PFQuery orQueryWithSubqueries:brandSubQueries];//-----brand
        PFQuery * conditionFilterSubQuery = [PFQuery orQueryWithSubqueries:conditionSubQueries];//----condition
        
        [sizeFilterSubQuery whereKey:kPAPPhotoLowerDescriptionKey containsString:searchKey];
        [soldFilterSubQuery whereKey:kPAPPhotoLowerDescriptionKey containsString:searchKey];
        [priceFilterSubQuery whereKey:kPAPPhotoLowerDescriptionKey containsString:searchKey];
        [categoryFilterSubQuery whereKey:kPAPPhotoLowerDescriptionKey containsString:searchKey];
        [colorFilterSubQuery whereKey:kPAPPhotoLowerDescriptionKey containsString:searchKey];//----color
        [brandFilterSubQuery whereKey:kPAPPhotoLowerDescriptionKey containsString:searchKey];//----brand
        [conditionFilterSubQuery whereKey:kPAPPhotoLowerDescriptionKey containsString:searchKey];//----condition
        
        if ([sizeSubQueries count])
            [workingQuery whereKey:kRLSizeKey matchesKey:kRLSizeKey inQuery:sizeFilterSubQuery];
        if ([soldOrSubQueries count])
            [workingQuery whereKey:kRLIsSoldKey matchesKey:kRLIsSoldKey inQuery:soldFilterSubQuery];
        if ([priceOrSubQueries count])
            [workingQuery whereKey:kRLPriceKey matchesKey:kRLPriceKey inQuery:priceFilterSubQuery];
        if ([categorySubQueries count])
            [workingQuery whereKey:kRLCategoryKey matchesKey:kRLCategoryKey inQuery:categoryFilterSubQuery];
        if ([colorSubQueries count])
            [workingQuery whereKey:kRLColorKey matchesKey:kRLColorKey inQuery:colorFilterSubQuery];
        if ([brandSubQueries count])
            [workingQuery whereKey:kRLBrandKey matchesKey:kRLBrandKey inQuery:brandFilterSubQuery];
        if ([conditionSubQueries count])
            [workingQuery whereKey:kRLConditionKey matchesKey:kRLConditionKey inQuery:conditionFilterSubQuery];
    }
    else {
        NSLog(@"No Filters");
    }
    
    [workingQuery whereKey:kPAPPhotoLowerDescriptionKey containsString:searchKey];
}

- (BOOL)filtersAreOn
{
    if ([[sizeFilterToIsSelectedDict allObjects] containsObject:@YES] ||
        [[priceFilterToIsSelectedDict allObjects] containsObject:@YES] ||
        [[categoryFilterToIsSelectedDict allObjects] containsObject:@YES] ||
        [[soldFilterToIsSelectedDict allObjects] containsObject:@YES] ||
        [[colorFilterToIsSelectedDict allObjects] containsObject:@YES] ||
        [[brandFilterToIsSelectedDict allObjects] containsObject:@YES] ||
        [[conditionFilterToIsSelectedDict allObjects] containsObject:@YES]) {
        return YES;
    }
    else return NO;

}

@end
