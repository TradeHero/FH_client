module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local LeagueConfig = require("scripts.config.League")
local TeamConfig = require("scripts.config.Team")
local LeagueTeamConfig = require("scripts.config.LeagueTeams")
local LeagueListScene = require("scripts.views.LeagueListScene")
local TutorialManager = require("scripts.TutorialManager")


local TEAM_NUM = 20
local mWidget
local mDisplayLeagueId
local mLeagueId
local mTeamId

function loadFrame()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/FavouriteTeam.json")

    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( widget )

    LeagueListScene.loadFrame( "scenes/FavouriteCountryContent.json", "scenes/FavouriteLeagueContent.json", 
        tolua.cast( mWidget:getChildByName("countryList"), "ScrollView" ), leagueSelected )

    -- Disable the ok button
    local okBt = widget:getChildByName("ok")
    okBt:addTouchEventListener( okEventHandler )
    okBt:setBright( false )
    okBt:setTouchEnabled( false )

    -- Set the default one.
    leagueSelected( LeagueConfig.getConfigId( 1 ) )

    local leagueName = tolua.cast( mWidget:getChildByName("leagueName"), "Label" )
    leagueName:setText( "Please select your favourite team." )

    TutorialManager.checkRunTutorial( TutorialManager.TUTORIAL_SEL_FAV_TEAM )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function okEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        print("Favourite Team is: "..mTeamId.." in league: "..mLeagueId)
        EventManager:postEvent( Event.Do_Post_Fav_Team, { mTeamId, mLeagueId } )
    end
end

function leagueSelected( leagueId )
    mDisplayLeagueId = leagueId
    print( "leagueSelected: "..mDisplayLeagueId )
--[[
    -- Update the country list
    local countryContainer = tolua.cast( mWidget:getChildByName("countryList"), "ScrollView" )
    for i = 1, LeagueConfig.getConfigNum() do
        local country = countryContainer:getChildByTag( i )
        if i == leagueId then
            country:setOpacity( 255 )
        else
            country:setOpacity( 100 )
        end
    end
--]]
    
    -- Update the team list.
    local teamList = LeagueTeamConfig.getConfig( leagueId )
    local teamListLength = table.getn( teamList )

    local teamContainer = tolua.cast( mWidget:getChildByName("teamList"), "ScrollView" )
    teamContainer:removeAllChildren()

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_LEFT)

    local contentHeight = 0
    for i = 1, ( teamListLength + 1 ) / 2 do

        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/Team.json")
        for j = 1, 2 do
            local teamIndex = ( i - 1 ) * 2 + j
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    local teamId = TeamConfig.getConfigIdByKey( teamList[teamIndex]["teamId"] )
                    teamSelected( teamId )
                end
            end

            local teamButton = tolua.cast( content:getChildByName("team"..j), "Button" )
            local teamName = tolua.cast( content:getChildByName("team"..j.."Name"), "Label" )

            if teamIndex > teamListLength then
                teamName:setVisible( false )
                teamButton:setVisible( false )
            else
                local teamId = TeamConfig.getConfigIdByKey( teamList[teamIndex]["teamId"] )
                teamButton:loadTextureNormal( TeamConfig.getLogo( teamId ) )
                teamButton:addTouchEventListener( eventHandler )
                teamName:setText( TeamConfig.getTeamName( teamId ) )
            end
            
        end

        content:setLayoutParameter( layoutParameter )
        teamContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
    end

    teamContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )

end

function teamSelected( index )
    print("Team Selected: "..index)
    mLeagueId = mDisplayLeagueId
    mTeamId = TeamConfig.getTeamId( index )
    local teamSelected = tolua.cast( mWidget:getChildByName("leagueName"), "Label" )
    teamSelected:setText( "Your favourite team: "..TeamConfig.getTeamName( index ) )

    local okBt = mWidget:getChildByName("ok")
    okBt:setBright( true )
    okBt:setTouchEnabled( true )
end

