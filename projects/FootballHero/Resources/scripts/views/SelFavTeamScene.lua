module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local LeagueConfig = require("scripts.config.League")
local TeamConfig = require("scripts.config.Team")

local TEAM_NUM = 20
local mWidget
local mCountryId
local mTeamId

function loadFrame()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/FavouriteTeam.json")

    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( widget )

    local countryContainer = tolua.cast( widget:getChildByName("countryList"), "ScrollView" )
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_LEFT)
    local contentHeight = 0

    for i = 1, LeagueConfig.getConfigNum() do
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                countrySelected( i )
            end
        end

        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/Country.json")
        local coutryButton = tolua.cast( content:getChildByName("country"), "Button" )
        coutryButton:loadTextureNormal( Constants.LEAGUE_IMAGE_PATH..LeagueConfig.getLogo( i ) )

        content:setLayoutParameter( layoutParameter )
        countryContainer:addChild( content, 0, i )
        coutryButton:addTouchEventListener( eventHandler )
        contentHeight = contentHeight + content:getSize().height
    end
    countryContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )

    -- Disable the ok button
    local okBt = widget:getChildByName("ok")
    okBt:addTouchEventListener( okEventHandler )
    okBt:setBright( false )

    -- Set the default one.
    countrySelected( 1 )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function okEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        print("Favourite Team is: "..mCountryId.."|"..mTeamId)
        EventManager:postEvent( Event.Enter_Match_List )
    end
end

function countrySelected( index )
    mCountryId = index

    -- Update the country name
    local countryName = tolua.cast( mWidget:getChildByName("countryName"), "Label" )
    countryName:setText( LeagueConfig.getDisplayName( index ) )

    -- Update the country list
    local countryContainer = tolua.cast( mWidget:getChildByName("countryList"), "ScrollView" )
    for i = 1, LeagueConfig.getConfigNum() do
        local country = countryContainer:getChildByTag( i )
        if i == index then
            country:setOpacity( 255 )
        else
            country:setOpacity( 100 )
        end
    end

    -- Update the team list.
    local teamList = LeagueConfig.getTeamList( index )
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
                    teamSelected( teamIndex )
                end
            end

            local teamButton = tolua.cast( content:getChildByName("team"..j), "Button" )
            local teamName = tolua.cast( content:getChildByName("team"..j.."Name"), "Label" )

            if teamIndex > teamListLength then
                teamName:setVisible( false )
                teamButton:setVisible( false )
            else
                teamButton:loadTextureNormal( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( teamList[teamIndex] ) )
                teamButton:addTouchEventListener( eventHandler )
                teamName:setText( TeamConfig.getDisplayName( teamList[teamIndex] ) )
            end
            
        end

        content:setLayoutParameter( layoutParameter )
        teamContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
    end

    teamContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
end

function teamSelected( index )
    mTeamId = index

    local okBt = mWidget:getChildByName("ok")
    okBt:setBright( true )
end

