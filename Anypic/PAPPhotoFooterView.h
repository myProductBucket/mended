//
//  PAPPhotoFooterView.h
//  Relaced
//
//  Created by Qibo Fu on 8/23/13.
//
//

#import <UIKit/UIKit.h>
#import "PAPButton.h"

@class PAPPhotoFooterView;

@protocol PAPPhotoFooterViewDelegate <NSObject>

- (void)photoFooterView:(PAPPhotoFooterView *)photoFooterView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo;
- (void)photoFooterView:(PAPPhotoFooterView *)photoFooterView didTapCommentOnPhotoButton:(UIButton *)button photo:(PFObject *)photo;
- (void)photoFooterView:(PAPPhotoFooterView *)photoFooterView didTapBuyOnPhotoButton:(UIButton *)button photo:(PFObject *)photo;
// - (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

@end

@interface PAPPhotoFooterView : UIView

@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) IBOutlet UILabel *priceHolder;
@property (nonatomic, strong) IBOutlet UILabel *sizeLabel;

@property (nonatomic, strong) IBOutlet UIView  *desclblBgView;
@property (nonatomic, strong) IBOutlet PAPButton *nameButton;
@property (nonatomic, strong) IBOutlet PAPButton *likeButton;
@property (nonatomic, strong) IBOutlet UILabel *likedByLabel;
@property (nonatomic, strong) IBOutlet PAPButton *commentButton;
@property (nonatomic, strong) IBOutlet PAPButton *buyButton;

@property (nonatomic, strong) IBOutlet UIView *buttonsContainer;
//- (IBAction)didTapUserNameButtonAction:(UIButton *)button;

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) id<PAPPhotoFooterViewDelegate> delegate;

+ (CGFloat)heightForCellWithDescriptionString:(NSString *)content;

- (void)setLikeStatus:(NSInteger)status;
- (void)setLikedByCount:(NSNumber *)likedByCount;
- (void)shouldEnableLikeButton:(BOOL)enable;

@end
