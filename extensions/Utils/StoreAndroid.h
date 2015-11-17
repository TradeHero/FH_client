#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void android_requestProducts();
void android_buy(int level);
#endif