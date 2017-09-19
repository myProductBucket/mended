//
//  RLSearchViewController.h
//  Relaced
//
//  Created by Benjamin Madueme on 11/9/14.
//
//

#import <Foundation/Foundation.h>
@class M13MutableOrderedDictionary;
@class PFQueryTableViewController;

typedef NS_ENUM(NSInteger, ItemSort) {
    kNewest,
    kOldest,
    kPriceAsc,
    kPriceDesc,
    kSizeAsc,
    kSizeDesc,
    kBrandAsc,
    kBrandDesc
};

typedef NS_ENUM(NSInteger, UsernameSort) {
    kAlphabetically,
    kJoinDateDesc,
    kJoinDateAsc
};

@interface RLSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    NSMutableArray * results;
    BOOL loading;
    NSInteger queryLimit;
    NSInteger totalNumberOfResults;
    ItemSort currentItemSort;
    UsernameSort currentUsernameSort;
    M13MutableOrderedDictionary * sizeFilterToIsSelectedDict;
    M13MutableOrderedDictionary * priceFilterToIsSelectedDict;
    M13MutableOrderedDictionary * soldFilterToIsSelectedDict;
    M13MutableOrderedDictionary * categoryFilterToIsSelectedDict;
    M13MutableOrderedDictionary * brandFilterToIsSelectedDict;//up-
    M13MutableOrderedDictionary * colorFilterToIsSelectedDict;//up-
    M13MutableOrderedDictionary * conditionFilterToIsSelectedDict;//up-
}

@property (weak, nonatomic) IBOutlet UISegmentedControl * searchScope;
@property (weak, nonatomic) IBOutlet UISearchBar * searchBar;
@property (weak, nonatomic) IBOutlet UILabel *numResultsLabel;
@property (weak, nonatomic) IBOutlet UITableView * resultsTableView;
@property (weak, nonatomic) IBOutlet UIButton * sortButton;
@property (weak, nonatomic) IBOutlet UIButton * filtersButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filtersScope;
@property (weak, nonatomic) IBOutlet UISegmentedControl *additionalFilterScope;//up-
@property (weak, nonatomic) IBOutlet UITableView *filtersTableView;
@property (nonatomic, retain) PFQueryTableViewController * queryTableViewController;
@property (nonatomic, retain) PFQuery * workingQuery;

@end
