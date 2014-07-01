#include "cocos2d.h"
#include "Analytics.h"
#include "CCLuaEngine.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "AnalyticsHandler.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#endif

USING_NS_CC;

namespace Utils
{
	static Analytics* s_sharedUtils;

	Analytics::Analytics()
	{

	}

	Analytics::~Analytics()
	{

	}

	Analytics* Analytics::sharedDelegate()
	{
		if (s_sharedUtils == NULL)
		{
			s_sharedUtils = new Analytics();
		}
		return s_sharedUtils;
	}

	void Analytics::postEvent(const char* eventName, const char* key, const char* value)
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		AnalyticsHandler::getInstance()->postEvent(eventName, key, value);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#endif
	}
}