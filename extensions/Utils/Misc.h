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
        
        void sendMail(char* receiver, char* subject, char* body);
        

	protected:
		Misc();
		int mSelectImageHandler;
	
	};
};

#endif
