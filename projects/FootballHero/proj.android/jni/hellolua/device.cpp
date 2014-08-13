#include "cocos2d.h"
#include <stdlib.h>
#include <jni.h>
#include <android/log.h>
#include <map>
#include "platform/android/jni/JniHelper.h"
#include "../extensions/GUI/Android/DeviceJNI.h"

#define  CLASS_NAME "com/myhero/fh/util/DeviceUtil"
#define  LOG_TAG    "Java_" CLASS_NAME
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)

using namespace cocos2d;
using namespace std;

void closeKeyboardJNI(void *ctx) {
  long long editTextSource = (long long) ctx;

  JniMethodInfo t;
  if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "hideKeyboard", "(J)V")) {
    t.env->CallStaticVoidMethod(t.classID, t.methodID, editTextSource);
  }
}