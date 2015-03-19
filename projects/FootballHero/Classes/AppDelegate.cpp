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
using namespace std;

#define KEY_OF_VERSION   "current-version-code"
#define KEY_OF_LANGUAGE  "app-language"

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
	CCEGLView* eglView = CCEGLView::sharedOpenGLView();
	eglView->setDesignResolutionSize(640, 1136, kResolutionShowAll);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	eglView->setFrameSize(541, 960);
#endif

	string assetsVersion = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_VERSION);
	unsigned long pSize = 0;
	string appVersionFilePath = CCFileUtils::sharedFileUtils()->fullPathForFilename("version");
	char* appVersionFileContent = (char*)CCFileUtils::sharedFileUtils()->getFileData(appVersionFilePath.c_str(), "r", &pSize);
	string appVersion(appVersionFileContent, pSize);
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
			string localAssetsPath = CCFileUtils::sharedFileUtils()->getWritablePath() + "local";
			string localAssetsPathNew = localAssetsPath + assetsVersion;
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

	vector<string> searchPaths = CCFileUtils::sharedFileUtils()->getSearchPaths();

    ccLanguageType currentLanguage = CCApplication::sharedApplication()->getCurrentLanguage();

    string szlanguageType = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_LANGUAGE);
    if (szlanguageType == "") {
        char * str = new char[32];
        sprintf(str,"%d",currentLanguage);
        szlanguageType = string(str);

        CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_LANGUAGE, szlanguageType);
    } else {
        int nLanguageType = std::atoi( szlanguageType.c_str() );
        currentLanguage = (ccLanguageType)nLanguageType;
    }

    string resLanguageKey = "";
    
	if (currentLanguage == kLanguageChinese)
	{
		resLanguageKey = "zh";
	}
    else if(currentLanguage == kLanguageBahasa)
    {
        resLanguageKey = "id";
    }
    else if (currentLanguage == kLanguageThailand)
    {
        resLanguageKey = "th";
    }
    else if (currentLanguage == kLanguageArabic)
    {
        resLanguageKey = "ar";
    }
    
    searchPaths.insert(searchPaths.begin(), CCFileUtils::sharedFileUtils()->getDefaultResRootPath() + resLanguageKey);
    searchPaths.insert(searchPaths.begin(), CCFileUtils::sharedFileUtils()->getWritablePath() + "local");
    searchPaths.insert(searchPaths.begin(), CCFileUtils::sharedFileUtils()->getWritablePath() + "local/" + resLanguageKey);
	searchPaths.insert(searchPaths.begin(), CCFileUtils::sharedFileUtils()->getWritablePath());
	CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);

	CCScene *updateScene = CCScene::create();
	UpdateLayer *updateLayer = new UpdateLayer();
	updateScene->addChild(updateLayer);
	updateLayer->release();

	pDirector->runWithScene(updateScene);
    
    // ShareSDK
    initPlatformConfig();

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    CCDirector::sharedDirector()->stopAnimation();
	CCDirector::sharedDirector()->pause();

    SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
	CCDirector::sharedDirector()->stopAnimation();
	CCDirector::sharedDirector()->resume();
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
	this->scheduleOnce(schedule_selector(UpdateLayer::update), 0.1f);
}

void UpdateLayer::update(float t)
{
	getAssetsManager()->update();
}

bool UpdateLayer::init()
{
	CCLayer::init();

	createDownloadedDir();

	CCSprite* background = CCSprite::create(CCFileUtils::sharedFileUtils()->fullPathForFilename("images/Default-568h@2x.png").c_str());
	background->setPosition(ccp(320, 568));
	addChild(background);

	string versionStr = "Version: ";
	versionStr.append(CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_VERSION));
	CCLabelTTF *versionLabel = CCLabelTTF::create(versionStr.c_str(), "Arial", 20);
	versionLabel->setPosition(ccp(320, 30));
	versionLabel->setFontFillColor(ccWHITE);
	addChild(versionLabel);

	pProgressLabel = CCLabelTTF::create("Loading...", "Arial", 30);
	pProgressLabel->setPosition(ccp(320, 300));
	pProgressLabel->setFontFillColor(ccBLACK);
	addChild(pProgressLabel);

	return true;
}

