//
//  Headers.h
//  FrontCamUnMirror
//

/* iOS 7 and 8 */
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


/* iOS 9/10 */

@interface CAMImageWell : UIButton
@property (nonatomic, readonly) UIImageView * _thumbnailImageView;
@end

@interface CUShutterButton : UIButton
@end

@interface CAMFlipButton : UIButton
@end

@interface CAMBottomBar : UIView
@property (nonatomic, retain) CAMImageWell *imageWell;
@property (nonatomic, retain) CUShutterButton *shutterButton;
@property (nonatomic, retain) CAMFlipButton *flipButton;
- (void)_commonCAMBottomBarInitialization; // 9
- (void)_commonCAMBottomBarInitializationInitWithLayoutStyle:(int)arg1; // 10
- (id)visibilityDelegate; // 9.0.x
- (id)visibilityUpdateDelegate; // >9.0.x
@end

@interface CAMPreviewView : UIView
@end

@interface CAMPreviewViewController : UIViewController
- (CAMPreviewView *)previewView;
- (void)willChangeToMode:(int)arg1 device:(int)arg2;
- (void)didChangeToMode:(int)arg1 device:(int)arg2 animated:(BOOL)arg3;
- (void)_didChangeModeOrDevice;
- (void)_updateVideoPreviewViewOrientationAnimated:(BOOL)arg1;
@end

@interface CAMViewfinderViewController : UIViewController
@property (nonatomic, assign) int _currentMode;
@property (nonatomic, assign) int _currentDevice;
- (CAMPreviewViewController *)_previewViewController;
- (void)_openViewfinderForAllModeAndDeviceChangeReasons;
- (void)_closeViewfinderForChangeFromMode:(int)arg1 toMode:(int)mode fromDevice:(int)arg3 toDevice:(int)device;
- (void)_didChangeToMode:(int)arg1 device:(int)arg2 shouldProcessIdenticalChanges:(char)arg3;
- (void)changeToMode:(int)arg1 device:(int)arg2;
- (void)changeToMode:(int)arg1 device:(int)arg2 animated:(BOOL)arg3;
- (void)_handleUserChangedToDevice:(int)arg1;
- (void)_handleUserChangedToMode:(int)arg1;
- (void)_handleUserChangedToMode:(int)arg1 device:(int)arg2;
- (void)_showControlsForGraphConfiguration:(id)arg1 animated:(BOOL)arg2;
@end
