#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>

#include "../extensions/Utils/AnalyticsAndroid.h"

using namespace cocos2d;

void android_analytics_postEvent(const char* eventName, const char* paramString)
{
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/metrics/Analytics",
        "fireEventWithParamString", "(Ljava/lang/String;Ljava/lang/String;)V"))
  {
    jstring eventNameArg = jmi.env->NewStringUTF(eventName);
    jstring paramStringArg = jmi.env->NewStringUTF(paramString);
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID,
        eventNameArg, paramStringArg);
    jmi.env->DeleteLocalRef(eventNameArg);
    jmi.env->DeleteLocalRef(paramStringArg);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}