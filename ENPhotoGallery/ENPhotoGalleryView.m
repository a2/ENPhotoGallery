//
//  ENPhotoGalleryView.m
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ENPhotoGalleryView.h"
#import "ENPhotoItemView.h"

#define kDefaultSubviewGap              30
#define kMaxSpareViews                  1

@interface ENPhotoGalleryView () <UIScrollViewDelegate>

@property (nonatomic) NSInteger dataSourceNumberOfViews;
@property (nonatomic, strong) NSMutableArray *circleScrollViews;
@property (nonatomic, strong) NSMutableSet *reusableViews;
@property (nonatomic, weak) UIImageView *mainScrollIndicatorView;
@property (nonatomic, weak) UIScrollView *mainScrollView;

@property (nonatomic, readwrite) NSInteger currentPage;

@end

@implementation ENPhotoGalleryView

- (BOOL)incrementCurrentPageByDelta:(NSInteger)delta animated:(BOOL)animation
{
    return [self scrollToPage:self.currentPage + delta animated:animation];
}
- (BOOL)reusableViewsContainViewAtIndex:(NSInteger)index
{
    for (UIView *view in self.reusableViews) {
        if (view.tag == index) {
            return YES;
		}
	}
    
    return NO;
}
- (BOOL)scrollToPage:(NSInteger)page animated:(BOOL)animation
{
    if (page < 0 || page >= self.dataSourceNumberOfViews)
        return NO;
    
	self.currentPage = page;
    [self populateSubviews];
    
    CGPoint contentOffset = self.mainScrollView.contentOffset;
    if (_verticalGallery)
        contentOffset.y = self.currentPage * self.mainScrollView.frame.size.height;
    else
        contentOffset.x = self.currentPage * self.mainScrollView.frame.size.width;
    
    [self.mainScrollView setContentOffset:contentOffset animated:animation];

    if ([_delegate respondsToSelector:@selector(photoGallery:didMoveToIndex:)])
        [_delegate photoGallery:self didMoveToIndex:self.currentPage];
    
    return YES;
}

- (ENPhotoContainerView *)viewToBeAddedWithFrame:(CGRect)frame atIndex:(NSInteger)index
{
    ENPhotoContainerView *subview = nil;
    id galleryItem = nil;
    
    switch (_galleryMode) {
        case ENPhotoGalleryModeImageLocal:
            galleryItem = [_dataSource photoGallery:self localImageAtIndex:index];
            break;
            
        case ENPhotoGalleryModeImageRemote:
            galleryItem = [_dataSource photoGallery:self remoteImageURLAtIndex:index];
            break;
            
        default:
            galleryItem = [_dataSource photoGallery:self customViewAtIndex:index];
            break;
    }
    
    if (!galleryItem) return nil;
    
    subview = [[ENPhotoContainerView alloc] initWithFrame:frame galleryMode:_galleryMode item:galleryItem];
    subview.tag = index;
    subview.galleryDelegate = self;
    
    id captionItem = nil;
    
    switch (_captionStyle) {
        case ENPhotoCaptionStyleText:
            if ([_dataSource respondsToSelector:@selector(photoGallery:captionAtIndex:)]) {
                captionItem = [_dataSource photoGallery:self captionAtIndex:index];
            }
			
            break;
            
        case ENPhotoCaptionStyleAttributedText:
            if ([_dataSource respondsToSelector:@selector(photoGallery:attributedCaptionAtIndex:)]) {
                captionItem = [_dataSource photoGallery:self attributedCaptionAtIndex:index];
            }
			
            break;
            
        default:
            if ([_dataSource respondsToSelector:@selector(photoGallery:customViewAtIndex:)]) {
                captionItem = [_dataSource photoGallery:self customViewForCaptionAtIndex:index];
            }
			
            break;
    }
    
    if (captionItem) [subview setCaptionWithStyle:_captionStyle item:captionItem];
    return subview;
}

