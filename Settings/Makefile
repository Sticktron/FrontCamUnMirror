ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0

include theos/makefiles/common.mk

BUNDLE_NAME = FrontCamUnMirror
FrontCamUnMirror_CFLAGS = -fobjc-arc
FrontCamUnMirror_FILES = FCUMSettings.mm
FrontCamUnMirror_FRAMEWORKS = UIKit Social
FrontCamUnMirror_PRIVATE_FRAMEWORKS = Preferences
FrontCamUnMirror_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FrontCamUnMirror.plist$(ECHO_END)
