#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void android_requestProducts(const char* ids);
void android_buy(const char* id);
#endif