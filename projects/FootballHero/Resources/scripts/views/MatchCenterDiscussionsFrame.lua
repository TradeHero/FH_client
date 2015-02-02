module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local Constants = require("scripts.Constants")
local Logic = require("scripts.Logic").getInstance()
local MatchCenterConfig = require("scripts.config.MatchCenter")

local mWidget
local mStep
local mCurrentTotalNum
local mHasMoreToLoad
local mMatch

local mScrollPositionY
--local mCurrScrollDirection
local mScrollCallback

local CONTENT_HEIGHT_LARGE = 880
local CONTENT_HEIGHT_SMALL = 520
local CONTENT_HEIGHT_SPEED = 30

-- DS for subType see LeaderboardConfig
function loadFrame( parent, jsonResponse, callback )
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterDiscussionsFrame.json")
    parent:addChild( mWidget )

    mScrollCallback = callback

    local discussionInfo
    if jsonResponse["GameInformation"] == nil then
        discussionInfo = jsonResponse
    else
        discussionInfo = jsonResponse["DiscussionInformation"]
    end
    mMatch = Logic:getSelectedMatch()
    
    mStep = 1
    if table.getn( discussionInfo ) < Constants.DISCUSSIONS_PER_PAGE then
        mHasMoreToLoad = false
    else
        mHasMoreToLoad = true
    end

    initContent( discussionInfo )
end

function exitFrame()
    mWidget = nil
end

