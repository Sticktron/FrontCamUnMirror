//
//  FrontCamUnMirror.xm
//  FrontCamUnMirror
//
//  Un-mirror the camera preview when taking selfies.
//  Supports iOS 7-9.
//
//  Copyright © 2014-2016 Sticktron. All rights reserved.
//

#define DEBUG_PREFIX @"••••• [FCUM]"
#import "DebugLog.h"
#import "Headers.h"


@interface CAMTopBar (FCUM)
- (void)unMirrorButtonPressed;
- (void)updatePreviewTransformation;
@end

@interface CAMBottomBar (FCUM)
- (UIButton *)_fcum_createUnMirrorButton;
- (void)_fcum_handleUnMirrorButton;
@end

@interface CAMViewfinderViewController (FCUM)
- (void)_fcum_updatePreviewTransformation;
@end


#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.10
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_9_0
#define kCFCoreFoundationVersionNumber_iOS_9_0 1240.10
#endif

#define IS_IOS7 (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0)
#define IS_IOS8 ((kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) && (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_9_0))
#define IS_IOS9 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_9_0)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

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

// iOS 7/8
#define BUTTON_TITLE			@"Un-Mirror"
#define BUTTON_TITLE_SELECTED	@"Un-Mirrored"

#define PREFS_ID				CFSTR("com.sticktron.fcum")


static UIButton *unMirrorButton = nil;
static BOOL isEnabled = YES;


static void loadSettings() {
	NSDictionary *settings = nil;

	CFPreferencesAppSynchronize(PREFS_ID);
	CFArrayRef keyList = CFPreferencesCopyKeyList(PREFS_ID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

	if (keyList) {
		settings = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, PREFS_ID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
		DebugLogC(@"loaded settings: %@", settings);
	}

	isEnabled = settings[@"isEnabled"] ? [settings[@"isEnabled"] boolValue] : YES;
}

// iOS 7/8
static UIButton *createUnMirrorButton() {
	UIButton *unMirrorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	unMirrorButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	unMirrorButton.userInteractionEnabled = YES;
	unMirrorButton.selected = NO;
	unMirrorButton.hidden = YES;

	float fontSize = IS_IOS7 ? 11.0f : 12.0f;
	unMirrorButton.titleLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:fontSize];

	// normal state
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:BUTTON_TITLE];
	[attributedString addAttribute:NSKernAttributeName value:@2 range:NSMakeRange(0, [BUTTON_TITLE length])];
	[attributedString addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, [BUTTON_TITLE length])];
	[unMirrorButton setAttributedTitle:attributedString forState:UIControlStateNormal];
	//[unMirrorButton setImage:[UIImage imageWithContentsOfFile:kMirrorButtonImagePath] forState:UIControlStateNormal];

	// selected state
	NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:BUTTON_TITLE_SELECTED];
	[attributedString2 addAttribute:NSKernAttributeName value:@2 range:NSMakeRange(0, [BUTTON_TITLE_SELECTED length])];
	[attributedString2 addAttribute:NSForegroundColorAttributeName value:CAMERA_YELLOW range:NSMakeRange(0, [BUTTON_TITLE_SELECTED length])];
	[unMirrorButton setAttributedTitle:attributedString2 forState:UIControlStateSelected];
	//[unMirrorButton setImage:[UIImage imageWithContentsOfFile:kMirrorButtonImagePath] forState:UIControlStateSelected];

	return unMirrorButton;
}

// iOS 7/8
static BOOL isUsingFrontCamera(id cameraView) {
	int device;
	if (IS_IOS7) {
		device = [((PLCameraView *)cameraView) cameraDevice];
	} else {
		device = [((CAMCameraView *)cameraView) cameraDevice];
	}
	return (device == CAMERA_DEVICE_FRONT);
}


//------------------------------------------------------------------------------
// Hooks for iOS 7/8
//------------------------------------------------------------------------------

%group iOS_7_8

%hook CAMTopBar

- (id)initWithFrame:(CGRect)frame {
	self = %orig;
	if (self) {

		unMirrorButton = createUnMirrorButton();

		[unMirrorButton addTarget:self
						   action:@selector(handleUnMirrorButton)
				 forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:unMirrorButton];
	}
	return self;
}

- (void)layoutSubviews {
	DebugLog0;
	%orig;

	unMirrorButton.frame = CGRectMake(10, 0, 90, self.bounds.size.height);

	if (isUsingFrontCamera(self.delegate)) {
		unMirrorButton.hidden = NO;
	} else {
		unMirrorButton.hidden = YES;
		unMirrorButton.selected = NO;
	}

	[self updatePreviewTransformation];
}

%new
- (void)handleUnMirrorButton {
	unMirrorButton.selected = !unMirrorButton.selected;
	[self updatePreviewTransformation];
}