- (UIImage *)scrollIndicatorForDirection:(BOOL)vertical andLength:(CGFloat)length
{
    CGFloat radius = 3.5;
    CGFloat ratio = MAX(2.5, 1.5*length/radius);
    
    CGSize size = CGSizeMake(2*radius*(vertical ? 1.0 : ratio), 2*radius*(vertical ? vertical*ratio : 1));
    CGFloat lineWidth = 0.5;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetAlpha(context, 0.8);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, radius, radius, radius-lineWidth, !!vertical*(-M_PI_2), !!vertical*M_PI_2, !vertical);
    CGContextAddArc(context, size.width - radius, size.height - radius, radius - lineWidth, !!vertical*M_PI_2, !!vertical*(-M_PI_2), !vertical);
    CGContextClosePath(context);
    
    [[UIColor grayColor] set];
    CGContextStrokePath(context);
	
	UIImage *scrollIndicator = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scrollIndicator;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
	
    [self initDefaults];
    [self initMainScrollView];
}
- (void)configureMainScrollView
{
    NSAssert(_dataSource != nil, @"Missing dataSource");
    NSAssert([_dataSource respondsToSelector:@selector(numberOfViewsInPhotoGallery:)], @"Missing dataSource method -numberOfViewsInPhotoGallery:");
    
    switch (_galleryMode) {
        case ENPhotoGalleryModeImageLocal:
            NSAssert([_dataSource respondsToSelector:@selector(photoGallery:localImageAtIndex:)], @"ENPhotoGalleryModeImageLocal mode missing dataSource method -photoGallery:localImageAtIndex:");
            break;
            
        case ENPhotoGalleryModeImageRemote:
            NSAssert([_dataSource respondsToSelector:@selector(photoGallery:remoteImageURLAtIndex:)], @"ENPhotoGalleryModeImageRemote mode missing dataSource method -photoGallery:remoteImageURLAtIndex:");
            break;
            
        case ENPhotoGalleryModeCustomView:
            NSAssert([_dataSource respondsToSelector:@selector(photoGallery:customViewAtIndex:)], @"ENPhotoGalleryModeCustomView mode missing dataSource method -photoGallery:viewAtIndex:");
            break;
            
        default:
            break;
    }
    
    [self initMainScrollView];
    
    NSInteger tmpCurrentIndex = self.currentPage;
    
    [self setSubviewGap:_subviewGap];
    
    CGSize contentSize = self.mainScrollView.contentSize;
    if (_verticalGallery)
        contentSize.height = self.mainScrollView.frame.size.height * self.dataSourceNumberOfViews;
    else
        contentSize.width = self.mainScrollView.frame.size.width * self.dataSourceNumberOfViews;
    
    self.mainScrollView.contentSize = contentSize;
    
	[self.mainScrollView.subviews.copy enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		if ([subview isKindOfClass:[ENPhotoContainerView class]]) [subview removeFromSuperview];
	}];
    [self.reusableViews removeAllObjects];
    
    [self scrollToPage:tmpCurrentIndex animated:NO];
    [self configureScrollIndicator];
}
- (void)configureScrollIndicator
{
    [self.mainScrollIndicatorView removeFromSuperview];
    
    if (!self.showsScrollIndicator || !self.dataSourceNumberOfViews) return;
    
    CGFloat scrollIndicatorLength = 0;
    
    if (_verticalGallery)
        scrollIndicatorLength = CGRectGetHeight(self.bounds) / self.dataSourceNumberOfViews;
    else
        scrollIndicatorLength = CGRectGetWidth(self.bounds) / self.dataSourceNumberOfViews;
    
    UIImage *scrollIndicator = [self scrollIndicatorForDirection:_verticalGallery andLength:scrollIndicatorLength];
    UIImageView *mainScrollIndicatorView = [[UIImageView alloc] initWithImage:scrollIndicator];
    
    CGRect frame = mainScrollIndicatorView.frame;
    
    if (_verticalGallery) {
        frame.origin.x = self.frame.size.width-frame.size.width;
        frame.origin.y = 0;
    } else {
        frame.origin.x = 0;
        frame.origin.y = self.frame.size.height-frame.size.height;
    }
    
    mainScrollIndicatorView.frame = frame;
    mainScrollIndicatorView.alpha = 0;
	
    [self addSubview:mainScrollIndicatorView];
	self.mainScrollIndicatorView = mainScrollIndicatorView;
}
- (void)initDefaults
{
    _galleryMode = ENPhotoGalleryModeImageLocal;
    _captionStyle = ENPhotoCaptionStyleText;
    _subviewGap = kDefaultSubviewGap;
    _peakSubview = NO;
    _showsScrollIndicator = YES;
    _verticalGallery = NO;
    _initialIndex = 0;
}
- (void)initMainScrollView
{
    CGRect frame = (CGRect){ CGPointZero, self.frame.size };
    
    if (_verticalGallery)
        frame.size.height += _subviewGap;
    else
        frame.size.width += _subviewGap;
    
    [self.mainScrollView removeFromSuperview];
    
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:frame];
    mainScrollView.autoresizingMask = self.autoresizingMask;
    mainScrollView.backgroundColor = [UIColor clearColor];
    mainScrollView.clipsToBounds = NO;
    mainScrollView.contentSize = frame.size;
    mainScrollView.delegate = self;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.showsHorizontalScrollIndicator = mainScrollView.showsVerticalScrollIndicator = NO;
    
    [self addSubview:mainScrollView];
    self.mainScrollView = mainScrollView;
	
    self.reusableViews = [NSMutableSet set];
    self.currentPage = 0;
}
- (void)populateSubviews
{
    NSMutableSet *toRemovedViews = [NSMutableSet set];
    
    for (UIView *view in self.reusableViews) {
        if (view.tag < self.currentPage - kMaxSpareViews || view.tag > self.currentPage + kMaxSpareViews) {
            [toRemovedViews addObject:view];
            [view removeFromSuperview];
        }
	}
    
    [self.reusableViews minusSet:toRemovedViews];
    
    for (NSInteger index = -kMaxSpareViews; index <= kMaxSpareViews; index++) {
        NSInteger assertIndex = self.currentPage + index;
        if (assertIndex < 0 || assertIndex >= self.dataSourceNumberOfViews || [self reusableViewsContainViewAtIndex:assertIndex]) {
            continue;
		}
        
        CGRect frame = (CGRect){ CGPointZero, self.frame.size };
        if (_verticalGallery)
            frame.origin.y = assertIndex * self.mainScrollView.frame.size.height;
        else
            frame.origin.x = assertIndex * self.mainScrollView.frame.size.width;
        
        ENPhotoContainerView *subview = [self viewToBeAddedWithFrame:frame atIndex:self.currentPage + index];
        if (subview) {
            [self.mainScrollView addSubview:subview];
            [self.reusableViews addObject:subview];
        }
    }
}
- (void)setInitialIndex:(NSInteger)initialIndex
{
    [self setInitialIndex:initialIndex animated:NO];
}
- (void)setInitialIndex:(NSInteger)initialIndex animated:(BOOL)animation
{
    _initialIndex = initialIndex;
    self.currentPage = _initialIndex;
    
    [self scrollToPage:self.currentPage animated:animation];
}

