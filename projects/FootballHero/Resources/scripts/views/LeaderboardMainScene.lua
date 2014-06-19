module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local LeaderboardConfig = require("scripts.config.Leaderboard")
local ViewUtils = require("scripts.views.ViewUtils")


local SUB_CONTENT_HEIGHT = 187

local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LeaderboardScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Navigator.loadFrame( widget )

    initContent()
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function initContent()
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)

    -- Add Competition items
    local contentHeight = initCompetition( layoutParameter, contentContainer )

    -- Add leaderboard items
    for i = 1, table.getn( LeaderboardConfig.LeaderboardType ) do
    	local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                contentClick( i )
            end
        end

        local content = SceneManager.widgetFromJsonFile("scenes/LeaderboardContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        local bt = content:getChildByName("button")
        bt:addTouchEventListener( eventHandler )
        initLeaderboardContent( content, LeaderboardConfig.LeaderboardType[i] )

        -- Add sub
        local subContent = GUIReader:shareReader():widgetFromJsonFile("scenes/LeaderboardSubContent.json")
        subContent:setLayoutParameter( layoutParameter )
        contentContainer:addChild( subContent )
        contentHeight = contentHeight + subContent:getSize().height
        subContent:setName( "subContent"..i )
        for j = 1, 4 do
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    subContentClick( i, j )
                end
            end

            local button = subContent:getChildByName("button"..j)
            button:addTouchEventListener( eventHandler )
        end
    end
    
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initLeaderboardContent( content, info )
    local name = tolua.cast( content:getChildByName("name"), "Label" )
    local logo = tolua.cast( content:getChildByName("logo"), "ImageView" )

    name:setText( info["displayName"] )
    logo:loadTexture( info["logo"] )
end

function initCompetition( layoutParameter, contentContainer )
    -- Add competition items
    local competitionTitle = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionTitle.json")
    competitionTitle:setLayoutParameter( layoutParameter )
    contentContainer:addChild( competitionTitle )
    local height = competitionTitle:getSize().height

    -- Add the create competition button
    local create = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionCreate.json")

    local createEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_Create_Competition )
        end
    end
    local joinEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            --EventManager:postEvent( Event.Enter_Create_Competition )
            local token = create:getChildByName( "tokenContainer" ):getNodeByTag( 1 ):getText()
            print("Token is: "..token)
        end
    end

    create:setLayoutParameter( layoutParameter )
    contentContainer:addChild( create )
    local createbt = create:getChildByName("Create")
    createbt:addTouchEventListener( createEventHandler )
    local joinBt = create:getChildByName("Join")
    joinBt:addTouchEventListener( joinEventHandler )
    local tokenInput = ViewUtils.createTextInput( create:getChildByName( "tokenContainer" ), "Enter Competition Code" )
    tokenInput:setFontColor( ccc3( 0, 0, 0 ) )
    tokenInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
    height = height + create:getSize().height

    -- Add existing competions
    for i = 1, 0 do
        local content = SceneManager.widgetFromJsonFile("scenes/CompetitionItem.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        height = height + content:getSize().height
    end

    return height
end

function contentClick( id )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    local subContent = contentContainer:getChildByName( "subContent"..id )
    local originSize = subContent:getSize()

    if originSize.height > 0 then
        subContent:setSize( CCSize:new( originSize.width, 0 ) )
        contentContainer:setInnerContainerSize( CCSize:new( 0, contentContainer:getInnerContainerSize().height - SUB_CONTENT_HEIGHT ) )
    else
        subContent:setSize( CCSize:new( originSize.width, SUB_CONTENT_HEIGHT ) )
        contentContainer:setInnerContainerSize( CCSize:new( 0, contentContainer:getInnerContainerSize().height + SUB_CONTENT_HEIGHT ) )
    end
    
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function subContentClick( id, subId )
    EventManager:postEvent( Event.Enter_Leaderboard_List, { id, subId } )
end