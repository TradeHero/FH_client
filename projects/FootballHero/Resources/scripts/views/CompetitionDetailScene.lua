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
local CompetitionsData = require("scripts.data.Competitions")
local CompetitionsConfig = require("scripts.config.Competitions")
local RequestUtils = require("scripts.RequestUtils")


local INFO_MOVE_OFFSET = 287

local SHARE_BODY = Constants.String.share_body
local SHARE_TITLE = Constants.String.share_title

local INFO_MOVE_TIME = 0.2

local mWidget
local mTokenInput
local mChatMessageContainer
local mCompetitionId
local mSubType
local mStep
local mCurrentTotalNum
local mHasMoreToLoad
local mSelfInfoOpen
local mCompetitionType
local mCompetitionToken
local mTabID
local mCompetitionDurations
local mDropdown
local mSelfPanelOriginY
local mScrollViewOriginHeight

local mYearNumber
local mMonthNumber
local mWeekNumber

local mLinkedLeagueId


-- DS for competitionDetail see CompetitionDetail
function loadFrame( subType, competitionId, showRequestPush, tabID, yearNumber, monthNumber, weekNumber )
    mCompetitionId = competitionId
    mSubType = subType
    mTabID = tabID
    competitionDetail = Logic:getCompetitionDetail()
    mCompetitionType = competitionDetail:getCompetitionType()
    mCompetitionToken = competitionDetail:getJoinToken()

    mYearNumber = yearNumber
    mMonthNumber = monthNumber
    mWeekNumber = weekNumber

    mLinkedLeagueId = competitionDetail:getLinkedLeagueId()

    local widget
    if mCompetitionType == CompetitionType["Private"] then
        widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionLeaderboard.json")
    elseif mCompetitionType == CompetitionType["DetailedRanking"] then
        -- Overall / Monthly / Weekly
        widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpecialDetailedCompetitionLeaderboard.json")
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

    -- label texts
    if mCompetitionType == CompetitionType["Private"] then
        local lbTop = tolua.cast( mWidget:getChildByName("Label_TopPerformers"), "Label" )
        local lbInvite = tolua.cast( mWidget:getChildByName("Label_InvitationCode"), "Label" )
        local lbCopy = tolua.cast( mWidget:getChildByName("Label_Copy"), "Label" )
        local lbShare = tolua.cast( mWidget:getChildByName("Label_Share"), "Label" )

        lbTop:setText( Constants.String.community.title_top_performers )
        lbInvite:setText( Constants.String.community.invite_code )
        lbCopy:setText( Constants.String.community.copy )
        lbShare:setText( Constants.String.community.share )

        setupRankingHeader( true, competitionDetail:getStartTime() )
    elseif mCompetitionType == CompetitionType["DetailedRanking"] then
        -- FHC Check
        local stage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_FHC_STATUS_KEY )
        if stage ~= Constants.EVENT_FHC_STATUS_JOINED then
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_FHC_STATUS_KEY, Constants.EVENT_FHC_STATUS_JOINED )
        end
        setupRankingHeader( true, competitionDetail:getStartTime() )
    end

    initContent( competitionDetail )
    initLeaderboard( competitionDetail )

    if mCompetitionType ~= CompetitionType["Private"] and isNewToCompetition() then
        initWelcome( competitionDetail )
    end

    mStep = 1
    mHasMoreToLoad = true
    mSelfInfoOpen = false

    local leaderboardInfo = competitionDetail:getDto()
    local numOfUsers = table.getn( leaderboardInfo )
    if numOfUsers < Constants.RANKINGS_PER_PAGE then
        mHasMoreToLoad = false
    end

    if showRequestPush then
        local yesCallback = function()
            postSettings( true )
        end

        local noCallback = function()
           postSettings( false )
        end

        PushNotificationManager.checkShowCompetitionSwitch( yesCallback, noCallback )
    end
end

