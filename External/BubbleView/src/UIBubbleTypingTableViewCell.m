//
//  UIBubbleTypingTableCell.m
//  UIBubbleTableViewExample
//
//  Created by Александр Баринов on 10/7/12.
//  Copyright (c) 2012 Stex Group. All rights reserved.
//

#import "UIBubbleTypingTableViewCell.h"

@interface UIBubbleTypingTableViewCell ()

@property (nonatomic, retain) UIImageView *typingImageView;

@end

@implementation UIBubbleTypingTableViewCell

@synthesize type = _type;
@synthesize typingImageView = _typingImageView;
@synthesize showAvatar = _showAvatar;

+ (CGFloat)height
{
    return 40.0;
}

- (void)setType:(NSBubbleTypingType)value
{
    if (!self.typingImageView)
    {
        self.typingImageView = [[UIImageView alloc] init];
        [self addSubview:self.typingImageView];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImage *bubbleImage = nil;
    CGFloat x = 0;
    
    if (value == NSBubbleTypingTypeMe)
    {
        bubbleImage = [UIImage imageNamed:@"typingMine.png"];
        x = self.frame.size.width - bubbleImage.size.width;
    }
    else if (value == NSBubbleTypingTypeSomebody)
    {
        bubbleImage = [UIImage imageNamed:@"typingSomeone.png"]; 
        x = 0;
    }
    else if (value == NSBubbleTypingTypeLoading)
    {
        bubbleImage = [UIImage imageNamed:@"typingLoading0.png"];
        x = (self.frame.size.width - bubbleImage.size.width) / 2;
        loadingImageIndex = 0;
        [self performSelector:@selector(animateLoading) withObject:nil afterDelay:0.75];
    }
    
    self.typingImageView.image = bubbleImage;
    self.typingImageView.frame = CGRectMake(x, 4, 73, 31);
}

- (void)animateLoading
{
    loadingImageIndex ++;
    if (loadingImageIndex >= 4) loadingImageIndex = 0;
    self.typingImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"typingLoading%ld.png", (long)loadingImageIndex]];
    [self performSelector:@selector(animateLoading) withObject:nil afterDelay:0.75];
}

@end
