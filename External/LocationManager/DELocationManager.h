//
//  DELocationManager.h
//  ios
//
//  Created by Michael Dominick on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class DELocationManager;

@protocol DELocationManagerDelegate <NSObject>

- (void) deLocationManagerDidCancelLocation: (DELocationManager *)manager;
- (void) deLocationManager: (DELocationManager *)manager didUpdateToLocation: (CLLocation *)location;
- (void) deLocationManager: (DELocationManager *)manager didFailWithError: (NSError *)error;

@end


@interface DELocationManager : NSObject <CLLocationManagerDelegate> {
    
}

@property (nonatomic, assign) id <DELocationManagerDelegate> delegate;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocation* mostRecentLocation;
@property (nonatomic, strong) NSString* manualLocation;
@property (nonatomic, strong) NSDate* attemptStartedTimestamp;
@property (nonatomic) NSInteger numAttempts;
@property (nonatomic, assign) BOOL locationUpdated;
@property (nonatomic, strong) NSTimer *scheduledTimer;

+ (DELocationManager *) sharedManager;
+ (void) reset;

- (void) startUpdatingLocation;
- (void) promptForManualLocation: (NSString *)prompt;
- (void)refreshLocation;

@end