-- refreshing of frame means that the competition id, type is not going to change, ie. within the same competition
-- and that it is a detailed competition
function refreshFrame( tabID, yearNumber, monthNumber, weekNumber )
    mTabID = tabID
    mYearNumber = tonumber( yearNumber )
    mMonthNumber = tonumber( monthNumber )
    mWeekNumber = tonumber( weekNumber )
    competitionDetail = Logic:getCompetitionDetail()
    
    if mCompetitionType == CompetitionType["DetailedRanking"] or mCompetitionType == CompetitionType["Private"] then
        setupRankingHeader( false, competitionDetail:getStartTime() )
    end

    initContent( competitionDetail )
    initLeaderboard( competitionDetail )

    mStep = 1
    mHasMoreToLoad = true

    if mSelfInfoOpen then
        local top  = mWidget:getChildByName("Panel_Top")
        local qualified = top:getChildByName("Panel_Info")
        qualified:setPositionX( qualified:getPositionX() + INFO_MOVE_OFFSET )
        mSelfInfoOpen = false
    end
end

function isShown()
    return mWidget ~= nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget:stopAllActions()
        mWidget = nil
        mDropdown = nil
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

function isNewToCompetition()
    if CCUserDefault:sharedUserDefault():getBoolForKey( Constants.EVENT_WELCOME_KEY..mCompetitionId ) ~= true then
        CCUserDefault:sharedUserDefault():setBoolForKey( Constants.EVENT_WELCOME_KEY..mCompetitionId, true )
        return true
    end
    
    return false
end

function setupRankingHeader( bInit, startTimeStamp )
    
    -- init header tab (Overall, Monthly, Weekly)
    for i = 1, table.getn( CompetitionsData.CompetitionTabs ) do
        initRankingTab( CompetitionsData.CompetitionTabs[i], i, bInit )
    end

    -- save header position
    if bInit then
        local selfPanel = mWidget:getChildByName( "Panel_Top" )
        mSelfPanelOriginY = selfPanel:getPositionY()

        local scrollView = mWidget:getChildByName( "ScrollView_Leaderboard" )
        mScrollViewOriginHeight = scrollView:getSize().height
    end

    -- init dropdown box
    if mTabID ~= CompetitionsData.COMPETITION_TAB_ID_OVERALL then
        initRankingDropdown( startTimeStamp )
    else
        removeRankingDropdown()
    end
end


function initRankingTab( tabInfo, tabId, bInit )
    local tab = tolua.cast( mWidget:getChildByName( tabInfo["id"] ), "Button" )
    tab:setTitleText( tabInfo["displayName"] )

    local isActive = mTabID == tabId

    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then

            onSelectTab( tabId )
        end
    end
    if bInit then
            tab:addTouchEventListener( eventHandler )
        end
    
    if isActive then
        tab:setBright( false )
        tab:setTouchEnabled( false )
        tab:setTitleColor( ccc3( 255, 255, 255 ) )
    else
        
        tab:setBright( true )
        tab:setTouchEnabled( true )
        tab:setTitleColor( ccc3( 127, 127, 127 ) )
    end
end

function removeRankingDropdown()
    local dropdown
    if mDropdown ~= nil then
        mDropdown:setEnabled( false )
        dropdown = mDropdown
    else
        dropdown = GUIReader:shareReader():widgetFromJsonFile("scenes/SpecialDetailedCompetitionDropdownFrame.json")
    end

    local dropButton = dropdown:getChildByName( "Panel_Button" )
    local height = dropButton:getSize().height

    local selfPanel = mWidget:getChildByName( "Panel_Top" )
    local separator = mWidget:getChildByName( "Panel_Separator" )
    local scrollView = mWidget:getChildByName( "ScrollView_Leaderboard" )
    
    selfPanel:setPositionY( mSelfPanelOriginY + height )
    separator:setPositionY( mSelfPanelOriginY + height )
    scrollView:setSize( CCSize:new( scrollView:getSize().width, mScrollViewOriginHeight + height ) )
end

