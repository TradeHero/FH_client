module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local CommunityConfig = require("scripts.config.Community")
local LeaderboardConfig = require("scripts.config.Leaderboard")
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
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityLeaderboardFrame.json")
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
    title:setText( LeaderboardConfig.LeaderboardType[mLeaderboardId]["displayName"] )
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
                EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_LEADERBOARD, otherType, typeKey, Constants.FILTER_MIN_PREDICTION } )
            else
                EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_LEADERBOARD, otherType, typeKey } )
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
        typeName:setText( mSubType["title"] )
    end

    local typeSelectedCallback = function( typeKey )
        list:setEnabled( false )
        mask:setEnabled( false )
        expendedIndicator:setBrightStyle( BRIGHT_NORMAL )
        
        initCurrentType( typeKey )

        -- Stop the loading logo actions.
        mWidget:stopAllActions()
        if mFilter == true then
            EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_LEADERBOARD, mLeaderboardId, typeKey, Constants.FILTER_MIN_PREDICTION } )
        else
            EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_LEADERBOARD, mLeaderboardId, typeKey } )
        end
    end

    CommunityLeaderboardDropdownFrame.loadFrame( "scenes/CommunityLeaderboardDropdownContentFrame.json", 
        list, typeSelectedCallback )

    initCurrentType()
end

function initFilter( bRefreshed )
    local minCheckboxEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            local minCheckBox = tolua.cast( sender, "CheckBox" )
            
            mWidget:stopAllActions()

            if minCheckBox:getSelectedState() == true then                
                EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_LEADERBOARD, mLeaderboardId, typeKey } )
                mFilter = false
            else                
                EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_LEADERBOARD, mLeaderboardId, typeKey, Constants.FILTER_MIN_PREDICTION } )
                mFilter = true
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
    end
    mCurrentTotalNum = table.getn( leaderboardInfo )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
    contentContainer:addEventListenerScrollView( scrollViewEventHandler )
end

function initLeaderboardContent( i, content, info )
    local name = tolua.cast( content:getChildByName("name"), "Label" )
    local score = tolua.cast( content:getChildByName("score"), "Label" )
    local index = tolua.cast( content:getChildByName("index"), "Label" )
    local logo = tolua.cast( content:getChildByName("logo"), "ImageView" )

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

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_TypeList"), "ScrollView" )

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
    local name = Constants.String.unknown_name
    if info["DisplayName"] ~= nil then
        name = info["DisplayName"]
    end
    EventManager:postEvent( Event.Enter_History, { id, name } )
end

function scrollViewEventHandler( target, eventType )
    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        EventManager:postEvent( Event.Load_More_In_Leaderboard, { mLeaderboardId, mSubType, mStep } )
    end
end