//
//  ENPhotoItemView.m
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ENPhotoItemView.h"

#define kMaxZoomingScale 2

@interface ENPhotoContainerView ()

@property (nonatomic, weak) ENPhotoItemView *photoItemView;
@property (nonatomic, weak) ENPhotoCaptionView *photoCaptionView;

@end

@implementation ENPhotoContainerView

- (instancetype)initWithFrame:(CGRect)frame galleryMode:(ENPhotoGalleryMode)galleryMode item:(id)galleryItem
{
	self = [super initWithFrame:frame];
	if (!self) return nil;
	
    CGRect displayFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
	ENPhotoItemView *photoItemView;
	
	switch (galleryMode) {
		case ENPhotoGalleryModeImageLocal:
			photoItemView = [[ENPhotoItemView alloc] initWithFrame:displayFrame localImage:galleryItem];
			break;
			
		case ENPhotoGalleryModeImageRemote:
			photoItemView = [[ENPhotoItemView alloc] initWithFrame:displayFrame remoteURL:galleryItem];
			break;
			
		default:
			photoItemView = [[ENPhotoItemView alloc] initWithFrame:displayFrame customView:galleryItem];
			break;
	}
	
	[self addSubview:photoItemView];
	self.photoItemView = photoItemView;
    
    return self;
}

- (void)setCaptionHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self.photoCaptionView setCaptionHidden:hidden animated:animated];
}
- (void)setCaptionWithStyle:(ENPhotoCaptionStyle)captionStyle item:(id)captionItem
{
    [self.photoCaptionView removeFromSuperview];
    
	ENPhotoCaptionView *photoCaptionView;
	
    switch (captionStyle) {
        case ENPhotoCaptionStyleText:
            photoCaptionView = [[ENPhotoCaptionView alloc] initWithFrame:self.frame text:captionItem];
            break;
            
        case ENPhotoCaptionStyleAttributedText:
            photoCaptionView = [[ENPhotoCaptionView alloc] initWithFrame:self.frame attributedText:captionItem];
            break;
            
        default:
            photoCaptionView = [[ENPhotoCaptionView alloc] initWithFrame:self.frame customView:captionItem];
            break;
    }
    
    [self addSubview:photoCaptionView];
	self.photoCaptionView = photoCaptionView;
}

#pragma mark - Accessors

- (void)setGalleryDelegate:(id<ENPhotoItemDelegate>)galleryDelegate
{
    _galleryDelegate = galleryDelegate;
    self.photoItemView.galleryDelegate = galleryDelegate;
}

#pragma mark - UIView

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    self.photoItemView.tag = tag;
}

@end

@interface ENPhotoItemView ()

@property (nonatomic, weak) UIImageView *mainImageView;
@property (nonatomic, weak) ENPhotoCaptionView *captionView;

@end

@implementation ENPhotoItemView

- (instancetype)initWithFrame:(CGRect)frame customView:(UIView *)customView
{
	self = [self initWithFrame:frame];
	if (!self) return nil;
	
	[self addSubview:customView];
    
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame localImage:(UIImage *)localImage
{
	self = [self initWithFrame:frame];
	if (!self) return nil;
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
	imageView.backgroundColor = [UIColor clearColor];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[imageView setImage:localImage];
	
	[self addSubview:imageView];
	self.mainImageView = imageView;
	
	CGFloat widthScale = localImage.size.width / self.frame.size.width;
	CGFloat heightScale = localImage.size.height / self.frame.size.height;
	self.maximumZoomScale = kMaxZoomingScale*MIN(widthScale, heightScale);
    
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame remoteURL:(NSURL *)remoteURL
{
	self = [self initWithFrame:frame];
	
	ENRemotePhotoItem *remotePhoto = [[ENRemotePhotoItem alloc] initWithFrame:frame remoteURL:remoteURL];
	remotePhoto.photoItemView = self;
	[self addSubview:remotePhoto];
	self.mainImageView = remotePhoto;
    
    return self;
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    ENPhotoGalleryView *photoGallery = (ENPhotoGalleryView *)self.galleryDelegate;
    
    if (tapGesture.numberOfTapsRequired == 1) {
        if ([photoGallery.delegate respondsToSelector:@selector(photoGallery:didTapAtIndex:)]) {
            [photoGallery.delegate photoGallery:photoGallery didTapAtIndex:self.tag];
		}
        
        return;
    }
    
    if (![photoGallery.delegate respondsToSelector:@selector(photoGallery:doubleTapHandlerAtIndex:)]) {
        [self zoomFromLocation:[tapGesture locationInView:self]];
        return;
    }
    
    switch ([photoGallery.delegate photoGallery:photoGallery doubleTapHandlerAtIndex:self.tag]) {
        case ENPhotoGalleryDoubleTapHandlerZoom:
            [self zoomFromLocation:[tapGesture locationInView:self]];
            break;
            
        case ENPhotoGalleryDoubleTapHandlerCustom:
            if ([photoGallery.delegate respondsToSelector:@selector(photoGallery:didDoubleTapAtIndex:)]) {
                [photoGallery.delegate photoGallery:photoGallery didDoubleTapAtIndex:self.tag];
            }
			
            break;
            
        default:
            break;
    }
}

- (void)zoomFromLocation:(CGPoint)zoomLocation {
    CGSize scrollViewSize = self.frame.size;
    
    CGFloat zoomScale = (self.zoomScale == self.maximumZoomScale) ?
    self.minimumZoomScale : self.maximumZoomScale;
    
    CGFloat width = scrollViewSize.width/zoomScale;
    CGFloat height = scrollViewSize.height/zoomScale;
    CGFloat x = zoomLocation.x - (width/2);
    CGFloat y = zoomLocation.y - (height/2);
    
    [self zoomToRect:CGRectMake(x, y, width, height) animated:YES];
}

#pragma mark - <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mainImageView;
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (!self) return nil;
	
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = YES;
	self.contentSize = self.frame.size;
	self.delegate = self;
	self.minimumZoomScale = 1;
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
	doubleTap.numberOfTapsRequired = 2;
	doubleTap.numberOfTouchesRequired = 1;
	[self addGestureRecognizer:doubleTap];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
	tap.numberOfTapsRequired = 1;
	tap.numberOfTouchesRequired = 1;
	[tap requireGestureRecognizerToFail:doubleTap];
	[self addGestureRecognizer:tap];
	
	return self;
}

@end

@implementation ENRemotePhotoItem

- (instancetype)initWithFrame:(CGRect)frame remoteURL:(NSURL *)remoteURL {
	self = [super initWithFrame:frame];
	if (!self) return nil;
	
	self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeScaleAspectFit;
	
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicator.frame = frame;
	[activityIndicator startAnimating];
	[self addSubview:activityIndicator];
	
	__weak __typeof(&*self) weakSelf = self;
	void (^completion)(UIImage *, NSError *) = ^(UIImage *image, NSError *error) {
		__strong __typeof(&*weakSelf) blockSelf = weakSelf;
		if (error || !image) return;
		
		[activityIndicator removeFromSuperview];
		
		CGFloat widthScale = image.size.width / CGRectGetWidth(blockSelf.photoItemView.bounds);
		CGFloat heightScale = image.size.height / CGRectGetHeight(blockSelf.photoItemView.bounds);
		blockSelf.photoItemView.maximumZoomScale = kMaxZoomingScale*MIN(widthScale, heightScale);
	};
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:remoteURL];
	[request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
	[self setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		completion(image, nil);
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		completion(nil, error);
	}];
    
    return self;
}

