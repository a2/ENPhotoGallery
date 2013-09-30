//
//  ENPhotoGalleryViewController.h
//  PhotoGalleryExample
//
//  Created by Ethan Nguyen on 5/24/13.
//
//

#import <UIKit/UIKit.h>
#import "ENPhotoGalleryView.h"

@interface ENPhotoGalleryViewController : UIViewController <ENPhotoGalleryDataSource, ENPhotoGalleryDelegate>

@property (nonatomic) BOOL circleScroll;
@property (nonatomic) BOOL peakSubview;
@property (nonatomic) BOOL showStatusBar;
@property (nonatomic) BOOL verticalGallery;
@property (nonatomic) CGFloat subviewGap;
@property (nonatomic) ENPhotoCaptionStyle captionStyle;
@property (nonatomic) ENPhotoGalleryMode galleryMode;
@property (nonatomic) NSInteger initialIndex;
@property (nonatomic, weak) id<ENPhotoGalleryDataSource> dataSource;

@end
