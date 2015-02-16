#include <cocos2d.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void quickblox_login(const char* userName, const char* profileImg, int userId);
void quickblox_logout();
void quickblox_joinChatRoom(const char* jid);
void quickblox_leaveChatRoom();
void quickblox_sendMessage(const char* message);
#endif