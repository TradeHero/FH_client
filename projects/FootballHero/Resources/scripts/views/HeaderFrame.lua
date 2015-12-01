module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SportsConfig = require("scripts.config.Sports")
local Logic = require("scripts.Logic").getInstance()


local mWidget
local mbHasWebView
local mSportChangeEventHanlder

function loadFrame( parent, titleText, bHasBackBtn, bHasWebView, bHasBalance )
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
	
	local btnBack = widget:getChildByName("Button_Back")
    if bHasBackBtn then
        SceneManager.setKeypadBackListener( keypadBackEventHandler )
    	btnBack:addTouchEventListener( backEventHandler )       
    else
        SceneManager.clearKeypadBackListener()
    	btnBack:setEnabled( false )
    end

    local btnBalance = widget:getChildByName("Button_Balance")
    if bHasBalance then
        btnBalance:addTouchEventListener( balanceEventHandler )
    else
        btnBalance:setEnabled( false )
    end

	local btnSettings = widget:getChildByName("Button_Settings")
    btnSettings:addTouchEventListener( settingsEventHandler )

    local btnStore = widget:getChildByName("Button_Store")
    btnStore:addTouchEventListener( storeEventHandler )

    local btnLive = tolua.cast( mWidget:getChildByName("Button_Live"), "Button" )
    btnLive:addTouchEventListener( eventLiveClicked )

    showLiveButton( false )

    local menuBtn = tolua.cast( mWidget:getChildByName("Button_Menu"), "Button" )
    local menuPanel = mWidget:getChildByName("Panel_Menu")
    menuPanel:addTouchEventListener( menuEventHandler )
    menuBtn:setEnabled( false )
    menuPanel:setEnabled( false )
    mSportChangeEventHanlder = nil

    local labelBalance = tolua.cast( mWidget:getChildByName("Label_Points"), "Label" )
    labelBalance:setText( Logic:getBalance() )

    local labelTickets = tolua.cast( mWidget:getChildByName("Label_Tickets"), "Label" )
    labelTickets:setText( Logic:getTicket() )

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
    local menuBtn = tolua.cast( mWidget:getChildByName("Button_Menu"), "Button" )
    local menuPanel = mWidget:getChildByName("Panel_Menu")
    menuBtn:setEnabled( true )
    menuPanel:setEnabled( true )

    mSportChangeEventHanlder = handler

    showSportLogo()
end

function hideMenuButton()
    local menuBtn = tolua.cast( mWidget:getChildByName("Button_Menu"), "Button" )
    local menuPanel = mWidget:getChildByName("Panel_Menu")
    menuBtn:setEnabled( false )
    menuPanel:setEnabled( false )

    hideSportLogo()
end

function showSportLogo()
    local sportLogo = tolua.cast( mWidget:getChildByName("Image_SportLogo"), "ImageView" )
    sportLogo:setEnabled( true )
end

function hideSportLogo()
    local sportLogo = tolua.cast( mWidget:getChildByName("Image_SportLogo"), "ImageView" )
    sportLogo:setEnabled( false )
end

function refreshLogo()
    local resPath = SportsConfig.getCurrentSportLogoPath()
    local sportLogo = tolua.cast( mWidget:getChildByName("Image_SportLogo"), "ImageView" )
    sportLogo:loadTexture( resPath )
end

function setCurrency( points, tickets )
    local labelPoints = tolua.cast( mWidget:getChildByName("Label_Points"), "Label" )
    local labelTickets = tolua.cast( mWidget:getChildByName("Label_Tickets"), "Label" )
    labelPoints:setText(points)
    labelTickets:setText(tickets)
end

function refreshCurrency()
    EventManager:postEvent( Event.Do_Get_Currencies, { setCurrency } )
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

function storeEventHandler( sender, eventType  )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Store )
    end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function balanceEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Spin_balance )
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
