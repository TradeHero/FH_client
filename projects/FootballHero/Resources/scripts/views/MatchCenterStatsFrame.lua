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
    contentHeight = contentHeight + initLastSixResults( contentContainer, statsInfo )
    contentHeight = contentHeight + initWDW( contentContainer, statsInfo )
    contentHeight = contentHeight + initLastSixHomeAway( contentContainer, statsInfo )
    contentHeight = contentHeight + initFormTable( contentContainer, statsInfo )
    contentHeight = contentHeight + initOverUnder( contentContainer, statsInfo )
    contentHeight = contentHeight + initLeagueTable( contentContainer, statsInfo )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initLastSixResults( contentContainer, statsInfo )

    local contentHeight = 0

    local last6HeaderFrame = SceneManager.widgetFromJsonFile("scenes/MatchCenterStatsLastSixFrame.json")
    contentContainer:addChild( last6HeaderFrame )
    contentHeight = contentHeight + last6HeaderFrame:getSize().height

    local date = tolua.cast( last6HeaderFrame:getChildByName("Label_Date"), "Label" )
    local home = tolua.cast( last6HeaderFrame:getChildByName("Label_Home"), "Label" )
    local vs = tolua.cast( last6HeaderFrame:getChildByName("Label_VS"), "Label" )
    local away = tolua.cast( last6HeaderFrame:getChildByName("Label_Away"), "Label" )

    date:setText( Constants.String.match_center.label_date )
    home:setText( Constants.String.match_center.label_home)
    vs:setText( Constants.String.vs )
    away:setText( Constants.String.match_center.label_away )

    -- TODO - read 'statsInfo' data
    for i = 1,3 do
        local content = SceneManager.widgetFromJsonFile("scenes/MatchCenterStatsLastSixFrame.json")
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        local bg = content:getChildByName("Image_BG")
        bg:setEnabled( false )

        local date = tolua.cast( content:getChildByName("Label_Date"), "Label" )
        local home = tolua.cast( content:getChildByName("Label_Home"), "Label" )
        local vs = tolua.cast( content:getChildByName("Label_VS"), "Label" )
        local away = tolua.cast( content:getChildByName("Label_Away"), "Label" )

        -- TODO - read 'statsInfo' data
        date:setText( Constants.String.month["m"..i] )
        home:setText( "Home Team "..i )
        vs:setText( "3:2" )
        away:setText( "Away Team"..i )
    end

    return contentHeight
end

function initWDW( contentContainer, statsInfo )

    local contentHeight = 0

    local wdwFrame = SceneManager.widgetFromJsonFile("scenes/MatchCenterStatsWDWFrame.json")
    contentContainer:addChild( wdwFrame )
    contentHeight = contentHeight + wdwFrame:getSize().height

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

    return contentHeight
end

function initLastSixHomeAway( contentContainer, statsInfo )

    local contentHeight = 0
    
    contentHeight = contentHeight + initHomeAway( contentContainer, statsInfo, true )
    contentHeight = contentHeight + initHomeAway( contentContainer, statsInfo, false )

    return contentHeight
end

function initHomeAway( contentContainer, statsInfo, isHome )

    local contentHeight = 0

    local teamId, titleText, bgImage
    if isHome then
        teamId = TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] )
        titleText = Constants.String.match_center.last_home_results
        bgImage = Constants.MATCH_CENTER_IMAGE_PATH.."img-homebox.png"
    else
        teamId = TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] )
        titleText = Constants.String.match_center.last_away_results
        bgImage = Constants.MATCH_CENTER_IMAGE_PATH.."img-awaybox.png"
    end

    local headerFrame = SceneManager.widgetFromJsonFile("scenes/MatchCenterStatsHomeAwayHeaderFrame.json")
    contentContainer:addChild( headerFrame )
    contentHeight = contentHeight + headerFrame:getSize().height

    local bg = tolua.cast( headerFrame:getChildByName("Image_BG"), "ImageView" )
    local team = tolua.cast( headerFrame:getChildByName("Label_Team"), "Label" )
    local image = tolua.cast( headerFrame:getChildByName("Image_Team"), "ImageView" )
    local title = tolua.cast( headerFrame:getChildByName("Label_Title"), "Label" )
    
    bg:loadTexture( bgImage )
    team:setText( TeamConfig.getTeamName( teamId ) )
    image:loadTexture( TeamConfig.getLogo( teamId ) )
    title:setText( titleText )

    -- TODO - read 'statsInfo' data
    for i = 1,3 do
        local content = SceneManager.widgetFromJsonFile("scenes/MatchCenterStatsHomeAwayContentFrame.json")
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        local date = tolua.cast( content:getChildByName("Label_Date"), "Label" )
        local status = tolua.cast( content:getChildByName("Label_Status"), "Label" )
        local vs = tolua.cast( content:getChildByName("Label_VS"), "Label" )
        local score = tolua.cast( content:getChildByName("Label_Score"), "Label" )

        -- TODO - read 'statsInfo' data
        date:setText( Constants.String.month["m"..i] )
        status:setText( Constants.String.match_center.win )
        vs:setText( "Opponent Team "..i  )
        score:setText( "3:2" )
    end

    return contentHeight
end

function initFormTable( contentContainer, statsInfo )
    return 0
end

function initOverUnder( contentContainer, statsInfo )
    return 0
end
    
function initLeagueTable( contentContainer, statsInfo )
    return 0
end


