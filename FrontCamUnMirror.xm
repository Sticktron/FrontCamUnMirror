//
//  FrontCamUnMirror.xm
//  FrontCamUnMirror
//
//  Un-mirror the camera preview when taking selfies.
//  Adds a new button to the camera UI.
//
//  Supports iOS 7-10.
//
//  Copyright © 2014-2017 Sticktron. All rights reserved.
//

#define DEBUG_PREFIX @"[FCUM]"
#import "DebugLog.h"

#import "Headers.h"
#import "version.h"


#define IS_IOS7 (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0)
#define IS_IOS8 ((kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) && (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_9_0))

#define CAMERA_DEVICE_REAR		0
#define CAMERA_DEVICE_FRONT		1

#define CAMERA_MODE_PHOTO		0
#define CAMERA_MODE_VIDEO		1
#define CAMERA_MODE_SLOMO		2
#define CAMERA_MODE_PANO		3
#define CAMERA_MODE_SQUARE		4
#define CAMERA_MODE_TIMELAPSE	6

#define TRANSFORM_FLIP_H		CGAffineTransformMake(-1, 0, 0, 1, 0, 0)
#define TRANSFORM_FLIP_V		CGAffineTransformMake(1, 0, 0, -1, 0, 0)

#define CAMERA_YELLOW			[UIColor colorWithRed:1.0 green:0.8 blue:0 alpha:1]

#define PREFS_PLIST_PATH		[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.sticktron.fcum.plist"]


@interface CAMTopBar (FCUM)
- (BOOL)fcum_isUsingFrontCamera;
- (void)fcum_unMirrorButtonPressed;
- (void)fcum_updatePreviewTransformation;
@end

@interface CAMBottomBar (FCUM)
- (void)fcum_unMirrorButtonPressed;
- (void)fcum_createUnMirrorButton;
@end

@interface CAMViewfinderViewController (FCUM)
- (void)fcum_updatePreviewTransformation;
@end

@interface CAMPreviewViewController (FCUM)
- (void)fcum_updatePreviewTransformation;
@end


static BOOL isEnabled = YES;
static UIButton *unMirrorButton = nil;

static void loadSettings() {
	DebugLogC(@"loading settings");

	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PLIST_PATH];

	if (settings && settings[@"isEnabled"]) {
		DebugLogC(@"found settings: %@", settings);
		isEnabled = [settings[@"isEnabled"] boolValue];
	} else {
		DebugLogC(@"no user settings.");
	}
}


// iOS 7/8 Hooks ---------------------------------------------------------------

%group iOS_7_8

%hook CAMTopBar
- (id)initWithFrame:(CGRect)frame {
	DebugLog0;

	if ((self = %orig)) {

		// create FCUM button ...

		unMirrorButton = [UIButton buttonWithType:UIButtonTypeCustom];
		unMirrorButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		unMirrorButton.userInteractionEnabled = YES;
		unMirrorButton.selected = NO;
		unMirrorButton.hidden = YES;

		float fontSize = IS_IOS8 ? 12.0f : 11.0f;

		// normal state
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Un-Mirror" attributes:@{
			NSFontAttributeName: [UIFont fontWithName:@"DINAlternate-Bold" size:fontSize],
			NSKernAttributeName: @2.0,
			NSForegroundColorAttributeName: UIColor.whiteColor,
		}];
		[unMirrorButton setAttributedTitle:title forState:UIControlStateNormal];

		// selected state
		NSAttributedString *selectedTitle = [[NSAttributedString alloc] initWithString:@"Un-Mirrored" attributes:@{
			NSFontAttributeName: [UIFont fontWithName:@"DINAlternate-Bold" size:fontSize],
			NSKernAttributeName: @2.0,
			NSForegroundColorAttributeName: CAMERA_YELLOW,
		}];
		[unMirrorButton setAttributedTitle:selectedTitle forState:UIControlStateSelected];

		[unMirrorButton addTarget:self
						   action:@selector(fcum_unMirrorButtonPressed)
				 forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:unMirrorButton];
	}
	return self;
}
- (void)layoutSubviews {
	DebugLog0;
	%orig;

	unMirrorButton.frame = CGRectMake(10, 0, 90, self.bounds.size.height);

	if ([self fcum_isUsingFrontCamera]) {
		unMirrorButton.hidden = NO;
	} else {
		unMirrorButton.hidden = YES;
		unMirrorButton.selected = NO;
	}

	[self fcum_updatePreviewTransformation];
}
%new
- (BOOL)fcum_isUsingFrontCamera {
	BOOL result;
	int device = 10000; //unknown

	if (self.delegate) {
		if (IS_IOS8) {
			device = [((CAMCameraView *)(self.delegate)) cameraDevice];
		} else {
			device = [((PLCameraView *)(self.delegate)) cameraDevice];
		}
	}
	result = (device == CAMERA_DEVICE_FRONT);
	DebugLog(@"= %@", result ? @"YES" : @"NO");

	return result;
}
%new
- (void)fcum_unMirrorButtonPressed {
	DebugLog0;

	unMirrorButton.selected = !unMirrorButton.selected;
	[self fcum_updatePreviewTransformation];
}
%new
- (void)fcum_updatePreviewTransformation {
	DebugLog0;

	CGAffineTransform newTransform;

	if (unMirrorButton.selected) {
		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			// landscape gets a vertical flip
			newTransform = TRANSFORM_FLIP_V;
		} else {
			// portrait gets a horizontal flip
			newTransform = TRANSFORM_FLIP_H;
		}
	} else {
		// return to normal
		newTransform = CGAffineTransformIdentity;
	}

	if (self.delegate) {
		[self.delegate setPreviewViewTransform:newTransform];
	}
}
%end

