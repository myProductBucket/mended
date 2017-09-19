//
//  PAPPhotoDetailsHeaderView.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PAPButton.h"

@protocol PAPPhotoDetailsHeaderViewDelegate;

@interface PAPPhotoDetailsHeaderView : UIView <CLLocationManagerDelegate, MKMapViewDelegate, UIScrollViewDelegate>

/*! @name Managing View Properties */

/// The photo displayed in the view
@property (nonatomic, strong) PFObject *photo;
/// The photo displayed in the view
@property (nonatomic, strong) PFObject *photo2;

/// The user that took the photo
@property (nonatomic, strong) PFUser *photographer;

/// Array of the users that liked the photo
@property (nonatomic, strong) NSArray *likeUsers;

/// Heart-shaped like button
@property (nonatomic, strong, readonly) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) IBOutlet UIButton *msgSellerBt;
//@property (nonatomic, strong) IBOutlet UITextField *commentField;

/*! @name Delegate */
@property (nonatomic, strong) id<PAPPhotoDetailsHeaderViewDelegate> delegate;

+ (CGRect)rectForViewWithDescription:(NSString *)description;

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto;
- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers;

- (void)setLikeButtonState:(BOOL)selected;
- (void)reloadLikeBar;
- (void)createView;
- (void)setBuyButtonAndPriceLabel;

- (IBAction)didTapLikePhotoButtonAction:(UIButton *)button;
- (IBAction)didTapUserNameButtonAction:(UIButton *)button;
- (IBAction)MessageToSellerButton:(UIButton *)sender;

@end

/*!
 The protocol defines methods a delegate of a PAPPhotoDetailsHeaderView should implement.
 */
@protocol PAPPhotoDetailsHeaderViewDelegate <NSObject>
@optional

- (void)photoDetailsView:(PAPPhotoDetailsHeaderView *)photoDetailsView didTapBuyButton:(UIButton *)button;

/*!
 Sent to the delegate when the photgrapher's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the photograper
 */
- (void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user;
- (void)photoDetailsView:(PAPPhotoDetailsHeaderView *)photoDetailsView didTapBuyOnPhotoButton:(UIButton *)button;

@end