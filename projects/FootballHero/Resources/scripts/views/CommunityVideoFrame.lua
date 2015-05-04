module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local Constants = require("scripts.Constants")
local TeamConfig = require("scripts.config.Team")
local ShareConfig = require("scripts.config.Share")


local mWidget
local mLeaderboardId
local mSubType
local mStep
local mCurrentTotalNum
local mHasMoreToLoad
local mDropDown
local mFilter

--[[
[   
    {
        "Title": "Lionel Messi - Magic Skills",
        "videoKey": "gW2UWuPTekk",
        "Time":"2015/4/30"
    },

    {
        "Title": "Lionel Messi - The King of Dribbling",
        "videoKey": "8cBIAwh4EjA",
        "Time":"2015/4/30"
    },

    {
        "Title": "Lionel Messi - Craziest Nutmegs Ever",
        "videoKey": "W40sCCdij2o",
        "Time":"2015/4/30"
    },

    {
        "Title": "There's Only One Ronaldo - Best Goals",
        "videoKey": "m8bZhNBQktQ",
        "Time":"2015/4/30"
    }
]

--]]

function loadFrame( parent, highLightInfo )
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityVideoFrame.json")
    parent:addChild( mWidget )
    mWidget:registerScriptHandler( EnterOrExit )

    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Video"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    
    for i = 1, table.getn( highLightInfo ) do
        local info = highLightInfo[i]
        
        local content = SceneManager.widgetFromJsonFile("scenes/CommunityVideoContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        local title = tolua.cast( content:getChildByName("Label_title"), "Label" )
        local time = tolua.cast( content:getChildByName("Label_time"), "Label" )
        local playBt = tolua.cast( content:getChildByName("Button_play"), "Button" )
        local shareBt = tolua.cast( content:getChildByName("Button_share"), "Button" )
        local thumbnail = tolua.cast( content:getChildByName("Panel_thumbnail"):getChildByName("Image_thumbnail"), "ImageView" )

        time:setText( info["Time"] )
        title:setText( info["Title"] )
        thumbnail:setEnabled( false )

        local playHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                local videoURL = Constants.getYoutubeVideoURLByKey( info["videoKey"] )
                EventManager:postEvent( Event.Enter_Video_Info, { videoURL, info["videoKey"] } )
            end
        end
        playBt:addTouchEventListener( playHandler )

        local shareHandler = function ( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                local callback = function( success, platType )
                    if success then
                        -- Do nothing.
                    end
                end

                local shareText = string.format( Constants.String.community.video_share_text, info["Title"] )
                local imageUrl = Constants.getYoutubeThumbnailURLByKey( info["videoKey"] )
                EventManager:postEvent( Event.Enter_Share, { ShareConfig.SHARE_VIDEO, callback, shareText, imageUrl } )
            end
        end
        shareBt:addTouchEventListener( shareHandler )

        -- Load thumbnail
        loadThumbnailImage( info["videoKey"], i, thumbnail )
    end
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function exitFrame()
    mWidget = nil
end

function isShown()
    return mWidget ~= nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end


function loadThumbnailImage( imageUrlKey, i, thumbnail )
    local seqArray = CCArray:create()

    seqArray:addObject( CCDelayTime:create( 0.1 * ( i - 1 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        imageUrl = Constants.getYoutubeThumbnailURLByKey( imageUrlKey )

        local handler = function( path )
            if mWidget and thumbnail and path then
                thumbnail:loadTexture( path )
                thumbnail:setEnabled( true )
            end
        end
        
        SMIS.getVideoImagePath( imageUrl, handler, imageUrlKey..".jpg" )
    end ) )
    
    mWidget:runAction( CCSequence:create( seqArray ) )
end
