module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")
local LeaderboardConfig = require("scripts.config.Leaderboard")


local mWidget
local mLeaderboardId
local mSubType
local mStep
local mCurrentTotalNum

-- DS for subType see LeaderboardConfig
function loadFrame( leaderboardInfo, leaderboardId, subType )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LeaderboardList.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Navigator.loadFrame( widget )
    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    mLeaderboardId = leaderboardId
    mSubType = subType

    initTitles()
    initContent( leaderboardInfo )
    mStep = 1
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        --EventManager:postEvent( Event.Enter_Leaderboard )
        EventManager:popHistory()
    end
end

function initTitles()
    local title = tolua.cast( mWidget:getChildByName("title"), "Label" )
    local subTitle = tolua.cast( mWidget:getChildByName("subTitle"), "Label" )

    title:setText( LeaderboardConfig.LeaderboardType[mLeaderboardId]["displayName"] )
    subTitle:setText( mSubType["title"] )
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

    -- Add the "More" button
    contentHeight = contentHeight + addMoreButton( contentContainer, layoutParameter ):getSize().height

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function addMoreButton( contentContainer, layoutParameter )
    local content = SceneManager.widgetFromJsonFile("scenes/MoreContent.json")
    content:setLayoutParameter( layoutParameter )
    contentContainer:addChild( content )
    content:addTouchEventListener( loadMore )
    content:setName("More")

    return content
end

function initLeaderboardContent( i, content, info )
    local name = tolua.cast( content:getChildByName("name"), "Label" )
    local score = tolua.cast( content:getChildByName("score"), "Label" )
    local index = tolua.cast( content:getChildByName("index"), "Label" )

    if info["DisplayName"] == nil then
        name:setText( "Unknow name" )
    else
        name:setText( info["DisplayName"] )
    end
    score:setText( string.format( mSubType["description"], info[mSubType["dataColumnId"]] ) )
    index:setText( i )
end

function loadMore( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        mStep = mStep + 1
        EventManager:postEvent( Event.Load_More_In_Leaderboard, { leaderboardId, mSubType, mStep } )
    end
end

function loadMoreContent( leaderboardInfo )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    -- Remove the "More" button
    local moreButton = contentContainer:getChildByName("More")
    moreButton:removeFromParent()

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

    if table.getn( leaderboardInfo ) > 0 then
        -- Add back the "More" button
        addMoreButton( contentContainer, layoutParameter )
    end

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