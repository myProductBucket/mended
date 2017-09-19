//
//  PAPPhotoCell.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

#import <ParseUI/ParseUI.h>
#import "PAPPhotoFooterView.h"

@interface PAPPhotoCell : PFTableViewCell

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic,strong) PFObject *photo;
@property (nonatomic, assign) BOOL hideDropShadow;
@property (nonatomic, strong) PAPPhotoFooterView *footerView;

+ (CGFloat)heightForCellWithPhotoObject:(PFObject *)photo;

@end
