module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local ViewUtils = require("scripts.views.ViewUtils")
local Logic = require("scripts.Logic").getInstance()
local ConnectingMessage = require("scripts.views.ConnectingMessage")


local SHARE_BODY = "Can you beat me? Join my competition on FootballHero. Code: %s  www.footballheroapp.com/download"
local SHARE_TITLE = "Join %s's competition on FootballHero"

local mWidget
local mTokenInput
local mChatMessageContainer
local mCompetitionId
local mSubType
local mStep
local mCurrentTotalNum
local mCompetitionCodeString
local mHasMoreToLoad

-- DS for competitionDetail see CompetitionDetail
function loadFrame( subType, competitionId )
    mCompetitionId = competitionId
    mSubType = subType
    competitionDetail = Logic:getCompetitionDetail()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionLeaderboard.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( mWidget )

    -- Init the title
    local title = tolua.cast( mWidget:getChildByName("title"), "Label" )
    title:setText( competitionDetail:getName() )
    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )
    local moreBt = mWidget:getChildByName("more")
    moreBt:addTouchEventListener( moreEventHandler )

    initContent( competitionDetail )
    initLeaderboard( competitionDetail )

    mStep = 1
    mHasMoreToLoad = true
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
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

function moreEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Competition_More, { mCompetitionId } )
    end
end

function initContent( competitionDetail )

    -- Token
    mCompetitionCodeString = competitionDetail:getJoinToken()
    local inputDelegate = EditBoxDelegateForLua:create()
    inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_TEXT_CHANGED, function ( textBox, text )
        mTokenInput:setText( mCompetitionCodeString )
    end )
    --[[inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_DID_BEGIN, function ( textBox )
        -- In order not to change the object-c code, here is the work around.
        -- recall the setPosition() to invoke the CCEditBoxImplIOS::adjustTextFieldPosition()
        -- Todo remove this code after the object-c fix is pushed out.
        mTokenInput:setPosition( mTokenInput:getPosition() )
    end )--]]
    mWidget:getChildByName( "token" ):addNode( tolua.cast( inputDelegate, "CCNode" ) )

    mTokenInput = ViewUtils.createTextInput( mWidget:getChildByName( "token" ), "", 230, 40 )
    mTokenInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
    mTokenInput:setText( mCompetitionCodeString )
    mTokenInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )
    mTokenInput:setTouchEnabled( false )

    -- Add the latest chat message.
    mChatMessageContainer = mWidget:getChildByName("chatRoom")
    updateLatestChatMessage( competitionDetail:getLatestChatMessage() )

    local copyCodeBt = mWidget:getChildByName("copy")
    copyCodeBt:addTouchEventListener( copyCodeEventHandler )
    local shareBt = mWidget:getChildByName("share")
    shareBt:addTouchEventListener( shareTypeSelectEventHandler )
    local chatBt = mWidget:getChildByName("chatRoom")
    chatBt:addTouchEventListener( chatRoomEventHandler )
end

