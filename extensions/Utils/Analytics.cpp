#include "cocos2d.h"
#include "Analytics.h"
#include "CCLuaEngine.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "AnalyticsHandler.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "AnalyticsAndroid.h"
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

	void Analytics::postEvent(const char* eventName, const char* paramString)
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		AnalyticsHandler::getInstance()->postEvent(eventName, paramString);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		android_analytics_postEvent(eventName, paramString);
#endif
	}
    
    void Analytics::postFlurryEvent(const char* eventName, const char* paramString)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        AnalyticsHandler::getInstance()->postFlurryEvent(eventName, paramString);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        android_flurry_postEvent(eventName, paramString);
#endif
    }
    
    void Analytics::postTongdaoEvent(const char* eventName, const char* paramString)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        AnalyticsHandler::getInstance()->postTongdaoEvent(eventName, paramString);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        android_tongdao_postEvent(eventName, paramString);
#endif
    }
    
    void Analytics::loginTongdao(const char* userId)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        AnalyticsHandler::getInstance()->loginTongdao(userId);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        android_login_Tongdao(userId);
#endif
    }
    
    void Analytics::trackTongdaoAttr(const char* paramString)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        AnalyticsHandler::getInstance()->trackTongdaoAttr(paramString);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        android_tongdao_trackAttr(attrName, paramString);
#endif
    }    
    
    void Analytics::trackTongdaoOrder(const char* orderName, const float* price, const char* currency)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        AnalyticsHandler::getInstance()->trackTongdaoOrder(orderName, price, currency);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        android_tongdao_trackOrder(orderName, price, currency);
#endif
    }
}