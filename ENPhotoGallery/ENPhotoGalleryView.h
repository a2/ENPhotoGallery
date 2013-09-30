//
//  ENPhotoGalleryView.h
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ENPhotoGalleryMode) {
    ENPhotoGalleryModeImageLocal = 0,
    ENPhotoGalleryModeImageRemote,
    ENPhotoGalleryModeCustomView
};

typedef NS_ENUM(NSUInteger, ENPhotoCaptionStyle) {
    ENPhotoCaptionStyleText = 0,
    ENPhotoCaptionStyleAttributedText,
    ENPhotoCaptionStyleCustomView
};

typedef NS_ENUM(NSUInteger, ENPhotoGalleryDoubleTapHandler) {
    ENPhotoGalleryDoubleTapHandlerNone = 0,
    ENPhotoGalleryDoubleTapHandlerZoom,
    ENPhotoGalleryDoubleTapHandlerCustom
};

@class ENPhotoGalleryView, ENPhotoGalleryViewController, ENPhotoCaptionView;

@protocol ENPhotoGalleryDataSource <NSObject>

- (NSInteger)numberOfViewsInPhotoGallery:(ENPhotoGalleryView*)photoGallery;

@optional
- (UIImage *)photoGallery:(ENPhotoGalleryView *)photoGallery localImageAtIndex:(NSInteger)index;
- (UIView *)photoGallery:(ENPhotoGalleryView *)photoGallery customViewAtIndex:(NSInteger)index;
- (NSURL *)photoGallery:(ENPhotoGalleryView *)photoGallery remoteImageURLAtIndex:(NSInteger)index;

- (NSAttributedString *)photoGallery:(ENPhotoGalleryView *)photoGallery attributedCaptionAtIndex:(NSInteger)index;
- (NSString *)photoGallery:(ENPhotoGalleryView *)photoGallery captionAtIndex:(NSInteger)index;
- (UIView *)photoGallery:(ENPhotoGalleryView *)photoGallery customViewForCaptionAtIndex:(NSInteger)index;

- (UIView *)customTopViewForGalleryViewController:(ENPhotoGalleryViewController *)galleryViewController;
- (UIView *)customBottomViewForGalleryViewController:(ENPhotoGalleryViewController *)galleryViewController;

@end

@protocol ENPhotoGalleryDelegate <UIScrollViewDelegate>

@optional
- (ENPhotoGalleryDoubleTapHandler)photoGallery:(ENPhotoGalleryView *)photoGallery doubleTapHandlerAtIndex:(NSInteger)index;
- (void)photoGallery:(ENPhotoGalleryView *)photoGallery didDoubleTapAtIndex:(NSInteger)index;
- (void)photoGallery:(ENPhotoGalleryView *)photoGallery didMoveToIndex:(NSInteger)index;
- (void)photoGallery:(ENPhotoGalleryView *)photoGallery didTapAtIndex:(NSInteger)index;

@end

@protocol ENPhotoItemDelegate <NSObject>

@optional
- (void)photoItemDidSingleTapAtIndex:(NSInteger)index;
- (void)photoItemDidDoubleTapAtIndex:(NSInteger)index;

@end

@interface ENPhotoGalleryView : UIView <ENPhotoItemDelegate>

@property (nonatomic) BOOL circleScroll;
@property (nonatomic) BOOL peakSubview;
@property (nonatomic) BOOL showsScrollIndicator;
@property (nonatomic) BOOL verticalGallery;
@property (nonatomic) CGFloat subviewGap;
@property (nonatomic) ENPhotoCaptionStyle captionStyle;
@property (nonatomic) ENPhotoGalleryMode galleryMode;
@property (nonatomic) NSInteger initialIndex;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, weak) IBOutlet id<ENPhotoGalleryDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<ENPhotoGalleryDelegate> delegate;

- (BOOL)incrementCurrentPageByDelta:(NSInteger)delta animated:(BOOL)animation;
- (BOOL)scrollToPage:(NSInteger)page animated:(BOOL)animation;

- (void)setInitialIndex:(NSInteger)initialIndex animated:(BOOL)animation;

@end
