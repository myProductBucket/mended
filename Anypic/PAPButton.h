//
//  PAPButton.h
//  Relaced
//
//  Created by Qibo Fu on 8/25/13.
//
//

#import <UIKit/UIKit.h>

enum PAPBUTTON_TYPE {
    PAPBUTTON_RED = 0,
    PAPBUTTON_GREEN,
    PAPBUTTON_CYAN,
    PAPBUTTON_DARKGRAY,
    };

@interface PAPButton : UIButton

@property (nonatomic, assign) enum PAPBUTTON_TYPE papType;

@end
