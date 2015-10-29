#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void android_analytics_postEvent(const char* eventName, const char* paramString);
void android_flurry_postEvent(const char* eventName, const char* paramString);
#endif