//
//  FrontCamUnMirror.h
//  FrontCamUnMirror
//

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.10
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_9_0
#define kCFCoreFoundationVersionNumber_iOS_9_0 1240.10
#endif

#define IS_IOS7 (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0)
#define IS_IOS8 ((kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) && (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_9_0))
#define IS_AT_LEAST_IOS9 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_9_0)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


/* iOS 7/8 */

@interface CAMTopBar : UIView
- (id)delegate;
@end


/* iOS 7 */

@interface PLCameraView : UIView
@property (nonatomic, assign) int cameraDevice;
@property (nonatomic, assign) int cameraMode;
@property (nonatomic, readonly) CAMTopBar *_topBar;
- (void)setPreviewViewTransform:(CGAffineTransform)arg1;
- (BOOL)_shouldHideFlashButtonForMode:(int)mode;
@end


/* iOS 8 */

@interface CAMCameraView : UIView
@property (nonatomic, assign) int cameraDevice;
@property (nonatomic, assign) int cameraMode;
- (void)setPreviewViewTransform:(CGAffineTransform)arg1;
- (BOOL)_shouldHideFlashButtonForMode:(int)mode;
@end


/* iOS 9 */

@interface CAMImageWell : UIButton
@property (nonatomic, readonly) UIImageView * _thumbnailImageView;
@end

@interface CUShutterButton : UIButton
@end

@interface CAMBottomBar : UIView
@property (nonatomic, retain) CAMImageWell *imageWell;
@property (nonatomic, retain) CUShutterButton *shutterButton;
- (id)visibilityDelegate;
- (void)_commonCAMBottomBarInitialization;
@end

@interface CAMPreviewView : UIView
@end

@interface CAMPreviewViewController : UIViewController
- (CAMPreviewView *)previewView;
@end

@interface CAMViewfinderViewController : UIViewController
@property (nonatomic, assign) int _currentMode;                                                                                                                                     //@synthesize _currentMode=__currentMode - In the implementation block
@property (nonatomic, assign) int _currentDevice;                                                                                                                                 //@synthesize _currentDevice=__currentDevice - In the implementation block
- (CAMPreviewViewController *)_previewViewController;
- (void)_didChangeToMode:(int)arg1 device:(int)arg2 shouldProcessIdenticalChanges:(char)arg3;
@end
