#ifndef _ANALYTICS_H_
#define _ANALYTICS_H_

#include "cocos2d.h"

namespace Utils
{
	class Analytics
	{
	public:
		~Analytics();
		static Analytics* sharedDelegate();

		void postEvent(const char* eventName, const char* paramString);

	protected:
		Analytics();
	
	};
};

#endif