#pragma mark - Accessors

// captionStyle
- (void)setCaptionStyle:(ENPhotoCaptionStyle)captionStyle
{
    _captionStyle = captionStyle;
    [self layoutSubviews];
}

// dataSource
- (void)setDataSource:(id<ENPhotoGalleryDataSource>)dataSource
{
	_dataSource = dataSource;
	self.dataSourceNumberOfViews = [dataSource numberOfViewsInPhotoGallery:self];
	[self setNeedsLayout];
}

// galleryMode
- (void)setGalleryMode:(ENPhotoGalleryMode)galleryMode
{
    _galleryMode = galleryMode;
    [self layoutSubviews];
}

// peakSubview
- (void)setPeakSubview:(BOOL)peakSubview
{
    _peakSubview = peakSubview;
    _mainScrollView.clipsToBounds = _peakSubview;
}

// showsScrollIndicator
- (void)setShowsScrollIndicator:(BOOL)showsScrollIndicator
{
    _showsScrollIndicator = showsScrollIndicator;
    if (_showsScrollIndicator) [self configureScrollIndicator];
}

// subviewGap
- (void)setSubviewGap:(CGFloat)subviewGap
{
    _subviewGap = subviewGap;
    
    CGRect frame = (CGRect){ CGPointZero, self.frame.size };
    
    if (_verticalGallery)
        frame.size.height += _subviewGap;
    else
        frame.size.width += _subviewGap;
    
    self.mainScrollView.frame = frame;
    self.mainScrollView.contentSize = frame.size;
}

// verticalGallery
- (void)setVerticalGallery:(BOOL)verticalGallery
{
    _verticalGallery = verticalGallery;
    [self setSubviewGap:_subviewGap];
    [self setInitialIndex:_initialIndex];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(photoGallery:didMoveToIndex:)])
        [_delegate photoGallery:self didMoveToIndex:self.currentPage];
    
    self.mainScrollIndicatorView.tag = 0;
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.mainScrollIndicatorView.tag == 0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.mainScrollIndicatorView.alpha = 0;
            }];
        }
    });
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate)
        return;
    
    [self scrollViewDidEndDecelerating:scrollView];
    
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
        [_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger newPage;
    CGFloat scrollIndicatorMoveSpace = 0;
    
    CGRect frame = self.mainScrollIndicatorView.frame;
    
    if (_verticalGallery) {
        newPage = scrollView.contentOffset.y / scrollView.frame.size.height;
        scrollIndicatorMoveSpace = (self.frame.size.height - self.mainScrollIndicatorView.frame.size.height)/(self.dataSourceNumberOfViews - 1);
        frame.origin.y = newPage*scrollIndicatorMoveSpace;
    } else {
        newPage = scrollView.contentOffset.x / scrollView.frame.size.width;
        scrollIndicatorMoveSpace = (self.frame.size.width - self.mainScrollIndicatorView.frame.size.width)/(self.dataSourceNumberOfViews - 1);
        frame.origin.x = newPage*scrollIndicatorMoveSpace;
    }
    
    self.mainScrollIndicatorView.frame = frame;
    
    if (newPage != self.currentPage) {
        self.currentPage = newPage;
        [self populateSubviews];
    }
    
    if ([_delegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [_delegate scrollViewDidScroll:scrollView];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.mainScrollIndicatorView.tag = 1;
    [UIView animateWithDuration:0.3 animations:^{
        self.mainScrollIndicatorView.alpha = 1;
    }];
    
    if ([_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
        [_delegate scrollViewWillBeginDragging:scrollView];
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (!self) return nil;
	
	self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.clipsToBounds = YES;
	
	[self initDefaults];
	[self initMainScrollView];
    
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
    [self configureMainScrollView];
}

@end
