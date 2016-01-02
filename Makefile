ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0

THEOS_BUILD_DIR = Packages

TWEAK_NAME = FrontCamUnMirror
FrontCamUnMirror_CFLAGS = -fobjc-arc
FrontCamUnMirror_FILES = FrontCamUnMirror.xm
FrontCamUnMirror_FRAMEWORKS = UIKit CoreGraphics
FrontCamUnMirror_PRIVATEFRAMEWORKS = CameraUI CameraKit PhotoLibrary

SUBPROJECTS += Settings

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	find $(FW_STAGING_DIR) -name '.DS_STORE' -exec rm {} \;
	find $(FW_STAGING_DIR) -iname '*.plist' -or -iname '*.strings' -exec plutil -convert binary1 {} \;
	find $(FW_STAGING_DIR) -iname '*.png' -exec pincrush-osx -i {} \;

after-install::
	install.exec "killall -9 SpringBoard"
