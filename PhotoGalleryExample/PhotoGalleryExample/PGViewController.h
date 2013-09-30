//
//  PGViewController.h
//  PhotoGalleryExample
//
//  Created by Ethan Nguyen on 5/24/13.
//
//

#import <UIKit/UIKit.h>
#import "ENPhotoGalleryView.h"

@class ENPhotoGalleryViewController;

@interface PGViewController : UIViewController<ENPhotoGalleryDataSource, ENPhotoGalleryDelegate> {
    IBOutlet ENPhotoGalleryView *vPhotoGallery;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *img1;
    IBOutlet UIImageView *img2;
    
    ENPhotoGalleryViewController *photoGalleryVC;
}

- (IBAction)btnFullscreenPressed:(UIButton *)sender;
- (IBAction)segGalleryModeChanged:(UISegmentedControl *)sender;

@end
