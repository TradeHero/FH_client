#include "cocos2d.h"
#include "WebviewDelegate.h"
#include "CCLuaEngine.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "WebviewController.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"

const char* kJNIPackageName = "com/myhero/fh/MainActivity";
#endif

USING_NS_CC;

namespace Utils
{
	static WebviewDelegate* s_sharedUtils;

	WebviewDelegate::WebviewDelegate()
	{

	}

	WebviewDelegate::~WebviewDelegate()
	{

	}

	WebviewDelegate* WebviewDelegate::sharedDelegate()
	{
		if (s_sharedUtils == NULL)
		{
			s_sharedUtils = new WebviewDelegate();
		}
		return s_sharedUtils;
	}

	void WebviewDelegate::openWebpage(const char* url, int x, int y, int w, int h)
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		WebviewController::getInstance()->openWebpage(url, x, y, w, h);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		this->openWebPageAndroid(url, x, y, w, h);
#endif
	}

	void WebviewDelegate::closeWebpage()
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		WebviewController::getInstance()->closeWebpage();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		this->closeWebPageAndroid();
#endif
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	void WebviewDelegate::openWebPageAndroid(const char* url, int x, int y, int w, int h)
	{
		// Get Android activity in MainActivity.java
		JniMethodInfo minfo;
		
		bool isHave = JniHelper::getStaticMethodInfo(minfo,
			kJNIPackageName,
			"getJavaActivity",
			"()Ljava/lang/Object;");
		jobject activityObj;
		if (isHave)
		{
			activityObj = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
		}

		// Find method 'openWebPage' in MainActivity.java
		isHave = JniHelper::getMethodInfo(minfo, kJNIPackageName, "openWebPage", "(Ljava/lang/String;IIII)V");

		if (!isHave)
		{
			CCLog("jni:openWebPage does not exist!");
		}
		else
		{	
			// Create the Android webview & load the url
			jstring jmsg = minfo.env->NewStringUTF(url);
			jint jX = (int)x;
			jint jY = (int)y;
			jint jWidth = (int)w;
			jint jHeight = (int)h;
			minfo.env->CallVoidMethod(activityObj, minfo.methodID, jmsg, jX, jY, jWidth, jHeight);
		}
	}

	void WebviewDelegate::closeWebPageAndroid()
	{
		// Get Android activity in MainActivity.java
		JniMethodInfo minfo;
		
		bool isHave = JniHelper::getStaticMethodInfo(minfo,
			kJNIPackageName,
			"getJavaActivity",
			"()Ljava/lang/Object;");
		jobject activityObj;
		if (isHave)
		{
			activityObj = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
		}

		// Find method 'closeWebPage' in MainActivity.java
		isHave = JniHelper::getMethodInfo(minfo, kJNIPackageName, "closeWebPage", "()V");

		if (!isHave)
		{
			CCLog("jni:closeWebPage does not exist!");
		}
		else
		{
			// Close the Android webview
			minfo.env->CallVoidMethod(activityObj, minfo.methodID);
		}
	}
#endif
}