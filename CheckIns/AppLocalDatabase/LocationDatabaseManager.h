//
//  DatabseManager.h
//  Paw Prints
//
//  Created by Lion on 4/7/13.
//  Copyright (c) 2013 Lion. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LocationDatabaseManager : NSObject
{
    
}

+ (LocationDatabaseManager*) shared;
- (void) createCustomLocation:(NSString*) locationString longitude:(double) longitude latitude:(double) latitude;
- (NSArray*) getCustomLocationByString:(NSString*) str;
- (BOOL) isLoctionStringMatched:(NSString*) str;
@end
