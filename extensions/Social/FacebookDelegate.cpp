#include "cocos2d.h"
#include "FacebookDelegate.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "FacebookConnector.h"
#endif

namespace Social
{
	static FacebookDelegate* s_sharedUtils;

	FacebookDelegate::FacebookDelegate()
	{

	}

	FacebookDelegate::~FacebookDelegate()
	{

	}

	FacebookDelegate* FacebookDelegate::sharedDelegate()
	{
		if (s_sharedUtils == NULL)
		{
			s_sharedUtils = new FacebookDelegate();
		}
		return s_sharedUtils;
	}

	void FacebookDelegate::login()
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        FacebookConnector::getInstance()->login();
#endif
	}
}