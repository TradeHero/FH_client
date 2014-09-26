#include "cocos2d.h"
#include "CCEGLView.h"
#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "Lua_extensions_CCB.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "Lua_web_socket.h"
#endif
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <dirent.h>
#include <sys/stat.h>
#endif

USING_NS_CC;
USING_NS_CC_EXT;
using namespace CocosDenshion;

#define KEY_OF_VERSION   "current-version-code"

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    CCDirector *pDirector = CCDirector::sharedDirector();
    pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());

    // turn on display FPS
    pDirector->setDisplayStats(false);

    // set FPS. the default value is 1.0/60 if you don't call this
    pDirector->setAnimationInterval(1.0 / 60);

    // register lua engine
    CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();
    CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);

    CCLuaStack *pStack = pEngine->getLuaStack();
    lua_State *tolua_s = pStack->getLuaState();
    tolua_extensions_ccb_open(tolua_s);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
    pStack = pEngine->getLuaStack();
    tolua_s = pStack->getLuaState();
    tolua_web_socket_open(tolua_s);
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_BLACKBERRY)
	CCFileUtils::sharedFileUtils()->addSearchPath("script");
#endif

	std::vector<std::string> searchPaths = CCFileUtils::sharedFileUtils()->getSearchPaths();
	searchPaths.insert(searchPaths.begin(), CCFileUtils::sharedFileUtils()->getWritablePath() + "local");
	searchPaths.insert(searchPaths.begin(), CCFileUtils::sharedFileUtils()->getWritablePath());
	CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);

	CCEGLView* eglView = CCEGLView::sharedOpenGLView();
	eglView->setDesignResolutionSize(640, 1136, kResolutionShowAll);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	eglView->setFrameSize(541, 960);
#endif

	std::string assetsVersion = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_VERSION);
	unsigned long pSize = 0;
	std::string appVersionFilePath = CCFileUtils::sharedFileUtils()->fullPathForFilename("version");
	char* appVersionFileContent = (char*)CCFileUtils::sharedFileUtils()->getFileData(appVersionFilePath.c_str(), "r", &pSize);
	std::string appVersion(appVersionFileContent, pSize);
	if (assetsVersion == "")
	{
		// For new install, set the currentVersion.
		CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_VERSION, appVersion);
		CCLOG("New app installed.");
	}
	else
	{
		// If App upgrade, rename the old local assets folder. 
		if (appVersion > assetsVersion)
		{
			std::string localAssetsPath = CCFileUtils::sharedFileUtils()->getWritablePath() + "local";
			std::string localAssetsPathNew = localAssetsPath + assetsVersion;
			CCLOG("App upgraded. Rename old local assets folder: %s", localAssetsPathNew.c_str());
			if (rename(localAssetsPath.c_str(), localAssetsPathNew.c_str()) != 0)
			{
				CCLOG("Can not rename old local assets folder.");
			}
			else
			{
				CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_VERSION, appVersion);
			}
		}
	}

	CCScene *updateScene = CCScene::create();
	UpdateLayer *updateLayer = new UpdateLayer();
	updateScene->addChild(updateLayer);
	updateLayer->release();

	pDirector->runWithScene(updateScene);

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    CCDirector::sharedDirector()->stopAnimation();

    SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    CCDirector::sharedDirector()->startAnimation();

    SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
}

UpdateLayer::UpdateLayer()
: pItemEnter(NULL)
, pItemReset(NULL)
, pItemUpdate(NULL)
, pProgressLabel(NULL)
{
	init();
}

UpdateLayer::~UpdateLayer()
{
	AssetsManager *pAssetsManager = getAssetsManager();
	CC_SAFE_DELETE(pAssetsManager);
}

void UpdateLayer::onEnter()
{
	CCNode::onEnter();
	getAssetsManager()->update();
}

bool UpdateLayer::init()
{
	CCLayer::init();

	createDownloadedDir();

	CCSprite* background = CCSprite::create(CCFileUtils::sharedFileUtils()->fullPathForFilename("images/Default-568h@2x.png").c_str());
	background->setPosition(ccp(320, 568));
	addChild(background);

	pProgressLabel = CCLabelTTF::create("Loading...", "Arial", 30);
	pProgressLabel->setPosition(ccp(320, 300));
    pProgressLabel->setFontFillColor(ccc3(0, 0, 0));
	addChild(pProgressLabel);

	return true;
}

AssetsManager* UpdateLayer::getAssetsManager()
{
	static AssetsManager *pAssetsManager = NULL;

	if (!pAssetsManager)
	{
		pAssetsManager = new AssetsManager("https://raw.githubusercontent.com/lesliesam/fhres/master/dev/res.zip",
			"https://raw.githubusercontent.com/lesliesam/fhres/master/version",
			pathToSave.c_str());
		pAssetsManager->setDelegate(this);
		pAssetsManager->setConnectionTimeout(10);
	}

	return pAssetsManager;
}

void UpdateLayer::createDownloadedDir()
{
	pathToSave = CCFileUtils::sharedFileUtils()->getWritablePath();
	pathToSave += "local";

	// Create the folder if it doesn't exist
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	DIR *pDir = NULL;

	pDir = opendir(pathToSave.c_str());
	if (!pDir)
	{
		mkdir(pathToSave.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
	}
#else
	if ((GetFileAttributesA(pathToSave.c_str())) == INVALID_FILE_ATTRIBUTES)
	{
		CreateDirectoryA(pathToSave.c_str(), 0);
	}
#endif
}

void UpdateLayer::onError(AssetsManager::ErrorCode errorCode)
{
	if (errorCode == AssetsManager::kNoNewVersion)
	{
		pProgressLabel->setString("");
	}

	if (errorCode == AssetsManager::kNetwork)
	{
		pProgressLabel->setString("");
	}
	loadGame();
}

void UpdateLayer::onProgress(int percent)
{
	char progress[20];
	snprintf(progress, 20, "Refreshing... %d%%", percent);
	pProgressLabel->setString(progress);
}

void UpdateLayer::onSuccess()
{
	pProgressLabel->setString("Refreshing done!");

	loadGame();
}

void UpdateLayer::loadGame()
{
	std::vector<std::string> searchPaths = CCFileUtils::sharedFileUtils()->getSearchPaths();
	searchPaths.insert(searchPaths.begin(), pathToSave);
	CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);

	std::string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("footballhero.lua");
	CCScriptEngineManager::sharedManager()->getScriptEngine()->executeScriptFile(path.c_str());
}
