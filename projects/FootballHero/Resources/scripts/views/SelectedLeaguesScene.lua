module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local LeagueListSceneUnexpended = require("scripts.views.LeagueListSceneUnexpended")


local mSelectedLeagues
local mCheckEnabled

-- If selectedLeagues is not Null, this is for review of the leagues selected.
-- So disable all the checkboxes.
function loadFrame( contentContainer, selectedLeagues, checkEnabled, existingContentHeight )
    mSelectedLeagues = selectedLeagues or Logic:getSelectedLeagues()
    mCheckEnabled = checkEnabled

    LeagueListSceneUnexpended.loadFrame( "scenes/LeagueContentWithTransparentBG.json", "", 
        contentContainer, leagueSelected, existingContentHeight, leagueInit )
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

        Logic:setSelectedLeagues( mSelectedLeagues )
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