ARCHS = armv7 armv7s arm64

TARGET = iphone:clang:latest:7.0

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

TWEAK_NAME = FCUM
FCUM_CFLAGS = -fobjc-arc
FCUM_FILES = FrontCamUnMirror.xm
FCUM_FRAMEWORKS = Foundation UIKit CoreGraphics AVFoundation
FCUM_PRIVATEFRAMEWORKS = PhotoLibrary

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
