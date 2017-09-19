#import "FoursquareExploreModel.h"

@implementation FoursquareExploreModel

@synthesize venues;

-  (id)initWithDictionary:(NSDictionary *)aDictionary
{
    self = [super init];
    
    if(self)
    {
        NSArray *venuesWrap = [aDictionary valueForKeyPath:@"response.groups.items"];
        
        if([venuesWrap isKindOfClass:[NSArray class]] && [venuesWrap count])
        {
            NSArray *pvenues =  [venuesWrap objectAtIndex:0];
            
            if([pvenues isKindOfClass:[NSArray class]])
            {
                self.venues = [[NSMutableArray alloc] initWithCapacity:[pvenues count]];
                
                for(NSDictionary *venue in pvenues)
                {
                    if(![venue isKindOfClass:[NSDictionary class]])
                        continue;
                    
                    VenueModel *vm = [[VenueModel alloc] initWithDictionary:venue];
                    if(vm)
                        [self.venues addObject:vm];
                }
            }
        }
    }
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [self.venues removeAllObjects];
//    self.venues = nil;
}
@end
