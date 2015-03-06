#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>

#include "../extensions/Utils/QuickBloxChatAndroid.h"
#include "../extensions/Utils/QuickBloxChat.h"

using namespace cocos2d;


extern "C"
{
	JNIEXPORT void JNICALL Java_com_myhero_fh_util_QuickBloxChat_quickbloxLoginResult(JNIEnv *env,
	  jobject thiz, jstring token)
	{
	    const char *dToken = env->GetStringUTFChars(token, NULL);
		Utils::QuickBloxChat::sharedDelegate()->loginResult(dToken);
	}

	JNIEXPORT void JNICALL Java_com_myhero_fh_util_QuickBloxChat_quickbloxJoinChatRoomResult(JNIEnv *env,
      jobject thiz, jboolean success)
     {
         Utils::QuickBloxChat::sharedDelegate()->joinChatRoomResult(success);
     }
}

void quickblox_login(const char* userName, const char* profileImg, int userId)
{
    JniMethodInfo jmi;
    if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/util/QuickBloxChat",
                "signin", "(Ljava/lang/String;Ljava/lang/String;I)V"))
    {
        jstring juserName = jmi.env->NewStringUTF(userName);
        jstring jprofileImg = jmi.env->NewStringUTF(profileImg);
        jint juserId = userId;
        jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID, juserName, jprofileImg, juserId);
        jmi.env->DeleteLocalRef(juserName);
        jmi.env->DeleteLocalRef(jprofileImg);
        jmi.env->DeleteLocalRef(jmi.classID);
    }
}

void quickblox_logout()
{
    JniMethodInfo jmi;
    if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/util/QuickBloxChat",
                "signout", "()V"))
    {
        jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID);
        jmi.env->DeleteLocalRef(jmi.classID);
    }
}

void quickblox_joinChatRoom(const char* jid)
{
    JniMethodInfo jmi;
    if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/util/QuickBloxChat",
                "joinChatRoom", "(Ljava/lang/String;)V"))
    {
        jstring jjid = jmi.env->NewStringUTF(jid);
        jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID, jjid);
        jmi.env->DeleteLocalRef(jjid);
        jmi.env->DeleteLocalRef(jmi.classID);
    }
}

void quickblox_leaveChatRoom()
{

}

void quickblox_sendMessage(const char* message)
{

}