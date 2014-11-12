module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local ViewUtils = require("scripts.views.ViewUtils")
local Logic = require("scripts.Logic").getInstance()
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local PushNotificationManager = require("scripts.PushNotificationManager")
local Constants = require("scripts.Constants")
local CompetitionType = require("scripts.data.Competitions").CompetitionType

local SHARE_BODY = Constants.String.share_body
local SHARE_TITLE = Constants.String.share_title

local mWidget
local mTokenInput
local mChatMessageContainer
local mCompetitionId
local mSubType
local mStep
local mCurrentTotalNum
local mCompetitionCodeString
local mHasMoreToLoad
local mSelfInfoOpen

-- DS for competitionDetail see CompetitionDetail
function loadFrame( subType, competitionId, showRequestPush )
    mCompetitionId = competitionId
    mSubType = subType
    competitionDetail = Logic:getCompetitionDetail()

    local widget
    if competitionDetail:getCompetitionType() == CompetitionType["Private"] then
        widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionLeaderboard.json")
    else
        widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpecialCompetitionLeaderboard.json")
    end
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
    local pushEnabledCheck = tolua.cast( mWidget:getChildByName("pushEnabled"), "CheckBox" )
    pushEnabledCheck:addTouchEventListener( pushEnabledHandler )
    if competitionDetail:getPNSetting() then
        pushEnabledCheck:setSelectedState( true )
    end

    initContent( competitionDetail )
    initLeaderboard( competitionDetail )

    mStep = 1
    mHasMoreToLoad = true
    mSelfInfoOpen = false

    if showRequestPush then
        local pushEnabledCheck = tolua.cast( mWidget:getChildByName("pushEnabled"), "CheckBox" )
        local yesCallback = function()
            pushEnabledCheck:setSelectedState( true )
            postSettings( true )
        end

        local noCallback = function()
           pushEnabledCheck:setSelectedState( false ) 
           postSettings( false )
        end

        PushNotificationManager.checkShowCompetitionSwitch( yesCallback, noCallback )
    end
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

function pushEnabledHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        -- Todo send to server
        local pushEnabledCheck = tolua.cast( sender, "CheckBox" )
        postSettings( not pushEnabledCheck:getSelectedState() )
    end
end

function postSettings( setting )
    EventManager:postEvent( Event.Do_Post_PN_Comp_Settings, { mCompetitionId, setting } )
end

function moreEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Competition_More, { mCompetitionId } )
    end
end

function initContent( competitionDetail )

    if competitionDetail:getCompetitionType() == CompetitionType["Private"] then
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

        local copyCodeBt = mWidget:getChildByName("copy")
        copyCodeBt:addTouchEventListener( copyCodeEventHandler )
        local shareBt = mWidget:getChildByName("share")
        shareBt:addTouchEventListener( shareTypeSelectEventHandler )
    else
        local banner = mWidget:getChildByName("Panel_Banner")
        local shareBt = banner:getChildByName("Button_Share")
        shareBt:addTouchEventListener( shareTypeSelectEventHandler )

        local selfInfo = competitionDetail:getSelfInfo()
        initSelfContent( selfInfo )
    end

    -- Add the latest chat message.
    mChatMessageContainer = mWidget:getChildByName("chatRoom")
    updateLatestChatMessage( competitionDetail:getLatestChatMessage() )

    local chatBt = mWidget:getChildByName("chatRoom")
    chatBt:addTouchEventListener( chatRoomEventHandler )
end

