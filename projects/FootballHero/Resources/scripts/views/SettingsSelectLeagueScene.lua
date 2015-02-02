module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SettingsConfig = require("scripts.config.Settings")
local Constants = require("scripts.Constants")
local Logic = require("scripts.Logic").getInstance()
local RequestUtils = require("scripts.RequestUtils")

local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")

local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SettingsHome.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( widget )

    local backBt = mWidget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    initContent()
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mLogo = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function initContent()
    local title = tolua.cast( mWidget:getChildByName("Label_Title"), "Label" )
    title:setText( Constants.String.settings.select_league )

    local logout = tolua.cast( mWidget:getChildByName("Button_Logout"), "Button" )
    logout:setEnabled( false )
    
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)

    initLeaguesList( contentContainer )
end

function initLeaguesList( contentContainer )
    local contentHeight = 0
    local childIndex = 1
    for i = 1, CountryConfig.getConfigNum() do
        local leagueNum = table.getn( CountryConfig.getLeagueList( i ) )
        for j = 1, leagueNum do
            local leagueId = CountryConfig.getLeagueList( i )[j]
        
            local content = SceneManager.widgetFromJsonFile( "scenes/SettingsLeagueListContentFrame.json" )
            contentContainer:addChild( content, 0, childIndex )
            
            local logo = tolua.cast( content:getChildByName("Image_Country"), "ImageView" )
            local leagueName = tolua.cast( content:getChildByName("Label_Name"), "Label" )
            local button = content:getChildByName( "Panel_Button" )
            
            leagueName:setText( CountryConfig.getCountryName( i ).." - "..LeagueConfig.getLeagueName( leagueId ) )
            logo:loadTexture( CountryConfig.getLogo( i ) )

            contentHeight = contentHeight + content:getSize().height
            childIndex = childIndex + 1

            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    EventManager:postEvent( Event.Enter_Settings_Select_Team, LeagueConfig.getConfigId( leagueId ) )
                end
            end
            button:addTouchEventListener( eventHandler )
        end
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end

function initCountryList( contentContainer )
    local contentHeight = 0

    for i = 1, CountryConfig.getConfigNum() do
        -- Assume there is at least 1 league and get it
        local leagueId = CountryConfig.getLeagueList( i )[1]

        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                mLeagueSelectCallback( LeagueConfig.getConfigId( leagueId ), sender )
            end
        end

        local content = SceneManager.widgetFromJsonFile( "scenes/SettingsLeagueListContentFrame.json" )
        contentContainer:addChild( content )
        content:addTouchEventListener( eventHandler )

        local logo = tolua.cast( content:getChildByName("Image_Country"), "ImageView" )
        local countryName = tolua.cast( content:getChildByName("Label_Name"), "Label" )

        countryName:setText( CountryConfig.getCountryName( i ) )
        logo:loadTexture( CountryConfig.getLogo( i ) )

        contentHeight = contentHeight + content:getSize().height
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end