function initRankingDropdown( startTimeStamp )

    initCompetitionDuration( startTimeStamp )

    -- add dropdown to scene if not already added
    if mDropdown == nil then
        if mCompetitionType == CompetitionType["Private"] then
            mDropdown = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionDropdownFrame.json")
        else
            mDropdown = GUIReader:shareReader():widgetFromJsonFile("scenes/SpecialDetailedCompetitionDropdownFrame.json")
        end
        mWidget:addChild( mDropdown )
    end

    mDropdown:setEnabled( true )

    local mask = mDropdown:getChildByName( "Panel_Mask" )
    local contentContainer = tolua.cast( mDropdown:getChildByName( "ScrollView_Date" ), "ScrollView" )

    local button = mDropdown:getChildByName( "Panel_Button" )
    local button_dropdown =  mDropdown:getChildByName( "Button_Dropdown" )

    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if mask:isEnabled() then
                mask:setEnabled( false )
                contentContainer:setEnabled( false )
                button_dropdown:setBrightStyle( BRIGHT_NORMAL )
            else
                mask:setEnabled( true )
                contentContainer:setEnabled( true )
                button_dropdown:setBrightStyle( BRIGHT_HIGHLIGHT )
            end
        end
    end
    button:addTouchEventListener( eventHandler )
    button_dropdown:addTouchEventListener( eventHandler )

    local dropButton = mDropdown:getChildByName( "Panel_Button" )
    local height = dropButton:getSize().height

    local selfPanel = mWidget:getChildByName( "Panel_Top" )
    local separator = mWidget:getChildByName( "Panel_Separator" )
    local scrollView = mWidget:getChildByName( "ScrollView_Leaderboard" )

    selfPanel:setPositionY( mSelfPanelOriginY )
    separator:setPositionY( mSelfPanelOriginY )
    scrollView:setSize( CCSize:new( scrollView:getSize().width, mScrollViewOriginHeight ) )

    local dateLabel = tolua.cast( mDropdown:getChildByName( "Label_DateFilter" ), "Label" )
    
    mask:setEnabled( false )
    contentContainer:removeAllChildrenWithCleanup( true )
    contentContainer:setEnabled( false )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    
    local contentHeight = 0
    
    local nowTimeStamp = os.time()

    if nowTimeStamp < startTimeStamp then
        local startDateString = os.date( "%b %d %Y", startTimeStamp )

        dateLabel:setText( string.format( Constants.String.info.competition_not_started, startDateString ) )
    else
        for i = 1, table.getn( mCompetitionDurations ) do

            local content = GUIReader:shareReader():widgetFromJsonFile("scenes/SpecialDetailedCompetitionDropdownContent.json")
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height

            local displayText = mCompetitionDurations[i]["displayDate"]
            local dateText = tolua.cast( content:getChildByName( "Label_Name" ), "Label" )
            dateText:setText( displayText )
            
            if mCompetitionDurations[i]["monthNumber"] ~= nil then
                if mCompetitionDurations[i]["monthNumber"] == tonumber( mMonthNumber ) then
                    dateLabel:setText( displayText )
                    break
                end
            else
                if mCompetitionDurations[i]["weekNumber"] == tonumber( mWeekNumber ) then
                    dateLabel:setText( displayText )
                    break
                end
            end

            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    local sortType = 3
                    if mTabID == CompetitionsData.COMPETITION_TAB_ID_MONTHLY then
                        EventManager:postEvent( Event.Enter_Competition_Detail, { mCompetitionId, false, sortType, mTabID, mCompetitionDurations[i]["yearNumber"], mCompetitionDurations[i]["monthNumber"] } )
                    else
                        EventManager:postEvent( Event.Enter_Competition_Detail, { mCompetitionId, false, sortType, mTabID, mCompetitionDurations[i]["yearNumber"], mCompetitionDurations[i]["weekNumber"] } )
                    end
                end
            end
            content:addTouchEventListener( eventHandler )

        end
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initCompetitionDuration( startTimeStamp )
    
    -- DEBUG - go back 1 year
    --startTimeStamp = startTimeStamp - 365 * 24 * 3600

    mCompetitionDurations = {}
    local nowTimeStamp = os.time()
    local startYear = tonumber( os.date( "%Y", startTimeStamp ) )
    local currYear = tonumber( os.date( "%Y", nowTimeStamp ) )
    
    if mTabID == CompetitionsData.COMPETITION_TAB_ID_MONTHLY then
        local startMth = os.date( "%m", startTimeStamp )
        local endMth = os.date( "%m", nowTimeStamp )
        
        local months = Constants.String.month

        if currYear > startYear then
            local tempEndMth

            while currYear >= startYear do
                if currYear == startYear then
                    tempEndMth = endMth
                else
                    tempEndMth = 12
                end
                for i = startMth, tempEndMth do
                    local displayDate = months[i].." "..startYear
                    table.insert( mCompetitionDurations, { ["displayDate"] = displayDate, ["monthNumber"] = i, ["yearNumber"] = startYear } )
                end

                startYear = startYear + 1
                startMth = 1
            end
        else
            for i = startMth, endMth do

                local displayDate = months[i].." "..startYear
                table.insert( mCompetitionDurations, { ["displayDate"] = displayDate, ["monthNumber"] = i, ["yearNumber"] = startYear } )
            end
        end
    else
        -- Since 2014/01/01 is week 1 on server, but week 0 on client, so client need to add one.
        local startWeek = os.date( "%W", startTimeStamp ) + 1
        local endWeek = os.date( "%W", nowTimeStamp ) + 1

        local currWeek = startTimeStamp - ( tonumber( os.date( "%w", startTimeStamp ) ) - 1 ) * 3600 * 24 
                                            - tonumber( os.date( "%H", startTimeStamp ) ) * 3600
                                            - tonumber( os.date( "%M", startTimeStamp ) ) * 60
                                            - tonumber( os.date( "%S", startTimeStamp ) )

        if currYear > startYear then
            local tempEndWeek
            local displyWeekIndex = 1
            while currYear >= startYear do
                if currYear == startYear then
                    tempEndWeek = endWeek
                else
                    tempEndWeek = 53
                end
                for i = startWeek, tempEndWeek do

                    if i == 53 then
                        local currMth = os.date( "%m", currWeek )
                        if currMth == "01" then
                            break
                        end
                    end

                    local startDay = os.date( "%d", currWeek )
                    local startMth = os.date( "%b", currWeek )

                    currWeek = currWeek + 7 * 24 * 3600

                    local endDay = os.date( "%d", currWeek )
                    local endMth = os.date( "%b", currWeek )

                    local displayDate = string.format( Constants.String.event.ranking_dropdown_week, displyWeekIndex, startDay, startMth, endDay, endMth )
                    displyWeekIndex = displyWeekIndex + 1
                    --print( "DISPLAY DATE = "..displayDate )
                    table.insert( mCompetitionDurations, { ["displayDate"] = displayDate , ["weekNumber"] = i, ["yearNumber"] = startYear } )
                end

                startYear = startYear + 1
                startWeek = 1
            end
        else
            local displyWeekIndex = 1
            for i = startWeek, endWeek do
                local startDay = os.date( "%d", currWeek )
                local startMth = os.date( "%b", currWeek )

                currWeek = currWeek + 7 * 24 * 3600

                local endDay = os.date( "%d", currWeek )
                local endMth = os.date( "%b", currWeek )

                local displayDate = string.format( Constants.String.event.ranking_dropdown_week, displyWeekIndex, startDay, startMth, endDay, endMth )
                displyWeekIndex = displyWeekIndex + 1
                --print( "DISPLAY DATE = "..displayDate )
                table.insert( mCompetitionDurations, { ["displayDate"] = displayDate , ["weekNumber"] = i, ["yearNumber"] = startYear } )
            end
        end
    end

    -- print( "Start date = ", os.date( "%c", competitionDetail:getStartTime()) )
    -- print( "Start year = ", os.date( "%Y", competitionDetail:getStartTime()) )
    -- print( "Start month = ", os.date( "%m", competitionDetail:getStartTime()) )
    -- print( "Start week = ", os.date( "%W", competitionDetail:getStartTime()) )
    -- print( "Start day = ", os.date( "%d", competitionDetail:getStartTime()) )
    -- print( "Start wday = ", os.date( "%w", competitionDetail:getStartTime()) )
    -- print( "Start hr = ", os.date( "%H", competitionDetail:getStartTime()) )
    -- print( "Start min = ", os.date( "%M", competitionDetail:getStartTime()) )
    -- print( "Start sec = ", os.date( "%S", competitionDetail:getStartTime()) )

