//
//  Headers.h
//  FrontCamUnMirror
//

/* iOS 7-8 */

@interface CAMFlipButton : UIButton
@end

@interface CAMTopBar : UIView
@property (nonatomic,retain) CAMFlipButton *flipButton;
- (id)delegate;
@end

@interface CAMBottomBar : UIView
@property (nonatomic,retain) CAMFlipButton *flipButton;
- (id)delegate;
@end


/* iOS 7 */

@interface PLCameraView : UIView
@property (nonatomic) long long cameraDevice;
@property (nonatomic) long long cameraMode;
@property (readonly, nonatomic) CAMTopBar *_topBar;
@property (readonly, nonatomic) CAMFlipButton *_flipButton;
- (void)setPreviewViewTransform:(CGAffineTransform)arg1;
@end
