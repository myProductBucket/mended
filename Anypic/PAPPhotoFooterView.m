//
//  PAPPhotoFooterView.m
//  Relaced
//
//  Created by Qibo Fu on 8/23/13.
//
//

#import "PAPPhotoFooterView.h"
#import <QuartzCore/QuartzCore.h>
#import "RLUtils.h"

@implementation PAPPhotoFooterView

@synthesize descriptionLabel;
@synthesize desclblBgView;
@synthesize priceLabel;

//@synthesize nameButton;
@synthesize sizeLabel;
@synthesize priceHolder;
@synthesize likeButton;
@synthesize likedByLabel;
@synthesize buttonsContainer;
@synthesize commentButton;
@synthesize buyButton;

@synthesize photo;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    //likeButton.papType = PAPBUTTON_RED;
    commentButton.papType = PAPBUTTON_CYAN;
    buyButton.papType = PAPBUTTON_GREEN;
}

- (void)dealloc
{
    self.descriptionLabel = nil;
    self.priceLabel = nil;
   
    self.priceHolder = nil;
    self.likeButton = nil;
    self.likedByLabel = nil;
    self.buttonsContainer = nil;
    self.commentButton = nil;
    self.buyButton = nil;
    self.desclblBgView = nil;
    self.sizeLabel = nil;
    //self.nameButton = nil;
    
    self.photo = nil;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //NSLog(@"Draw in Rect: %f", rect.origin.y);
}
//NSString *authorName = [user objectForKey:kPAPUserDisplayNameKey];
//[didTapUserButton setTitle:authorName forState:UIControlStateNormal];

//- (IBAction)didSelectUser:(id)sender
//{
    //if ([delegate respondsToSelector:@selector(photoHeaderView:didTapUserButton:user:)]) {
        //[//delegate photoHeaderView:self didTapUserButton:sender user:[self.photo objectForKey:kPAPPhotoUserKey]];
    //}
//}


- (IBAction)like:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(photoFooterView:didTapLikePhotoButton:photo:)]) {
        [delegate photoFooterView:self didTapLikePhotoButton:sender photo:self.photo];
    }
}

- (IBAction)comment:(id)sender
{
    if ([delegate respondsToSelector:@selector(photoFooterView:didTapCommentOnPhotoButton:photo:)]) {
        [delegate photoFooterView:self didTapCommentOnPhotoButton:sender photo:photo];
    }
}



- (IBAction)buy:(id)sender
{
    if ([delegate respondsToSelector:@selector(photoFooterView:didTapBuyOnPhotoButton:photo:)]) {
        [delegate photoFooterView:self didTapBuyOnPhotoButton:sender photo:photo];
    }
}

