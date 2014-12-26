#ifndef _MISC_H_
#define _MISC_H_

#include "cocos2d.h"
#include "cocos-ext.h"
#include "../network/HttpRequestForLua.h"

USING_NS_CC_EXT;

namespace Utils
{
	class Misc
	{
	public:
		~Misc();
		static Misc* sharedDelegate();

		void copyToPasteboard(const char* content);

		void selectImage(char* path, int width, int height, int handler);

		void selectImageResult(bool success);
        
        void sendMail(char* receiver, char* subject, char* body, int handler);

		void sendMailResult(int resultCode);

		void sendSMS(char* body, int handler);

		void sendSMSResult(int resultCode);

		void getDeepLink(int handler);

		void addEventListenerDeepLink(int handler);

		void notifyDeepLink(const char * result);
        
		char* createFormWithFile(const char* begin, const char* end, const char* filePath, const char* pszMode, unsigned long *pSize);

		void setFileToRequestData(HttpRequestForLua* request, const char* begin, const char* end, const char* filePath, const char* pszMode);

		void getUADeviceToken(int handler);

		void setUADeviceTokenHandler(int handler);

		void responseUADeviceToken(const char* token);

		void requestPushNotification();

		void openUrl(char* url);

		void openRate();

		void terminate();
	protected:
		Misc();
		int mSelectImageHandler;
		int mSendMailHandler;
		int mSendSMSHandler;
		int mUADeviceTokenHandler;
		int mDeepLinkEventHandler;
	};
};

#endif
