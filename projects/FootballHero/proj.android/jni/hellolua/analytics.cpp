#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>

#include "../extensions/Utils/AnalyticsAndroid.h"

using namespace cocos2d;

void android_analytics_postEvent(const char* eventName, const char* paramString)
{
/*
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/MainActivity",
        "tagLocalyticsEvent", "(Ljava/lang/String;Ljava/lang/String;)V"))
  {
    jstring eventNameArg = jmi.env->NewStringUTF(eventName);
    jstring paramStringArg = jmi.env->NewStringUTF(paramString);
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID,
        eventNameArg, paramStringArg);
    jmi.env->DeleteLocalRef(eventNameArg);
    jmi.env->DeleteLocalRef(paramStringArg);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
*/
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

  // Find method 'tagLocalyticsEvent' in MainActivity.java
  isHave = JniHelper::getMethodInfo(minfo, "com/myhero/fh/MainActivity", "tagLocalyticsEvent", "(Ljava/lang/String;Ljava/lang/String;)V");

  if (!isHave)
  {
    CCLog("jni:tagLocalyticsEvent does not exist!");
  }
  else
  {
  	jstring eventNameArg = minfo.env->NewStringUTF(eventName);
    jstring paramStringArg = minfo.env->NewStringUTF(paramString);
    minfo.env->CallVoidMethod(activityObj, minfo.methodID,
        eventNameArg, paramStringArg);
    minfo.env->DeleteLocalRef(eventNameArg);
    minfo.env->DeleteLocalRef(paramStringArg);
    minfo.env->DeleteLocalRef(minfo.classID);
    minfo.env->DeleteLocalRef(activityObj);
  }
}

void android_flurry_postEvent(const char* eventName, const char* paramString)
{
  JniMethodInfo minfo;

  if (JniHelper::getStaticMethodInfo(minfo, "com/myhero/fh/MainActivity", "logFlurryEvent", "(Ljava/lang/String;Ljava/lang/String;)V")) {
    jstring jEventName = minfo.env->NewStringUTF(eventName);
    jstring jParamString = minfo.env->NewStringUTF(paramString);
    minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jEventName, jParamString);
    minfo.env->DeleteLocalRef(jEventName);
    minfo.env->DeleteLocalRef(jParamString);
    minfo.env->DeleteLocalRef(minfo.classID);
  }
}