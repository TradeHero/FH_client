module(..., package.seeall)

local Constants = require("scripts.Constants")
local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")
local SceneManager = require("scripts.SceneManager")


local mCountryNum = CountryConfig.getConfigNum()

local mCountryWidget
local mLeagueWidget
local mLeagueListContainer
local mLeagueSelectCallback
local mLeagueInitCallback

local mChildIndex

function loadFrame( countryWidget, leagueWidget, leagueListContainer, leagueSelectCallback, existingContentHeight, leagueInitCallback )
	mCountryWidget = countryWidget
	mLeagueWidget = leagueWidget
	mLeagueListContainer = leagueListContainer
	mLeagueSelectCallback = leagueSelectCallback
    mLeagueInitCallback = leagueInitCallback

	helperInitLeagueList( existingContentHeight or 0 )
end

function helperInitLeagueList( existingContentHeight )
    local contentHeight = existingContentHeight
    mChildIndex = 1

    -- Add in the "Most Popular" league - top 25 upcoming games
    contentHeight = contentHeight + addPopularLeague()

    for i = 1, mCountryNum do
        local leagueNum = table.getn( CountryConfig.getLeagueList( i ) )
        for j = 1, leagueNum do
            local leagueId = CountryConfig.getLeagueList( i )[j]

            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    selectOnLeague( sender )
                    mLeagueSelectCallback( LeagueConfig.getConfigId( leagueId ), sender )
                end
            end

            local content = SceneManager.widgetFromJsonFile( mCountryWidget )
            mLeagueListContainer:addChild( content, 0, mChildIndex )
            content:addTouchEventListener( eventHandler )

            local logo = tolua.cast( content:getChildByName("countryLogo"), "ImageView" )
            local leagueName = tolua.cast( content:getChildByName("countryName"), "Label" )
            local expendedIndicator = content:getChildByName( "expendIndi" )
            local selectedIndi = content:getChildByName("selectedIndi")

            if expendedIndicator ~= nil then
                expendedIndicator:setEnabled( false )
            end
            leagueName:setText( CountryConfig.getCountryName( i ).." - "..LeagueConfig.getLeagueName( leagueId ) )
            logo:loadTexture( CountryConfig.getLogo( i ) )
            if selectedIndi ~= nil then
                selectedIndi:setEnabled( false )
            end

            contentHeight = contentHeight + content:getSize().height

            if mLeagueInitCallback ~= nil then
                mLeagueInitCallback( content, LeagueConfig.getConfigId( leagueId ) )
            end

            mChildIndex = mChildIndex + 1
        end
    end

    mLeagueListContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( mLeagueListContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end

function selectOnLeague( selectedLeague )
    for i = 1, mChildIndex - 1  do
        local child = mLeagueListContainer:getChildByTag( i )
        if child == selectedLeague then
            local selectedIndi = child:getChildByName("selectedIndi")
            if selectedIndi ~= nil then
                selectedIndi:setEnabled( true )
            end
        else
            local selectedIndi = child:getChildByName("selectedIndi")
            if selectedIndi ~= nil then
                selectedIndi:setEnabled( false )
            end
        end
    end
end

function addPopularLeague()
    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            selectOnLeague( sender )
            mLeagueSelectCallback( Constants.MOST_POPULAR_LEAGUE_ID, sender )
        end
    end

    local content = SceneManager.widgetFromJsonFile( mCountryWidget );
    mLeagueListContainer:addChild( content, 0, mChildIndex );
    content:addTouchEventListener( eventHandler )

    local logo = tolua.cast( content:getChildByName("countryLogo"), "ImageView" )
    local leagueName = tolua.cast( content:getChildByName("countryName"), "Label" )
    local expendedIndicator = content:getChildByName( "expendIndi" )
    local selectedIndi = content:getChildByName("selectedIndi")

    if expendedIndicator ~= nil then
        expendedIndicator:setEnabled( false )
    end
    leagueName:setText( "Most Popular" )
    logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."favorite.png" )
    if selectedIndi ~= nil then
        selectedIndi:setEnabled( false )
    end

    if mLeagueInitCallback ~= nil then
        mLeagueInitCallback( content, Constants.MOST_POPULAR_LEAGUE_ID )
    end

    mChildIndex = mChildIndex + 1

    return content:getSize().height
end
