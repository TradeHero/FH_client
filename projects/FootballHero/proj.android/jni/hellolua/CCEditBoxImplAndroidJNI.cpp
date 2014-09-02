#include "cocos2d.h"
#include <stdlib.h>
#include <jni.h>
#include <android/log.h>
#include <map>
#include "platform/android/jni/JniHelper.h"
#include "../extensions/GUI/CCEditBox/CCEditBoxImplAndroid.h"
#include "../extensions/GUI/CCEditBox/CCEditBoxImplAndroidJNI.h"

#define  LOG_TAG    "Java_org_cocos2dx_lib_Cocos2dxHelper.cpp"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  CLASS_NAME "org/cocos2dx/lib/Cocos2dxHelper"

static std::map<long long, EditTextCallback> s_editTextCallbackRepo;

using namespace cocos2d;
using namespace std;

extern "C"
{
JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogResult(JNIEnv * env, jobject obj, jlong source, jbyteArray text) {
    jsize  size = env->GetArrayLength(text);

    long long pSource = (long long) source;
    LOGD("source: %lld", pSource);
    void *s_ctx = (void *) pSource;
    EditTextCallback s_pfEditTextCallback = s_editTextCallbackRepo[pSource];
    if (size > 0) {
        jbyte * data = (jbyte*)env->GetByteArrayElements(text, 0);
        char* pBuf = (char*)malloc(size+1);
        if (pBuf != NULL) {
            memcpy(pBuf, data, size);
            pBuf[size] = '\0';
            // pass data to edittext's delegate
            if (s_pfEditTextCallback) s_pfEditTextCallback(pBuf, s_ctx);
            free(pBuf);
        }
        env->ReleaseByteArrayElements(text, data, 0);
    } else {
        if (s_pfEditTextCallback) s_pfEditTextCallback("", s_ctx);
    }
}
}

void destroyEditTextJNI(void* ctx) {
  long long editTextSource = (long long) ctx;

  JniMethodInfo t;
  if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "destroyEditText", "(J)V")) {
    t.env->CallStaticVoidMethod(t.classID, t.methodID, editTextSource);
  }
}

void showEditTextDialogJNI(
	const char* pszTitle,
	const char* pszMessage,
	int nInputMode,
	int nInputFlag,
	int nReturnType,
	int nMaxLength,
	float x,
	float y,
  float width,
  float height,
    int color,
	EditTextCallback pfEditTextCallback,
	void* ctx) {
    if (pszMessage == NULL) {
        return;
    }

    long long editTextSource = (long long) ctx;
    LOGD("color: %d", color);
    s_editTextCallbackRepo[editTextSource] = pfEditTextCallback;

    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "showEditTextDialog", "(JLjava/lang/String;Ljava/lang/String;IIIIFFFFI)V")) {
        jstring stringArg1;

        if (!pszTitle) {
            stringArg1 = t.env->NewStringUTF("");
        } else {
            stringArg1 = t.env->NewStringUTF(pszTitle);
        }

        jstring stringArg2 = t.env->NewStringUTF(pszMessage);

        t.env->CallStaticVoidMethod(
            t.classID,
            t.methodID,
            editTextSource,
            stringArg1,
            stringArg2,
            nInputMode,
            nInputFlag,
            nReturnType,
            nMaxLength,
            x,
            y,
            width,
            height,
            color);

        t.env->DeleteLocalRef(stringArg1);
        t.env->DeleteLocalRef(stringArg2);
        t.env->DeleteLocalRef(t.classID);
    }
}