THEOS_DEVICE_IP = localhost 
THEOS_DEVICE_PORT = 2222

include $(THEOS)/makefiles/common.mk

SRC = $(wildcard src/*.m)

TWEAK_NAME = WeChatPlugin
WeChatPlugin_FILES =  $(wildcard src/*.m) $(wildcard src/*.xm)

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
