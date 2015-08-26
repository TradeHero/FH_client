#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void android_facebook_login();
void android_facebook_requestPublishPermissions(const char* newPermission);
void android_facebook_inviteFriend(const char* appLinkUrl);
#endif