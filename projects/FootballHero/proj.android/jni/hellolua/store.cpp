#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>

#include "../extensions/Utils/StoreAndroid.h"
#include "../extensions/Utils/Store.h"

using namespace cocos2d;


extern "C"
{
  JNIEXPORT void JNICALL Java_com_myhero_fh_GooglePlayIABPlugin_requestProductCallback(JNIEnv *env,
   jobject thiz, jstring str, jboolean succeed)
  {
    Utils::Store::sharedDelegate()->requestProductResult(env->GetStringUTFChars(str, NULL), succeed == JNI_TRUE);
  }

  JNIEXPORT void JNICALL Java_com_myhero_fh_GooglePlayIABPlugin_buyCallback(JNIEnv *env,
    jobject thiz, jboolean succeed)
  {
    Utils::Store::sharedDelegate()->buyResult(succeed == JNI_TRUE);
  }

}

void android_requestProducts(const char* ids)
{
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/MainActivity", "requestProducts", "(Ljava/lang/String;)V"))
  {
    jstring jIds = jmi.env->NewStringUTF(ids);
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID, jIds);
    jmi.env->DeleteLocalRef(jmi.classID);
   }
}

void android_buy(const char* id)
{
  JniMethodInfo jmi;
  if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/MainActivity", "buy", "(Ljava/lang/String;)V"))
  {
    jstring jId = jmi.env->NewStringUTF(id);
    jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID, jId);
    jmi.env->DeleteLocalRef(jmi.classID);
    jmi.env->DeleteLocalRef(jId);
  }
}
