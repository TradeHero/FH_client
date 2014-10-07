#ifndef _WEBVIEW_DELEGATE_H_
#define _WEBVIEW_DELEGATE_H_

#include "cocos2d.h"

namespace Utils
{
	class WebviewDelegate
	{
	public:
		~WebviewDelegate();
		static WebviewDelegate* sharedDelegate();

		void openWebpage(const char* url, int x, int y, int w, int h);
		void closeWebpage();

		// @ADD Vincent: Webview for Android
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		void openWebPageAndroid(const char* url, int x, int y, int w, int h);
		void closeWebPageAndroid();
#endif
	protected:
		WebviewDelegate();
	
	};
};

#endif
