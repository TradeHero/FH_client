#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void misc_send_mail(const char* receiver, const char* subject, const char* body);
void misc_send_sms(const char* body);
#endif