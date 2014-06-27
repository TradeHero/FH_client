module(..., package.seeall)

local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")
local SceneManager = require("scripts.SceneManager")

local mCountryNum = CountryConfig.getConfigNum()
local mCountryExpended = {}

local COUNTRY_CONTENT_HEIGHT = 140
local LEAGUE_CONTENT_HEIGHT = 60

local mCountryWidget
local mLeagueWidget
local mLeagueListContainer
local mLeagueSelectCallback
local mLeagueInitCallback

function loadFrame( countryWidget, leagueWidget, leagueListContainer, leagueSelectCallback, leagueInitCallback )
	mCountryWidget = countryWidget
	mLeagueWidget = leagueWidget
	mLeagueListContainer = leagueListContainer
	mLeagueSelectCallback = leagueSelectCallback
    mLeagueInitCallback = leagueInitCallback

    local content = SceneManager.widgetFromJsonFile( mCountryWidget )
    COUNTRY_CONTENT_HEIGHT = content:getSize().height
    content = SceneManager.widgetFromJsonFile( mLeagueWidget )
    LEAGUE_CONTENT_HEIGHT = content:getSize().height

	helperInitLeagueList()
end

function expendAll()
    for i = 1, mCountryNum do
        mCountryExpended[i] = true
        helperUpdateLeagueList( i )
    end
end

function unexpendAll()
    for i = 1, mCountryNum do
        mCountryExpended[i] = false
        helperUpdateLeagueList( i )
    end
end

function helperInitLeagueList()
    local contentHeight = 0

    for i = 1, mCountryNum do
        mCountryExpended[i] = false
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                -- Handler
                if mCountryExpended[i] == true then
                    mCountryExpended[i] = false
                else
                    mCountryExpended[i] = true
                end
                helperUpdateLeagueList( i )
            end
        end

        local content = SceneManager.widgetFromJsonFile( mCountryWidget )
        local countryName = tolua.cast( content:getChildByName("countryName"), "Label" )
        if countryName ~= nil then
        	countryName:setText( CountryConfig.getCountryName( i ) )
       	end

        content:addTouchEventListener( eventHandler )
        content:setPosition( ccp( 0, ( i - 1 ) * COUNTRY_CONTENT_HEIGHT ) )
        mLeagueListContainer:addChild( content )
        content:setName( "country"..i )
        local logo = tolua.cast( content:getChildByName("countryLogo"), "ImageView" )
        logo:loadTexture( CountryConfig.getLogo( i ) )
        contentHeight = contentHeight + content:getSize().height
        mLeagueListContainer:jumpToPercentVertical( 1 )
    end

    local scrollViewHeight = mLeagueListContainer:getSize().height
    if contentHeight < scrollViewHeight then
        local offset = scrollViewHeight - contentHeight

        for i = 1, mCountryNum do
            local countryLogo = mLeagueListContainer:getChildByName( "country"..i )
            countryLogo:setPosition( ccp( countryLogo:getPositionX() , countryLogo:getPositionY() + offset ) )
        end
    else
        mLeagueListContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )    
    end

    local layout = tolua.cast( mLeagueListContainer, "Layout" )
    layout:requestDoLayout()
end

function helperUpdateLeagueList( clickedCountryId )
	print( "helperUpdateLeagueList "..clickedCountryId )

    local leagueNum = table.getn( CountryConfig.getLeagueList( clickedCountryId ) ) 

    -- Calculate the move offset
    local moveOffsetX = 0
    if mCountryExpended[clickedCountryId] == true then
        moveOffsetX = leagueNum * LEAGUE_CONTENT_HEIGHT
    else
        moveOffsetX = leagueNum * (-LEAGUE_CONTENT_HEIGHT)
    end

    -- Move upper country and league logo's position    
    for i = clickedCountryId, mCountryNum do
        local countryLogo = mLeagueListContainer:getChildByName( "country"..i )
        countryLogo:setPosition( ccp( countryLogo:getPositionX() , countryLogo:getPositionY() + moveOffsetX ) )
        local otherCountryLeagueNum = table.getn( CountryConfig.getLeagueList( i ) ) 
        for j = 1, otherCountryLeagueNum do
            local leagueLogo = mLeagueListContainer:getChildByName( "country"..i.."_league"..j )
            if leagueLogo ~= nil then
                leagueLogo:setPosition( ccp( leagueLogo:getPositionX() , leagueLogo:getPositionY() + moveOffsetX ) )
            end
        end
    end

    -- Add or remove league logos according to the status
    if mCountryExpended[clickedCountryId] == true then
        for i = 1, leagueNum do
            local leagueId = CountryConfig.getLeagueList( clickedCountryId )[i]

            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    mLeagueSelectCallback( LeagueConfig.getConfigId( leagueId ), sender )
                end
            end

            local content = SceneManager.widgetFromJsonFile( mLeagueWidget )
            local parent = mLeagueListContainer:getChildByName( "country"..clickedCountryId )
            content:setPosition( ccp( 0, parent:getPositionY() - ( leagueNum - i + 1 ) * LEAGUE_CONTENT_HEIGHT ) )
            mLeagueListContainer:addChild( content )
            content:setName( "country"..clickedCountryId.."_league"..i )
            content:addTouchEventListener( eventHandler )
            local leagueName = tolua.cast( content:getChildByName("leagueName"), "Label" )
            leagueName:setText( LeagueConfig.getLeagueName( leagueId ) )
            
            if mLeagueInitCallback ~= nil then
                mLeagueInitCallback( content, LeagueConfig.getConfigId( leagueId ) )
            end
        end
    else
        for i = 1, leagueNum do
            local leagueLogo = mLeagueListContainer:getChildByName( "country"..clickedCountryId.."_league"..i )
            mLeagueListContainer:removeChild( leagueLogo )
        end
    end 
    
    -- Update the max container size.
    local originHeight = mLeagueListContainer:getInnerContainerSize().height
    mLeagueListContainer:setInnerContainerSize( CCSize:new( 0, originHeight + moveOffsetX ) )
    local layout = tolua.cast( mLeagueListContainer, "Layout" )
    layout:requestDoLayout()
end