function initLeaderboard( competitionDetail )
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    -- Add the competition detail info
    --[[
    local content = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionLeaderboardInfo.json")
    local time = tolua.cast( content:getChildByName("time"), "Label" )
    local description = tolua.cast( content:getChildByName("description"), "Label" )
    if competitionDetail:getEndTime() == 0 then
        time:setText( string.format( "%s until forever", 
                os.date( "%m/%d/%Y", competitionDetail:getStartTime() ) ) )
    else
        time:setText( string.format( "%s to %s", 
                os.date( "%m/%d/%Y", competitionDetail:getStartTime() ), 
                os.date( "%m/%d/%Y", competitionDetail:getEndTime() ) ) )
    end
    
    description:setText( competitionDetail:getDescription() )
    --]]
    

    -- Add the leaderboard info
    local leaderboardInfo = competitionDetail:getDto()
    for i = 1, table.getn( leaderboardInfo ) do
    	local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                contentClick( leaderboardInfo[i] )
            end
        end

        local content = SceneManager.widgetFromJsonFile("scenes/LeaderboardListContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        initLeaderboardContent( i, content, leaderboardInfo[i] )
        content:addTouchEventListener( eventHandler )

        if i == table.getn( leaderboardInfo ) then
            content:getChildByName("separater"):setEnabled( false )
        end
    end
    mCurrentTotalNum = table.getn( leaderboardInfo )

    local challengeContent = SceneManager.widgetFromJsonFile("scenes/CompetitionInviteContent.json")
    challengeContent:setLayoutParameter( layoutParameter )
    contentContainer:addChild( challengeContent )
    contentHeight = contentHeight + challengeContent:getSize().height
    challengeContent:getChildByName("challenge"):addTouchEventListener( shareTypeSelectEventHandler )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
    contentContainer:addEventListenerScrollView( scrollViewEventHandler )
end

function updateLatestChatMessage( messageInfo )
    local MAX_MESSAGE_WIDTH = 390

    local name = tolua.cast( mChatMessageContainer:getChildByName("name"), "Label" )
    local message = tolua.cast( mChatMessageContainer:getChildByName("message"), "Label" )
    local time = tolua.cast( mChatMessageContainer:getChildByName("time"), "Label" )

    if messageInfo ~= nil then
        name:setEnabled( true )
        time:setEnabled( true )
        
        name:setText( messageInfo["UserName"] )
        message:setText( messageInfo["MessageText"] )
        if message:getSize().width > MAX_MESSAGE_WIDTH then
            local shortMessage = string.sub( messageInfo["MessageText"], 0, 39 ).."..."
            message:setText( shortMessage )
        end

        local now = os.time()
        local messageTime = messageInfo["UnixTimeStamp"]
        if os.date( "%x", now ) == os.date( "%x", messageTime ) then
            time:setText( os.date( "%H:%M", messageTime ) )
        else
            time:setText( os.date( "%d %B", messageTime ) )
        end
    else
        name:setEnabled( false )
        message:setText( "Tap here to start chatting!" )
        time:setEnabled( false )
    end
end

function showLeagueEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Competition_Leagues, { mCompetitionId } )
    end
end

function copyCodeEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        Misc:sharedDelegate():copyToPasteboard( mCompetitionCodeString )
        EventManager:postEvent( Event.Show_Info, { "Join code is copied to clipboard." } )
    end
end

function shareByFacebook( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local doShare = function()
            local handler = function( accessToken, success )
                if success then
                    EventManager:postEvent( Event.Do_Share_Competition, { mCompetitionId, accessToken } )
                end
                ConnectingMessage.selfRemove()
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

function shareTypeSelectEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Share, { string.format( SHARE_TITLE, Logic:getDisplayName() ),
                                                    string.format( SHARE_BODY, mCompetitionCodeString ),
                                                    shareByFacebook } )
    end
end

function chatRoomEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Competition_Chat )
        EventManager:postEvent( Event.Do_Get_Chat_Message, { mCompetitionId, 0 } )
    end
end

function initLeaderboardContent( i, content, info )
    local name = tolua.cast( content:getChildByName("name"), "Label" )
    local score = tolua.cast( content:getChildByName("score"), "Label" )
    local index = tolua.cast( content:getChildByName("index"), "Label" )
    local logo = tolua.cast( content:getChildByName("logo"), "ImageView" )

    if info["DisplayName"] == nil then
        name:setText( "Unknow name" )
    else
        name:setText( info["DisplayName"] )
    end
    score:setText( string.format( mSubType["description"], info[mSubType["dataColumnId"]] ) )
    index:setText( i )


    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        if info["PictureUrl"] ~= nil then
            local handler = function( filePath )
                if filePath ~= nil and mWidget ~= nil then
                    logo:loadTexture( filePath )
                end
            end
            SMIS.getSMImagePath( info["PictureUrl"], handler )
        end
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function loadMoreContent( leaderboardInfo )
    if table.getn( leaderboardInfo ) == 0 then
        mHasMoreToLoad = false
        return
    end
    
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = contentContainer:getInnerContainerSize().height

    for i = 1, table.getn( leaderboardInfo ) do
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                contentClick( leaderboardInfo[i] )
            end
        end

        local content = SceneManager.widgetFromJsonFile("scenes/LeaderboardListContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        initLeaderboardContent( mCurrentTotalNum + i, content, leaderboardInfo[i] )
        content:addTouchEventListener( eventHandler )
    end
    mCurrentTotalNum = mCurrentTotalNum + table.getn( leaderboardInfo )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function contentClick( info )
    local id = info["Id"]
    local name = "Unknow name"
    if info["DisplayName"] ~= nil then
        name = info["DisplayName"]
    end
    EventManager:postEvent( Event.Enter_History, { id, name, mCompetitionId } )
end

function scrollViewEventHandler( target, eventType )
    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        EventManager:postEvent( Event.Load_More_In_Competition_Detail, { mCompetitionId, mStep } )
    end
end