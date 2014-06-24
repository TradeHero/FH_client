module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local LeagueListScene = require("scripts.views.LeagueListScene")
local CountryConfig = require("scripts.config.Country")


local mWidget
local mSelectedLeagues
local mCheckEnabled

-- If selectedLeagues is not Null, this is for review of the leagues selected.
-- So disable all the checkboxes.
function loadFrame( selectedLeagues )
    mSelectedLeagues = selectedLeagues or Logic:getSelectedLeagues() or CountryConfig.getAllLeagues()
    mCheckEnabled = ( selectedLeagues == nil )

    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CreateCompSelectLeague.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(widget)

    LeagueListScene.loadFrame( "scenes/CreateCompCountryListContent.json", "scenes/CreateCompLeagueListContent.json", 
        tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" ), leagueSelected, leagueInit )
    LeagueListScene.expendAll()

    local okBt = widget:getChildByName("OK")
    okBt:addTouchEventListener( confirmEventHandler )
    local backBt = widget:getChildByName("Back")
    backBt:addTouchEventListener( backEventHandler )
    local allBt = widget:getChildByName("all")
    allBt:addTouchEventListener( allEventHandler )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function confirmEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        if table.getn( mSelectedLeagues ) == 0 then
            EventManager:postEvent( Event.Show_Error_Message, { "Please select at least one league or cup." } )
        else
            Logic:setSelectedLeagues( mSelectedLeagues )
            EventManager:popHistory()
        end
    end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:popHistory()
    end
end

function allEventHandler( sender, eventType )
    if mCheckEnabled and eventType == TOUCH_EVENT_ENDED then
        mSelectedLeagues = CountryConfig.getAllLeagues()
        LeagueListScene.unexpendAll()
        LeagueListScene.expendAll()
    end
end

function leagueSelected( leagueId, sender )
    if mCheckEnabled then
        local tick = sender:getChildByName("ticked")
        if tick:isEnabled() then
            tick:setEnabled( false )
            for i = 1, table.getn( mSelectedLeagues ) do
                if mSelectedLeagues[i] == leagueId then
                    table.remove( mSelectedLeagues, i )
                    break
                end
            end
        else
            tick:setEnabled( true )
            table.insert( mSelectedLeagues, leagueId )
        end
    end
end

function leagueInit( content, leagueId )
    local isTicked = false
    for i = 1, table.getn( mSelectedLeagues ) do
        if mSelectedLeagues[i] == leagueId then
            isTicked = true
            break
        end
    end

    content:getChildByName("ticked"):setEnabled( isTicked )
end