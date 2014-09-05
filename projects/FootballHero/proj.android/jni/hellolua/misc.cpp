#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>

#include "../extensions/Utils/MiscAndroid.h"
#include "../extensions/Utils/Misc.h"

using namespace cocos2d;

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

void misc_get_UA_DeviceToken() {
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/IntentReceiver",
        "getUADeviceToken", "()V"))
  {
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}