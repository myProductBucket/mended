//
//  PAPPhotoTimelineViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

#import <ParseUI/ParseUI.h>
#import "PAPPhotoHeaderView.h"
#import "PAPPhotoFooterView.h"

@interface PAPPhotoTimelineViewController : PFQueryTableViewController <PAPPhotoHeaderViewDelegate, PAPPhotoFooterViewDelegate>

- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView;

@end
