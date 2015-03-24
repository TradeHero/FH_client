#ifndef __APP_DELEGATE_H__
#define __APP_DELEGATE_H__

#include "cocos2d.h"
#include "Social/C2DXShareSDK.h"
#include "AssetsManager/AssetsManager.h"

using namespace cn::sharesdk;

/**
@brief    The cocos2d Application.

The reason for implement as private inheritance is to hide some interface call by CCDirector.
*/
class  AppDelegate : private cocos2d::CCApplication
{
private:
    // Init the ShareSDK config.
    void initPlatformConfig();

public:
    AppDelegate();
    virtual ~AppDelegate();

    /**
    @brief    Implement CCDirector and CCScene init code here.
    @return true    Initialize success, app continue.
    @return false   Initialize failed, app terminate.
    */
    virtual bool applicationDidFinishLaunching();

    /**
    @brief  The function be called when the application enter background
    @param  the pointer of the application
    */
    virtual void applicationDidEnterBackground();

    /**
    @brief  The function be called when the application enter foreground
    @param  the pointer of the application
    */
    virtual void applicationWillEnterForeground();
};


class UpdateLayer : public cocos2d::CCLayer, public cocos2d::extension::AssetsManagerDelegateProtocol
{
public:
	UpdateLayer();
	~UpdateLayer();
	virtual bool init();
	void loadGame();

    virtual void onEnter();
	virtual void update(float t);
	virtual void onError(cocos2d::extension::AssetsManager::ErrorCode errorCode);
	virtual void onProgress(int percent);
	virtual void onSuccess();
	

private:
	cocos2d::extension::AssetsManager* getAssetsManager();
	void createDownloadedDir();

	cocos2d::CCMenuItemFont *pItemEnter;
	cocos2d::CCMenuItemFont *pItemReset;
	cocos2d::CCMenuItemFont *pItemUpdate;
	cocos2d::CCLabelTTF *pProgressLabel;
	std::string pathToSave;
};
#endif  // __APP_DELEGATE_H__

