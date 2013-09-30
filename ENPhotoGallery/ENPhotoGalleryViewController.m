//
//  ENPhotoGalleryViewController.m
//  PhotoGalleryExample
//
//  Created by Ethan Nguyen on 5/24/13.
//
//

#import "ENPhotoGalleryViewController.h"

@interface ENPhotoGalleryViewController ()

@property (nonatomic, getter = isStatusBarHidden) BOOL statusBarHidden;
@property (nonatomic, getter = isControlViewHidden) BOOL controlViewHidden;
@property (nonatomic, weak) ENPhotoGalleryView *photoGallery;
@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIView *bottomView;

@end

@implementation ENPhotoGalleryViewController

- (void)configureBottomBar
{
    [self.bottomView removeFromSuperview];
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(customBottomViewForGalleryViewController:)]) {
        UIView *bottomView = [_dataSource customBottomViewForGalleryViewController:self];
        bottomView.frame = CGRectMake(0, self.view.frame.size.height-bottomView.frame.size.height, bottomView.frame.size.width, bottomView.frame.size.height);
        [self.view addSubview:bottomView];
		self.bottomView = bottomView;
        return;
    }
    
    UIToolbar *bottomViewBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    bottomViewBar.barStyle = UIBarStyleBlackTranslucent;
    bottomViewBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *previous = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Previous", nil) style:UIBarButtonItemStylePlain target:self action:@selector(goToPrevious)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStylePlain target:self action:@selector(goToNext)];
    [bottomViewBar setItems:@[ previous, flexibleSpace, next ] animated:YES];
    
	UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 44.0, CGRectGetWidth(self.view.bounds), 44.0)];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [bottomView addSubview:bottomViewBar];
    [self.view addSubview:bottomView];
	self.bottomView = bottomView;
}
- (void)configureTopBar
{
    [self.topView removeFromSuperview];
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(customTopViewForGalleryViewController:)]) {
        UIView *topView = [_dataSource customTopViewForGalleryViewController:self];
        topView.frame = CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height);
        topView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:topView];
		self.topView = topView;
        return;
    }
    
    UIToolbar *topViewBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    topViewBar.barStyle = UIBarStyleBlackTranslucent;
    topViewBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [topViewBar setItems:@[ done ] animated:YES];
    
    UIView *topView = [[UIView alloc] initWithFrame:topViewBar.frame];
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [topView addSubview:topViewBar];
    [self.view addSubview:topView];
	self.topView = topView;
}
- (void)done
{
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)goToNext
{
    [self.photoGallery incrementCurrentPageByDelta:1 animated:YES];
}
- (void)goToPrevious
{
    [self.photoGallery incrementCurrentPageByDelta:-1 animated:YES];
}

#pragma - Accessors

// circleScroll
- (void)setCircleScroll:(BOOL)circleScroll
{
    _circleScroll = circleScroll;
    self.photoGallery.circleScroll = _circleScroll;
}

// dataSource
- (void)setDataSource:(id<ENPhotoGalleryDataSource>)dataSource
{
    _dataSource = dataSource;
	
	if (self.photoGallery) {
		self.photoGallery.dataSource = _dataSource ?: self;
		
		[self configureTopBar];
		[self configureBottomBar];
	}
}

// captionStyle
- (void)setCaptionStyle:(ENPhotoCaptionStyle)captionStyle
{
    _captionStyle = captionStyle;
    self.photoGallery.captionStyle = _captionStyle;
}

// galleryMode
- (void)setGalleryMode:(ENPhotoGalleryMode)galleryMode
{
    _galleryMode = galleryMode;
    self.photoGallery.galleryMode = _galleryMode;
}

// initialIndex
- (void)setInitialIndex:(NSInteger)initialIndex
{
    _initialIndex = initialIndex;
    self.photoGallery.initialIndex = _initialIndex;
}

// peakSubview
- (void)setPeakSubview:(BOOL)peakSubview
{
    _peakSubview = peakSubview;
    self.photoGallery.peakSubview = _peakSubview;
}

// subviewGap
- (void)setSubviewGap:(CGFloat)subviewGap
{
    _subviewGap = subviewGap;
    self.photoGallery.subviewGap = _subviewGap;
}

// verticalGallery
- (void)setVerticalGallery:(BOOL)verticalGallery
{
    _verticalGallery = verticalGallery;
    self.photoGallery.verticalGallery = _verticalGallery;
}

#pragma mark - <ENPhotoGalleryDataSource>

- (NSInteger)numberOfViewsInPhotoGallery:(ENPhotoGalleryView *)photoGallery
{
    return 0;
}

- (NSURL *)photoGallery:(ENPhotoGalleryView *)photoGallery remoteImageURLAtIndex:(NSInteger)index
{
    return nil;
}

- (UIImage *)photoGallery:(ENPhotoGalleryView *)photoGallery localImageAtIndex:(NSInteger)index
{
    return nil;
}

- (UIView *)photoGallery:(ENPhotoGalleryView *)photoGallery customViewAtIndex:(NSInteger)index
{
    return nil;
}

#pragma mark - <ENPhotoGalleryDelegate>

- (void)photoGallery:(ENPhotoGalleryView *)photoGallery didTapAtIndex:(NSInteger)index
{
    self.controlViewHidden ^= YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.topView.frame;
        frame.origin.y = -1*!!self.isControlViewHidden*frame.size.height;
        self.topView.frame = frame;
        self.topView.alpha = self.isControlViewHidden ? 0.0 : 1.0;
        
        frame = self.bottomView.frame;
        
        if (self.isControlViewHidden)
            frame.origin.y += frame.size.height;
        else
            frame.origin.y -= frame.size.height;
        
        self.bottomView.frame = frame;
        self.bottomView.alpha = self.isControlViewHidden ? 0.0 : 1.0;
    }];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
	self.view.backgroundColor = [UIColor blackColor];
	
	ENPhotoGalleryView *photoGallery = [[ENPhotoGalleryView alloc] initWithFrame:self.view.bounds];
	photoGallery.dataSource = self.dataSource ?: self;
	photoGallery.delegate = self;
	
	[self.view addSubview:photoGallery];
	self.photoGallery = photoGallery;
	
	self.statusBarHidden = UIApplication.sharedApplication.statusBarHidden;
	self.controlViewHidden = NO;
	
	[self configureTopBar];
	[self configureBottomBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.isStatusBarHidden && !self.showStatusBar) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        self.view.frame = UIScreen.mainScreen.bounds;
		
        if (self.navigationController) [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.isStatusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        
        if (self.navigationController) [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

@end
