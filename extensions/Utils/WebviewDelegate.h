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

	protected:
		WebviewDelegate();
	
	};
};

#endif