%end

//

%group iOS_7_EXTRA

%hook PLCameraView
- (BOOL)_shouldHideFlashButtonForMode:(long long)mode {
	DebugLog0;

	// iOS 7 doesn't call layoutSubviews as often as iOS 8 when changing
	// camera modes, so let's call it layoutSubviews manually here.
	[self._topBar layoutSubviews];

	return %orig;
}
%end

%end


// iOS 9 Hooks -----------------------------------------------------------------

%group iOS_9

%hook CAMBottomBar
- (void)_commonCAMBottomBarInitialization {
	DebugLog0;
	%orig;
	
	[self fcum_createUnMirrorButton];
}
- (void)layoutSubviews {
	DebugLog0;
	%orig;

	// update position
	if (self.shutterButton) {
		CGPoint center = self.shutterButton.center;

		if (IS_IPAD) {
			// put button on top of shutter
			center.y -= 70;
		} else {
			// put button beside shutter
			center.x += 70;
		}

		unMirrorButton.center = center;
	}

	// update orientation
	if (self.imageWell && self.imageWell._thumbnailImageView) {
		unMirrorButton.transform = self.imageWell._thumbnailImageView.transform;
	}
}
%new
- (void)fcum_createUnMirrorButton {
	DebugLog0;
	
	// create FCUM button ...
	
	unMirrorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	unMirrorButton.frame = CGRectMake(0, 0, 30, 30);
	unMirrorButton.userInteractionEnabled = YES;
	unMirrorButton.selected = NO;
	unMirrorButton.hidden = YES;
	
	unMirrorButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	unMirrorButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	unMirrorButton.titleLabel.numberOfLines = 2;

	// normal state
	NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"UN MIR" attributes:@{
		NSFontAttributeName: [UIFont systemFontOfSize:10],
		NSKernAttributeName: @1.0,
		NSForegroundColorAttributeName: UIColor.whiteColor,
	}];
	[unMirrorButton setAttributedTitle:title forState:UIControlStateNormal];

	// selected state
	NSAttributedString *selectedTitle = [[NSAttributedString alloc] initWithString:@"UN MIR" attributes:@{
		NSFontAttributeName: [UIFont systemFontOfSize:10],
		NSKernAttributeName: @1.0,
		NSForegroundColorAttributeName: CAMERA_YELLOW,
	}];
	[unMirrorButton setAttributedTitle:selectedTitle forState:UIControlStateSelected];

	[unMirrorButton addTarget:self
					   action:@selector(fcum_unMirrorButtonPressed)
			 forControlEvents:UIControlEventTouchUpInside];

	[self addSubview:unMirrorButton];
}
%new
- (void)fcum_unMirrorButtonPressed {
	DebugLog0;

	unMirrorButton.selected = !unMirrorButton.selected;
	
	if ([self respondsToSelector:@selector(visibilityUpdateDelegate)]) { // iOS 9.3
		[self.visibilityUpdateDelegate fcum_updatePreviewTransformation];
	
	} else if ([self respondsToSelector:@selector(visibilityDelegate)]) { // iOS 9
		[self.visibilityDelegate fcum_updatePreviewTransformation];
	}
}
%end

%hook CAMViewfinderViewController
- (void)_didChangeToMode:(int)mode device:(int)device shouldProcessIdenticalChanges:(char)arg3 {
	DebugLog(@"changed to device=%d; mode=%d", device, mode);
	%orig;

	if (device == CAMERA_DEVICE_FRONT) {
		DebugLog(@"showing button");
		unMirrorButton.hidden = NO;
	} else {
		DebugLog(@"hiding+deselecting button");
		unMirrorButton.hidden = YES;
		unMirrorButton.selected = NO;
	}

	[self fcum_updatePreviewTransformation];
}
%new
- (void)fcum_updatePreviewTransformation {
	DebugLog0;

	CGAffineTransform newTransform;

	if (unMirrorButton.selected) {
		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			// landscape gets a vertical flip
			newTransform = TRANSFORM_FLIP_V;
		} else {
			// portrait gets a horizontal flip
			newTransform = TRANSFORM_FLIP_H;
		}
	} else {
		// return to normal
		newTransform = CGAffineTransformIdentity;
	}

	if (self._previewViewController) {
		CAMPreviewView *view = [self._previewViewController previewView];
		if (view) {
			DebugLog(@"transforming preview");
			view.transform = newTransform;
		}
	}
}
%end

