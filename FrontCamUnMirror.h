//
//  FrontCamUnMirror.h
//  FCUM
//
//  Created by Sticktron in 2014. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class AVCaptureSession, AVCaptureConnection;

//--------------------------------------------------------------------------------------------------

@interface CAMButtonLabel : UIView {
    UILabel *__label;
}
@property(readonly, nonatomic) UILabel *_label; // @synthesize _label=__label;
@end

//--------------------------------------------------------------------------------------------------

@interface CAMFlashButton : UIControl {
    CAMButtonLabel *__autoLabel;
}
@property(readonly, nonatomic) CAMButtonLabel *_autoLabel; // @synthesize _autoLabel=__autoLabel;
@end

//--------------------------------------------------------------------------------------------------

@interface CAMTopBar : UIView
@property(retain, nonatomic) CAMFlashButton *flashButton; // @synthesize flashButton=_flashButton;
@property(nonatomic) long long style; // @synthesize style=_style;
//- (void)flashButtonDidCollapse:(id)arg1;
//- (void)flashButtonWillExpand:(id)arg1;
//- (void)flashButtonWasPressed:(id)arg1;
//- (void)flashButtonModeDidChange:(id)arg1;
- (void)_layoutFloatingRecordingStyle;
- (void)_layoutFloatingStyle;
- (void)_layoutDefaultStyle;
- (struct UIEdgeInsets)_backgroundEdgeInsetsForStyle:(long long)arg1;
- (BOOL)_shouldHideHDRButton;
- (BOOL)_shouldHideElapsedTimeView;
- (void)_updateHiddenViewsForFlashExpansion;
- (void)_updateBackgroundStyleAnimated:(_Bool)arg1;
- (void)_updateStyleAnimated:(_Bool)arg1;
- (void)setBackgroundStyle:(long long)arg1 animated:(_Bool)arg2;
- (void)setStyle:(long long)arg1 animated:(BOOL)arg2;
- (void)layoutSubviews;
- (struct CGSize)sizeThatFits:(struct CGSize)arg1;
- (void)_commonCAMTopBarInitialization;
@end

//--------------------------------------------------------------------------------------------------

@interface PLCameraView : UIView
{
    struct CGAffineTransform _previewTransform;
}
@property(readonly, nonatomic) CAMTopBar *_topBar; // @synthesize _topBar=__topBar;
@property(readonly, nonatomic) BOOL _switchingBetweenCameras;
- (void)cameraControllerSessionDidStart:(id)arg1;
- (void)cameraControllerPreviewDidStart:(id)arg1;
- (void)cameraControllerModeDidChange:(id)arg1;
- (void)cameraController:(id)arg1 willChangeToMode:(long long)arg2 device:(long long)arg3;
- (void)_createTopBarIfNecessary;
- (void)setPreviewViewTransform:(struct CGAffineTransform)arg1;
- (void)_updateTopBarOrientationWithDeviceOrientation:(long long)arg1;
- (void)_layoutTopBarForOrientation:(long long)arg1;
- (void)_updateTopBarStyleForDeviceOrientation:(long long)arg1;
- (void)_flipToBlurredPreviewWithCompletionBlock:(id)arg1;
- (BOOL)_shouldHideHDRButtonForMode:(long long)arg1;
- (void)_showControlsForChangeToMode:(long long)arg1 animated:(BOOL)arg2;
- (void)_hideControlsForChangeToMode:(long long)arg1 animated:(BOOL)arg2;
- (BOOL)_shouldEnableHDRButton;
- (void)_updateEnabledControlsWithReason:(id)arg1;
@end

//--------------------------------------------------------------------------------------------------


@interface PLCameraViewController : UIViewController
@end


//--------------------------------------------------------------------------------------------------

@interface PLApplicationCameraViewController : PLCameraViewController
- (id)initWithSessionID:(id)arg1 startPreviewImmediately:(_Bool)arg2;
- (void)cameraViewDidFinishUnblurringForPreview:(id)arg1;
- (id)cameraButtonBar;
- (void)setupForCameraStart;
- (void)_startCameraPreviewWithPreviewStartedBlock:(id)arg1;
- (BOOL)_shouldResetMode:(id)arg1;
- (void)_defaultCameraDevice:(id *)arg1 cameraMode:(id *)arg2;
@end

//--------------------------------------------------------------------------------------------------

@interface DeferredPUApplicationCameraViewController : PLApplicationCameraViewController
- (id)initForCurrentPlatformWithSessionID:(id)arg1 usesCameraLocationBundleID:(_Bool)arg2 startPreviewImmediately:(_Bool)arg3;
- (id)initForCurrentPlatformWithSessionID:(id)arg1 startPreviewImmediately:(_Bool)arg2;
- (id)_initWithSessionID:(id)arg1 usesCameraLocationBundleID:(_Bool)arg2 startPreviewImmediately:(_Bool)arg3;
@end

//--------------------------------------------------------------------------------------------------

@interface PLCameraController : NSObject
- (void)startPreview;
- (void)startPreview:(id)arg1;
- (void)_startPreview:(id)arg1;
- (void)_startPreviewWithCameraDevice:(long long)arg1 cameraMode:(long long)arg2 effectFilterIndices:(id)arg3;
- (void)_setCameraMode:(long long)arg1 cameraDevice:(long long)arg2;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
@end

//--------------------------------------------------------------------------------------------------

@protocol UIImagePickerCameraViewController <NSObject>
- (void)_stopVideoCapture;
- (_Bool)_startVideoCapture;
- (void)_setCameraFlashMode:(long long)arg1;
- (long long)_cameraFlashMode;
- (void)_setCameraCaptureMode:(long long)arg1;
- (long long)_cameraCaptureMode;
- (void)_setCameraDevice:(long long)arg1;
- (long long)_cameraDevice;
- (void)_takePicture;
- (void)_setCameraViewTransform:(struct CGAffineTransform)arg1;
- (struct CGAffineTransform)_cameraViewTransform;
- (void)_setCameraOverlayView:(id)arg1;
- (id)_cameraOverlayView;
- (void)_setShowsCameraControls:(_Bool)arg1;
- (_Bool)_showsCameraControls;
@end

//--------------------------------------------------------------------------------------------------
@interface PLUICameraViewController : PLCameraViewController
{
    long long _previousStatusBarStyle;
    long long _newStatusBarStyle;
    struct CGAffineTransform _previewViewTransform;
}
- (id)init;
- (void)_setCameraCaptureMode:(long long)arg1;
- (void)_setCameraViewTransform:(CGAffineTransform)arg1;
- (CGAffineTransform)_cameraViewTransform;
- (void)_setCameraOverlayView:(id)arg1;
- (void)viewDidLayoutSubviews;
- (long long)_imagePickerStatusBarStyle;
- (void)loadView;
- (id)_cameraView;
@end

//--------------------------------------------------------------------------------------------------

@interface UIImagePickerController (FCUM_Privates)
- (id)_cameraViewController;
- (id)_createInitialController;
- (void)_setupControllersForCurrentMediaTypes;
- (void)_setupControllersForCurrentSourceType;
- (BOOL)_sourceTypeIsCamera;
- (void)_updateCameraCaptureMode;
@end

//--------------------------------------------------------------------------------------------------