function initLeaderboard( competitionDetail )
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Leaderboard"), "ScrollView" )
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
        local content = SceneManager.widgetFromJsonFile("scenes/CommunityLeaderboardListContentFrame.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        initLeaderboardContent( i, content, leaderboardInfo[i] )
    end
    mCurrentTotalNum = table.getn( leaderboardInfo )

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
        message:setText( Constants.String.chat_hint )
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
        EventManager:postEvent( Event.Show_Info, { Constants.String.info.join_code_copied } )
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

-- function initLeaderboardContent( i, content, info )
--     local name = tolua.cast( content:getChildByName("name"), "Label" )
--     local score = tolua.cast( content:getChildByName("score"), "Label" )
--     local index = tolua.cast( content:getChildByName("index"), "Label" )
--     local logo = tolua.cast( content:getChildByName("logo"), "ImageView" )

--     if info["DisplayName"] == nil then
--         name:setText( Constants.String.unknown_name )
--     else
--         name:setText( info["DisplayName"] )
--     end
--     score:setText( string.format( mSubType["description"], info[mSubType["dataColumnId"]], info["NumberOfCoupons"] ) )
--     if info[mSubType["dataColumnId"]] < 0 then
--         score:setColor( ccc3( 240, 75, 79 ) )
--     end
--     index:setText( i )


--     local seqArray = CCArray:create()
--     seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
--     seqArray:addObject( CCCallFuncN:create( function()
--         if info["PictureUrl"] ~= nil then
--             local handler = function( filePath )
--                 if filePath ~= nil and mWidget ~= nil then
--                     logo:loadTexture( filePath )
--                 end
--             end
--             SMIS.getSMImagePath( info["PictureUrl"], handler )
--         end
--     end ) )

--     mWidget:runAction( CCSequence:create( seqArray ) )
-- end

function initSelfContent( info )
    local top  = mWidget:getChildByName("Panel_Top")
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local score = tolua.cast( top:getChildByName("Label_Score"), "Label" )
    local index = tolua.cast( top:getChildByName("Label_Index"), "Label" )
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )
    local click = top:getChildByName("Panel_Click")
    local check = tolua.cast( top:getChildByName("Image_Check"), "ImageView" )
    local qualified = top:getChildByName("Panel_Info")
    
    local infoCheck = tolua.cast( qualified:getChildByName("Image_Check"), "ImageView" )
    local infoHint = tolua.cast( qualified:getChildByName("Label_Hint"), "Label" )
    local infoQualified = tolua.cast( qualified:getChildByName("Label_Qualified"), "Label" )

    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            contentClick( info )
        end
    end
    click:addTouchEventListener( eventHandler )    

    local infoHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if mSelfInfoOpen then
                qualified:setPositionX( 560 )
                click:setSize( CCSize:new( 560, click:getSize().height ) )
                mSelfInfoOpen = false
            else
                qualified:setPositionX( 355 )
                click:setSize( CCSize:new( 355, click:getSize().height ) )
                mSelfInfoOpen = true
            end
        end
    end
    qualified:addTouchEventListener( infoHandler )
    if info["DisplayName"] == nil then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    score:setText( string.format( score:getStringValue(), info["Profit"] ) )
    if info["Profit"] < 0 then
        score:setColor( ccc3( 240, 75, 79 ) )
    end

    index:setText( info["Position"] )

    if info["NumberOfUserGamesLeftToQualify"] <= 0 then
        check:loadTexture( Constants.COMPETITION_SCENE_IMAGE_PATH.."icn-qualified.png" )
        infoCheck:loadTexture( Constants.COMPETITION_SCENE_IMAGE_PATH.."icn-qualified.png" )
        infoQualified:setText( Constants.String.event.status_qualified )
        infoHint:setText( Constants.String.event.hint_qualified )
    else
        infoQualified:setText( Constants.String.event.status_unqualified )
        infoHint:setText( string.format( Constants.String.event.hint_unqualified, info["NumberOfUserGamesLeftToQualify"] ) )
    end
    
    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( 0.2 ) )
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

