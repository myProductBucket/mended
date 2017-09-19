//
//  PAPConversationCell.m
//  Relaced
//
//  Created by Qibo Fu on 8/11/13.
//
//

#import <ParseUI/ParseUI.h>
#import "PAPConversationCell.h"

@implementation PAPConversationCell

//@synthesize nameButton;
@synthesize object;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

//- (void)dealloc
//{
//self.nameButton = nil;
//}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setObject:(PFObject *)value
{
    object = value;
    
    PFObject *srcUser = [object objectForKey:@"srcUser"];
    PFUser *oppositeUser = nil;
    newIndicator.hidden = YES;
    if ([srcUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
        oppositeUser = [object objectForKey:@"dstUser"];
        BOOL newFromDst = [[object objectForKey:@"newFromDst"] boolValue];
        newIndicator.hidden = !newFromDst;
    }
    else {
        oppositeUser = [object objectForKey:@"srcUser"];
        BOOL newFromSrc = [[object objectForKey:@"newFromSrc"] boolValue];
        newIndicator.hidden = !newFromSrc;
    }
    
    avatarView.file = [oppositeUser objectForKey:kPAPUserProfilePicSmallKey];
    [avatarView loadInBackground];
    nameLabel.text = [oppositeUser objectForKey:kPAPUserDisplayNameKey];
    
    PFObject *last = [object objectForKey:@"lastMessage"];
    lastMessage.text = [last objectForKey:@"message"];
}

//- (IBAction)didSelectUser:(id)sender
//{
  //  if ([delegate respondsToSelector:@selector(photoHeaderView:didTapUserButton:user:)]) {
    //    [delegate photoHeaderView:self didTapUserButton:sender user:[self.photo objectForKey:kPAPPhotoUserKey]];
   // }


@end
