//
//  Headers.h
//  FrontCamUnMirror
//
//  Private Apple interfaces.
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


/* iOS 9 */

@interface CAMImageWell : UIButton
@property (nonatomic, readonly) UIImageView * _thumbnailImageView;
@end

@interface CUShutterButton : UIButton
@end

@interface CAMBottomBar : UIView
@property (nonatomic, retain) CAMImageWell *imageWell;
@property (nonatomic, retain) CUShutterButton *shutterButton;
- (void)_commonCAMBottomBarInitialization;
- (id)visibilityDelegate; // iOS 9.0.x
- (id)visibilityUpdateDelegate; // newer
@end

@interface CAMPreviewView : UIView
@end

@interface CAMPreviewViewController : UIViewController
- (CAMPreviewView *)previewView;
@end

@interface CAMViewfinderViewController : UIViewController
@property (nonatomic, assign) int _currentMode;
@property (nonatomic, assign) int _currentDevice;
- (CAMPreviewViewController *)_previewViewController;
- (void)_didChangeToMode:(int)arg1 device:(int)arg2 shouldProcessIdenticalChanges:(char)arg3;
@end