function initLeaderboardContent( i, content, info )
    local top  = content:getChildByName("Panel_Top")
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local score = tolua.cast( top:getChildByName("Label_Score"), "Label" )
    local index = tolua.cast( top:getChildByName("Label_Index"), "Label" )
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )
    local click = top:getChildByName("Panel_Click")
    local drop = top:getChildByName("Panel_Dropdown")
    local btn = tolua.cast( drop:getChildByName("Button_Dropdown"), "Button" )
    local stats = top:getChildByName("Panel_Stats")
    stats:setEnabled( false )

    local check = tolua.cast( top:getChildByName("Image_Check"), "ImageView" )
    if competitionDetail:getCompetitionType() == CompetitionType["Private"] then
        check:setEnabled( false )
    else
        if info["NumberOfUserGamesLeftToQualify"] <= 0 then
            check:loadTexture( Constants.COMPETITION_SCENE_IMAGE_PATH.."icn-qualified.png" )
        end
    end

    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            contentClick( info )
        end
    end
    click:addTouchEventListener( eventHandler )

    local dropHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            
            local deltaY = stats:getSize().height
            local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Leaderboard"), "ScrollView" )
            local contentHeight = contentContainer:getInnerContainerSize().height

            if stats:isEnabled() then
                stats:setEnabled( false )
                btn:setBrightStyle( BRIGHT_NORMAL )

                content:setSize( CCSize:new( content:getSize().width, content:getSize().height - deltaY ) )
                top:setPositionY( top:getPositionY() - deltaY )

                contentHeight = contentHeight - deltaY
            else
                stats:setEnabled( true )
                btn:setBrightStyle( BRIGHT_HIGHLIGHT )
                
                content:setSize( CCSize:new( content:getSize().width, content:getSize().height + deltaY ) )
                top:setPositionY( top:getPositionY() + deltaY )

                contentHeight = contentHeight + deltaY
            end

            contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
            local layout = tolua.cast( contentContainer, "Layout" )
            layout:requestDoLayout()
            contentContainer:addEventListenerScrollView( scrollViewEventHandler )
        end
    end
    drop:addTouchEventListener( dropHandler )
    btn:addTouchEventListener( dropHandler )

    if info["DisplayName"] == nil then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    score:setText( string.format( mSubType["description"], info[mSubType["dataColumnId"]], info["NumberOfCoupons"] ) )
    if info[mSubType["dataColumnId"]] < 0 then
        score:setColor( ccc3( 240, 75, 79 ) )
    end

    string.format( mSubType["description"], info[mSubType["dataColumnId"]], info["NumberOfCoupons"] )
    index:setText( i )

    -- stat box
    local stat_win = tolua.cast( stats:getChildByName("Label_Win"), "Label" )
    local stat_lose = tolua.cast( stats:getChildByName("Label_Lose"), "Label" )
    local stat_win_percent = tolua.cast( stats:getChildByName("Label_Win_Percent"), "Label" )
    local stat_gain_percent = tolua.cast( stats:getChildByName("Label_Gain_Percent"), "Label" )
    local stat_last_10_win = tolua.cast( stats:getChildByName("Label_W"), "Label" )
    local stat_last_10_lose = tolua.cast( stats:getChildByName("Label_L"), "Label" )

    stat_win:setText( info["NumberOfCouponsWon"] )
    stat_lose:setText( info["NumberOfCouponsLost"] )
    stat_win_percent:setText( string.format( "%d", info["WinPercentage"] ) )
    stat_gain_percent:setText( info["Roi"] )
    stat_last_10_win:setText( info["WinStreakCouponsWon"] )
    stat_last_10_lose:setText( info["WinStreakCouponsLost"] )

    if info["Roi"] < 0 then
        stat_gain_percent:setColor( ccc3( 240, 75, 79 ) )
    end

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

function loadMoreContent( leaderboardInfo )
    if table.getn( leaderboardInfo ) == 0 then
        mHasMoreToLoad = false
        return
    end
    
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Leaderboard"), "ScrollView" )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = contentContainer:getInnerContainerSize().height

    for i = 1, table.getn( leaderboardInfo ) do
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                contentClick( leaderboardInfo[i] )
            end
        end

        local content = SceneManager.widgetFromJsonFile("scenes/CommunityLeaderboardListContentFrame.json")
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
    local name = Constants.String.unknown_name
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