//
//  CheckInViewController.m
//  Paw Prints
//
//  Created by Lion on 4/6/13.
//  Copyright (c) 2013 Lion. All rights reserved.
//

#import "CheckInViewController.h"
#import "ConvenientPopups.h"
#import "FoursquareExploreModel.h"
#import "LocationDatabaseManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CheckInViewController ()
{
    FoursquareExploreModel *_exploreModel;
}
@end

@implementation CheckInViewController


@synthesize nearBySearchString;
@synthesize searchString;
@synthesize delegate;
@synthesize view_type;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (view_type == VIEW_FINDNEARBY)
    {
        [_tblFoursqureSearch setTableHeaderView:nil];
    }
    _mapView.delegate = self;
//    self.title = @"Select a location";
    
    self.navigationItem.title = @"Select a location"; // Added by Saleh
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(actionBack:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStyleDone target:self action:@selector(refreshTouchUp:)];
    
    [self refresh];
}

- (void) dealloc
{
    if (reqeustProcessor)
    {
        [reqeustProcessor release];
        reqeustProcessor = nil;
    }
    if (arrSearch)
    {
        [arrSearch release];
        arrSearch = nil;
    }
    self.searchString = nil;
    
    [super dealloc];
}

- (void)refreshTouchUp: (id)sender
{
    [self refresh];
}

