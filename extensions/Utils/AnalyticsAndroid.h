#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void android_analytics_postEvent(const char* eventName, const char* key, const char* value);
#endif