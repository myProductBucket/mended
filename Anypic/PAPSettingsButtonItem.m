//
//  PAPSettingsButtonItem.m
//  Anypic
//
//  Created by Héctor Ramos on 5/18/12.
//

#import "PAPSettingsButtonItem.h"

@implementation PAPSettingsButtonItem

#pragma mark - Initialization

- (id)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithImage:[UIImage imageNamed:@"buttonImageSettings.png"] style:UIBarButtonItemStyleBordered target:target action:action];
    return self;
}
@end
