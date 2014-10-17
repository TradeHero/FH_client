module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Constants = require("scripts.Constants")

local mWidget

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SoundSettings.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local backBt = widget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    local sfxCheck = tolua.cast( mWidget:getChildByName("sfxCheck"), "CheckBox" )
    sfxCheck:addTouchEventListener( sfxCheckHandler )

    if CCUserDefault:sharedUserDefault():getBoolForKey( Constants.NOTIFICATION_KEY_SFX ) ~= true then
        sfxCheck:setSelectedState( true )
    end
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

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function sfxCheckHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local check = tolua.cast( sender, "CheckBox" )
        CCUserDefault:sharedUserDefault():setBoolForKey( Constants.NOTIFICATION_KEY_SFX, check:getSelectedState() )

        AudioEngine.playEffect( AudioEngine.SETTINGS_ON_OFF )
    end
end
