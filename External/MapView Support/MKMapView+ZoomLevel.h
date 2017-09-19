//
//  MKMapView+ZoomLevel.h
//  JulyTPAManager
//
//  Created by A. K. M. Saleh Sultan on 11/12/12.
//
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end
