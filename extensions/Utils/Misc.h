#ifndef _MISC_H_
#define _MISC_H_

#include "cocos2d.h"

namespace Utils
{
	class Misc
	{
	public:
		~Misc();
		static Misc* sharedDelegate();

		void copyToPasteboard(const char* content);

		void selectImage(char* path, int handler);

		void selectImageResult(bool success);
        
        void sendMail(char* receiver, char* subject, char* body, int handler);

		void sendMailResult(int resultCode);

		void sendSMS(char* body, int handler);

		void sendSMSResult(int resultCode);
        
		char* createFormWithFile(const char* begin, const char* end, const char* filePath, const char* pszMode, unsigned long *pSize);

		void getUADeviceToken(int handler);

		void setUADeviceTokenHandler(int handler);

		void responseUADeviceToken(const char* token);

		void requestPushNotification();

		void terminate();
	protected:
		Misc();
		int mSelectImageHandler;
		int mSendMailHandler;
		int mSendSMSHandler;
		int mUADeviceTokenHandler;
	};
};

#endif
