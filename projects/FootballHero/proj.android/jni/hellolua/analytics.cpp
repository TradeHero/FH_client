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


void android_tongdao_postEvent(const char* eventName, const char* paramString)
{
  JniMethodInfo minfo;

  if (JniHelper::getStaticMethodInfo(minfo, "com/myhero/fh/MainActivity", "logTongdaoEvent", "(Ljava/lang/String;Ljava/lang/String;)V")) {
    jstring jEventName = minfo.env->NewStringUTF(eventName);
    jstring jParamString = minfo.env->NewStringUTF(paramString);
    minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jEventName, jParamString);
    minfo.env->DeleteLocalRef(jEventName);
    minfo.env->DeleteLocalRef(jParamString);
    minfo.env->DeleteLocalRef(minfo.classID);
  }
}

void android_login_Tongdao(const char* userId)
{
  JniMethodInfo minfo;

  if (JniHelper::getStaticMethodInfo(minfo, "com/myhero/fh/MainActivity", "loginTongdao", "(Ljava/lang/String;)V")) {
    jstring jUserId = minfo.env->NewStringUTF(userId);
    minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jUserId);
    minfo.env->DeleteLocalRef(jUserId);
    minfo.env->DeleteLocalRef(minfo.classID);
  }
}

void android_tongdao_trackAttr(const char* attrName, const char* value)
{
  JniMethodInfo minfo;

  if (JniHelper::getStaticMethodInfo(minfo, "com/myhero/fh/MainActivity", "trackTongdaoAttr", "(Ljava/lang/String;Ljava/lang/String;)V")) {
    jstring jAttrName = minfo.env->NewStringUTF(attrName);
    jstring jValue = minfo.env->NewStringUTF(value);
    minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jAttrName, jValue);
    minfo.env->DeleteLocalRef(jAttrName);
    minfo.env->DeleteLocalRef(jValue);
    minfo.env->DeleteLocalRef(minfo.classID);
  }
}

void android_tongdao_trackAttrs(const char* paramString)
{
  JniMethodInfo minfo;

  if (JniHelper::getStaticMethodInfo(minfo, "com/myhero/fh/MainActivity", "trackTongdaoAttrs", "(Ljava/lang/String;)V")) {
    jstring jParamString = minfo.env->NewStringUTF(paramString);
    minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jParamString);
    minfo.env->DeleteLocalRef(jParamString);
    minfo.env->DeleteLocalRef(minfo.classID);
  }
}

void android_tongdao_trackOrder(const char* orderName, const float price, const char* currency)
{
  JniMethodInfo minfo;

  if (JniHelper::getStaticMethodInfo(minfo, "com/myhero/fh/MainActivity", "trackTongdaoOrder", "(Ljava/lang/String;FLjava/lang/String;)V")) {
    jstring jOrderName = minfo.env->NewStringUTF(orderName);
    jfloat jPrice = price;
    jstring jCurrency = minfo.env->NewStringUTF(currency);
    minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jOrderName, jPrice, jCurrency );
    minfo.env->DeleteLocalRef(jOrderName);
    minfo.env->DeleteLocalRef(jCurrency);
    minfo.env->DeleteLocalRef(minfo.classID);
  }
}

void android_tongdao_trackSessionStart(const char* pageName)
{
  JniMethodInfo minfo;

  if (JniHelper::getStaticMethodInfo(minfo, "com/myhero/fh/MainActivity", "trackTongdaoSessionStart", "(Ljava/lang/String;)V")) {
    jstring jParamString = minfo.env->NewStringUTF(pageName);
    minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jParamString);
    minfo.env->DeleteLocalRef(jParamString);
    minfo.env->DeleteLocalRef(minfo.classID);
  }
}

void android_tongdao_trackSessionEnd(const char* pageName)
{
  JniMethodInfo minfo;

  if (JniHelper::getStaticMethodInfo(minfo, "com/myhero/fh/MainActivity", "trackTongdaoSessionEnd", "(Ljava/lang/String;)V")) {
    jstring jParamString = minfo.env->NewStringUTF(pageName);
    minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jParamString);
    minfo.env->DeleteLocalRef(jParamString);
    minfo.env->DeleteLocalRef(minfo.classID);
  }
}

void android_tongdao_trackRegistration()
{
  JniMethodInfo minfo;

  if (JniHelper::getStaticMethodInfo(minfo, "com/myhero/fh/MainActivity", "trackTongdaoRegistration", "()V")) {
    minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID);
    minfo.env->DeleteLocalRef(minfo.classID);
  }
}
