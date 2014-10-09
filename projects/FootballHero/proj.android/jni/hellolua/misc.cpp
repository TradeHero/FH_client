#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>

#include "../extensions/Utils/MiscAndroid.h"
#include "../extensions/Utils/Misc.h"

using namespace cocos2d;

const char* kJNIPackageName = "com/myhero/fh/MainActivity";

extern "C"
{
	JNIEXPORT void JNICALL Java_com_myhero_fh_util_MiscUtil_sendSmsResult(JNIEnv *env,
	  jobject thiz, jint resultCode)
	{
		Utils::Misc::sharedDelegate()->sendSMSResult(resultCode);
	}

	JNIEXPORT void JNICALL Java_com_myhero_fh_util_MiscUtil_sendMailResult(JNIEnv *env,
	  jobject thiz, jint resultCode)
	{
		Utils::Misc::sharedDelegate()->sendMailResult(resultCode);
	}

	JNIEXPORT void JNICALL Java_com_myhero_fh_IntentReceiver_responseUADeviceToken(JNIEnv *env,
      jobject thiz, jstring token)
    {
        const char *dToken = env->GetStringUTFChars(token, NULL);
        Utils::Misc::sharedDelegate()->responseUADeviceToken(dToken);
    }
}

void openWebPageAndroid(const char* url, int x, int y, int w, int h)
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

void closeWebPageAndroid()
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

// @@ADD Vincent: copy to paste board function for Android
void misc_copy_to_paste_board(const char* content)
{
	// Get Android activity in MainActivity.java
	JniMethodInfo minfo;

	bool isHave = JniHelper::getStaticMethodInfo(minfo,
		"com/myhero/fh/MainActivity",
		"getJavaActivity",
		"()Ljava/lang/Object;");
	jobject activityObj;
	if (isHave)
	{
		activityObj = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
	}

	// Find method 'copyToPasteBoard' in MainActivity.java
	isHave = JniHelper::getMethodInfo(minfo, "com/myhero/fh/MainActivity", "copyToPasteBoard", "(Ljava/lang/String;)V");

	if (!isHave)
	{
		CCLog("jni:copyToPasteBoard does not exist!");
	}
	else
	{
		// Copy the data
		jstring jmsg = minfo.env->NewStringUTF(content);
		minfo.env->CallVoidMethod(activityObj, minfo.methodID, jmsg);
	}
}

void misc_send_mail(const char* receiver, const char* subject, const char* body)
{
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/util/MiscUtil",
        "sendMail", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"))
  {
    jstring receiverArg = jmi.env->NewStringUTF(receiver);
    jstring subjectArg = jmi.env->NewStringUTF(subject);
    jstring bodyArg = jmi.env->NewStringUTF(body);
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID,
        receiverArg, subjectArg, bodyArg);
    jmi.env->DeleteLocalRef(receiverArg);
    jmi.env->DeleteLocalRef(subjectArg);
    jmi.env->DeleteLocalRef(bodyArg);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}

void misc_send_sms(const char* body) {
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/util/MiscUtil",
        "sendSms", "(Ljava/lang/String;)V"))
  {
    jstring bodyArg = jmi.env->NewStringUTF(body);
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID, bodyArg);
    jmi.env->DeleteLocalRef(bodyArg);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}

void misc_open_url(const char* url) {
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/util/MiscUtil",
        "openUrl", "(Ljava/lang/String;)V"))
  {
    jstring bodyArg = jmi.env->NewStringUTF(url);
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID, bodyArg);
    jmi.env->DeleteLocalRef(bodyArg);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}

void misc_get_UA_DeviceToken() {
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/IntentReceiver",
        "getUADeviceToken", "()V"))
  {
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}