//
//  Headers.h
//  FrontCamUnMirror
//

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
- (BOOL)_shouldHideFlashButtonForMode:(long long)mode;
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
- (void)changeToMode:(int)arg1 device:(int)arg2;
- (void)_changeToMode:(int)arg1 device:(int)arg2;
- (void)changeToMode:(int)arg1 device:(int)arg2 animated:(char)arg3;
- (void)_didChangeToMode:(int)arg1 device:(int)arg2 shouldProcessIdenticalChanges:(char)arg3;
@end
