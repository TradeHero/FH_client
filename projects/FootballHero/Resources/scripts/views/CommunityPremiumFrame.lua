module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local CommunityConfig = require("scripts.config.Community")
local LeaderboardConfig = require("scripts.config.Premiumboard")
local CommunityLeaderboardDropdownFrame = require("scripts.views.CommunityLeaderboardDropdownFrame")
local SMIS = require("scripts.SMIS")
local Constants = require("scripts.Constants")


local mWidget
local mLeaderboardId
local mSubType
local mStep
local mCurrentTotalNum
local mHasMoreToLoad
local mDropDown
local mFilter

-- DS for subType see LeaderboardConfig
function loadFrame( parent, leaderboardInfo, leaderboardId, subType, bRefresh )
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityPremiumLeaderboardFrame.json")
    parent:addChild( mWidget )

    mLeaderboardId = leaderboardId
    mSubType = subType
    mStep = 1
    mHasMoreToLoad = true

    initTitles()
    initContent( leaderboardInfo )
    initTypeList()

    if bRefresh then
        initFilter( true )
    else
        mFilter = true
        initFilter( false )
    end
end

function refreshFrame( parent, leaderboardInfo, leaderboardId, subType )
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityLeaderboardFrame.json")
    mWidget = widget

    parent:addChild( mWidget )

    mLeaderboardId = leaderboardId
    mSubType = subType

    initTitles()
    initContent( leaderboardInfo )
    initTypeList()
    initFilter( true )

    mStep = 1
    mHasMoreToLoad = true
end

function exitFrame()
    mWidget = nil
end

function isShown()
    return mWidget ~= nil
end

function initTitles()
    local title = tolua.cast( mWidget:getChildByName("Label_Leaderboard_Type"), "Label" )
    title:setText( Constants.String[LeaderboardConfig.LeaderboardType[mLeaderboardId]["displayNameKey"]] )

    local minTitle = tolua.cast( mWidget:getChildByName( "Label_Min_Prediction" ), "Label" )
    minTitle:setText( string.format( Constants.String.leaderboard.min_prediction, Constants.FILTER_MIN_PREDICTION ) )
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function initTypeList()
    mDropDown = SceneManager.widgetFromJsonFile("scenes/CommunityLeaderboardDropdownFrame.json")
    mWidget:addChild( mDropDown )
    
    local mask = mDropDown:getChildByName("Panel_Mask")
    local list = tolua.cast( mDropDown:getChildByName("ScrollView_TypeList"), "ScrollView" )
    local button = mWidget:getChildByName("Panel_Filter")
    local expendedIndicator = mWidget:getChildByName( "Button_Filter" )
    
    --local leaderboardType = mWidget:getChildByName( "Label_Leaderboard_Type")
    local leftPanel = mWidget:getChildByName( "Panel_Arrow_Left")
    local leftButton = leftPanel:getChildByName( "Button_Left")
    local rightPanel = mWidget:getChildByName( "Panel_Arrow_Right")
    local rightButton = rightPanel:getChildByName( "Button_Right")

    local switchLeaderboardEventHandler = function( sender, eventType ) 
        if eventType == TOUCH_EVENT_ENDED then
            -- Stop the loading logo actions.
            mWidget:stopAllActions()
            
            local otherType = mLeaderboardId % table.getn( LeaderboardConfig.LeaderboardType ) + 1
            if mFilter == true then
                EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_PREMIUM, otherType, typeKey, Constants.FILTER_MIN_PREDICTION } )
            else
                EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_PREMIUM, otherType, typeKey } )
            end
        end
    end
    leftPanel:addTouchEventListener( switchLeaderboardEventHandler )
    leftButton:addTouchEventListener( switchLeaderboardEventHandler )
    rightPanel:addTouchEventListener( switchLeaderboardEventHandler )
    rightButton:addTouchEventListener( switchLeaderboardEventHandler )
    
    local buttonEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if list:isEnabled() then
                list:setEnabled( false )
                mask:setEnabled( false )
                expendedIndicator:setBrightStyle( BRIGHT_NORMAL )
            else
                list:setEnabled( true )
                mask:setEnabled( true )
                expendedIndicator:setBrightStyle( BRIGHT_HIGHLIGHT )
            end
        end
    end
    expendedIndicator:addTouchEventListener( buttonEventHandler )
    button:addTouchEventListener( buttonEventHandler )
    list:setEnabled( false )
    mask:setEnabled( false )

    local initCurrentType = function( typeKey )
        local typeName = tolua.cast( mWidget:getChildByName("Label_Sort_Type"), "Label" )
        typeName:setText( Constants.String.leaderboard[mSubType["titleKey"]] )
    end

    local typeSelectedCallback = function( typeKey )
        list:setEnabled( false )
        mask:setEnabled( false )
        expendedIndicator:setBrightStyle( BRIGHT_NORMAL )
        
        initCurrentType( typeKey )

        -- Stop the loading logo actions.
        mWidget:stopAllActions()
        if mFilter == true then
            EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_PREMIUM, mLeaderboardId, typeKey, Constants.FILTER_MIN_PREDICTION } )
        else
            EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_PREMIUM, mLeaderboardId, typeKey } )
        end
    end

    CommunityLeaderboardDropdownFrame.loadFrame( "scenes/CommunityLeaderboardDropdownContentFrame.json", 
        list, typeSelectedCallback )

    initCurrentType()
