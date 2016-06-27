#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void android_analytics_postEvent(const char* eventName, const char* paramString);
void android_flurry_postEvent(const char* eventName, const char* paramString);

//for Tongdao
void android_tongdao_postEvent(const char* eventName, const char* paramString);
void android_login_Tongdao(const char* userId);
void android_tongdao_trackAttr(attrName, paramString);
void android_tongdao_trackOrder(orderName, price, currency);
#endif