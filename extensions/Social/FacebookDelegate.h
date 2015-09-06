#ifndef _FACEBOOK_DELEGATE_H_
#define _FACEBOOK_DELEGATE_H_

#include "cocos2d.h"

namespace Social
{
	class FacebookDelegate
	{
	public:
		~FacebookDelegate();
		static FacebookDelegate* sharedDelegate();

		void login(int handler);
		void grantPublishPermission(const char* permission, int handler);
		void inviteFriend(const char* appLinkUrl, int handler);
        void shareTimeline(const char* title, const char* description, const char* appLinkUrl, int handler);
        
        void accessTokenUpdate(const char* accessToken);
		void permissionUpdate(const char* accessToken, bool success);
        void inviteFriendResult(bool success);
        void shareTimelineResult(bool success);

	protected:
		FacebookDelegate();
		int mAccessTokenUpdateHandler;
		int mPermissionUpdateHandler;
        int mInviteFriendHandler;
        int mShareHandler;
	};
};

#endif
