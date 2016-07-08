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
        void trackTongdaoAttr(const char* attrName, const char* value);
        void trackTongdaoAttrs(const char* paramString);
        void trackTongdaoOrder(const char* orderName, const float price, const char* currency);
        void tractSessionStart(const char* pageName);
        void tractSessionEnd(const char* pageName);
        void trackRegistration();
        
	protected:
		Analytics();
	
	};
};

#endif
