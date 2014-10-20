
#include "Utils/VideoView.h"
#include "CCLuaEngine.h"

#include <jni.h>
#include "platform/android/jni/JniHelper.h"

extern "C"  {
	void Java_cn_sharedream_game_VideoView_doLuaFinishCallback(JNIEnv *env, jobject thiz,jint handle)
	{
		CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
		cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
		if (pLuaEngine == NULL)
		{
			assert(false);
			return;
		}

		CCLuaStack* pStack = pLuaEngine->getLuaStack();
		int ret = pStack->executeFunctionByHandler(handle, 0);
		pStack->clean();
	}
}

void VideoView::playVideo(const char* filename,int funcID)
{
	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t,
		"cn/sharedream/game/VideoView",
		"playVideo",
		"(Ljava/lang/String;I)V"))
	{
		t.env->CallStaticVoidMethod(t.classID, t.methodID,
			t.env->NewStringUTF(filename),funcID);
	}
}
