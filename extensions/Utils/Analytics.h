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
        void postFlurryEvent(const char* eventName, const char* paramString);
        
        // for Tongdao
        void postTongdaoEvent(const char* eventName, const char* paramString);
        void loginTongdao(const char* userId);
        void trackTongdaoAttr(const char* paramString);
        void trackTongdaoOrder(const char* orderName, const float* price, const char* currency);
        
	protected:
		Analytics();
	
	};
};

#endif