end

function onSelectTab( tabID )
    local sortType = 3
    if tabID == CompetitionsData.COMPETITION_TAB_ID_MONTHLY then
        EventManager:postEvent( Event.Enter_Competition_Detail, { mCompetitionId, false, sortType, tabID, mYearNumber, mMonthNumber } )
    elseif tabID == CompetitionsData.COMPETITION_TAB_ID_WEEKLY then
        EventManager:postEvent( Event.Enter_Competition_Detail, { mCompetitionId, false, sortType, tabID, mYearNumber, mWeekNumber } )
    else
        EventManager:postEvent( Event.Enter_Competition_Detail, { mCompetitionId, false, sortType, tabID } )
    end
end

function initWelcome( competitionDetail )
    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        local popup = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityCompetitionWelcome.json")
        popup:setZOrder( Constants.ZORDER_POPUP )
        mWidget:addChild(popup)

        local joinToken = competitionDetail:getJoinToken()
        local bgImage = tolua.cast( popup:getChildByName( "Image_BG"), "ImageView" )
        bgImage:loadTexture( Constants.COMPETITION_IMAGE_PATH..Constants.WelcomePrefix..joinToken..".png" )

        local competitionConfigID = CompetitionsConfig.getConfigIdByKey( joinToken )
        local title1 = tolua.cast( popup:getChildByName( "Label_Title1" ), "Label" )
        title1:setText( CompetitionsConfig.getTitle1( competitionConfigID ) )

        local title2 = tolua.cast( popup:getChildByName( "Label_Title2" ), "Label" )
        title2:setText( CompetitionsConfig.getTitle2( competitionConfigID ) )

        local body = tolua.cast( popup:getChildByName( "Label_Desc" ), "Label" )
        body:setText( CompetitionsConfig.getBody( competitionConfigID ) )

        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                mWidget:removeChild(popup)
            end
        end

        local close = popup:getChildByName( "Button_Close" )
        close:addTouchEventListener( eventHandler )

        local start = tolua.cast( popup:getChildByName( "Button_Play" ), "Button" )
        local share = tolua.cast( popup:getChildByName( "Button_Share" ), "Button" )

        start:setTitleText( Constants.String.button.play_now )
        share:setTitleText( Constants.String.button.share )

        local isShare = CompetitionsConfig.getIsShare( competitionConfigID )
        if isShare then
            start:setEnabled( false )

            local shareNClose = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    mWidget:removeChild(popup)
                    shareByFacebook( sender, eventType )
                end
            end
            share:addTouchEventListener( shareNClose )
        else
            
            start:addTouchEventListener( eventHandler )
            share:setEnabled( false )
        end
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function initContent( competitionDetail )

    if mCompetitionType == CompetitionType["Private"] then
        -- Token
        local inputDelegate = EditBoxDelegateForLua:create()
        inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_TEXT_CHANGED, function ( textBox, text )
            mTokenInput:setText( mCompetitionToken )
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
        mTokenInput:setText( mCompetitionToken )
        mTokenInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )
        mTokenInput:setTouchEnabled( false )

        local copyCodeBt = mWidget:getChildByName("copy")
        copyCodeBt:addTouchEventListener( copyCodeEventHandler )
        local shareBt = mWidget:getChildByName("share")
        shareBt:addTouchEventListener( shareTypeSelectEventHandler )
    else
        local banner = mWidget:getChildByName("Panel_Banner")
        local predictBt = tolua.cast( banner:getChildByName("Button_Predict"), "Button" )
        local shareBt = tolua.cast( banner:getChildByName("Button_Share"), "Button" )
        local prizeBt = tolua.cast( banner:getChildByName("Button_Learn"), "Button" )
        local playerNum = tolua.cast( banner:getChildByName("Label_PlayerNum"), "Label" )
        local lbPlayerNum = tolua.cast( banner:getChildByName("Label_HeaderPlayerNum"), "Label" )

        predictBt:addTouchEventListener( predictNowEventHandler )
        shareBt:addTouchEventListener( shareTypeSelectEventHandler )
        prizeBt:addTouchEventListener( competitionPrizeEventHandler )
        
        playerNum:setText( competitionDetail:getPlayerNum() )
        lbPlayerNum:setText( Constants.String.event.total_players )
        shareBt:setTitleText( Constants.String.button.share )
        predictBt:setTitleText( Constants.String.event.predict_now )
        prizeBt:setTitleText( Constants.String.event.prizes )

        local bannerBG = tolua.cast( banner:getChildByName("Image_BannerBG"), "ImageView" )
        bannerBG:loadTexture( Constants.COMPETITION_IMAGE_PATH..Constants.PrizesPrefix..competitionDetail:getJoinToken()..".png" )
    end

    local selfInfo = competitionDetail:getSelfInfo()
    initSelfContent( selfInfo )

    -- Add the latest chat message.
    --mChatMessageContainer = mWidget:getChildByName("chatRoom")
    --updateLatestChatMessage( competitionDetail:getLatestChatMessage() )

    --local chatBt = mWidget:getChildByName("chatRoom")
    local chatBt = tolua.cast( mWidget:getChildByName("Button_Chat"), "Button" )
    chatBt:addTouchEventListener( chatRoomEventHandler )

    if competitionDetail:getNewChatMessages() then
        chatBt:loadTextureNormal( Constants.COMMUNITY_IMAGE_PATH.."icn-new-message.png" )
    end
