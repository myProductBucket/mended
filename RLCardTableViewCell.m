//
//  RLCardTableViewCell.m
//  Relaced
//
//  Created by Mybrana on 09/04/15.
//
//

#import "RLCardTableViewCell.h"
#import <Stripe.h>
#import "RLUtils.h"

@interface RLCardTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *cardDetailsLabel;

@property (strong, nonatomic) PFObject *cardObject;

@end

@implementation RLCardTableViewCell

- (void)awakeFromNib
{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureWithCard:(PFObject *)cardObject
{
    self.cardObject = cardObject;
    
    STPCardBrand brand = [cardObject[kRLBrandKey] intValue];
    NSString *brandName;
    
    switch(brand)
    {
        case STPCardBrandVisa:
            brandName = @"Visa";
            break;
        case STPCardBrandAmex:
            brandName = @"Amex";
            break;
        case STPCardBrandMasterCard:
            brandName = @"MasterCard";
            break;
        case STPCardBrandDiscover:
            brandName = @"Discover";
            break;
        case STPCardBrandJCB:
            brandName = @"JCB";
            break;
        case STPCardBrandDinersClub:
            brandName = @"DinersClub";
            break;
        default:
            brandName = @"Unknown";
    }
    
    self.cardDetailsLabel.text = [NSString stringWithFormat:@"%@ **** %@ %@/%@", brandName, self.cardObject[kRLLastFourKey], self.cardObject[kRLExpirationMonthKey], self.cardObject[kRLExpirationYearKey]];
}

@end
