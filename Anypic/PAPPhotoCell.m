//
//  PAPPhotoCell.m
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

#import "PAPPhotoCell.h"
#import "PAPUtility.h"

@interface PAPPhotoCell ()
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *sizeLabel;

// @property (nonatomic, strong) UIView *descBgView;
@end

@implementation PAPPhotoCell
@synthesize photoButton;

@synthesize descriptionLabel;
@synthesize priceLabel;
@synthesize sizeLabel;

@synthesize photo;
@synthesize hideDropShadow;
@synthesize footerView;
//@synthesize descBgView;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake( 8.0f, 0.0f, 320.0f, 320.0f);
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
        
        [self.contentView bringSubviewToFront:self.imageView];

        // Description and Price
        self.footerView = [[NSBundle mainBundle] loadNibNamed:@"PAPPhotoFooterView" owner:nil options:nil][0];
        self.descriptionLabel = footerView.descriptionLabel;
        self.priceLabel = footerView.priceLabel;
        self.sizeLabel = footerView.sizeLabel;
        
        //self.descBgView = footerView.desclblBgView;
        
        [self addSubview:footerView];
    }

    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
    self.photoButton.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
}

/* Static helper to get the height for a cell if it had the given description */
+ (CGFloat)heightForCellWithPhotoObject:(PFObject *)photo {
    NSString *description = [photo objectForKey:kPAPPhotoTitleKey];//just changed by urban
    CGFloat height = [PAPPhotoFooterView heightForCellWithDescriptionString:description];
    return height + 15 + 320;
// + (CGFloat)heightForCellWithPhotoObject:(PFObject *)photo {
    //NSString *description = [photo objectForKey:kPAPPhotoDescriptionKey];
    //CGFloat height = [PAPPhotoFooterView heightForCellWithDescriptionString:description];
    //return 304+10;//height + 10 + 304;
}

- (void)setPhoto:(PFObject *)aPhoto {
    photo = aPhoto;
    
    self.imageView.image = [UIImage imageNamed:@"placeholderPhoto.png"];
    
    if (photo) {
        self.imageView.file = [photo objectForKey:kPAPPhotoPictureKey];
        
        // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
        if ([self.imageView.file isDataAvailable]) {
            [self.imageView loadInBackground];
        }
    }
    
    NSString *content = [photo objectForKey:kPAPPhotoTitleKey];// just changed by urban
    descriptionLabel.text = content;
    //NSString *productinfo = [ photo objectForKey: kPAPPhotoInfoKey];
    
    NSNumber *price = [photo objectForKey:kPAPPhotoPriceKey];
    if (price) {
        //priceLabel.text = [NSString stringWithFormat:@"$%@", [photo objectForKey:kPAPPhotoPriceKey]];
        priceLabel.text = ([[photo objectForKey:kPAPPhotoIsSoldKey] isEqualToString:@"1"] ? @"Sold" : [NSString stringWithFormat:@"$%@", [photo objectForKey:kPAPPhotoPriceKey]]);
    }
    footerView.photo = photo;
    [self setNeedsDisplay];
}

@end