%end


// iOS 10 Hooks ----------------------------------------------------------------

static CAMPreviewViewController *previewViewController;

%group iOS_10

%hook CAMBottomBar
- (void)layoutSubviews {
	DebugLog0;
	%orig;
	
	if (!unMirrorButton) {
		[self fcum_createUnMirrorButton];
	}
	
	// update position
	if (IS_IPAD) {
		// put fcum button above the shutter button
		CGPoint center = self.shutterButton.center;
		center.y -= 70;
		unMirrorButton.center = center;
	} else {
		// put fcum button left of the flip button
		CGPoint center = self.flipButton.center;
		center.x -= 55;
		center.y += 2;
		unMirrorButton.center = center;
	}
	
	// update orientation
	if (self.imageWell && self.imageWell._thumbnailImageView) {
		unMirrorButton.transform = self.imageWell._thumbnailImageView.transform;
	}
}
%new
- (void)fcum_createUnMirrorButton {
	DebugLog0;
	
	unMirrorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	unMirrorButton.frame = CGRectMake(0, 0, 36, 36);
	unMirrorButton.userInteractionEnabled = YES;
	unMirrorButton.selected = NO;
	unMirrorButton.hidden = YES;
	
	unMirrorButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	unMirrorButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	unMirrorButton.titleLabel.numberOfLines = 2;

	// normal state
	NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"UN MIR" attributes:@{
		NSFontAttributeName: [UIFont systemFontOfSize:11],
		NSKernAttributeName: @1.0,
		NSForegroundColorAttributeName: UIColor.whiteColor,
	}];
	[unMirrorButton setAttributedTitle:title forState:UIControlStateNormal];

	// selected state
	NSAttributedString *selectedTitle = [[NSAttributedString alloc] initWithString:@"UN MIR" attributes:@{
		NSFontAttributeName: [UIFont systemFontOfSize:11],
		NSKernAttributeName: @1.0,
		NSForegroundColorAttributeName: CAMERA_YELLOW,
	}];
	[unMirrorButton setAttributedTitle:selectedTitle forState:UIControlStateSelected];

	[unMirrorButton addTarget:self
					   action:@selector(fcum_unMirrorButtonPressed)
			 forControlEvents:UIControlEventTouchUpInside];

	[self addSubview:unMirrorButton];
}
%new
- (void)fcum_unMirrorButtonPressed {
	unMirrorButton.selected = !unMirrorButton.selected;
	HBLogInfo(@"FCUM button was pressed (is: %@)", unMirrorButton.selected?@"YES":@"NO");
	
	if (previewViewController) {
		HBLogInfo(@"calling for a transformation update");
		[previewViewController fcum_updatePreviewTransformation];
	}
}
%end

%hook CAMPreviewViewController
- (void)viewDidLoad {
	DebugLog0;
	%orig;
	previewViewController = self;
}
- (void)willChangeToMode:(int)mode device:(int)device {
	DebugLog(@"changed to device=%d; mode=%d", device, mode);
	%orig;
	
	if (device == CAMERA_DEVICE_FRONT) {
		DebugLog(@"showing button");
		unMirrorButton.hidden = NO;
		
		// Changing camera modes resets the preview to normal (not un-mirrored),
		// so turn off the button if it was previously on.
		unMirrorButton.selected = NO;
	} else {
		DebugLog(@"hiding button");
		unMirrorButton.hidden = YES;
		unMirrorButton.selected = NO;
	}
}
%new
- (void)fcum_updatePreviewTransformation {
	DebugLog0;

	CGAffineTransform newTransform;

	if (unMirrorButton.selected) {
		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			// landscape gets a vertical flip
			newTransform = TRANSFORM_FLIP_V;
		} else {
			// portrait gets a horizontal flip
			newTransform = TRANSFORM_FLIP_H;
		}
		DebugLog(@"Un-mirrored. Set new transform: %@", NSStringFromCGAffineTransform(newTransform));
	} else {
		// return to normal
		newTransform = CGAffineTransformIdentity;
		DebugLog(@"Not un-mirrored. Apply identity transform");
	}
	
	CAMPreviewView *view = self.previewView;
	if (view) {
		DebugLog(@"setting new transform.");
		view.transform = newTransform;
	}
}
%end

%end


//------------------------------------------------------------------------------

%ctor {
	@autoreleasepool {
		NSLog(@"FCUM baby!");

		loadSettings();

		if (!isEnabled) {
			NSLog(@"FCUM is disabled.");
			return;
		}
		
		if (IS_IOS_OR_NEWER(iOS_10_0)) {
			%init(iOS_10);
		} else if (IS_IOS_OR_NEWER(iOS_9_0)) {
			%init(iOS_9);
		} else {
			%init(iOS_7_8);
			if (IS_IOS7) {
				%init(iOS_7_EXTRA);
			}
		}
	}
}