@end

@implementation ENPhotoCaptionView

- (instancetype)initWithFrame:(CGRect)frame attributedText:(NSAttributedString *)attributedText
{
    UILabel *captionLabel = [self captionLabelWithText:attributedText fromFrame:frame];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:captionLabel.frame];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.6;
    
    CGRect captionFrame = CGRectMake(0, frame.size.height-captionLabel.frame.size.height, captionLabel.frame.size.width, captionLabel.frame.size.height);
	self = [super initWithFrame:captionFrame];
	if (!self) return nil;

	self.backgroundColor = [UIColor clearColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	
	[self addSubview:backgroundView];
	[self addSubview:captionLabel];
    
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame customView:(UIView *)customView
{
    CGRect captionFrame = CGRectMake(0, frame.size.height-customView.frame.size.height, frame.size.width, customView.frame.size.height);
	self = [super initWithFrame:captionFrame];
	if (!self) return nil;

	self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	self.backgroundColor = [UIColor clearColor];

	[self addSubview:customView];
    
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text
{
    UILabel *captionLabel = [self captionLabelWithText:text fromFrame:frame];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:captionLabel.frame];
    backgroundView.alpha = 0.6;
    backgroundView.backgroundColor = [UIColor blackColor];
    
    CGRect captionFrame = CGRectMake(0, frame.size.height-captionLabel.frame.size.height, captionLabel.frame.size.width, captionLabel.frame.size.height);
	self = [super initWithFrame:captionFrame];

	self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	self.backgroundColor = [UIColor clearColor];
    
	[self addSubview:backgroundView];
	[self addSubview:captionLabel];
    
    return self;
}

- (UILabel *)captionLabelWithText:(id)string fromFrame:(CGRect)frame
{
    UIFont *captionFont = [UIFont systemFontOfSize:14];
    CGSize captionSize;
    
    if ([string isKindOfClass:[NSString class]]) {
        captionSize = [(NSString *)string sizeWithFont:captionFont constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX)];
    } else if ([string isKindOfClass:[NSAttributedString class]]) {
        captionSize = [(NSAttributedString *)string size];
	} else {
		NSAssert1(NO, @"Unexpected string class %@. Expected instance or subclass of NSString or NSAttributedString.", NSStringFromClass([string class]));
		return nil;
	}
    
	CGFloat maxHeight = CGRectGetHeight(frame)/3;
	if (captionSize.height > maxHeight) captionSize.height = maxHeight;
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), captionSize.height)];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.font = captionFont;
    captionLabel.numberOfLines = 0;
    captionLabel.textColor = [UIColor whiteColor];
    
    if ([string isKindOfClass:[NSString class]])
        captionLabel.text = (NSString *)string;
    else
        captionLabel.attributedText = (NSAttributedString *)string;
    
    return captionLabel;
}

- (void)setCaptionHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!self.superview) return;
    CGRect superviewFrame = self.superview.frame;
    
	void (^animations)(void) = ^{
		CGRect frame = self.frame;
        frame.origin.y = superviewFrame.size.height - (!hidden ? self.frame.size.height : 0.0);
        self.frame = frame;
        self.alpha = hidden ? 0.0 : 1.0;
	};
	
	if (animated) {
		[UIView animateWithDuration:0.5 animations:animations];
	} else {
		animations();
	}
}

@end