end

function initLeaderboard( competitionDetail )
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Leaderboard"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

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

function copyCodeEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        Misc:sharedDelegate():copyToPasteboard( mCompetitionToken )
        EventManager:postEvent( Event.Show_Info, { Constants.String.info.join_code_copied } )
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
                    EventManager:postEvent( Event.Do_Share_Competition, { mCompetitionId, accessToken } )
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

function predictNowEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local competitionDetail = Logic:getCompetitionDetail()
        local startTimeStamp = competitionDetail:getStartTime()
        local nowTimeStamp = os.time()

        if nowTimeStamp < startTimeStamp then
            local startDateString = os.date( "%b %d %Y", startTimeStamp )

            EventManager:postEvent( Event.Show_Info, { string.format( Constants.String.info.competition_not_started, startDateString ) } )
        else
            EventManager:postEvent( Event.Enter_Match_List, { mLinkedLeagueId } )
        end
    end
end 

function shareTypeSelectEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Share, { string.format( SHARE_TITLE, Logic:getDisplayName() ),
                                                    string.format( SHARE_BODY, mCompetitionToken ),
                                                    shareByFacebook } )
    end
end

function competitionPrizeEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local title = tolua.cast( mWidget:getChildByName("title"), "Label" )
        local titleText = title:getStringValue()
        EventManager:postEvent( Event.Enter_Competition_Prize, { titleText, mCompetitionToken, Constants.COMPETITION_PRIZE_OVERALL, 0 } )
    end
