module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local TeamConfig = require("scripts.config.Team")

local mWidget
local mTextInput
local mPostId
local mStep
local mCurrentTotalNum
local mHasMoreToLoad

function loadFrame( discussionInfo, comments )
    mStep = 1
    mHasMoreToLoad = true
    mPostId = discussionInfo["Id"]    

	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterDiscussionsDetailScene.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )
    
    Navigator.loadFrame( mWidget )

    initTitle()

    initPost( discussionInfo )

    initContent( comments )

    local backBt = mWidget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )
end

function refreshFrame( discussionInfo, comments )
    mPostId = discussionInfo["Id"]    

    initTitle()

    initPost( discussionInfo )

    initContent( comments )
end

function isShown()
    return mWidget ~= nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mTextInput = nil
    end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function initTitle()
    local matchInfo = Logic:getSelectedMatch()

    local title = tolua.cast( mWidget:getChildByName( "Label_Title"), "Label" )

    local homeTeamId = TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] )
    local awayTeamId = TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] )

    local homeTeamName = TeamConfig.getTeamName( homeTeamId )
    local awayTeamName = TeamConfig.getTeamName( awayTeamId )

    title:setText( homeTeamName.." "..Constants.String.vs.." "..awayTeamName )
end

function initContent( comments )
    initCommentsList( comments )

    local eventHandler = function( sender,eventType )
        if eventType == TOUCH_EVENT_ENDED then
            local postPanel = mWidget:getChildByName("Panel_Post")
            postPanel:setEnabled( true )
        end
    end

    local button = tolua.cast( mWidget:getChildByName("Button_Comment"), "Button" )
    button:addTouchEventListener( eventHandler )
    local text = tolua.cast( button:getChildByName("Label_Comment"), "Label" )
    text:setText( Constants.String.match_center.write_discussion )

    initInput()
end

function initInput()
    local top = mWidget:getChildByName("Panel_Post")
    top:setEnabled( false )

    local container = top:getChildByName("Panel_Input")
    container:addTouchEventListener( inputEventHandler )

    local inputDelegate = EditBoxDelegateForLua:create()
    container:addNode( tolua.cast( inputDelegate, "CCNode" ) )

    mTextInput = CCEditBox:create( CCSizeMake( 552, 35 ), CCScale9Sprite:create() )
    container:addNode( mTextInput )
    mTextInput:setPosition( 552 / 2, 60 / 2 )
    mTextInput:setVisible( false )
    mTextInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )
    --mTextInput:setText( "" )

    local postEventHandler = function( sender,eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Do_Make_Discussion_Post, { mPostId, mTextInput:getText() } )
        end
    end
    local button = top:getChildByName("Button_Post")
    button:addTouchEventListener( postEventHandler )

end

function inputEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        mTextInput:touchDownAction( sender, eventType )
    end
end

function initPost( info )
    local content = mWidget:getChildByName("Panel_Discussion")

    local top  = content:getChildByName("Panel_Top")
    local bottom  = content:getChildByName("Panel_Bottom")
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local post = tolua.cast( top:getChildByName("Label_Post"), "Label" )
    local time = tolua.cast( top:getChildByName("Label_Time"), "Label" )
    
    local checkLike = tolua.cast( bottom:getChildByName("CheckBox_Like"), "CheckBox" )
    local lblLike = tolua.cast( bottom:getChildByName("Label_Like"), "Label" )
    local comments = tolua.cast( bottom:getChildByName("Label_Comments"), "Label" )
    local share = tolua.cast( bottom:getChildByName("Button_Share"), "Button" )
    
    local likeEventHandler = function( sender, eventType )
        local checkbox = tolua.cast( sender, "CheckBox" )
        if eventType == TOUCH_EVENT_ENDED then
            checkbox:setTouchEnabled( false )
            EventManager:postEvent( Event.Do_Like_Discussion_Post, { not checkbox:getSelectedState() } )
        end
    end
    checkLike:addTouchEventListener( likeEventHandler )

    share:addTouchEventListener( shareTypeSelectEventHandler )

    if type( info["DisplayName"]  ) ~= "string" or info["DisplayName"] == nil then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    post:setText( info["Text"] )
    lblLike:setText( info["LikeCount"] )
    checkLike:setSelectedState( info["Liked"] )
    comments:setText( info["CommentCount"] )
    
    -- TODO set date
    -- setDate( info["UnixTimeStamp"] )

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

end

function initCommentsList( comments )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Comments"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0
    
    for i = 1, table.getn( comments ) do
        local content = SceneManager.widgetFromJsonFile("scenes/MatchCenterDiscussionsCommentFrame.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        initCommentContent( i, content, comments[i] )
    end
    mCurrentTotalNum = table.getn( comments )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
    contentContainer:addEventListenerScrollView( scrollViewEventHandler )
end

function initCommentContent( i, content, info )

    local logo = tolua.cast( content:getChildByName("Image_Logo"), "ImageView" )
    local name = tolua.cast( content:getChildByName("Label_Name"), "Label" )
    local post = tolua.cast( content:getChildByName("Label_Comment"), "Label" )
    local time = tolua.cast( content:getChildByName("Label_Time"), "Label" )
    
    local checkLike = tolua.cast( content:getChildByName("CheckBox_Like"), "CheckBox" )
    local lblLike = tolua.cast( content:getChildByName("Label_Like"), "Label" )

    local likeEventHandler = function( sender, eventType )
        local checkbox = tolua.cast( sender, "CheckBox" )
        if eventType == TOUCH_EVENT_ENDED then
            checkbox:setTouchEnabled( false )
            EventManager:postEvent( Event.Do_Like_Discussion_Post, { info["Id"], not checkbox:getSelectedState() } )
        end
    end
    checkLike:addTouchEventListener( likeEventHandler )

    if type( info["DisplayName"]  ) ~= "string" or info["DisplayName"] == nil then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    post:setText( info["Text"] )
    lblLike:setText( info["LikeCount"] )
    checkLike:setSelectedState( info["Liked"] )
    
    -- TODO set date
    -- setDate( info["UnixTimeStamp"] )

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

function scrollViewEventHandler( target, eventType )
    --[[
    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        if mFilter == true then
            EventManager:postEvent( Event.Load_More_In_Leaderboard, { mLeaderboardId, mSubType, mStep, Constants.FILTER_MIN_PREDICTION } )
        else
            EventManager:postEvent( Event.Load_More_In_Leaderboard, { mLeaderboardId, mSubType, mStep } )
        end
    end
    ]]--
end
