module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local Constants = require("scripts.Constants")
local TeamConfig = require("scripts.config.Team")
local ShareConfig = require("scripts.config.Share")


local mWidget

-- DS, see Competitions.lua
function loadFrame( parent, highLightInfo )
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityMediaFrame.json")
    parent:addChild( mWidget )
    mWidget:registerScriptHandler( EnterOrExit )
    local tabHighlight = tolua.cast( mWidget:getChildByName( "Button_HighLights" ), "Button" )
    local tabVideo = tolua.cast( mWidget:getChildByName( "Button_Videos" ), "Button" )
    
    -- init tab
    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Do_Show_Media, {1 , tabSelected })
        end
    end
    tabHighlight:setTitleText( Constants.String.community["title_highlight"] )
    tabHighlight:addTouchEventListener( eventHandler )

    eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Do_Show_Media, {2 , tabSelected })
        end
    end
    tabVideo:setTitleText( Constants.String.community["title_video"] )
    tabVideo:addTouchEventListener( eventHandler )
 
    tabSelected( 1 ,highLightInfo )
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

function  tabSelected( tabId, highLightInfo )
    local tabHighlight = tolua.cast( mWidget:getChildByName( "Button_HighLights" ), "Button" )
    local tabVideo = tolua.cast( mWidget:getChildByName( "Button_Videos" ), "Button" )
	if tabId == 1 then
        tabHighlight:setBright( false )
        tabHighlight:setTouchEnabled( false )
        tabHighlight:setTitleColor( ccc3( 255, 255, 255 ) )
        tabVideo:setBright( true )
        tabVideo:setTouchEnabled( true )
        tabVideo:setTitleColor( ccc3( 127, 127, 127 ) )

		initHighLightContent(highLightInfo)
	elseif tabId == 2 then
        tabVideo:setBright( false )
        tabVideo:setTouchEnabled( false )
        tabVideo:setTitleColor( ccc3( 255, 255, 255 ) )
        tabHighlight:setBright( true )
        tabHighlight:setTouchEnabled( true )
        tabHighlight:setTitleColor( ccc3( 127, 127, 127 ) )

		initVideoContent(highLightInfo)
	end
end

function initHighLightContent( highLightInfo )
    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    
    for i = 1, table.getn( highLightInfo ) do
        local info = highLightInfo[i]
        
        local content = SceneManager.widgetFromJsonFile("scenes/CommunityHighLightContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        local teamName1 = tolua.cast( content:getChildByName("Label_teamname1"), "Label" )
        local teamName2 = tolua.cast( content:getChildByName("Label_teamname2"), "Label" )
        local teamImage1 = tolua.cast( content:getChildByName("Image_Team1"), "ImageView" )
        local teamImage2 = tolua.cast( content:getChildByName("Image_Team2"), "ImageView" )
        local score = tolua.cast( content:getChildByName("Label_score"), "Label" )
        local time = tolua.cast( content:getChildByName("Label_time"), "Label" )
        local playBt = tolua.cast( content:getChildByName("Button_play"), "Button" )
        local shareBt = tolua.cast( content:getChildByName("Button_share"), "Button" )
        local thumbnail = tolua.cast( content:getChildByName("Panel_thumbnail"):getChildByName("Image_thumbnail"), "ImageView" )

        teamName1:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( info["HomeID"] ) ) )
        teamName2:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( info["AwayID"] ) ) )
        teamImage1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( info["HomeID"] ), true ) )
        teamImage2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( info["AwayID"] ), false ) )
        time:setText( info["Time"] )
        score:setText( info["HomeGoal"].." - "..info["AwayGoal"] )

        local playHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Enter_Video_Info, { info["videoURL"] } )
            end
        end
        playBt:addTouchEventListener( playHandler )

        local shareHandler = function ( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                local callback = function( success, videoInfo )
                    local imageUrl = ""
                    if success and videoInfo and type( videoInfo ) == "table" then
                        imageUrl = videoInfo["thumbnail_url"]
                    else
                        EventManager:postEvent( Event.Show_Info, { Constants.String.error.video_not_available } )
                        return
                    end

                    local callback = function( success, platType )
                        if success then
                            -- Do nothing.
                        end
                    end

                    local shareText = string.format( Constants.String.community.highlight_share_text, 
                                        TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( info["HomeID"] ) ),
                                        info["HomeGoal"], 
                                        info["AwayGoal"],
                                        TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( info["AwayID"] ) ) )

                    EventManager:postEvent( Event.Enter_Share, { ShareConfig.SHARE_VIDEO, callback, shareText, imageUrl } )
                end
                EventManager:postEvent( Event.Do_Get_DailyMotion_Video_Info, { info["videoURL"], callback } )
            end
        end
        shareBt:addTouchEventListener( shareHandler )

        -- Load thumbnail
        loadHThumbnailImage( info["videoURL"], i, thumbnail )
    end
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initVideoContent( highLightInfo )
   local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
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
        loadVThumbnailImage( info["videoKey"], i, thumbnail )
    end
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end 



function loadHThumbnailImage( imageUrlKey, i, thumbnail )
    local seqArray = CCArray:create()

    seqArray:addObject( CCDelayTime:create( 0.1 * ( i - 1 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        local callback = function( success, videoInfo )
            if success and videoInfo and type( videoInfo ) == "table" then
                local imageUrl = videoInfo["thumbnail_url"]

                if imageUrl then
                    local handler = function( path )
                        CCLuaLog("highLight thumbnail")
                        if mWidget and thumbnail and path then
                            thumbnail:loadTexture( path )
                            thumbnail:setEnabled( true )
                            thumbnail:ignoreContentAdaptWithSize( false )
                            thumbnail:setSize( CCSize:new( 620, 280 ) )
                        end
                    end
                    
                    SMIS.getVideoImagePath( imageUrl, handler )
                end
            end
        end
        EventManager:postEvent( Event.Do_Get_DailyMotion_Video_Info, { imageUrlKey , callback } )
    end ) )
    
    mWidget:runAction( CCSequence:create( seqArray ) )
end


function loadVThumbnailImage( imageUrlKey, i, thumbnail )
    local seqArray = CCArray:create()

    seqArray:addObject( CCDelayTime:create( 0.1 * ( i - 1 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        imageUrl = Constants.getYoutubeThumbnailURLByKey( imageUrlKey )

        local handler = function( path )
            CCLuaLog("video thumbnail")
            if mWidget and thumbnail and path then
                thumbnail:loadTexture( path )
                thumbnail:setEnabled( true )
                thumbnail:ignoreContentAdaptWithSize( false )
                thumbnail:setSize( CCSize:new( 620, 280 ) )
            end
        end
        
        SMIS.getVideoImagePath( imageUrl, handler, imageUrlKey..".jpg" )
    end ) )
    
    mWidget:runAction( CCSequence:create( seqArray ) )
end