end

function getFilter()
    local minCheckbox = tolua.cast( mWidget:getChildByName("CheckBox_Min_Prediction"), "CheckBox" )
    if minCheckbox:getSelectedState() then
        return Constants.FILTER_MIN_PREDICTION
    else
        return 1
    end
end

function initFilter( bRefreshed )
    local minCheckboxEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            local minCheckBox = tolua.cast( sender, "CheckBox" )
            
            mWidget:stopAllActions()

            if minCheckBox:getSelectedState() == true then                
                mFilter = false
                EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_PREMIUM, mLeaderboardId, typeKey } )
            else                
                mFilter = true
                EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_PREMIUM, mLeaderboardId, typeKey, Constants.FILTER_MIN_PREDICTION } )
            end
        end
    end
    local minCheckbox = tolua.cast( mWidget:getChildByName("CheckBox_Min_Prediction"), "CheckBox" )
    minCheckbox:addTouchEventListener( minCheckboxEventHandler )
    
    if bRefreshed == true then
        minCheckbox:setSelectedState( mFilter )
    else
        minCheckbox:setSelectedState( true )
    end
end

function initContent( leaderboardInfo )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Leaderboard"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    for i = 1, table.getn( leaderboardInfo ) do
        local content = SceneManager.widgetFromJsonFile("scenes/CommunityPremiumLeaderboardListContentFrame.json")
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

function initLeaderboardContent( i, content, info )
    local top  = content:getChildByName("Panel_Top")
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local score = tolua.cast( top:getChildByName("Label_Score"), "Label" )
    local index = tolua.cast( top:getChildByName("Label_Index"), "Label" )
    local open = tolua.cast( top:getChildByName("Label_open"), "Label" )
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )
    local click = top:getChildByName("Panel_Click")
    local drop = top:getChildByName("Panel_Dropdown")
    local btn = tolua.cast( drop:getChildByName("Button_Dropdown"), "Button" )
    local stats = top:getChildByName("Panel_Stats")
    stats:setEnabled( false )

    if info["OpenCount"] == 0 then
        open:setEnabled( false )
    else
        open:setText(string.format( "%d open", info["OpenCount"] ))
    end

    local check = tolua.cast( top:getChildByName("Image_Check"), "ImageView" )
    check:setEnabled( false )

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

    if info["DisplayName"] == nil or type( info["DisplayName"] ) ~= "string" then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    score:setText( string.format( Constants.String.leaderboard[mSubType["descriptionKey"]], info[mSubType["dataColumnId"]], info["NumberOfCoupons"] ) )
    if info[mSubType["dataColumnId"]] < 0 then
        score:setColor( ccc3( 240, 75, 79 ) )
    else
        score:setColor( ccc3( 79, 199, 93 ) )
    end

    index:setText( info["NonPremiumRank"] )

    -- stat box
    local title_stat_win = tolua.cast( stats:getChildByName("Label_Title_Win"), "Label" )
    local title_stat_lose = tolua.cast( stats:getChildByName("Label_Title_Lose"), "Label" )
    local title_stat_win_percent = tolua.cast( stats:getChildByName("Label_Title_Win_Percent"), "Label" )
    local title_stat_gain_percent = tolua.cast( stats:getChildByName("Label_Title_Gain_Percent"), "Label" )
    local title_stat_last_10 = tolua.cast( stats:getChildByName("Label_Title_Last_10"), "Label" )
    
    title_stat_win:setText( Constants.String.leaderboard.stats_win )
    title_stat_lose:setText( Constants.String.leaderboard.stats_lose )
    title_stat_win_percent:setText( Constants.String.leaderboard.stats_win_rate )
    title_stat_gain_percent:setText( Constants.String.leaderboard.stats_gain_rate )
    title_stat_last_10:setText( Constants.String.leaderboard.stats_last_ten )
    
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
    else
        stat_gain_percent:setColor( ccc3( 79, 199, 93 ) )
    end

    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        if type( info["PictureUrl"] ) ~= "userdata" and info["PictureUrl"] ~= nil then
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

        local content = SceneManager.widgetFromJsonFile("scenes/CommunityPremiumLeaderboardListContentFrame.json")
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
    EventManager:postEvent( Event.Enter_History, { id } )
end

function scrollViewEventHandler( target, eventType )
    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        if mFilter == true then
            EventManager:postEvent( Event.Load_More_In_PremiumLeaderboard, { mLeaderboardId, mSubType, mStep, Constants.FILTER_MIN_PREDICTION } )
        else
            EventManager:postEvent( Event.Load_More_In_PremiumLeaderboard, { mLeaderboardId, mSubType, mStep } )
        end
    end
end