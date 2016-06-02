module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local CommunityConfig = require("scripts.config.Community")
local Constants = require("scripts.Constants")

local mWidget
local mToken

function loadFrame( token )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/AskForJoin.json")
    local bg = tolua.cast( widget:getChildByName("Image_bg"), "ImageView" )
    local btnClose = tolua.cast( bg:getChildByName("Button_Close"), "Button" )
    local btnJoin = tolua.cast( bg:getChildByName("Button_Join"), "Button" )

    mToken = token

    btnClose:addTouchEventListener( closeEventHandler )
    btnJoin:addTouchEventListener( joinEventHandler )

    bg:loadTexture( Constants.COMPETITION_IMAGE_PATH .. Constants.AdPrefix .. token .. ".png" )


    widget:addTouchEventListener( onFrameTouch )
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )
    SceneManager.setKeyPadBackEnabled( false )
    local ts = os.time()
    CCUserDefault:sharedUserDefault():setIntegerForKey( "COMPETITION_AD_TIME", ts )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function closeEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
        SceneManager.setKeyPadBackEnabled( true )
    end
end

function joinEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_COMPETITION } )
    end
end


function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end