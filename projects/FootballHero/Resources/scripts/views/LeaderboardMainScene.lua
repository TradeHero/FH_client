module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local LeaderboardConfig = require("scripts.config.Leaderboard")
local ViewUtils = require("scripts.views.ViewUtils")
local Constants = require("scripts.Constants")

local SUB_CONTENT_HEIGHT = 187

local mWidget


-- DS, see Competitions.lua
function loadFrame( compList )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LeaderboardScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()

    Navigator.loadFrame( widget )

    initContent( compList )
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

function initContent( compList )
	local contentContainer = mWidget:getChildByName("list")
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)

    -- Add Competition items
    initCompetition( layoutParameter, contentContainer, compList )

    -- Add leaderboard items
    for i = 1, table.getn( LeaderboardConfig.LeaderboardType ) do
    	local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                subContentClick( i, 1 )
            end
        end

        local content = SceneManager.widgetFromJsonFile("scenes/LeaderboardContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        local bt = content:getChildByName("button")
        bt:addTouchEventListener( eventHandler )
        initLeaderboardContent( content, LeaderboardConfig.LeaderboardType[i] )

        if i == table.getn( LeaderboardConfig.LeaderboardType ) then
            local separater = content:getChildByName("separater")
            separater:setEnabled( false )
        end
    end
    
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initLeaderboardContent( content, info )
    local name = tolua.cast( content:getChildByName("name"), "Label" )
    name:setText( info["displayName"] )
end

function initCompetition( layoutParameter, contentContainer, compList )
    -- Add competition items
    local competitionTitle = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionTitle.json")
    competitionTitle:setLayoutParameter( layoutParameter )
    contentContainer:addChild( competitionTitle )

    local scrollView = tolua.cast( competitionTitle:getChildByName("ScrollView"), "ScrollView")
    scrollView:removeAllChildrenWithCleanup( true )

    -- Add the create competition button
    local create = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionCreate.json")
    local height = 0

    local createEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_Create_Competition )
        end
    end
    local joinEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            local token = create:getChildByName( "tokenContainer" ):getNodeByTag( 1 ):getText()
            EventManager:postEvent( Event.Do_Join_Competition, { token } )
        end
    end

    create:setLayoutParameter( layoutParameter )
    scrollView:addChild( create )
    local createbt = create:getChildByName("Create")
    createbt:addTouchEventListener( createEventHandler )
    local joinBt = create:getChildByName("Join")
    joinBt:addTouchEventListener( joinEventHandler )
    local tokenInput = ViewUtils.createTextInput( create:getChildByName( "tokenContainer" ), Constants.String.enter_comp_code )
    tokenInput:setFontColor( ccc3( 0, 0, 0 ) )
    tokenInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
    local inputDelegate = EditBoxDelegateForLua:create()
    inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_DID_BEGIN, function ( textBox )
        -- In order not to change the object-c code, here is the work around.
        -- recall the setPosition() to invoke the CCEditBoxImplIOS::adjustTextFieldPosition()
        -- Todo remove this code after the object-c fix is pushed out.
        tokenInput:setPosition( tokenInput:getPosition() )
    end )
    create:getChildByName( "tokenContainer" ):addNode( tolua.cast( inputDelegate, "CCNode" ) )
    tokenInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )
    height = height + create:getSize().height

    -- Add existing competions
    if compList:getSize() > 0 then
        for i = 1, compList:getSize() do
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    enterCompetition( compList:get( i )["Id"] )
                end
            end

            local content = SceneManager.widgetFromJsonFile("scenes/CompetitionItem.json")
            content:setLayoutParameter( layoutParameter )
            scrollView:addChild( content )
            height = height + content:getSize().height

            local name = tolua.cast( content:getChildByName("name"), "Label" )
            name:setText( compList:get( i )["Name"] )

            local bt = content:getChildByName("button")
            bt:addTouchEventListener( eventHandler )

            if i == compList:getSize() then
                local separater = content:getChildByName("separater")
                separater:setEnabled( false )
            end
        end
    else
        local content = SceneManager.widgetFromJsonFile("scenes/CompetitionEmpty.json")
        content:setLayoutParameter( layoutParameter )
        scrollView:addChild( content )
        height = height + content:getSize().height
    end

    scrollView:setInnerContainerSize( CCSize:new( 0, height ) )
    local layout = tolua.cast( scrollView, "Layout" )
    layout:requestDoLayout()
end

function subContentClick( id, subId )
    EventManager:postEvent( Event.Enter_Leaderboard_List, { id, subId } )
end

function enterCompetition( competitionId )
    EventManager:postEvent( Event.Enter_Competition_Detail, { competitionId } )
end