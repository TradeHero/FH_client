#include <jni.h>

// TODO add include path to Android.mk instead of doing this
#include "../extensions/Social/FacebookDelegate.h"

extern "C"
{
	void Java_com_myhero_fh_FootballHero_loginResult(JNIEnv *env, jobject thiz, jstring accessToken)
	{
		const char *token = env->GetStringUTFChars(accessToken, NULL);
		Social::FacebookDelegate::sharedDelegate()->loginResult(token);
	}
}