module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")


local mVideoURL
local mWidget

function loadFrame( videoURL )
    mVideoURL = videoURL

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityPlayVideoFrame.json")

    local backBt = widget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local playButton = mWidget:getChildByName("Button_PlayVideo")
    local gotoVideoButton = mWidget:getChildByName("Button_GotoVideo")
    local subtitle = tolua.cast( mWidget:getChildByName("Label_content1"), "Label" )
    local disclaimer = tolua.cast( mWidget:getChildByName("Label_content2"), "Label" )
    local thumbnail = tolua.cast( mWidget:getChildByName("Panel_thumbnail"):getChildByName("Image_thumbnail"), "ImageView" )
    playButton:addTouchEventListener( playVideoHandler )
    gotoVideoButton:addTouchEventListener( playVideoHandler )
    subtitle:setText( Constants.String.community.highlight_subtitle )
    disclaimer:setText( Constants.String.community.highlight_disclaimer )
    thumbnail:setEnabled( false )

    local callback = function( success, videoInfo )
        if success and videoInfo and type( videoInfo ) == "table" then
            local imageUrl = videoInfo["thumbnail_url"]

            if imageUrl then
                local handler = function( path )
                    if mWidget and thumbnail and path then
                        thumbnail:loadTexture( path )
                        thumbnail:setEnabled( true )
                    end
                end
                
                SMIS.getVideoImagePath( imageUrl, handler )
            end
        end
    end
    EventManager:postEvent( Event.Do_Get_DailyMotion_Video_Info, { mVideoURL, callback } )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function playVideoHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        Misc:sharedDelegate():openUrl( mVideoURL )
    end
end