#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>

#include "../extensions/Utils/StoreAndroid.h"
#include "../extensions/Utils/Store.h"

using namespace cocos2d;


extern "C"
{
  JNIEXPORT void JNICALL Java_com_myhero_fh_GooglePlayIABPlugin_requestProductCallback(JNIEnv *env,
   jobject thiz, jboolean succeed)
  {
    Utils::Store::sharedDelegate()->requestProductResult(succeed == JNI_TRUE);
  }

  JNIEXPORT void JNICALL Java_com_myhero_fh_GooglePlayIABPlugin_buyCallback(JNIEnv *env,
    jobject thiz, jboolean succeed)
  {
    Utils::Store::sharedDelegate()->buyResult(succeed == JNI_TRUE);
  }

}

void android_requestProducts()
{
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/MainActivity", "requestProducts", "()V"))
  {
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}

void android_buy(int level)
{
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/MainActivity", "buy", "(I)V"))
  {
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID, level);
    jmi.env->DeleteLocalRef(jmi.classID);
  }
}
