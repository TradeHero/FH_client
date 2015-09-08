module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")

local mWidget
local mAwardWidget

function loadFrame()
    local widget = SceneManager.secondLayerWidgetFromJsonFile("scenes/FriendsReferalSelection.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local panelTitle = mWidget:getChildByName("Panel_Title")
    local btnBack = panelTitle:getChildByName("Button_Back")
    btnBack:addTouchEventListener( backEventHandler )

    local btnBalance = panelTitle:getChildByName("Button_Balance")
    btnBalance:addTouchEventListener( balanceEventHandler )



    mWidget:getChildByName("Button_fb"):addTouchEventListener( fbInvite )
    mWidget:getChildByName("Button_fbTimeline"):addTouchEventListener( fbTimeline )
    mWidget:getChildByName("Button_wechat"):addTouchEventListener( wechatInvite )
    mWidget:getChildByName("Button_wechatMoments"):addTouchEventListener( wechatMomentsInvite )
    initAwardWidget()
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function keypadBackEventHandler()
    EventManager:popHistory()
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

function initAwardWidget()
    mAwardWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/FriendsReferalAward.json")

    -- Set the text
    -- tolua.cast( mAwardWidget:getChildByName("Label_prize"), "Label" ):setText( Constants.String.spinWheel.win_ticket_prize )
    -- tolua.cast( mAwardWidget:getChildByName("Label_ticket"), "Label" ):setText( Constants.String.spinWheel.win_ticket_left )
    -- tolua.cast( mAwardWidget:getChildByName("Label_description"), "Label" ):setText( Constants.String.spinWheel.win_ticket_left )
    -- tolua.cast( mAwardWidget:getChildByName("Label_please"), "Label" ):setText( Constants.String.spinWheel.win_ticket_left )
    local btnOK = tolua.cast( mAwardWidget:getChildByName("Button_OK"), "Button")
    btnOK:addTouchEventListener( function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            mAwardWidget:setEnabled( false )
        end
    end)

    mAwardWidget:setEnabled( false )
    mWidget:addChild( mAwardWidget )
end

function showAwardWidget( ticket )
    mAwardWidget:setEnabled( true )
    tolua.cast( mAwardWidget:getChildByName("Label_ticket"), "Label" ):setText( ticket )
end

function fbInvite( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_FB_Friend_Referal )
    end
end

function fbTimeline( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_FB_Timeline_Friend_Referal )
    end
end

function wechatInvite( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_Wechat_Friend_Referal )
    end
end

function wechatMomentsInvite( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_Wechat_Moments_Friend_Referal )
    end
end