AssetsManager* UpdateLayer::getAssetsManager()
{
	static AssetsManager *pAssetsManager = NULL;

	if (!pAssetsManager)
	{
		unsigned long pSize = 0;
		char* serverConfigChar = (char*)CCFileUtils::sharedFileUtils()->getFileData("server", "r", &pSize);
		string serverConfig(serverConfigChar, pSize);
		rapidjson::Document jsonDict;
		jsonDict.Parse<0>(serverConfig.c_str());
		if (jsonDict.HasParseError())
		{
			CCLOG("GetParseError %s\n", jsonDict.GetParseError());
		}

		string assetsVersion = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_VERSION);

		bool useDev = DICTOOL->getBooleanValue_json(jsonDict, "useDev");
		string selfUpdateURL(DICTOOL->getStringValue_json(jsonDict, "selfUpdateURL"));
		selfUpdateURL.append("?version=").append(assetsVersion)
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
			.append("&deviceType=IOS")
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
			.append("&deviceType=ANDROID")
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
			.append("&deviceType=IOS")
#endif
			.append("&useDev=").append(useDev ? "true" : "false");

		const char* versionAPI = selfUpdateURL.c_str();

		pAssetsManager = new AssetsManager("https://raw.githubusercontent.com/lesliesam/fhres/master/dev/res.zip",
			versionAPI, pathToSave.c_str());
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
		//pProgressLabel->setString("");
	}

	if (errorCode == AssetsManager::kNetwork)
	{
		//pProgressLabel->setString("");
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
	vector<string> searchPaths = CCFileUtils::sharedFileUtils()->getSearchPaths();
	searchPaths.insert(searchPaths.begin(), pathToSave);
	CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);

	string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("footballhero.lua");
	CCScriptEngineManager::sharedManager()->getScriptEngine()->executeScriptFile(path.c_str());
}

void authResultHandler(C2DXResponseState state, C2DXPlatType platType, CCDictionary *error)
{
    switch (state) {
        case C2DXResponseStateSuccess:
        {
            CCLog("授权成功");
            CCDictionary *content = CCDictionary::create();
            content -> setObject(CCString::create("I have won a prize in FootballHero Spin-The-Wheel game! Download now for a chance to win Messi & Ronaldo Signed Jerseys!"), "content");
            content -> setObject(CCString::create("https://fbexternal-a.akamaihd.net/safe_image.php?d=AQDUZiW0WQBqnF67&w=487&h=255&url=http%3A%2F%2Ffhmainstorage.blob.core.windows.net%2Ffhres%2Fspin-the-wheel-1200x650.png&cfs=1&upscale=1"), "image");
            content -> setObject(CCString::create("Football Hero"), "title");
            content -> setObject(CCString::create("Football Hero"), "description");
            content -> setObject(CCString::create("http://www.footballheroapp.com/download"), "url");
            content -> setObject(CCString::createWithFormat("%d", C2DXContentTypeNews), "type");
            content -> setObject(CCString::create("http://www.footballheroapp.com"), "siteUrl");
            content -> setObject(CCString::create("FootballHero"), "site");
            content -> setObject(CCString::create("extInfo"), "extInfo");
            
            
            //C2DXShareSDK::shareContent(C2DXPlatTypeFacebook, content, 0);
            C2DXShareSDK::showShareView(C2DXPlatTypeFacebook, content, NULL);

            break;
        }
        case C2DXResponseStateFail:
            CCLog("授权失败");
            break;
        default:
            break;
    }
}

void shareResultHandler(C2DXResponseState state, C2DXPlatType platType, CCDictionary *shareInfo, CCDictionary *error)
{
    switch (state) {
        case C2DXResponseStateSuccess:
            CCLog("分享成功");
            break;
        case C2DXResponseStateFail:
            CCLog("分享失败");
            break;
        default:
            break;
    }
}

