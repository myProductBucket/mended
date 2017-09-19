//
//  PAPButton.m
//  Relaced
//
//  Created by Qibo Fu on 8/25/13.
//
//

#import "PAPButton.h"

@implementation PAPButton

@synthesize papType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPapType:(enum PAPBUTTON_TYPE)type
{
    papType = type;

    switch (papType) {
        case PAPBUTTON_RED:
            [self setBackgroundImage:[[UIImage imageNamed:@"buttonRed"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 5, 12, 5)] forState:UIControlStateNormal];
            [self setBackgroundImage:[[UIImage imageNamed:@"buttonRed"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 5, 12, 5)] forState:UIControlStateSelected];
            break;
            
        case PAPBUTTON_GREEN:
            [self setBackgroundImage:[[UIImage imageNamed:@"buttonGreen"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 5, 12, 5)] forState:UIControlStateNormal];
            break;
            
        case PAPBUTTON_CYAN:
            [self setBackgroundImage:[[UIImage imageNamed:@"buttonCyan"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 5, 12, 5)] forState:UIControlStateNormal];
            break;
            
        case PAPBUTTON_DARKGRAY:
            [self setBackgroundImage:[[UIImage imageNamed:@"buttonDarkGray"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 5, 12, 5)] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

@end
