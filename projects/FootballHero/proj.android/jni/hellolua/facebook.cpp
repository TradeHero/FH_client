#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>

// TODO add include path to Android.mk instead of doing this
#include "../extensions/Social/FacebookDelegate.h"
#include "../extensions/Social/FacebookAndroid.h"

using namespace cocos2d;

extern "C"
{
	void Java_com_myhero_fh_MainActivity_accessTokenUpdate(JNIEnv *env, jobject thiz, jstring accessToken)
	{
		const char *token = env->GetStringUTFChars(accessToken, NULL);
		Social::FacebookDelegate::sharedDelegate()->accessTokenUpdate(token);
	}
}

void android_facebook_login()
{
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/MainActivity", "login", "()V"))
  {
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}
