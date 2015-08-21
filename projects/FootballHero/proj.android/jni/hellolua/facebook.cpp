#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>

// TODO add include path to Android.mk instead of doing this
#include "../extensions/Social/FacebookDelegate.h"
#include "../extensions/Social/FacebookAndroid.h"

using namespace cocos2d;

extern "C"
{
	JNIEXPORT void JNICALL Java_com_myhero_fh_auth_FacebookAuth_accessTokenUpdate(JNIEnv *env,
	  jobject thiz, jstring accessToken)
	{
	    if (accessToken == NULL)
	    {
	        Social::FacebookDelegate::sharedDelegate()->accessTokenUpdate(NULL);
	    }
	    else
	    {
            const char *token = env->GetStringUTFChars(accessToken, NULL);
            Social::FacebookDelegate::sharedDelegate()->accessTokenUpdate(token);
	    }

	}

  JNIEXPORT void JNICALL Java_com_myhero_fh_auth_FacebookAuth_permissionUpdate(JNIEnv *env,
    jobject thiz, jstring accessToken, jboolean granted)
  {
    const char *token = env->GetStringUTFChars(accessToken, NULL);
    Social::FacebookDelegate::sharedDelegate()->permissionUpdate(
      strlen(token) != 0 ? token : NULL, granted == JNI_TRUE);
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

void android_facebook_requestPublishPermissions(
	const char* newPermission)
{
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/MainActivity", "requestPublishPermissions", "(Ljava/lang/String;)V"))
  {
    jstring jNewPermission = jmi.env->NewStringUTF(newPermission);
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID, jNewPermission);
    jmi.env->DeleteLocalRef(jNewPermission);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}

void android_facebook_gameRequest(const char* title, const char* message)
{
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/MainActivity", "gameRequest", "(Ljava/lang/String,Ljava/lang/String;)V"))
  {
    jstring jTitle = t.env->NewStringUTF(title);
    jstring jMessage = t.env->NewStringUTF(message);
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID, jTitle, jMessage);
    jmi.env->DeleteLocalRef(jTitle);
    jmi.env->DeleteLocalRef(jMessage);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}

