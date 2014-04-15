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

		void login(int successHandler, int errorHandler);
        void loginResult(const char* accessToken);

	protected:
		FacebookDelegate();
		int mSuccessHandler;
		int mErrorHandler;
	
	};
};

#endif
