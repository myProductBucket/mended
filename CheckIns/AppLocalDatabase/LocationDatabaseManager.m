//
//  DatabseManager.m
//  Paw Prints
//
//  Created by Lion on 4/7/13.
//  Copyright (c) 2013 Lion. All rights reserved.
//

#import "LocationDatabaseManager.h"
static LocationDatabaseManager *_sharedDatabaseManager = nil;

@implementation LocationDatabaseManager

+ (LocationDatabaseManager*) shared
{
    if (_sharedDatabaseManager == nil)
    {
        _sharedDatabaseManager = [[LocationDatabaseManager alloc] init];
    }
    return _sharedDatabaseManager;
}


- (void) createCustomLocation:(NSString*) locationString longitude:(double) longitude latitude:(double) latitude
{
    NSMutableArray *arr = (NSMutableArray*)([[NSUserDefaults standardUserDefaults] objectForKey:@"custom_location_arr"]);
    if (arr == nil)
        arr = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: locationString, @"Name",
                          [NSNumber numberWithDouble:longitude],@"longitude",
                          [NSNumber numberWithDouble:latitude], @"latitude",
                          nil];
    [arr addObject:dict];
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"custom_location_arr"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSArray*) getCustomLocationByString:(NSString*) str
{
    NSMutableArray *arr = (NSMutableArray*)([[NSUserDefaults standardUserDefaults] objectForKey:@"custom_location_arr"]);
    if (arr != nil)
    {
        NSMutableArray *arrR = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for (NSDictionary *dict in arr)
        {
            NSString *strName = [dict objectForKey:@"Name"];
            NSRange range = [strName rangeOfString:str];
            if ( range.length > 0)
            {
                [arrR addObject:dict];
            }
        }
        return arrR;
    }
    return nil;
}

- (BOOL) isLoctionStringMatched:(NSString*) str
{
    NSMutableArray *arr = (NSMutableArray*)([[NSUserDefaults standardUserDefaults] objectForKey:@"custom_location_arr"]);
    if (arr != nil)
    {
        for (NSDictionary *dict in arr)
        {
            NSString *strName = [dict objectForKey:@"Name"];
            
            if ([strName isEqualToString:str])
            {
                return YES;
            }
        }
    }
    return FALSE;
}
@end