- (void)refresh {
    [ConvenientPopups showNonBlockingPopupOnView:self.view withText:@"Finding..."];
    CLLocationManager*locationManager = [[[CLLocationManager alloc] init]autorelease];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [locationManager requestAlwaysAuthorization];
    
    [locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    // Configure the new event with information from the location
    if (location)
    {
        currentLocation = [location coordinate];
        [self locationFound:location isNew:TRUE];
    }
    else
    {
        [self locationNotFound];
    }
    //[[LocationManager instance] startWithDelegate:self implicitly:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void) actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
}


#pragma mark - LocationManagerDelegate

- (void)locationFound:(CLLocation*)location isNew:(BOOL)newLocation
{
    [self setupMapForLocatoion:location];
    [ConvenientPopups closeNonBlockingPopupOnView:self.view];
    [ConvenientPopups showNonBlockingPopupOnView:self.view withText:@"Fetching places..."];
    
    if ( reqeustProcessor)
    {
        [reqeustProcessor release];
        reqeustProcessor = nil;
    }
    reqeustProcessor = [[RequestProcessor alloc] init];
    reqeustProcessor.delegate = self;
    reqeustProcessor.successCallback = @selector(venuesLoaded:);
    reqeustProcessor.failCallback = @selector(venuesFailedToLoad:);
    if ( view_type == VIEW_NORMAL)
    {
        [reqeustProcessor getFoursquareVenuesForLocation:location
                                                  radius:@"50"
                                                   query:nil
                                             limitToFood:NO];
    }else
    {
        [reqeustProcessor getFoursquareVenuesForLocation:location
                                                  radius:@"50"
                                                   query:self.nearBySearchString
                                             limitToFood:NO];
    }
}

- (void)locationNotFound;
{
    [ConvenientPopups closeNonBlockingPopupOnView:self.view];
    [ConvenientPopups showAlertWithTitle:@"Error"
                              andMessage:@"This feature requires location autorization. Please go to Settings > General > Location Services and enable access for GearShift"];
    
}

#pragma mark - RequestProcessorDelegate

- (void)venuesLoaded:(RequestProcessor *)rp
{
    [ConvenientPopups closeNonBlockingPopupOnView:self.view];
    
    // Convert dictionary into a model
    if (_exploreModel)
    {
        [_exploreModel release];
        _exploreModel = nil;
    }
    _exploreModel = [[FoursquareExploreModel alloc] initWithDictionary:rp.processedJSON];
    NSLog(@"venues: %@", rp.processedJSON);
    
    [_tblFoursqureSearch reloadData];
    [self proccessAnnotations];
}

- (void)venuesFailedToLoad:(RequestProcessor *)rp
{
    [ConvenientPopups closeNonBlockingPopupOnView:self.view];
    [ConvenientPopups showToastLikeMessage:@"Error loading results from foursquare!" onView:self.view];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( _tblFoursqureSearch == tableView )
    {
        if(_exploreModel)
            return [_exploreModel.venues count]+1;
    }
    else
    {
        if (arrSearch)
        {
            if (isMatched)
                return [arrSearch count] +1;
            else
                return [arrSearch count] +2;
        }
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( _tblFoursqureSearch == tableView )
    {
        NSString *cellIdentifier = @"venue cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (indexPath.row < [_exploreModel.venues count])
        {
            VenueModel *currentItem = [_exploreModel.venues objectAtIndex:indexPath.row];
            cell.textLabel.text = currentItem.name;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            for (UIView *subView in cell.contentView.subviews)
            {
                if (subView == _viewFoursquareMark)
                    [_viewFoursquareMark removeFromSuperview];
            }
            // [cell.selectedBackgroundView willRemoveSubview:_viewFoursquareMark];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            [cell.contentView addSubview:_viewFoursquareMark];
        }
        return cell;
    }else
    {
        NSString *cellIdentifier = @"find cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if ( indexPath.row < [arrSearch count])
        {
            NSDictionary *dic = (NSDictionary*)[arrSearch objectAtIndex:indexPath.row];
            cell.textLabel.text = [dic objectForKey:@"Name"];
            cell.detailTextLabel.text = @"custom location";
            cell.imageView.image = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        else
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (isMatched)
            {
                cell.textLabel.text = [NSString stringWithFormat:@"Find '%@'", searchString];
                cell.detailTextLabel.text = @"Search for nearby places to meetup";
            }
            else
            {
                if ( indexPath.row == [arrSearch count])
                {
                    cell.textLabel.text = [NSString stringWithFormat:@"Find '%@'", searchString];
                    cell.detailTextLabel.text = @"Search more places nearby";
                }
                else
                {
                    cell.textLabel.text = [NSString stringWithFormat:@"Create '%@'", searchString];
                    cell.detailTextLabel.text = @"Create a custom meetup location";
                    cell.imageView.image = [UIImage imageNamed:@"pin"];
                    
                }
                
            }
        }
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tblFoursqureSearch)
    {
        if ([_exploreModel.venues count] > indexPath.row )
        {
            VenueModel *model = [_exploreModel.venues objectAtIndex:indexPath.row];
            if ([delegate respondsToSelector:@selector(checkinDidFinishWithVenue:)])
                [delegate checkinDidFinishWithVenue:model];
            [self.navigationController popViewControllerAnimated:TRUE];
        }
    }
    else
    {
        if ([arrSearch count] > indexPath.row)
        {
            NSDictionary *dic =  [arrSearch objectAtIndex:indexPath.row];
            NSString *strName = [dic objectForKey:@"Name"];
            NSNumber *longitude = [dic objectForKey:@"longitude"];
            NSNumber *latitude = [dic objectForKey:@"latitude"];
            if ([delegate respondsToSelector:@selector(checkinDidFinish:longitude:latitude:)])
                [delegate checkinDidFinish:strName longitude:longitude.doubleValue latitude:latitude.doubleValue];
            [self.navigationController popViewControllerAnimated:TRUE];
        }
        if ( indexPath.row == [arrSearch count])
        {
            // search more places ;
            CheckInViewController *controller = [[CheckInViewController alloc] initWithNibName:@"CheckInViewController" bundle:nil];
            controller.view_type = VIEW_FINDNEARBY;
            controller.nearBySearchString = searchString;
            controller.delegate = self.delegate;
            UINavigationController *navigation = [self.navigationController retain];
            [self.navigationController popViewControllerAnimated:NO];
            [navigation pushViewController:controller animated:TRUE];
            [navigation release];
        }
        if (indexPath.row == [arrSearch count] + 1)
        {
            //CLLocation *lastLocation = [[LocationManager instance] getLastLocation];
            //double longitude = lastLocation.coordinate.longitude;
            //double latitude = lastLocation.coordinate.latitude;
            double longitude = currentLocation.longitude;
            double latitude = currentLocation.latitude;
            
//            [[LocationDatabaseManager shared] createCustomLocation:searchString longitude:longitude latitude:latitude];
            if ([delegate respondsToSelector:@selector(checkinDidFinish:longitude:latitude:)])
                [delegate checkinDidFinish:searchString longitude:longitude latitude:latitude];
            [self.navigationController popViewControllerAnimated:TRUE];
        }
    }
}

# pragma search delegate
- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)_searchString
{
    if (arrSearch)
    {
        [arrSearch release];
        arrSearch = nil;
    }
    self.searchString = _searchString;
    arrSearch = (NSArray*)[[[LocationDatabaseManager shared] getCustomLocationByString:searchString] retain];
    isMatched = [[LocationDatabaseManager shared] isLoctionStringMatched:searchString];
    return YES;
}

# pragma MapView Functions
- (void) checkInButton
{
    VenueModel *model = _mapView.selectedAnnotations.lastObject;
    if ([delegate respondsToSelector:@selector(checkinDidFinishWithVenue:)])
        [delegate checkinDidFinishWithVenue:model];
    [self.navigationController popViewControllerAnimated:TRUE];
    
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if (annotation == mapView.userLocation)
        return nil;
    
    static NSString *s = @"ann";
    MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:s];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:s];
        pin.canShowCallout = YES;
        pin.image = [UIImage imageNamed:@"pin.png"];
        pin.calloutOffset = CGPointMake(0, 0);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self
                   action:@selector(checkInButton) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = button;
        
    }
    return pin;
}


-(void)removeAllAnnotationExceptOfCurrentUser
{
    NSMutableArray *annForRemove = [[NSMutableArray alloc] initWithArray:_mapView.annotations];
    if ([_mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
        [annForRemove removeObject:_mapView.annotations.lastObject];
    }else{
        for (id <MKAnnotation> annot_ in _mapView.annotations)
        {
            if ([annot_ isKindOfClass:[MKUserLocation class]] ) {
                [annForRemove removeObject:annot_];
                break;
            }
        }
    }
    
    
    [_mapView removeAnnotations:annForRemove];
}

-(void)proccessAnnotations{
    [self removeAllAnnotationExceptOfCurrentUser];
    [_mapView addAnnotations:_exploreModel.venues];
    
}

-(void)setupMapForLocatoion:(CLLocation*)newLocation{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.009;
    span.longitudeDelta = 0.009;
    CLLocationCoordinate2D location;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [_mapView setRegion:region animated:YES];
}



@end
