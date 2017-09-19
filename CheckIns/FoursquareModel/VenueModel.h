/*
 A simple model for Foursquare venue - it can easily be extended to include other data
 */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface VenueModel : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) double latitude;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSString *index;

-  (id)initWithDictionary:(NSDictionary *)aDictionary;

@end
