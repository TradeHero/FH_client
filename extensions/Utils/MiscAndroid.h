#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void openWebPageAndroid(const char* url, int x, int y, int w, int h);
void closeWebPageAndroid();
void misc_copy_to_paste_board(const char* content);
void misc_send_mail(const char* receiver, const char* subject, const char* body);
void misc_send_sms(const char* body);
void misc_open_url(const char* url);
void misc_get_UA_DeviceToken();
#endif