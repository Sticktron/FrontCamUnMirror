ARCHS = armv7 armv7s arm64

TARGET = iphone:clang:latest:7.0

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

TWEAK_NAME = FrontCamUnMirror
FrontCamUnMirror_CFLAGS = -fobjc-arc
FrontCamUnMirror_FILES = FrontCamUnMirror.xm
FrontCamUnMirror_FRAMEWORKS = Foundation UIKit CoreGraphics
FrontCamUnMirror_PRIVATEFRAMEWORKS = PhotoLibrary

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
