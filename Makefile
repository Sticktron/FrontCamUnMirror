ARCHS = armv7 arm64
TARGET = iphone:clang:10.2:7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FrontCamUnMirror
FrontCamUnMirror_CFLAGS = -fobjc-arc
FrontCamUnMirror_FILES = FrontCamUnMirror.xm
FrontCamUnMirror_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Settings
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	find $(FW_STAGING_DIR) -name '.DS_STORE' -exec rm {} \;

after-install::
	install.exec "killall -9 SpringBoard"
