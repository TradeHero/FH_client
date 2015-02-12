module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Constants = require("scripts.Constants")
local Header = require("scripts.views.HeaderFrame")

local mWidget

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SoundSettings.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Header.loadFrame( mWidget, Constants.String.settings.sound_settings, true )

    local soundfx = tolua.cast( widget:getChildByName("Label_SoundFx"), "Label" )
    soundfx:setText( Constants.String.settings.sound_effects )
    
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

function sfxCheckHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local check = tolua.cast( sender, "CheckBox" )
        CCUserDefault:sharedUserDefault():setBoolForKey( Constants.NOTIFICATION_KEY_SFX, check:getSelectedState() )

        AudioEngine.playEffect( AudioEngine.SETTINGS_ON_OFF )
    end
end
