#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>

#include "../extensions/Utils/AnalyticsAndroid.h"

using namespace cocos2d;

void android_analytics_postEvent(const char* eventName, const char* key, const char* value)
{
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/metrics/Analytics",
        "fireSingleAttributeEvent", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"))
  {
    jstring eventNameArg = jmi.env->NewStringUTF(eventName);
    jstring keyArg = jmi.env->NewStringUTF(key);
    jstring valueArg = jmi.env->NewStringUTF(value);
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID,
        eventNameArg, keyArg, valueArg);
    jmi.env->DeleteLocalRef(eventNameArg);
    jmi.env->DeleteLocalRef(keyArg);
    jmi.env->DeleteLocalRef(valueArg);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}