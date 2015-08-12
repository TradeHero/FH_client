module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Header = require("scripts.views.HeaderFrame")

local mWidget

function loadFrame()
    local widget = SceneManager.secondLayerWidgetFromJsonFile("scenes/FriendsReferalSelection.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Header.loadFrame( mWidget, Constants.String.settings.sound_settings, true )

    mWidget:getChildByName("Button_fb"):addTouchEventListener( fbInvite )
    mWidget:getChildByName("Button_wechat"):addTouchEventListener( wechatInvite )
    mWidget:getChildByName("Button_wechatMoments"):addTouchEventListener( wechatMomentsInvite )
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

function fbInvite( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_FB_Friend_Referal )
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