void AppDelegate::initPlatformConfig()
{
    C2DXShareSDK::open(CCString::create("358192cd0c0a"), false);
    
    //微信
    CCDictionary *wcConfigDict = CCDictionary::create();
    wcConfigDict -> setObject(CCString::create("wxf75bd5c7f852b490"), "app_id");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeWeixiSession, wcConfigDict);
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeWeixiTimeline, wcConfigDict);
    
    /**
    C2DXShareSDK::authorize(C2DXPlatTypeFacebook, authResultHandler);
    
    // Share example w/o shareMenu
    CCDictionary *content = CCDictionary::create();
    content -> setObject(CCString::create("I have won a prize in FootballHero Spin-The-Wheel game! Download now for a chance to win Messi & Ronaldo Signed Jerseys!"), "content");
    content -> setObject(CCString::create("https://fbexternal-a.akamaihd.net/safe_image.php?d=AQDUZiW0WQBqnF67&w=487&h=255&url=http%3A%2F%2Ffhmainstorage.blob.core.windows.net%2Ffhres%2Fspin-the-wheel-1200x650.png&cfs=1&upscale=1"), "image");
    content -> setObject(CCString::create("Football Hero"), "title");
    content -> setObject(CCString::create("Football Hero"), "description");
    content -> setObject(CCString::create("http://www.footballheroapp.com/download"), "url");
    content -> setObject(CCString::createWithFormat("%d", C2DXContentTypeNews), "type");
    content -> setObject(CCString::create("http://www.footballheroapp.com"), "siteUrl");
    content -> setObject(CCString::create("FootballHero"), "site");
    content -> setObject(CCString::create("extInfo"), "extInfo");
    
    //C2DXShareSDK::showShareMenu(NULL, content, CCPointMake(100, 100), C2DXMenuArrowDirectionLeft, shareResultHandler);
    //C2DXShareSDK::shareContent(C2DXPlatTypeFacebook, content, shareResultHandler);
    **/
    
    
    /**
    //新浪微博
    CCDictionary *sinaConfigDict = CCDictionary::create();
    sinaConfigDict -> setObject(CCString::create("568898243"), "app_key");
    sinaConfigDict -> setObject(CCString::create("38a4f8204cc784f81f9f0daaf31e02e3"), "app_secret");
    sinaConfigDict -> setObject(CCString::create("http://www.sharesdk.cn"), "redirect_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeSinaWeibo, sinaConfigDict);
    
    //腾讯微博
    CCDictionary *tcConfigDict = CCDictionary::create();
    tcConfigDict -> setObject(CCString::create("801307650"), "app_key");
    tcConfigDict -> setObject(CCString::create("ae36f4ee3946e1cbb98d6965b0b2ff5c"), "app_secret");
    tcConfigDict -> setObject(CCString::create("http://www.sharesdk.cn"), "redirect_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeTencentWeibo, tcConfigDict);
    
    //短信
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeSMS, NULL);
    
    //QQ空间
    CCDictionary *qzConfigDict = CCDictionary::create();
    qzConfigDict -> setObject(CCString::create("100371282"), "app_id");
    qzConfigDict -> setObject(CCString::create("aed9b0303e3ed1e27bae87c33761161d"), "app_key");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeQZone, qzConfigDict);
    **/
    
    /**
    //QQ
    CCDictionary *qqConfigDict = CCDictionary::create();
    qqConfigDict -> setObject(CCString::create("100371282"), "app_id");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeQQ, qqConfigDict);
    
    //Facebook
    CCDictionary *fbConfigDict = CCDictionary::create();
    fbConfigDict -> setObject(CCString::create("107704292745179"), "api_key");
    fbConfigDict -> setObject(CCString::create("38053202e1a5fe26c80c753071f0b573"), "app_secret");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeFacebook, fbConfigDict);
    
    //Twitter
    CCDictionary *twConfigDict = CCDictionary::create();
    twConfigDict -> setObject(CCString::create("mnTGqtXk0TYMXYTN7qUxg"), "consumer_key");
    twConfigDict -> setObject(CCString::create("ROkFqr8c3m1HXqS3rm3TJ0WkAJuwBOSaWhPbZ9Ojuc"), "consumer_secret");
    twConfigDict -> setObject(CCString::create("http://www.sharesdk.cn"), "redirect_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeTwitter, twConfigDict);
    
    //Google+
    CCDictionary *gpConfigDict = CCDictionary::create();
    gpConfigDict -> setObject(CCString::create("232554794995.apps.googleusercontent.com"), "client_id");
    gpConfigDict -> setObject(CCString::create("PEdFgtrMw97aCvf0joQj7EMk"), "client_secret");
    gpConfigDict -> setObject(CCString::create("http://localhost"), "redirect_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeGooglePlus, gpConfigDict);
    
    //人人网
    CCDictionary *rrConfigDict = CCDictionary::create();
    rrConfigDict -> setObject(CCString::create("226427"), "app_id");
    rrConfigDict -> setObject(CCString::create("fc5b8aed373c4c27a05b712acba0f8c3"), "app_key");
    rrConfigDict -> setObject(CCString::create("f29df781abdd4f49beca5a2194676ca4"), "secret_key");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeRenren, rrConfigDict);
    
    //开心网
    CCDictionary *kxConfigDict = CCDictionary::create();
    kxConfigDict -> setObject(CCString::create("358443394194887cee81ff5890870c7c"), "api_key");
    kxConfigDict -> setObject(CCString::create("da32179d859c016169f66d90b6db2a23"), "secret_key");
    kxConfigDict -> setObject(CCString::create("http://www.sharesdk.cn/"), "redirect_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeKaixin, kxConfigDict);
    
    //邮件
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeMail, NULL);
    
    //打印
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeAirPrint, NULL);
    
    //拷贝
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeCopy, NULL);
    
    //搜狐微博
    CCDictionary *shwbConfigDict = CCDictionary::create();
    shwbConfigDict -> setObject(CCString::create("SAfmTG1blxZY3HztESWx"), "consumer_key");
    shwbConfigDict -> setObject(CCString::create("yfTZf)!rVwh*3dqQuVJVsUL37!F)!yS9S!Orcsij"), "consumer_secret");
    shwbConfigDict -> setObject(CCString::create("http://www.sharesdk.cn"), "callback_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeSohuWeibo, shwbConfigDict);
    
    //网易微博
    CCDictionary *neConfigDict = CCDictionary::create();
    neConfigDict -> setObject(CCString::create("T5EI7BXe13vfyDuy"), "consumer_key");
    neConfigDict -> setObject(CCString::create("gZxwyNOvjFYpxwwlnuizHRRtBRZ2lV1j"), "consumer_secret");
    neConfigDict -> setObject(CCString::create("http://www.shareSDK.cn"), "redirect_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatType163Weibo, neConfigDict);
    
    //豆瓣
    CCDictionary *dbConfigDict = CCDictionary::create();
    dbConfigDict -> setObject(CCString::create("02e2cbe5ca06de5908a863b15e149b0b"), "api_key");
    dbConfigDict -> setObject(CCString::create("9f1e7b4f71304f2f"), "secret");
    dbConfigDict -> setObject(CCString::create("http://www.sharesdk.cn"), "redirect_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeDouBan, dbConfigDict);
    
    //印象笔记
    CCDictionary *enConfigDict = CCDictionary::create();
    enConfigDict -> setObject(CCString::create("sharesdk-7807"), "consumer_key");
    enConfigDict -> setObject(CCString::create("d05bf86993836004"), "consumer_secret");
    enConfigDict -> setObject(CCString::create("0"), "host_type");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeEvernote, enConfigDict);
    
    //LinkedIn
    CCDictionary *liConfigDict = CCDictionary::create();
    liConfigDict -> setObject(CCString::create("ejo5ibkye3vo"), "api_key");
    liConfigDict -> setObject(CCString::create("cC7B2jpxITqPLZ5M"), "secret_key");
    liConfigDict -> setObject(CCString::create("http://sharesdk.cn"), "redirect_url");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeLinkedIn, liConfigDict);
    
    //Pinterest
    CCDictionary *piConfigDict = CCDictionary::create();
    piConfigDict -> setObject(CCString::create("1432928"), "client_id");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypePinterest, piConfigDict);
    
    //Pocket
    CCDictionary *poConfigDict = CCDictionary::create();
    poConfigDict -> setObject(CCString::create("11496-de7c8c5eb25b2c9fcdc2b627"), "consumer_key");
    poConfigDict -> setObject(CCString::create("pocketapp1234"), "redirect_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypePocket, poConfigDict);
    
    //Instapaper
    CCDictionary *ipConfigDict = CCDictionary::create();
    ipConfigDict -> setObject(CCString::create("4rDJORmcOcSAZL1YpqGHRI605xUvrLbOhkJ07yO0wWrYrc61FA"), "consumer_key");
    ipConfigDict -> setObject(CCString::create("GNr1GespOQbrm8nvd7rlUsyRQsIo3boIbMguAl9gfpdL0aKZWe"), "consumer_secret");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeInstapaper, ipConfigDict);
    
    //有道云笔记
    CCDictionary *ydConfigDict = CCDictionary::create();
    ydConfigDict -> setObject(CCString::create("dcde25dca105bcc36884ed4534dab940"), "consumer_key");
    ydConfigDict -> setObject(CCString::create("d98217b4020e7f1874263795f44838fe"), "consumer_secret");
    ydConfigDict -> setObject(CCString::create("http://www.sharesdk.cn/"), "oauth_callback");
    ydConfigDict -> setObject(CCString::create("1"), "host_type");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeYouDaoNote, ydConfigDict);
    
    //搜狐随身看
    CCDictionary *shkConfigDict = CCDictionary::create();
    shkConfigDict -> setObject(CCString::create("e16680a815134504b746c86e08a19db0"), "app_key");
    shkConfigDict -> setObject(CCString::create("b8eec53707c3976efc91614dd16ef81c"), "app_secret");
    shkConfigDict -> setObject(CCString::create("http://sharesdk.cn"), "redirect_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeSohuKan, shkConfigDict);
    
    //Flickr
    CCDictionary *flickrConfigDict = CCDictionary::create();
    flickrConfigDict -> setObject(CCString::create("33d833ee6b6fca49943363282dd313dd"), "api_key");
    flickrConfigDict -> setObject(CCString::create("3a2c5b42a8fbb8bb"), "api_secret");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeFlickr, flickrConfigDict);
    
    //Tumblr
    CCDictionary *tumblrConfigDict = CCDictionary::create();
    tumblrConfigDict -> setObject(CCString::create("2QUXqO9fcgGdtGG1FcvML6ZunIQzAEL8xY6hIaxdJnDti2DYwM"), "consumer_key");
    tumblrConfigDict -> setObject(CCString::create("3Rt0sPFj7u2g39mEVB3IBpOzKnM3JnTtxX2bao2JKk4VV1gtNo"), "consumer_secret");
    tumblrConfigDict -> setObject(CCString::create("http://sharesdk.cn"), "callback_url");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeTumblr, tumblrConfigDict);
    
    //Dropbox
    CCDictionary *dropboxConfigDict = CCDictionary::create();
    dropboxConfigDict -> setObject(CCString::create("7janx53ilz11gbs"), "app_key");
    dropboxConfigDict -> setObject(CCString::create("c1hpx5fz6tzkm32"), "app_secret");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeDropbox, dropboxConfigDict);
    
    //Instagram
    CCDictionary *instagramConfigDict = CCDictionary::create();
    instagramConfigDict -> setObject(CCString::create("ff68e3216b4f4f989121aa1c2962d058"), "client_id");
    instagramConfigDict -> setObject(CCString::create("1b2e82f110264869b3505c3fe34e31a1"), "client_secret");
    instagramConfigDict -> setObject(CCString::create("http://sharesdk.cn"), "redirect_uri");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeInstagram, instagramConfigDict);
    
    //VK
    CCDictionary *vkConfigDict = CCDictionary::create();
    vkConfigDict -> setObject(CCString::create("3921561"), "application_id");
    vkConfigDict -> setObject(CCString::create("6Qf883ukLDyz4OBepYF1"), "secret_key");
    C2DXShareSDK::setPlatformConfig(C2DXPlatTypeVKontakte, vkConfigDict);
     
    **/
}
