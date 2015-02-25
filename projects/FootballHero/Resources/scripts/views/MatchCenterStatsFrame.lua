module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Logic = require("scripts.Logic").getInstance()

local TeamConfig = require("scripts.config.Team")

local mMatch

function loadFrame( parent, jsonResponse, callback )
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsFrame.json")
    parent:addChild( mWidget )

    local statsInfo
    -- TODO
    -- if jsonResponse["GameInformation"] == nil then
    --     statsInfo = jsonResponse
    -- else
    --     statsInfo = jsonResponse["DiscussionInformation"]
    -- end
    mMatch = Logic:getSelectedMatch()
    
    initContent( statsInfo )
end

function exitFrame()
    mWidget = nil
end

function isShown()
    return mWidget ~= nil
end

function initContent( statsInfo )

	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Stats"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0
    
    -- TODO populate scrollview
    initLastSixResults( contentContainer, statsInfo )
    initWDW( contentContainer, statsInfo )
    initLastSixHomeAway( contentContainer, statsInfo )
    initFormTable( contentContainer, statsInfo )
    initOverUnder( contentContainer, statsInfo )
    initLeagueTable( contentContainer, statsInfo )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initLastSixResults( contentContainer, statsInfo )

end

function initWDW( contentContainer, statsInfo )

    local wdwFrame = SceneManager.widgetFromJsonFile("scenes/MatchCenterStatsWDWFrame.json")
    contentContainer:addChild( wdwFrame )

    local home = tolua.cast( wdwFrame:getChildByName("Image_Home"), "ImageView" )
    local homeRate = tolua.cast( home:getChildByName("Label_Percent"), "Label" )
    local homeSide = tolua.cast( home:getChildByName("Label_Side"), "Label" )

    local draw = tolua.cast( wdwFrame:getChildByName("Image_Draw"), "ImageView" )
    local drawRate = tolua.cast( draw:getChildByName("Label_Percent"), "Label" )
    local drawSide = tolua.cast( draw:getChildByName("Label_Side"), "Label" )

    local away = tolua.cast( wdwFrame:getChildByName("Image_Away"), "ImageView" )
    local awayRate = tolua.cast( away:getChildByName("Label_Percent"), "Label" )
    local awaySide = tolua.cast( away:getChildByName("Label_Side"), "Label" )
    
    -- TODO set correct image based on win % (img-more.png / img-less.png)
    -- home:loadText()
    -- away:loadText()
    
    homeSide:setText( string.format( Constants.String.match_center.team_wins, TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) ) )
    awaySide:setText( string.format( Constants.String.match_center.team_wins, TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) ) )
    drawSide:setText( Constants.String.match_list.draw )

    -- TODO set %s
    -- homeRate:setText()
    -- drawRate:setText()
    -- awayRate:setText()
end

function initLastSixHomeAway( contentContainer, statsInfo )

end

function initFormTable( contentContainer, statsInfo )

end

function initOverUnder( contentContainer, statsInfo )

end
    
function initLeagueTable( contentContainer, statsInfo )

end


