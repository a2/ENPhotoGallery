# ENPhotoGallery

**ENPhotoGallery** is a set of extended & customizable views to show Photo Gallery for iOS UIKit. This library contains 2 main components: **ENPhotoGalleryView** & **ENPhotoGalleryViewController**.

### Table of Contents
1. [DataSource, Delegate, Mode & Style](#datasource-delegate-mode--style)
	* [DataSource, Mode & Style](#datasource-mode--style)
	* [Delegate](#delegate)
2. [ENPhotoGalleryView](#ENPhotoGalleryview)
	* [Properties](#properties)
	* [Methods](#methods)
3. [ENPhotoGalleryViewController](#ENPhotoGalleryviewcontroller)
4. [Installation & Dependencies](installation--dependencies)
	* [Installation](#installation)
	* [Setup](#setup)
	* [Dependencies](#dependencies)
	* [Requirements & Supports](#requirements--supports)
5. [Licences](#licences)

## DataSource, Delegate, Mode & Style

ENPhotoGallery is implemented in UITableView style, which uses `dataSource` and `delegate` pointers to contruct UI components.

### DataSource, Mode & Style

To declare number of views showing in gallery:

```objective-c
- (NSInteger)numberOfViewsInPhotoGallery:(ENPhotoGalleryView *)photoGallery;
```
	
To declare a view component in specific index:

```objective-c
- (NSURL *)photoGallery:(ENPhotoGalleryView *)photoGallery remoteImageURLAtIndex:(NSInteger)index;
- (UIImage *)photoGallery:(ENPhotoGalleryView *)photoGallery localImageAtIndex:(NSInteger)index;
- (UIView *)photoGallery:(ENPhotoGalleryView *)photoGallery customViewAtIndex:(NSInteger)index;
```

At a moment, **only one** method will be used to contruct view components for gallery, depends on ENPhotoGalleryView's `galleryMode` property. So far, there are 3 modes supported:

```objective-c
ENPhotoGalleryModeImageLocal
ENPhotoGalleryModeImageRemote
ENPhotoGalleryModeCustomView
```

To declare a caption component in specific index:

```objective-c
- (NSAttributedString *)photoGallery:(ENPhotoGalleryView *)photoGallery attributedCaptionAtIndex:(NSInteger)index;
- (NSString *)photoGallery:(ENPhotoGalleryView *)photoGallery captionAtIndex:(NSInteger)index;
- (UIView *)photoGallery:(ENPhotoGalleryView *)photoGallery customViewForCaptionAtIndex:(NSInteger)index;
```

Similar to view component, **only one** caption contruction method is used at a moment to contruct caption for gallery item, depends on `ENPhotoGalleryView`'s `captionStyle`, including 3 supported styles:

```objective-c
ENPhotoCaptionStyleText
ENPhotoCaptionStyleAttributedText
ENPhotoCaptionStyleCustomView
```

### Delegate

So far, `ENPhotoGallery` provides 4 delegate methods:

```objective-c
- (ENPhotoGalleryDoubleTapHandler)photoGallery:(ENPhotoGalleryView *)photoGallery doubleTapHandlerAtIndex:(NSInteger)index;
- (void)photoGallery:(ENPhotoGalleryView *)photoGallery didDoubleTapAtIndex:(NSInteger)index;
- (void)photoGallery:(ENPhotoGalleryView *)photoGallery didMoveToIndex:(NSInteger)index;
- (void)photoGallery:(ENPhotoGalleryView *)photoGallery didTapAtIndex:(NSInteger)index;
```

Use `-photoGallery:didTapAtIndex:` method to handle single tap at gallery item.

Use `-photoGallery:doubleTapHandlerAtIndex:` method to set default action for double tap gesture recognizer. Options including:

```objective-c
ENPhotoGalleryDoubleTapHandlerNone
ENPhotoGalleryDoubleTapHandlerZoom
ENPhotoGalleryDoubleTapHandlerCustom
```

If this method returns `ENPhotoGalleryDoubleTapHandlerZoom`, the current photo item will be zoomed centered at the position of the tap. If `ENPhotoGalleryDoubleTapHandlerCustom` is returned, the action will be dispatched to `-photoGallery:didDoubleTapAtIndex:` if implemented. Otherwise, if `ENPhotoGalleryDoubleTapHandlerNone` is returned, nothing happens.

Use the `-photoGallery:didMoveToIndex:` method to be notified when `currentIndex` changes. (Thanks to [**jstubenrauch**](https://github.com/jstubenrauch))

## ENPhotoGalleryView

### Properties

There are several properties that are helpful to quickly customize your gallery

```objective-c
@property (nonatomic) BOOL circleScroll;
@property (nonatomic) BOOL peakSubview;
@property (nonatomic) BOOL showsScrollIndicator;
@property (nonatomic) BOOL verticalGallery;
@property (nonatomic) CGFloat subviewGap;
@property (nonatomic) ENPhotoCaptionStyle captionStyle;
@property (nonatomic) ENPhotoGalleryMode galleryMode;
@property (nonatomic) NSInteger initialIndex;
@property (nonatomic, readonly) NSInteger currentPage;
```

As mentioned above, `galleryMode` and `captionStyle` are used to change gallery's mode (showing local images, remote images or custom views) and caption style (text, attributed text, or custom views). By default, `galleryMode` is set to `ENPhotoGalleryModeLocalImage` and `captionStyle` is set to `ENPhotoCaptionStyleText`.

Use `peakSubView` to enable/disable gallery item's peak (draw items outside the `ENPhotoGallery`'s frame). By default, this property is set to `NO`.

```objective-c
photoGallery.peakSubView = YES;
```

Use `showsScrollIndicator` to show or hide scrollbar indicator. The direction of scrollbar is automatically adjusted to reflect gallery scrolling direction.

Use `verticalGallery` to set gallery's scroll direction to horizontal/vertical. By default, this property is set to `NO` (horizontal scrolling).

```objective-c
photoGallery.verticalGallery = YES;
```

Use `subviewGap` to adjust a blank gap between gallery items. By default, this property is set to `30.0`.

```objective-c
ohotoGallery.subviewGap = 50;
```

Use `initialIndex` to set the initial position when view is loaded. By default, this property is set to `0`.

```objective-c
photoGallery.initialIndex = 4;
```

The readonly `currentIndex` property returns current showing gallery item index.

### Methods

Comming along with properties to customize gallery's style, some helper methods are provided to control the scrolling of your gallery.

```objective-c
- (BOOL)incrementCurrentPageByDelta:(NSInteger)delta animated:(BOOL)animation;
- (BOOL)scrollToPage:(NSInteger)page animated:(BOOL)animation;

- (void)setInitialIndex:(NSInteger)initialIndex animated:(BOOL)animation;
```

The method `-setInitialIndex:animated:` is an alternative way to animate the initialization page setup. The default `initialIndex` property has no animation effect.

```objective-c
[photoGallery setInitialIndex:4 animated:YES]	
[photoGallery setInitialIndex:4 animated:NO]; // Equivalent to photoGallery.initialIndex = 4;
```

The method `-incrementCurrentPageByDelta:animated:` takes an `NSInteger` delta parameter to scroll to the page `delta` away from the current page.

```objective-c
[photoGallery incrementCurrentPageByDelta:1 animated:YES];
[photoGallery incrementCurrentPageByDelta:-2 animated:YES];
```

All validation of page index are done for you and returned `YES` if the index is valid and the scrolling is in progress, otherwise `NO`.

## ENPhotoGalleryViewController

As an extension, ENPhotoGalleryViewController is created to help simplify your process of creating a view controller for gallery browsing. This view controller already included a `ENPhotoGalleryView` item named `photoGallery`, which is initialized with default configurations.

There are same properties with `ENPhotoGalleryView` that you can use to set for your `photoGallery`, except `delegate` (by default, gallery's delegate is handled by the view controller itself):

```objective-c
@property (nonatomic) BOOL circleScroll;
@property (nonatomic) BOOL peakSubview;
@property (nonatomic) BOOL showStatusBar;
@property (nonatomic) BOOL verticalGallery;
@property (nonatomic) CGFloat subviewGap;
@property (nonatomic) ENPhotoCaptionStyle captionStyle;
@property (nonatomic) ENPhotoGalleryMode galleryMode;
@property (nonatomic) NSInteger initialIndex;
@property (nonatomic, weak) id<ENPhotoGalleryDataSource> dataSource;
```

An additional property is included, `showStatusBar` to force hiding status bar if application status bar is visible.
**NB**: if this property is set to `YES`, navigation bar will be hidden too.

Beside default dataSource methods from `ENPhotoGalleryDataSource`, there are 2 additional methods to setup top & bottom view for gallery view controller:

```objective-c
- (UIView *)customTopViewForGalleryViewController:(ENPhotoGalleryViewController *)galleryViewController;
- (UIView *)customBottomViewForGalleryViewController:(ENPhotoGalleryViewController *)galleryViewController;
```

If these methods are not implemented, `ENPhotoGalleryViewController` provide 2 default views for top & bottom for essential actions (dismiss view controller, scroll next & previous page).

If implemented, a custom view will be placed at top or bottom of view controller respectively.

Otherwise, if these methods are implemented and returned `nil`, the respective view will be hidden from view controller.

By default, for gallery delegate handling, when the user single taps in the gallery, the top and bottom views will toggle their visibility.

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like ENPhotoGallery in your projects.

### Podfile

```ruby
platform :ios, '6.0'
pod 'ENPhotoGallery', '~> 0.2.0'
```

### Requirements & Supports

`ENPhotoGalleryView` requires iOS 6.0 or greater with ARC enabled.

## Licences

All source code is licensed under the [MIT License](http://opensource.org/licenses/MIT)

> Copyright (c) 2013 Ethan Nguyen <ethan@vinova.sg> and ENPhotoGallery Contributors
>  
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is furnished
> to do so, subject to the following conditions:
>  
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
>  
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE.