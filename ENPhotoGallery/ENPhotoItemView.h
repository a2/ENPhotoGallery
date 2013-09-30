//
//  ENPhotoItemView.h
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENPhotoGalleryView.h"

@class ENRemotePhotoItem, ENPhotoCaptionView, ENPhotoItemView;

@interface ENPhotoContainerView : UIView

@property (nonatomic, weak) id<ENPhotoItemDelegate> galleryDelegate;

- (instancetype)initWithFrame:(CGRect)frame galleryMode:(ENPhotoGalleryMode)galleryMode item:(id)galleryItem;

- (void)setCaptionWithStyle:(ENPhotoCaptionStyle)captionStyle item:(id)captionItem;
- (void)setCaptionHidden:(BOOL)hidden animated:(BOOL)animated;

@end

@interface ENPhotoItemView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, weak) id<ENPhotoItemDelegate> galleryDelegate;

- (instancetype)initWithFrame:(CGRect)frame customView:(UIView *)customView;
- (instancetype)initWithFrame:(CGRect)frame localImage:(UIImage *)localImage;
- (instancetype)initWithFrame:(CGRect)frame remoteURL:(NSURL *)remoteUrl;

@end

@interface ENRemotePhotoItem : UIImageView

@property (nonatomic, weak) ENPhotoItemView *photoItemView;

- (instancetype)initWithFrame:(CGRect)frame remoteURL:(NSURL *)remoteURL;

@end

@interface ENPhotoCaptionView : UIView

- (instancetype)initWithFrame:(CGRect)frame attributedText:(NSAttributedString *)attributedText;
- (instancetype)initWithFrame:(CGRect)frame customView:(UIView *)customView;
- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text;

- (void)setCaptionHidden:(BOOL)hidden animated:(BOOL)animated;

@end