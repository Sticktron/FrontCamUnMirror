//
//  FrontCamUnMirror.xm
//  FCUM
//
//  Created by Sticktron in 2014. All rights reserved.
//
//

#import "FrontCamUnMirror.h"


//--------------------------------------------------------------------------------------------------
#define __DEBUG_ON__
#ifdef __DEBUG_ON__
	#define DebugLog(s, ...) \
		NSLog(@" [FrontCamUnMirror] %@", [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
	#define DebugLog(s, ...)
#endif
//--------------------------------------------------------------------------------------------------



#define kMirrorButtonImagePath			@"/Library/Application Support/FrontCamUnMirror/mirror.png"
#define kMirrorButtonTitleMirrored		@"Mirrored"
#define kMirrorButtonTitleUnMirrored	@"Un-Mirrored"
#define kMirrorButtonFontName			@"DINAlternate-Bold"
#define kMirrorButtonFontSize			11.0f
#define kMirrorButtonTitleInsets		(UIEdgeInsets){ .left = 6.0f, .top = 2.0f, .right = 0, .bottom = 0 }
#define kMirrorButtonMarginLeft			9.0f

#define kTransformMirrorH				CGAffineTransformMake(-1, 0, 0, 1, 0, 0)

// Apple's constants, my names
#define kCameraModePhoto	0
#define kCameraModeVideo	1
#define kCameraModeSloMo	2
#define kCameraModePano		3
#define kCameraModeSquare	4


// globals (file-scope)
static UIButton *mirrorButton = nil;
static PLCameraView *cameraView = nil;





//--------------------------------------------------------------------------------------------------
// New Class Members
//--------------------------------------------------------------------------------------------------
@interface PLCameraView (FCUM)
- (void)handleMirrorButtonTap;
- (void)mirrorPreview;
@end
//--------------------------------------------------------------------------------------------------





//--------------------------------------------------------------------------------------------------
%hook CAMTopBar
//--------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
	self = %orig;
	
	// create mirror button if needed
	
	if (!mirrorButton) {
		mirrorButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
		mirrorButton.frame = CGRectMake(0, 0, 90.0f, 40.0f);
		
		mirrorButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		mirrorButton.userInteractionEnabled = YES;
		mirrorButton.hidden = YES;
		mirrorButton.selected = NO;
		
		mirrorButton.titleLabel.font = [UIFont fontWithName:kMirrorButtonFontName size:kMirrorButtonFontSize];
		mirrorButton.titleEdgeInsets = kMirrorButtonTitleInsets;
		
		// config normal state
		[mirrorButton setTitle:kMirrorButtonTitleMirrored forState:UIControlStateNormal];
		[mirrorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[mirrorButton setImage:[UIImage imageWithContentsOfFile:kMirrorButtonImagePath] forState:UIControlStateNormal];
		
		// config selected state
		[mirrorButton setTitle:kMirrorButtonTitleUnMirrored forState:UIControlStateSelected];
		[mirrorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
		[mirrorButton setImage:[UIImage imageWithContentsOfFile:kMirrorButtonImagePath] forState:UIControlStateSelected];
	}
	
	// setup tap action
	[mirrorButton addTarget:cameraView
					 action:@selector(handleMirrorButtonTap)
		   forControlEvents:UIControlEventTouchUpInside];
	
	// add to view
	[self addSubview:mirrorButton];
	
	return self;
}

- (void)layoutSubviews {
	%orig;
	
	// layout mirror button
	float top = (self.bounds.size.height - mirrorButton.frame.size.height) / 2.0f;
	CGPoint origin = CGPointMake(kMirrorButtonMarginLeft, top);
	mirrorButton.frame = (CGRect){origin, mirrorButton.frame.size};
}

%end
//--------------------------------------------------------------------------------------------------





//--------------------------------------------------------------------------------------------------
%hook PLCameraView
//--------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)arg1 spec:(id)arg2 {
	DebugLog(@"initWithFrame:%@ spec:%@", NSStringFromCGRect(arg1), arg2);
	
	// save this reference so we can use it in another class
	cameraView = %orig;
	
	return cameraView;
}

- (BOOL)_shouldHideFlashButtonForMode:(long long)mode {
	BOOL result = %orig;
	
	// The Flash Button doesn't show up when the front camera is active,
	// since no devices have a flash on the front (yet?).
	//
	// Let's use this information to determine when the front camera is active.
	// TODO: find a more concrete way to make this determination.
	//
	
	DebugLog(@"PLCameraView::_shouldHideFlashButtonForMode(%lld) returning %@", mode, result?@"YES":@"NO");
	
	// Pano & SloMo modes don't use the front camera, so make sure we put things back to normal
	if (mode == kCameraModePano || mode == kCameraModeSloMo) {
		DebugLog(@"mode is Pano or SloMo (%lld)", mode);
		
		mirrorButton.hidden = YES;
		if (mirrorButton.selected) {
			mirrorButton.selected = NO;
			[self mirrorPreview];
		}
		
	} else {
		DebugLog(@"mode is not Pano or SloMo (%lld)", mode);
		// show mirror button when hiding flash button and vice-versa
		mirrorButton.hidden = !result;
	}
	
	return result;
}

%new
- (void)handleMirrorButtonTap {
	DebugLog(@"Mirror Button was tapped");
	
	// change button state
	mirrorButton.selected = !mirrorButton.selected;
	
	// flip the mirror state
	[self mirrorPreview];
}

%new
- (void)mirrorPreview {
	DebugLog(@"Flipping Preview.................");
	
	// this is current preview transformation
	CGAffineTransform currentTransform = MSHookIvar<CGAffineTransform>(self, "_previewTransform");
	DebugLog(@"current transformation = %@", NSStringFromCGAffineTransform(currentTransform));
	
	// apply the mirror-h transform to the current transform
	CGAffineTransform newTransform = CGAffineTransformConcat(currentTransform, kTransformMirrorH);
	DebugLog(@"new transformation = %@", NSStringFromCGAffineTransform(newTransform));
	
	// apply the result to the view
	[self setPreviewViewTransform:newTransform];
	
	DebugLog(@"Done.............................");
}

%end
//--------------------------------------------------------------------------------------------------





//--------------------------------------------------------------------------------------------------
// Constructor
//--------------------------------------------------------------------------------------------------
%ctor {
	@autoreleasepool {
		NSLog(@" FCUM, baby");
		%init;
	}
}
//--------------------------------------------------------------------------------------------------

