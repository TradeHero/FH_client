#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void openWebPageAndroid(const char* url);
void openWebPageAndroid(const char* url, int x, int y, int w, int h);
void closeWebPageAndroid();
void misc_copy_to_paste_board(const char* content);
void misc_send_mail(const char* receiver, const char* subject, const char* body);
void misc_send_sms(const char* body);
void misc_open_url(const char* url);
void misc_select_image(const char* path, int width, int height);
void misc_get_UA_DeviceToken();
void misc_get_deepLink();
void misc_add_UA_Tags(const char* tagsString);
void misc_remove_UA_Tags(const char* tagsString);
const char* misc_get_device_ID();
void misc_open_rate();
#endif