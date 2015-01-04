LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE    := cocos_lua_static

LOCAL_MODULE_FILENAME := liblua

LOCAL_SRC_FILES := ../cocos2dx_support/CCLuaBridge.cpp \
          ../cocos2dx_support/LuaCocos2dExtension.cpp \
          ../cocos2dx_support/CCLuaEngine.cpp \
          ../cocos2dx_support/CCLuaStack.cpp \
          ../cocos2dx_support/CCLuaValue.cpp \
          ../cocos2dx_support/Cocos2dxLuaLoader.cpp \
          ../cocos2dx_support/LuaCocos2d.cpp \
          ../cocos2dx_support/LuaCocoStudio.cpp \
          ../cocos2dx_support/CCBProxy.cpp \
          ../cocos2dx_support/Lua_extensions_CCB.cpp \
          ../cocos2dx_support/Lua_web_socket.cpp \
          ../cocos2dx_support/lua_cocos2dx_manual.cpp \
          ../cocos2dx_support/lua_cocos2dx_extensions_manual.cpp \
          ../cocos2dx_support/lua_cocos2dx_cocostudio_manual.cpp \
          ../tolua/tolua_event.c \
          ../tolua/tolua_is.c \
          ../tolua/tolua_map.c \
          ../tolua/tolua_push.c \
          ../tolua/tolua_to.c \
          ../crypt/md5lib.c \
          ../crypt/md5.c \
          ../crypt/ldes56.c \
          ../crypt/des56.c \
          ../crypt/lua_zlib.c \
          ../lfs/lfs.c \
          ../cjson/lua_cjson.c \
          ../cjson/strbuf.c \
          ../cjson/fpconv.c \
          ../cocos2dx_support/tolua_fix.c \
          ../xxtea/xxtea.cpp
          
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../luajit/include \
                           $(LOCAL_PATH)/../tolua \
                           $(LOCAL_PATH)/../cocos2dx_support \
                           $(LOCAL_PATH)/../xxtea
          
          
LOCAL_C_INCLUDES := $(LOCAL_PATH)/ \
                    $(LOCAL_PATH)/../luajit/include \
                    $(LOCAL_PATH)/../tolua \
                    $(LOCAL_PATH)/../crypt \
                    $(LOCAL_PATH)/../lfs \
                    $(LOCAL_PATH)/../cjson \
                    $(LOCAL_PATH)/../../../cocos2dx \
                    $(LOCAL_PATH)/../../../cocos2dx/include \
                    $(LOCAL_PATH)/../../../cocos2dx/platform \
                    $(LOCAL_PATH)/../../../cocos2dx/platform/android \
                    $(LOCAL_PATH)/../../../cocos2dx/kazmath/include \
                    $(LOCAL_PATH)/../../../CocosDenshion/include \
                    $(LOCAL_PATH)/../../../extensions \
                    $(LOCAL_PATH)/../../../extensions/GUI/CCEditBox \
                    $(LOCAL_PATH)/../../../extensions/Social \
                    $(LOCAL_PATH)/../../../extensions/Utils \
                    $(LOCAL_PATH)/../xxtea

LOCAL_WHOLE_STATIC_LIBRARIES := luajit_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_extension_static

LOCAL_CFLAGS += -Wno-psabi
LOCAL_EXPORT_CFLAGS += -Wno-psabi

include $(BUILD_STATIC_LIBRARY)

$(call import-module,scripting/lua/luajit)
$(call import-module,extensions)
