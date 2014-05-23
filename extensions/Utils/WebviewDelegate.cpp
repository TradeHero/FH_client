#include "cocos2d.h"
#include "WebviewDelegate.h"
#include "CCLuaEngine.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "WebviewController.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#endif

USING_NS_CC;

namespace Utils
{
	static WebviewDelegate* s_sharedUtils;

	WebviewDelegate::WebviewDelegate()
	{

	}

	WebviewDelegate::~WebviewDelegate()
	{

	}

	WebviewDelegate* WebviewDelegate::sharedDelegate()
	{
		if (s_sharedUtils == NULL)
		{
			s_sharedUtils = new WebviewDelegate();
		}
		return s_sharedUtils;
	}

	void WebviewDelegate::openWebpage(const char* url, int x, int y, int w, int h)
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		WebviewController::getInstance()->openWebpage(url, x, y, w, h);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#endif
	}

	void WebviewDelegate::closeWebpage()
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		WebviewController::getInstance()->closeWebpage();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#endif
	}
}