//
//  DELocationManager.m
//  ios
//
//  Created by Michael Dominick on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DELocationManager.h"

@implementation DELocationManager
@synthesize mostRecentLocation, locationManager, manualLocation, attemptStartedTimestamp, numAttempts, delegate;
@synthesize scheduledTimer;

static DELocationManager* sharedManager = nil;

+ (DELocationManager *) sharedManager
{
    if (!sharedManager) {
        sharedManager = [[DELocationManager alloc] init];
    }
    return sharedManager;
}

+ (void) reset
{
    sharedManager = nil;
}

- (void) startUpdatingLocation
{
    self.locationUpdated = NO;
    self.numAttempts = 0;
    if ([CLLocationManager locationServicesEnabled]) {
        if (!self.locationManager) {
            self.locationManager = [[[CLLocationManager alloc] init] autorelease];
            [self.locationManager setDelegate:self];
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            [self.locationManager setPurpose:@"Mended needs your current location to find listings nearby"];
        }
        self.mostRecentLocation = nil;
        self.attemptStartedTimestamp = [NSDate date];
        
        [self refreshLocation];
        self.scheduledTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refreshLocation) userInfo:nil repeats:YES];
    } else {
        [self promptForManualLocation:@"Location services must be enabled to continue your search"];
    }
}

- (void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];
    [self.scheduledTimer invalidate];
}

- (void) promptForManualLocation:(NSString *)prompt
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Location Required" message:prompt delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    UITextField* textField = [[[UITextField alloc] initWithFrame:CGRectMake(22.0, 49.0, 240.0, 30.0)] autorelease];
    [textField setBackgroundColor:[UIColor clearColor]];
    [textField setPlaceholder:@"Your location"];
    [textField setBorderStyle:UITextBorderStyleBezel];
    [textField setText:self.manualLocation];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [alertView addSubview:textField];
    [alertView show];
    [textField becomeFirstResponder];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied) {
        if ([self.delegate respondsToSelector:@selector(deLocationManagerDidCancelLocation:)]) {
            [self.delegate deLocationManagerDidCancelLocation:self];
        }
        [self.locationManager stopUpdatingLocation];
    } else if ([error code] == kCLErrorLocationUnknown) {
        // the manager will keep trying, so this is ignored
    }
    else {
        if ([self.delegate respondsToSelector:@selector(deLocationManager:didFailWithError:)]) {
            [self.delegate deLocationManager:self didFailWithError:error];
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) {
        NSLog(@"the GPS has served a bad location from cache");
        // there is a known glitch in the coreLocation framework itslef, so we are checking timestamps to work around it.
        return;
    }
    if (newLocation.horizontalAccuracy < 0) {
        NSLog(@"GPS Error the location served is a bad measurement. Disregarding");
        return;
    }
    
    self.mostRecentLocation = newLocation;
    self.locationUpdated = YES;
    if ([self.delegate respondsToSelector:@selector(deLocationManager:didUpdateToLocation:)]) {
        [self.delegate deLocationManager:self didUpdateToLocation:newLocation];
    }
}

- (void)refreshLocation
{
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager performSelector:@selector(stopUpdatingLocation) withObject:nil afterDelay:10];
}

@end
