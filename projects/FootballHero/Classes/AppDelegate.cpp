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

	CCScene *updateScene = CCScene::create();
	UpdateLayer *updateLayer = new UpdateLayer();
	updateScene->addChild(updateLayer);
	updateLayer->release();

	pDirector->runWithScene(updateScene);
	updateLayer->update(NULL);

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
, isUpdateItemClicked(false)
{
	init();
}

UpdateLayer::~UpdateLayer()
{
	AssetsManager *pAssetsManager = getAssetsManager();
	CC_SAFE_DELETE(pAssetsManager);
}

void UpdateLayer::update(cocos2d::CCObject *pSender)
{
	pProgressLabel->setString("");

	// update resources
	if (!getAssetsManager()->checkUpdate())
	{
		// Do nothing.
	}
	else
	{
		getAssetsManager()->update();
	}
	isUpdateItemClicked = true;
}

void UpdateLayer::reset(cocos2d::CCObject *pSender)
{
	pProgressLabel->setString(" ");

	// Remove downloaded files
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
    std::string command = "rm -r ";
	// Path may include space.
	command += "\"" + pathToSave + "\"";
	system(command.c_str());
#else
	std::string command = "rd /s /q ";
	// Path may include space.
	command += "\"" + pathToSave + "\"";
	system(command.c_str());
#endif
	// Delete recorded version codes.
	getAssetsManager()->deleteVersion();

	createDownloadedDir();
}

void UpdateLayer::enter(cocos2d::CCObject *pSender)
{
	// Should set search resource path before running script if "update" is not clicked.
	// Because AssetsManager will set 
	if (!isUpdateItemClicked)
	{
		std::vector<std::string> searchPaths = CCFileUtils::sharedFileUtils()->getSearchPaths();
		searchPaths.insert(searchPaths.begin(), pathToSave);
		CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);
	}
}

bool UpdateLayer::init()
{
	CCLayer::init();

	createDownloadedDir();

	pProgressLabel = CCLabelTTF::create("", "Arial", 40);
	pProgressLabel->setPosition(ccp(320, 700));
	addChild(pProgressLabel);

	return true;
}

AssetsManager* UpdateLayer::getAssetsManager()
{
	static AssetsManager *pAssetsManager = NULL;

	if (!pAssetsManager)
	{
		pAssetsManager = new AssetsManager("https://raw.githubusercontent.com/lesliesam/fhres/master/res.zip",
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
	std::string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("footballhero.lua");
	CCScriptEngineManager::sharedManager()->getScriptEngine()->executeScriptFile(path.c_str());
}
