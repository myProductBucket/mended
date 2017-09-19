#import "VenueModel.h"

@implementation VenueModel

@synthesize name;
@synthesize longitude;
@synthesize latitude;
@synthesize title;
@synthesize coordinate;

-  (id)initWithDictionary:(NSDictionary *)aDictionary
{
    self = [super init];
    
    if(self)
    {
        NSString *venueName = [aDictionary valueForKeyPath:@"venue.name"];
//        NSLog(@"%@", aDictionary);
        if([venueName isKindOfClass:[NSString class]])
            self.name = venueName;
        else
            self.name = @"";
        NSString *strLatitude =  [aDictionary valueForKeyPath:@"venue.location.lat"];
        NSString *strLongitude =  [aDictionary valueForKeyPath:@"venue.location.lng"];
        CLLocationCoordinate2D cordinate;
        cordinate.latitude = strLatitude.doubleValue;
        cordinate.longitude = strLongitude.doubleValue;
        self.latitude = strLatitude.doubleValue;
        self.longitude = strLongitude.doubleValue;
        self.coordinate = cordinate;
        self.title = self.name;
        self.index = [aDictionary valueForKeyPath:@"venue.id"];
    }
    
    return self;
}

- (void) dealloc{
    self.name = nil;
    [super dealloc];
}
@end
