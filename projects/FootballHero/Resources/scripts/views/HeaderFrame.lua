module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SportsConfig = require("scripts.config.Sports")


local mWidget
local mbHasWebView
local mSportChangeEventHanlder

function loadFrame( parent, titleText, bHasBackBtn, bHasWebView )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/HeaderFrame.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    parent:addChild( widget )

    mbHasWebView = bHasWebView

	local title = tolua.cast( widget:getChildByName("Label_Title"), "Label" )
    if titleText ~= nil then
		title:setText( titleText )
        local titleImg = tolua.cast( widget:getChildByName("Image_Title"), "ImageView" )
        titleImg:setEnabled( false ) 
    else
    	title:setEnabled( false )
    end
	
	local backBt = widget:getChildByName("Button_Back")
    if bHasBackBtn then
        SceneManager.setKeypadBackListener( keypadBackEventHandler )
    	backBt:addTouchEventListener( backEventHandler )       
    else
        SceneManager.clearKeypadBackListener()
    	backBt:setEnabled( false )
    end

	local settingsBt = widget:getChildByName("Button_Settings")
    settingsBt:addTouchEventListener( settingsEventHandler )

    local btnLive = tolua.cast( mWidget:getChildByName("Button_Live"), "Button" )
    btnLive:addTouchEventListener( eventLiveClicked )

    showLiveButton( false )

    local menuBtn = tolua.cast( mWidget:getChildByName("Button_menu"), "Button" )
    menuBtn:addTouchEventListener( menuEventHandler )
    menuBtn:setEnabled( false )
    mSportChangeEventHanlder = nil

    hideSportLogo()
    refreshLogo()
end

function eventLiveClicked( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        CCLuaLog("eventLiveClicked")
        EventManager:postEvent( Event.Enter_LiveScoreScene, { 0, false } )
    end
end

function showLiveButton( isShow )
    local btnLive = tolua.cast( mWidget:getChildByName("Button_Live"), "Button" )
    if isShow == true then
        btnLive:setVisible( true )
        btnLive:setTouchEnabled( true )
    else
        btnLive:setVisible( false )
        btnLive:setTouchEnabled( false )
    end
end

function showMenuButtonWithSportChangeEventHanlder( handler )
    local menuBtn = tolua.cast( mWidget:getChildByName("Button_menu"), "Button" )
    menuBtn:setEnabled( true )

    mSportChangeEventHanlder = handler

    showSportLogo()
end

function hideMenuButton()
    local menuBtn = tolua.cast( mWidget:getChildByName("Button_menu"), "Button" )
    menuBtn:setEnabled( false )

    hideSportLogo()
end

function showSportLogo()
    local sportLogo = tolua.cast( mWidget:getChildByName("Image_sportLogo"), "ImageView" )
    sportLogo:setEnabled( true )
end

function hideSportLogo()
    local sportLogo = tolua.cast( mWidget:getChildByName("Image_sportLogo"), "ImageView" )
    sportLogo:setEnabled( false )
end

function refreshLogo()
    local resPath = SportsConfig.getCurrentSportLogoPath()
    local sportLogo = tolua.cast( mWidget:getChildByName("Image_sportLogo"), "ImageView" )
    sportLogo:loadTexture( resPath )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function settingsEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		EventManager:postEvent( Event.Enter_Settings )
	end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    if mbHasWebView then
        WebviewDelegate:sharedDelegate():closeWebpage()
    end
    EventManager:popHistory()
end

function menuEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        if SceneManager.isSideMenuShown() then
            SceneManager.closeSideMenu()
        else
            SceneManager.showSideMenu( function ()
                refreshLogo()

                if mSportChangeEventHanlder then
                    mSportChangeEventHanlder()
                end
            end)
        end
    end
end
