//
//  FrontCamUnMirror.xm
//  FrontCamUnMirror
//
//  Un-mirror the camera preview when taking selfies.
//
//  Copyright (C) 2014-2015 Sticktron. All rights reserved.
//
//

#define DEBUG_PREFIX @"••••• [FCUM]"
#import "DebugLog.h"


@interface CAMTopBar : UIView
- (id)delegate;
@end

@interface CAMCameraView : UIView // iOS 8 API
@property (assign,nonatomic) int cameraDevice;
- (void)setPreviewViewTransform:(CGAffineTransform)arg1;
@end

@interface PLCameraView : UIView // iOS 7 API
@property(nonatomic) int cameraDevice;
@property(readonly, nonatomic) CAMTopBar *_topBar;
- (void)setPreviewViewTransform:(CGAffineTransform)arg1;
@end

@interface CAMTopBar (FCUM)
- (void)unMirrorButtonPressed;
- (void)updatePreviewTransformation;
@end


#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.10
#endif

#define IS_IOS7 (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0)

#define TRANSFORM_FLIP_H		CGAffineTransformMake(-1, 0, 0, 1, 0, 0)
#define TRANSFORM_FLIP_V		CGAffineTransformMake(1, 0, 0, -1, 0, 0)

#define CAMERA_YELLOW			[UIColor colorWithRed:1.0 green:0.8 blue:0 alpha:1]

#define BUTTON_TITLE			@"Un-Mirror"
#define BUTTON_TITLE_SELECTED	@"Un-Mirrored"

#define CAMERA_MODE_PHOTO		0
#define CAMERA_MODE_VIDEO		1
#define CAMERA_MODE_SLOMO		2
#define CAMERA_MODE_PANO		3
#define CAMERA_MODE_SQUARE		4

#define CAMERA_DEVICE_REAR		0
#define CAMERA_DEVICE_FRONT		1

#define PREFS_ID				CFSTR("com.sticktron.fcum")


static UIButton *unMirrorButton = nil;
static BOOL isEnabled = YES;


static inline UIButton *createUnMirrorButton() {
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

static inline BOOL isUsingFrontCamera(id cameraView) {
	int device;
	if (IS_IOS7) {
		device = [((PLCameraView *)cameraView) cameraDevice];
	} else {
		device = [((CAMCameraView *)cameraView) cameraDevice];
	}
	return (device == CAMERA_DEVICE_FRONT);
}

static inline void loadSettings() {
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

static inline void reloadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	loadSettings();
}



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
	
	if (isUsingFrontCamera(self.delegate) && isEnabled) {
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



%group iOS7

%hook PLCameraView
- (BOOL)_shouldHideFlashButtonForMode:(long long)mode {
	// iOS 7 doesn't call layoutSubviews as often as iOS 8 when changing
	// camera modes, but this method is called at the right times, so
	// we'll use to it call layoutSubviews manually.
	[self._topBar layoutSubviews];
	return %orig;
}
%end

%end



%ctor {
	@autoreleasepool {
		NSLog(@"FCUM baby!");
		
		loadSettings();
		
		%init;
		if (IS_IOS7) {
			%init(iOS7);
		}
		
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)reloadSettings,
										CFSTR("com.sticktron.fcum.settingschanged"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately);
	}
}