%new
- (void)updatePreviewTransformation {
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

	[self.delegate setPreviewViewTransform:newTransform];
}

%end

%end //grp


//------------------------------------------------------------------------------
// Hooks for iOS 7
//------------------------------------------------------------------------------

%group iOS_7

%hook PLCameraView
- (BOOL)_shouldHideFlashButtonForMode:(long long)mode {
	// iOS 7 doesn't call layoutSubviews as often as iOS 8 when changing
	// camera modes, but this method is called at the right times, so
	// we'll use to it call layoutSubviews manually.
	[self._topBar layoutSubviews];
	return %orig;
}
%end

%end //grp


//------------------------------------------------------------------------------
// Hooks for iOS 9
//------------------------------------------------------------------------------

%group iOS_9

%hook CAMBottomBar

- (id)initWithFrame:(CGRect)frame {
	self = %orig;
	if (self) {

		if (!unMirrorButton) {
			unMirrorButton = [self _fcum_createUnMirrorButton];
		}
		DebugLog(@"unMirrorButton=%@", unMirrorButton);

		[unMirrorButton addTarget:self
						   action:@selector(_fcum_handleUnMirrorButton)
				 forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:unMirrorButton];
	}
	return self;
}

- (void)layoutSubviews {
	DebugLog0;
	%orig;

	// update position
	if (self.shutterButton) {
		unMirrorButton.center = self.shutterButton.center;

		CGRect frame = unMirrorButton.frame;
		frame.origin.x += 60;
		unMirrorButton.frame = frame;
	}

	// update orientation
	if (self.imageWell) {
		unMirrorButton.transform = self.imageWell._thumbnailImageView.transform;
	}
}

%new
- (UIButton *)_fcum_createUnMirrorButton {
	DebugLog0;

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

	button.frame = CGRectMake(0, 0, 30, 30);
	//button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
	button.userInteractionEnabled = YES;
	button.selected = NO;

	button.titleLabel.textAlignment = NSTextAlignmentCenter;
	button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	button.titleLabel.numberOfLines = 2;

	button.titleLabel.font = [UIFont systemFontOfSize:10];
	//button.titleLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:10];

	NSString *title = @"UN MIR";

	// normal state
	NSMutableAttributedString *normalTitle = [[NSMutableAttributedString alloc] initWithString:title];
	[normalTitle addAttribute:NSKernAttributeName value:@1 range:NSMakeRange(0, title.length)];
	[normalTitle addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, title.length)];
	[button setAttributedTitle:normalTitle forState:UIControlStateNormal];
	//[unMirrorButton setImage:[UIImage imageWithContentsOfFile:kMirrorButtonImagePath] forState:UIControlStateNormal];

	// selected state
	NSMutableAttributedString *selectedTitle = [[NSMutableAttributedString alloc] initWithString:title];
	[selectedTitle addAttribute:NSKernAttributeName value:@1 range:NSMakeRange(0, title.length)];
	[selectedTitle addAttribute:NSForegroundColorAttributeName value:CAMERA_YELLOW range:NSMakeRange(0, title.length)];
	[button setAttributedTitle:selectedTitle forState:UIControlStateSelected];

	return button;
}

%new
- (void)_fcum_handleUnMirrorButton {
	unMirrorButton.selected = !unMirrorButton.selected;

	if (self.visibilityDelegate) {
		[self.visibilityDelegate _fcum_updatePreviewTransformation];
	}
}

%end


%hook CAMViewfinderViewController
- (void)_didChangeToMode:(int)mode device:(int)device shouldProcessIdenticalChanges:(char)arg3 {
	DebugLog0;
	%orig;

	DebugLog(@"changed to device=%d; mode=%d", device, mode);

	if (device == CAMERA_DEVICE_FRONT) {
		DebugLog(@"showing FCUM button");
		unMirrorButton.hidden = NO;
	} else {
		DebugLog(@"hiding FCUM button");
		unMirrorButton.hidden = YES;
		unMirrorButton.selected = NO;
	}

	[self _fcum_updatePreviewTransformation];
}

%new
- (void)_fcum_updatePreviewTransformation {
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
		DebugLog(@"CAMPrevieWView=%@", view);
		if (view) {
			view.transform = newTransform;
		}
	}
}

%end

%end //grp


//------------------------------------------------------------------------------


%ctor {
	@autoreleasepool {
		loadSettings();
		NSLog(@"FCUM baby! (%@)", isEnabled?@"Enabled":@"Disabled");

		if (isEnabled) {
			if (IS_IOS9) {
				NSLog(@"FCUM: init for iOS 9+");
				%init(iOS_9);
			} else {
				NSLog(@"FCUM: init for iOS 7/8");
				%init(iOS_7_8);
				if (IS_IOS7) {
					%init(iOS_7);
				}
			}
		}
	}
}
