//
//  CheckInViewController.h
//  Paw Prints
//
//  Created by Lion on 4/6/13.
//  Copyright (c) 2013 Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
#import "RequestProcessor.h"
#import "VenueModel.h"

@protocol CheckInViewDelegate <NSObject>

- (void)checkinDidFinishWithVenue:(VenueModel *)locationVenue;
- (void)checkinDidFinish:(NSString*) name longitude:(double)longitude latitude:(double) latitude;

@end

enum VIEW_TYPE {
    VIEW_NORMAL = 1,
    VIEW_FINDNEARBY= 2
};
@interface CheckInViewController : UIViewController <LocationManagerDelegate, RequestProcessorDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,MKMapViewDelegate>
{
    IBOutlet UIView *_viewTblHeader;
    IBOutlet UITableView *_tblFoursqureSearch;
    IBOutlet UIView *_viewFoursquareMark;
    IBOutlet MKMapView *_mapView;
    
    RequestProcessor *reqeustProcessor;
    BOOL     isMatched;
    NSArray *arrSearch;
    NSString *searchString;
    CLLocationCoordinate2D currentLocation;
}
@property (nonatomic, assign) enum VIEW_TYPE view_type;
@property (nonatomic, retain) NSString *searchString;
@property (nonatomic, assign) id<CheckInViewDelegate> delegate;
@property (nonatomic, retain) NSString *nearBySearchString;
- (IBAction) actionBack:(id)sender;
@end
