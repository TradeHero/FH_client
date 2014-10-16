#ifndef _SHARESDK_DELEGATE_H_
#define _SHARESDK_DELEGATE_H_

#include "cocos2d.h"

namespace Social
{
	class ShareSDKDelegate
	{
	public:
		~ShareSDKDelegate();
		static ShareSDKDelegate* sharedDelegate();

		void login(int handler);
		void doShare(const char* title, const char* content, int handler);

		// Callbacks
        void accessTokenUpdate(const char* accessToken);
		void shareResult(int result);

	protected:
		ShareSDKDelegate();
		int mAccessTokenUpdateHandler;
		int mShareHandler;
	};
};

#endif
