module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")
local LeaderboardConfig = require("scripts.config.Leaderboard")
local LeaderboardListSceneUnexpended = require("scripts.views.LeaderboardListSceneUnexpended")
local SMIS = require("scripts.SMIS")


local mWidget
local mLeaderboardId
local mSubType
local mStep
local mCurrentTotalNum
local mHasMoreToLoad
local maTypeStack
local mDropDown

-- DS for subType see LeaderboardConfig
function loadFrame( leaderboardInfo, leaderboardId, subType )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LeaderboardList.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( widget )
    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    mLeaderboardId = leaderboardId
    mSubType = subType

    initTitles()
    initContent( leaderboardInfo )
    initTypeList()
    mStep = 1
    mHasMoreToLoad = true
end

function refreshFrame( leaderboardInfo, leaderboardId, subType )
    mLeaderboardId = leaderboardId
    mSubType = subType

    initContent( leaderboardInfo )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isShown()
    return mWidget ~= nil
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    -- Vincent: change the dropdown title to the previous one when going back
    initPreviousType()
    EventManager:popHistory()
    end

-- @@ADD Vincent: update the dropbox title with a previously saved string stored in a stack
function initPreviousType()    
    local previousText = table.remove(maTypeStack)
    if next(maTypeStack) == nil then
        -- no more previous type, do nothing
    else
        local typeName = tolua.cast( mDropDown:getChildByName("currentType"), "Label" )
        typeName:setText( previousText )
    end
end

function initTypeList()
    mDropDown = SceneManager.widgetFromJsonFile("scenes/LeaderbaordDropDown.json")
    mWidget:addChild( mDropDown )
    
    local list = tolua.cast( mDropDown:getChildByName("typeList"), "ScrollView" )
    local expendedIndicator = mDropDown:getChildByName( "expendIndi" )
    local mask = mDropDown:getChildByName("mask")
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
    local button = mDropDown:getChildByName("button")
    button:addTouchEventListener( buttonEventHandler )
    list:setEnabled( false )
    mask:setEnabled( false )

    local initCurrentType = function( typeKey )        
        local typeName = tolua.cast( mDropDown:getChildByName("currentType"), "Label" )
        -- insert previous string value into stack
        table.insert(maTypeStack, typeName:getStringValue())
        typeName:setText( LeaderboardConfig.LeaderboardSubType[typeKey]["title"] )
    end

    local leagueSelectedCallback = function( typeKey )
        list:setEnabled( false )
        mask:setEnabled( false )
        expendedIndicator:setBrightStyle( BRIGHT_NORMAL )
        
        initCurrentType( typeKey )

        -- Stop the loading logo actions.
        mWidget:stopAllActions()
        EventManager:postEvent( Event.Enter_Leaderboard_List, { mLeaderboardId, typeKey } )
    end

    LeaderboardListSceneUnexpended.loadFrame( "scenes/LeaderbaordContentInDropDown.json", 
        list, leagueSelectedCallback )

    maTypeStack = {}
    initCurrentType( 1 )
end

function initTitles()
    local title = tolua.cast( mWidget:getChildByName("title"), "Label" )
    title:setText( LeaderboardConfig.LeaderboardType[mLeaderboardId]["displayName"] )
end

function initContent( leaderboardInfo )
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
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
        name:setText( "Unknown name" )
    else
        name:setText( info["DisplayName"] )
    end
    score:setText( string.format( mSubType["description"], info[mSubType["dataColumnId"]], info["NumberOfCoupons"] ) )
    if info[mSubType["dataColumnId"]] < 0 then
        score:setColor( ccc3( 240, 75, 79 ) )
    end
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
    EventManager:postEvent( Event.Enter_History, { id, name } )
end

function scrollViewEventHandler( target, eventType )
    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        EventManager:postEvent( Event.Load_More_In_Leaderboard, { leaderboardId, mSubType, mStep } )
    end
end