//
//  RLAddressTableViewCell.m
//  Relaced
//
//  Created by Mybrana on 09/04/15.
//
//

#import "RLAddressTableViewCell.h"
#import "RLUtils.h"

@interface RLAddressTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *recipientLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) PFObject *addressObject;

@end

@implementation RLAddressTableViewCell

- (void)awakeFromNib
{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)configureWithAddress:(PFObject *)addressObject
{
    self.addressObject = addressObject;
    
    self.recipientLabel.text = self.addressObject[kRLPersonNameKey];
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@, %@", self.addressObject[kRLAddressLine1Key], self.addressObject[kRLCityKey], self.addressObject[kRLStateOrRegionKey], self.addressObject[kRLPostalCodeKey]];
}

@end