end

function chatRoomEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Competition_Chat )
        EventManager:postEvent( Event.Do_Get_Chat_Message, { mCompetitionId, 0 } )
    end
end

function initSelfContent( info )
    local top  = mWidget:getChildByName("Panel_Top")
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local score = tolua.cast( top:getChildByName("Label_Score"), "Label" )
    local index = tolua.cast( top:getChildByName("Label_Index"), "Label" )
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )
    local click = top:getChildByName("Panel_Click")
    local check = tolua.cast( top:getChildByName("Image_Check"), "ImageView" )
    local qualified = top:getChildByName("Panel_Info")
    
    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            contentClick( info )
        end
    end
    click:addTouchEventListener( eventHandler )

    score:setText( string.format( Constants.String.leaderboard.me_score, info["Profit"] ) )
    if info["Profit"] < 0 then
        score:setColor( ccc3( 240, 75, 79 ) )
    end

    index:setText( info["Position"] )

    if info["DisplayName"] == nil then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    if qualified ~= nil then
        local infoCheck = tolua.cast( qualified:getChildByName("Image_Check"), "ImageView" )
        local infoHint = tolua.cast( qualified:getChildByName("Label_Hint"), "Label" )
        local infoQualified = tolua.cast( qualified:getChildByName("Label_Qualified"), "Label" )
    
        local infoHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                local deltaX
                if mSelfInfoOpen then
                    click:setSize( CCSize:new( 560, click:getSize().height ) )
                    mSelfInfoOpen = false
                    deltaX = INFO_MOVE_OFFSET
                else
                    click:setSize( CCSize:new( 283, click:getSize().height ) )
                    mSelfInfoOpen = true
                    deltaX = INFO_MOVE_OFFSET * (-1)
                end

                local resultSeqArray = CCArray:create()
                resultSeqArray:addObject( CCMoveBy:create( INFO_MOVE_TIME, ccp( deltaX, 0 ) ) )
                qualified:runAction( CCSequence:create( resultSeqArray ) )

            end
        end
        qualified:addTouchEventListener( infoHandler )
        

        if info["NumberOfUserGamesLeftToQualify"] <= 0 then
            check:loadTexture( Constants.COMPETITION_SCENE_IMAGE_PATH.."icn-qualified.png" )
            infoCheck:loadTexture( Constants.COMPETITION_SCENE_IMAGE_PATH.."icn-qualified.png" )
            infoQualified:setText( Constants.String.event.status_qualified )
            infoHint:setText( Constants.String.event.hint_qualified )
        else
            check:loadTexture( Constants.COMPETITION_SCENE_IMAGE_PATH.."icn-unqualified.png" )
            infoQualified:setText( Constants.String.event.status_unqualified )
            infoHint:setText( string.format( Constants.String.event.hint_unqualified, info["NumberOfUserGamesLeftToQualify"] ) )
        end
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
    if mCompetitionType == CompetitionType["Private"] then
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


    -- if mCompetitionType == CompetitionType["Private"] then
    --     score:setText( string.format( mSubType["description"], info[mSubType["dataColumnId"]], info["NumberOfCoupons"] ) )
    -- else
        score:setText( string.format( score:getStringValue(), info["Profit"] ) )
    -- end
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

    local additionalParam
    if mTabID == CompetitionsData.COMPETITION_TAB_ID_MONTHLY then
        additionalParam = "&yearNumber="..mYearNumber.."&monthNumber="..mMonthNumber
    elseif mTabID == CompetitionsData.COMPETITION_TAB_ID_WEEKLY then
        additionalParam = "&yearNumber="..mYearNumber.."&weekNumber="..mWeekNumber
    else
        additionalParam = ""
    end
    EventManager:postEvent( Event.Enter_History, { id, mCompetitionId, additionalParam } )
end

function scrollViewEventHandler( target, eventType )
    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        
        mStep = mStep + 1
        local sortType = 3
        if mCompetitionType == CompetitionType["DetailedRanking"] then
            if mTabID == CompetitionsData.COMPETITION_TAB_ID_MONTHLY then
                EventManager:postEvent( Event.Load_More_In_Competition_Detail, { mCompetitionId, mStep, sortType, mTabID, mYearNumber, mMonthNumber } )
            else
                EventManager:postEvent( Event.Load_More_In_Competition_Detail, { mCompetitionId, mStep, sortType, mTabID, mYearNumber, mWeekNumber } )
            end 
        else
            EventManager:postEvent( Event.Load_More_In_Competition_Detail, { mCompetitionId, mStep, sortType } )
        end
    end
end