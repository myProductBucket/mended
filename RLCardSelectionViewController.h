//
//  RLCardSelectionViewController.h
//  Relaced
//
//  Created by Mybrana on 09/04/15.
//
//

#import <UIKit/UIKit.h>

@protocol RLCardSelectionViewControllerDelegate <NSObject>

@optional

- (void)didConfirmPurchaseWithCard:(PFObject *)cardObject;

@end

@interface RLCardSelectionViewController : UIViewController

@property (strong, nonatomic) PFObject *shippingAddressObject;
@property (weak, nonatomic) id<RLCardSelectionViewControllerDelegate> delegate;

@end
