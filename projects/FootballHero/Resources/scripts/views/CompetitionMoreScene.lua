module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local ViewUtils = require("scripts.views.ViewUtils")
local SelectedLeaguesScene = require("scripts.views.SelectedLeaguesScene")
local Logic = require("scripts.Logic").getInstance()


local mWidget
local mCompetitionId

-- DS for competitionDetail see CompetitionDetail
function loadFrame( selectedLeagues, competitionId )
    competitionDetail = Logic:getCompetitionDetail()
    mCompetitionId = competitionId

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionMore.json")
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
    
    initContent( competitionDetail, selectedLeagues )
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

function leaveEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local yesCallback = function()
            EventManager:postEvent( Event.Do_Leave_Competition, { mCompetitionId } )
        end

        local noCallback = function()
        end

        EventManager:postEvent( Event.Show_Choice_Message, { "Leave Competition", "Are you sure you want to leave the competition?", yesCallback, noCallback } )
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function initContent( competitionDetail, selectedLeagues )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    mContainerHeight = 0

    -- Add the competition detail info
    local content = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionMoreContent.json")
    content:setLayoutParameter( layoutParameter )
    contentContainer:addChild( content )
    mContainerHeight = mContainerHeight + content:getSize().height

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

    SelectedLeaguesScene.loadFrame( contentContainer, selectedLeagues, false, mContainerHeight )

    content = SceneManager.widgetFromJsonFile("scenes/CompetitionLeave.json")
    content:setLayoutParameter( layoutParameter )
    contentContainer:addChild( content )
    mContainerHeight = contentContainer:getInnerContainerSize().height + content:getSize().height
    contentContainer:setInnerContainerSize( CCSize:new( 0, mContainerHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    local leaveBtn = content:getChildByName("leave")
    leaveBtn:addTouchEventListener( leaveEventHandler )

end
