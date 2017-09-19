//
//  PAPSearchCell.m
//  Relaced
//
//  Created by Qibo Fu on 8/5/13.
//
//

#import <ParseUI/ParseUI.h>
#import "PAPSearchCell.h"
#import "DELocationManager.h"
#import "TTTTimeIntervalFormatter.h"
#import "RLUtils.h"
#import "PAPConstants.h"
#import "PAPUtility.h"

#define METERS_PER_MILE 1609.34

@implementation PAPSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)generateSearchCell:(PFObject *)result withType:(NSString *)type
{
    if ([type isEqualToString:@"Listings"]) {
        titleLabel.text = [result objectForKey:kPAPPhotoTitleKey];
//        leftSubtitleLabel.text = [NSString stringWithFormat:@"Size: %@", [result objectForKey:kPAPPhotoSizeKey]];
        leftSubtitleLabel.text = [NSString stringWithFormat:@"$%@", [result objectForKey:kPAPPhotoPriceKey]];
        leftSubtitleLabel.hidden = NO;
        rightSubtitleLabel.hidden = YES;
        bottomSubtitleLabel.hidden = NO;
        NSString * timePosted = [[[TTTTimeIntervalFormatter alloc] init] stringForTimeIntervalFromDate:[NSDate date] toDate:[result updatedAt]];
        if ([timePosted length] != 0) {
            bottomSubtitleLabel.text = [NSString stringWithFormat:@"Last Updated: %@", timePosted];
        }
        else {
            bottomSubtitleLabel.hidden = YES;
        }
        
        if  ([[result objectForKey:kPAPPhotoIsSoldKey] isEqualToString:@"1"]) {
            rightSubtitleLabel.text = [NSString stringWithFormat:@"$%@ (Mended)", [result objectForKey:kPAPPhotoPriceKey]];
            [rightSubtitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
            rightSubtitleLabel.textColor = [UIColor whiteColor];
            rightSubtitleLabel.backgroundColor = [RLUtils relacedRed];
            [rightSubtitleLabel sizeToFit];
        } else {
            rightSubtitleLabel.text = [NSString stringWithFormat:@"$%@", [result objectForKey:kPAPPhotoPriceKey]];
            [rightSubtitleLabel setFont:[UIFont systemFontOfSize:14]];
            rightSubtitleLabel.textColor = [UIColor blackColor];
            rightSubtitleLabel.backgroundColor = [UIColor clearColor];
            [rightSubtitleLabel sizeToFit];
        }
        
        PFFile *thumbFile = [result objectForKey:kPAPPhotoThumbnailKey];
        photoView.image = [UIImage imageNamed:@"placeholderPhoto.png"];
        photoView.file = thumbFile;
        [photoView loadInBackground];
    }
    else if ([type isEqualToString:@"Users"]) {
        titleLabel.text = [result objectForKey:kPAPUserDisplayNameKey];
        leftSubtitleLabel.font = [leftSubtitleLabel.font fontWithSize:12];
        leftSubtitleLabel.text = [NSString stringWithFormat:@"Member Since: %@", [PAPUtility dateToFormattedString:result.createdAt]];
        rightSubtitleLabel.hidden = YES;
        bottomSubtitleLabel.hidden = YES;
        PFFile * thumbFile = [result objectForKey:kPAPUserProfilePicMediumKey];
        photoView.image = [UIImage imageNamed:@"placeholderPhoto.png"];
        photoView.file = thumbFile;
        [photoView loadInBackground];
    }
    //Some location-related code.  Can we reuse this later? -Benjamin M.
//    locationLabel.text = [object objectForKey:@"locationName"];
//    if ([locationLabel.text isEqualToString:@""]) {
//        locationIcon.hidden = YES;
//    }
//    else {
//        locationIcon.hidden = NO;
//    }

//    PFGeoPoint *geoPoint = [object objectForKey:kPAPPhotoLocationKey];
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
//    CGFloat distance = [location distanceFromLocation:[DELocationManager sharedManager].mostRecentLocation];
//    distanceLabel.text = [NSString stringWithFormat:@"%0.1f miles away", distance / METERS_PER_MILE];
}

@end
