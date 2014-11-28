module(..., package.seeall)

local Constants = require("scripts.Constants")
local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")
local SceneManager = require("scripts.SceneManager")

local mCountryNum = CountryConfig.getConfigNum()

local mCountryWidget
local mLeagueWidget
local mCountryListContainer
local mLeagueListContainer
local mLeagueSelectCallback

local mChildIndex

function loadFrame( leagueKey, countryWidget, leagueWidget, countryListContainer, leagueListContainer, leagueSelectCallback )
	mCountryWidget = countryWidget
	mLeagueWidget = leagueWidget
    mCountryListContainer = countryListContainer
	mLeagueListContainer = leagueListContainer
	mLeagueSelectCallback = leagueSelectCallback

	initCountryList()
    initLeagueList( leagueKey )
end

function initCountryList()
    local contentHeight = 0
    mChildIndex = 1

    -- Add in the "Most Popular" league - top 25 upcoming games
    contentHeight = contentHeight + addPopular()

    for i = 1, mCountryNum do
        -- Assume there is at least 1 league and get it
        local leagueId = CountryConfig.getLeagueList( i )[1]

        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                mLeagueSelectCallback( LeagueConfig.getConfigId( leagueId ), sender )
            end
        end

        local content = SceneManager.widgetFromJsonFile( mCountryWidget )
        mCountryListContainer:addChild( content, 0, mChildIndex )
        content:addTouchEventListener( eventHandler )

        local logo = tolua.cast( content:getChildByName("Image_CountryLogo"), "ImageView" )
        local countryName = tolua.cast( content:getChildByName("Label_CountryName"), "Label" )

        countryName:setText( CountryConfig.getCountryName( i ) )
        logo:loadTexture( CountryConfig.getLogo( i ) )

        contentHeight = contentHeight + content:getSize().height
        mChildIndex = mChildIndex + 1
    end

    mCountryListContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( mCountryListContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end

function initLeagueList( leagueKey )
    if leagueKey ~= Constants.MOST_POPULAR_LEAGUE_ID then
        local contentHeight = 0
        mChildIndex = 1

        mLeagueListContainer:removeAllChildrenWithCleanup( true )

        local leagueId = LeagueConfig.getConfigIdByKey( leagueKey )
        local countryId = CountryConfig.getConfigIdByKey( LeagueConfig.getCountryId( leagueId ) )
        
        local leagueNum = table.getn( CountryConfig.getLeagueList( countryId ) )
        for j = 1, leagueNum do
            local leagueId = CountryConfig.getLeagueList( countryId )[j]

            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    mLeagueSelectCallback( LeagueConfig.getConfigId( leagueId ), sender )
                end
            end

            local content = SceneManager.widgetFromJsonFile( mLeagueWidget )
            mLeagueListContainer:addChild( content, 0, mChildIndex )
            content:addTouchEventListener( eventHandler )

            local leagueName = tolua.cast( content:getChildByName("Label_LeagueName"), "Label" )
            leagueName:setText( LeagueConfig.getLeagueName( leagueId ) )
            
            contentHeight = contentHeight + content:getSize().height
            mChildIndex = mChildIndex + 1
        end

        mLeagueListContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
        local layout = tolua.cast( mLeagueListContainer, "Layout" )
        layout:requestDoLayout()
        layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
    end
end

function addPopular()
    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            mLeagueSelectCallback( Constants.MOST_POPULAR_LEAGUE_ID, sender )
        end
    end

    local content = SceneManager.widgetFromJsonFile( mCountryWidget );
    mCountryListContainer:addChild( content, 0, mChildIndex );
    content:addTouchEventListener( eventHandler )

    local logo = tolua.cast( content:getChildByName("Image_CountryLogo"), "ImageView" )
    local leagueName = tolua.cast( content:getChildByName("Label_CountryName"), "Label" )
    
    leagueName:setText( Constants.String.most_popular )
    logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."favorite.png" )
    
    mChildIndex = mChildIndex + 1

    return content:getSize().height
end
