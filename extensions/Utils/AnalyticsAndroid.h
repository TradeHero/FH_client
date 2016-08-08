#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void android_analytics_postEvent(const char* eventName, const char* paramString);
void android_flurry_postEvent(const char* eventName, const char* paramString);

//for Tongdao
void android_tongdao_postEvent(const char* eventName, const char* paramString);
void android_login_Tongdao(const char* userId);
void android_logout_Tongdao();
void android_tongdao_trackAttr(const char* attrName, const char* value);
void android_tongdao_trackAttrs(const char* paramString);
void android_tongdao_trackOrder(const char* orderName, const float price, const char* currency);
void android_tongdao_trackSessionStart(const char* pageName);
void android_tongdao_trackSessionEnd(const char* pageName);
void android_tongdao_trackRegistration();
#endif