+ (CGFloat)heightForCellWithDescriptionString:(NSString *)content {
    
    if (content.length > 0) {
        CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(310, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        return contentSize.height + 70.0;
    }
    //else
        
        //{
            
          //  if (20 < content.length > 60) {
            //    CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(310, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
              //  return contentSize.height + 70.0;
           // }
            
            //else {
                
              //  if (content.length > 60) {
                //    CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(310, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
                  //  return contentSize.height + 85;
                //}
                
               // else {
                    
                //if (content.length < 20) {
                  //  CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(310, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
                   // return contentSize.height + 70.0;
                //}
                    
                //else {
                    
                  //  if (content.length < 10) {
                    //    CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(310, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
                      //  return contentSize.height + 70.0;
                   // }
                else {
        
        
        return 100.0;
    }
    
                }

- (void)setPhoto:(PFObject *)object
{
    photo = object;

    //NSString *authorName = [photo objectForKey:kPAPUserDisplayNameKey];
    // [nameButton setTitle:authorName forState:UIControlStateNormal];
    
    NSString *content = [photo objectForKey:kPAPPhotoTitleKey];
    sizeLabel.text = [NSString stringWithFormat:@"Size: %@", [object objectForKey:kPAPPhotoSizeKey]];
      
    descriptionLabel.text = content;
    
    
    
    CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(305, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = descriptionLabel.frame;
    frame.size = contentSize;
     descriptionLabel.frame = frame;
    descriptionLabel.frame = CGRectMake(20, descriptionLabel.frame.size.height, 280, frame.size.height);
    // Set the number of line in of the label
    float lineNumber = (float)frame.size.height/(float)17.895;
    descriptionLabel.numberOfLines = lineNumber ;
    //infoLabel.text = productinfo;
    
    NSNumber *price = [photo objectForKey:kPAPPhotoPriceKey];
    if (price) {
        //priceLabel.text = [NSString stringWithFormat:@"$%@", [photo objectForKey:kPAPPhotoPriceKey]];
        priceLabel.text = ([[photo objectForKey:kPAPPhotoIsSoldKey] isEqualToString:@"1"] ? @"Mended" : [NSString stringWithFormat:@"$%@", [photo objectForKey:kPAPPhotoPriceKey]]);
    }
    else {
        priceLabel.text = @"";
    }
    
    likeButton.layer.cornerRadius = 6; // this value vary as per your desire
    likeButton.clipsToBounds = YES;
    self.likeButton.layer.borderWidth = 2.0f;
    self.likeButton.layer.borderColor = [RLUtils relacedRed].CGColor;
    
    
    //priceLabel.frame = CGRectMake(52, contentSize.height + 8, 60, 20);
    //priceHolder.frame = CGRectMake(10, contentSize.height + 8, 40, 20);
    
    //likeButton.frame = CGRectMake(10, sizeLabel.frame.size.height-10, 90, 30);
    
    // Hide price holder label and re-position the price lable
    priceHolder.hidden = FALSE;
    // [priceLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    //[priceLabel setTextAlignment:NSTextAlignmentCenter];
    //[priceLabel setTextColor:[UIColor blackColor]];
    //[priceLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    //priceLabel.frame = CGRectMake(-135, contentSize.height-frame.size.height+35, 320, frame.size.height);
    //priceLabel.frame = CGRectMake(150, descriptionLabel.frame.size.height+10, 320, frame.size.height);
    //priceLabel.frame = CGRectMake(52, contentSize.height + 8, 300, 20);
    //sizeLabel.frame = CGRectMake(10, priceLabel.frame.size.height+10, 320, frame.size.height);
    //priceHolder.frame = CGRectMake(8, contentSize.height-frame.size.height-1, 275, frame.size.height);
    //priceLabel.frame = CGRectMake(8, 18 - 323, 60, 25);   //contentSize.height
    //priceHolder.frame = CGRectMake(100, descriptionLabel.frame.size.height+10, 320, frame.size.height);
    //likeButton.frame = CGRectMake(10, descriptionLabel.frame.size.height+45, 60, 20);
    //likedByLabel.frame = CGRectMake(100, descriptionLabel.frame.size.height+45, 100, 20);
    
    //Change description level position and background
    desclblBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
    //[descriptionLabel setTextColor:[UIColor blackColor]];
    //desclblBgView.frame = CGRectMake(8, contentSize.height-frame.size.height*2, 304, frame.size.height);
    descriptionLabel.frame = CGRectMake(10, contentSize.height-frame.size.height-2, 275, frame.size.height+10);
    // descriptionLabel.frame = frame;
    
    [buttonsContainer removeFromSuperview];
    buttonsContainer.frame = CGRectMake(10, sizeLabel.frame.size.height+120, 320,27);
    self.frame = CGRectMake(0, 320, 320,[PAPPhotoFooterView heightForCellWithDescriptionString:content]);
    self.backgroundColor =[UIColor whiteColor];
}

- (void)setLikeStatus:(NSInteger)status
{
    if (status == -1) { //Unknown
        likeButton.enabled = NO;
    }
    else {
        likeButton.enabled = YES;
        likeButton.selected = status;
    }
}

- (void)shouldEnableLikeButton:(BOOL)enable
{
    likeButton.enabled = enable;
}

-(void)setLikedByCount:(NSNumber *)likedByCount
{
    likedByLabel.text = [NSString stringWithFormat:@"%ld Likes", (long)[likedByCount integerValue]];
}

@end
