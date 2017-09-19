//
//  RLAddressSelectionViewController.h
//  Relaced
//
//  Created by Mybrana on 09/04/15.
//
//

#import <UIKit/UIKit.h>

@protocol RLAddressSelectionViewControllerDelegate

- (void)didSelectAddress:(PFObject *)addressObject;

@end

@interface RLAddressSelectionViewController : UIViewController

@property (weak, nonatomic) id<RLAddressSelectionViewControllerDelegate> delegate;

@end