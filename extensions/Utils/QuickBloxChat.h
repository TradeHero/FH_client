#ifndef _QUICKBLOXCHAT_H_
#define _QUICKBLOXCHAT_H_

#include "cocos2d.h"

namespace Utils
{
	class QuickBloxChat
	{
	public:
		~QuickBloxChat();
		static QuickBloxChat* sharedDelegate();

        void login(const char* username, const char* profileImg, int userId, int handler);
        void logout();
        void loginResult(const char* token);
        
        void joinChatRoom(const char* jid, int handler);
        void joinChatRoomResult(bool success);
        
        void leaveChatRoom(int handler);
        void leaveChatRoomResult(bool success);
        
        void sendMessage(const char* message);
        void setNewMessageHandler(int handler);
        void newMessageHandler(const char* sender, const char* message, int timestamp);

	protected:
		QuickBloxChat();
        int mLoginHandler;
        int mJoinRoomHandler;
        int mLeaveRoomHandler;
        int mNewMessageHandler;
	
	};
};

#endif