function isShown()
    return mWidget ~= nil
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function initContent( discussionInfo )

    local eventHandler = function( sender,eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_Make_Discussion_Post, {} )
        end
    end

    local button = tolua.cast( mWidget:getChildByName("Button_Discussion"), "Button" )
    button:addTouchEventListener( eventHandler )
    local text = tolua.cast( button:getChildByName("Label_Discussion"), "Label" )
    text:setText( Constants.String.match_center.write_discussion )

	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Discussion"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0
    
    for i = 1, table.getn( discussionInfo ) do
        local content = SceneManager.widgetFromJsonFile("scenes/MatchCenterDiscussionsContentFrame.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content,  -discussionInfo[i]["UnixTimeStamp"] )
        contentHeight = contentHeight + content:getSize().height
        initDiscussionContent( i, content, discussionInfo[i] )
    end
    mCurrentTotalNum = table.getn( discussionInfo )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
    contentContainer:addEventListenerScrollView( scrollViewEventHandler )
    contentContainer:addTouchEventListener( scrollTouchEventListener )
end

function initDiscussionContent( i, content, info )
    
    local top  = content:getChildByName("Panel_Top")
    local bottom  = content:getChildByName("Panel_Bottom")
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local post = tolua.cast( top:getChildByName("Label_Post"), "Label" )
    local time = tolua.cast( top:getChildByName("Label_Time"), "Label" )
    
    local checkLike = tolua.cast( bottom:getChildByName("CheckBox_Like"), "CheckBox" )
    local lblLike = tolua.cast( bottom:getChildByName("Label_Like"), "Label" )
    local comments = tolua.cast( bottom:getChildByName("Label_Comments"), "Label" )
    local btnComments = tolua.cast( bottom:getChildByName("Button_Comments"), "Button" )
    local share = tolua.cast( bottom:getChildByName("Button_Share"), "Button" )

    local enterDetailEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_Discussion_Details, info )
        end
    end
    top:addTouchEventListener( enterDetailEventHandler )
    btnComments:addTouchEventListener( enterDetailEventHandler )
    
    local enterHistoryEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_History, { info["UserId"] } )
        end
    end
    logo:setTouchEnabled( true )
    logo:addTouchEventListener( enterHistoryEventHandler )

    local enableLikeEventHandler = function( bLiked )
        checkLike:setTouchEnabled( true )
        local newCount
        if bLiked then
            newCount = tonumber( lblLike:getStringValue() ) + 1
        else
            newCount = math.max( 0, tonumber( lblLike:getStringValue() ) - 1 )
        end
        info["LikeCount"] = newCount
        info["Liked"] = bLiked
        lblLike:setText( newCount )
    end
    local likeEventHandler = function( sender, eventType )
        local checkbox = tolua.cast( sender, "CheckBox" )    
        if eventType == TOUCH_EVENT_ENDED then
            checkbox:setTouchEnabled( false )
            EventManager:postEvent( Event.Do_Like_Discussion_Post, { info["Id"], not checkbox:getSelectedState(), enableLikeEventHandler, MatchCenterConfig.DISCUSSION_POST_TYPE_GAME } )
        end
    end
    checkLike:addTouchEventListener( likeEventHandler )

    --share:addTouchEventListener( shareTypeSelectEventHandler )
    share:setEnabled( false )

    if type( info["DisplayName"]  ) ~= "string" or info["DisplayName"] == nil then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    post:setText( info["Text"] )
    local originalSize = post:getSize()
    if originalSize.width > MatchCenterConfig.MAX_DISCUSSION_POST_TEXT_WIDTH then

        info["numOfRows"] = math.ceil( originalSize.width / MatchCenterConfig.MAX_DISCUSSION_POST_TEXT_WIDTH )
        if info["numOfRows"] > 2 then
            -- truncate text
            info["ShortText"] = string.sub( post:getStringValue(), 0, 90 ).."..."
            post:setText( info["ShortText"] )
        end

        post:setTextAreaSize( CCSize:new( MatchCenterConfig.MAX_DISCUSSION_POST_TEXT_WIDTH, MatchCenterConfig.MAX_DISCUSSION_TEXT_HEIGHT ) )
    end

    lblLike:setText( info["LikeCount"] )
    checkLike:setSelectedState( info["Liked"] )
    comments:setText( info["CommentCount"] )
    
    MatchCenterConfig.setTimeDiff( time, info["UnixTimeStamp"] )
    
    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        if info["PictureUrl"] ~= nil then
            local handler = function( filePath )
                if filePath ~= nil and mWidget ~= nil and logo ~= nil then
                    local safeLoadTexture = function()
                        logo:loadTexture( filePath )
                    end

                    local errorHandler = function( msg )
                        -- Do nothing
                    end

                    xpcall( safeLoadTexture, errorHandler )
                end
            end
            SMIS.getSMImagePath( info["PictureUrl"], handler )
        end
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function loadMoreContent( discussionInfo )
    if table.getn( discussionInfo ) < Constants.DISCUSSIONS_PER_PAGE then
        mHasMoreToLoad = false
        if table.getn( discussionInfo ) == 0 then
            return
        end
    else
        mHasMoreToLoad = true
    end

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Discussion"), "ScrollView" )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = contentContainer:getInnerContainerSize().height

    for i = 1, table.getn( discussionInfo ) do
        local content = SceneManager.widgetFromJsonFile("scenes/MatchCenterDiscussionsContentFrame.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content,  -discussionInfo[i]["UnixTimeStamp"] )
        contentHeight = contentHeight + content:getSize().height
        initDiscussionContent( mCurrentTotalNum + i, content, discussionInfo[i] )
    end
    mCurrentTotalNum = mCurrentTotalNum + table.getn( discussionInfo )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end



function scrollTouchEventListener( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        mScrollPositionY = nil
    end
end

function scrollViewEventHandler( target, eventType )
    
    if eventType == SCROLLVIEW_EVENT_SCROLLING then
        local scrollview = tolua.cast( target, "ScrollView" )
        local container = scrollview:getInnerContainer()
        
        local currentHeight = scrollview:getSize().height
        local newHeight = currentHeight

        if mScrollPositionY ~= nil then
            if mScrollPositionY < container:getPositionY() then
                --print("scrolling down..")
                showMatchInfo( false )

                newHeight = math.min( currentHeight + CONTENT_HEIGHT_SPEED, CONTENT_HEIGHT_LARGE )
                
            elseif mScrollPositionY > container:getPositionY() then
                --print("scrolling up..")
                showMatchInfo( true )

                newHeight = math.max( currentHeight - CONTENT_HEIGHT_SPEED, CONTENT_HEIGHT_SMALL )
            end

            scrollview:setSize( CCSize:new( scrollview:getSize().width, newHeight ) )
            scrollview:setPositionY( scrollview:getPositionY() + currentHeight -  newHeight )
            --scrollview:setInnerContainerSize( CCSize:new( 0, newHeight ) )

            local layout = tolua.cast( scrollview, "Layout" )
            layout:requestDoLayout()
        end
        mScrollPositionY = container:getPositionY()
    end

    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        
        EventManager:postEvent( Event.Load_More_Discussion_Posts, { mMatch["Id"], mStep, MatchCenterConfig.DISCUSSION_POST_TYPE_GAME } )
    end
end

function showMatchInfo( bShow )
    mScrollCallback( bShow )
end

function shareTypeSelectEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Share, { Constants.String.match_center.share_title,
                                                    Constants.String.match_center.share_body, mCompetitionToken,
                                                    shareByFacebook } )
    end
end

function shareByFacebook( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local doShare = function()
            local handler = function( accessToken, success )
                ConnectingMessage.selfRemove()
                if success then
                    -- already has permission
                    if accessToken == nil then
                        accessToken = Logic:getFBAccessToken()
                    end
                    EventManager:postEvent( Event.Do_Share_Discussion_Post, { mCompetitionId, accessToken } )
                end
            end
            ConnectingMessage.loadFrame()
            FacebookDelegate:sharedDelegate():grantPublishPermission( "publish_actions", handler )
        end

        if Logic:getFbId() == false then
            local successHandler = function()
                doShare()
            end
            local failedHandler = function()
                -- Nothing to do.
            end
            EventManager:postEvent( Event.Do_FB_Connect_With_User, { successHandler, failedHandler } )
        else
            doShare()
        end
    end
end