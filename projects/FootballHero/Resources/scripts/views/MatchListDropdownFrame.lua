module(..., package.seeall)

local Constants = require("scripts.Constants")
local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")
local SceneManager = require("scripts.SceneManager")


local mCountryWidget
local mLeagueWidget
local mCountryListContainer
local mLeagueListContainer
local mLeagueSelectCallback

local mChildIndex

local mbIsHidden = true

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

    mCountryListContainer:removeAllChildrenWithCleanup( true )
    
    -- Add "Special" tab
    contentHeight = contentHeight + addSpecial()

    -- Add the "Shown by Default" countries
    local shownCountries = CountryConfig.getShownCountries()
    for index, country in pairs ( shownCountries ) do
        contentHeight = contentHeight + addCountry( index, country )
    end
    
    contentHeight = contentHeight + addMoreRegion()

    if not mbIsHidden then
        mHiddenCountries = CountryConfig.getHiddenCountries()
        for index, country in pairs ( mHiddenCountries ) do
            contentHeight = contentHeight + addCountry( index, country )
        end
    end

    mCountryListContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( mCountryListContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end

function addCountry( i, country )
    if CountryConfig.getLeagueList( i ) == nil then
        return 0
    end

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

    mChildIndex = mChildIndex + 1

    return content:getSize().height
end

function initLeagueList( leagueKey )
    
    local contentHeight = 0
    local content
    mChildIndex = 1

    mLeagueListContainer:removeAllChildrenWithCleanup( true )

    if Constants.IsSpecialLeague( leagueKey ) then
        for i = 1, Constants.SpecialLeagueIds.SPECIAL_COUNT do
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    mLeagueSelectCallback( -i, sender )
                end
            end

            content = SceneManager.widgetFromJsonFile( mLeagueWidget )
            mLeagueListContainer:addChild( content, 0, mChildIndex )
            content:addTouchEventListener( eventHandler )

            local leagueName = tolua.cast( content:getChildByName("Label_LeagueName"), "Label" )
            
            if -i == Constants.SpecialLeagueIds.MOST_POPULAR then
                leagueName:setText( Constants.String.match_list.most_popular )
            elseif -i == Constants.SpecialLeagueIds.UPCOMING_MATCHES then
                leagueName:setText( Constants.String.match_list.upcoming_matches )
            elseif -i == Constants.SpecialLeagueIds.MOST_DISCUSSED then
                leagueName:setText( Constants.String.match_list.most_discussed )
            end
        end
    else
        local leagueId = LeagueConfig.getConfigIdByKey( leagueKey )
        local countryId = CountryConfig.getConfigIdByKey( LeagueConfig.getCountryId( leagueId ) )
        
        local leagueList = CountryConfig.getLeagueList( countryId )
        local leagueNum = table.getn( leagueList )
        for j = 1, leagueNum do
            local leagueId = leagueList[j]
            if not LeagueConfig.isHidden( leagueId ) then

                local eventHandler = function( sender, eventType )
                    if eventType == TOUCH_EVENT_ENDED then
                        mLeagueSelectCallback( LeagueConfig.getConfigId( leagueId ), sender )
                    end
                end
                
                content = SceneManager.widgetFromJsonFile( mLeagueWidget )
                mLeagueListContainer:addChild( content, 0, mChildIndex )
                content:addTouchEventListener( eventHandler )

                local leagueName = tolua.cast( content:getChildByName("Label_LeagueName"), "Label" )
                leagueName:setText( LeagueConfig.getLeagueName( leagueId ) )
            end
        end
    end

    contentHeight = contentHeight + content:getSize().height
    mChildIndex = mChildIndex + 1

    mLeagueListContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( mLeagueListContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end

function addSpecial()
    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            mLeagueSelectCallback( Constants.SpecialLeagueIds.MOST_POPULAR, sender )
        end
    end

    local content = SceneManager.widgetFromJsonFile( mCountryWidget );
    mCountryListContainer:addChild( content, 0, mChildIndex );
    content:addTouchEventListener( eventHandler )

    local logo = tolua.cast( content:getChildByName("Image_CountryLogo"), "ImageView" )
    local countryName = tolua.cast( content:getChildByName("Label_CountryName"), "Label" )
    
    countryName:setText( Constants.String.match_list.special )
    logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."favorite.png" )
    
    mChildIndex = mChildIndex + 1

    return content:getSize().height
end

function addMoreRegion()
    local content = SceneManager.widgetFromJsonFile( mCountryWidget );
    mCountryListContainer:addChild( content, 0, mChildIndex );
    content:addTouchEventListener( toggleRegions )

    local logo = tolua.cast( content:getChildByName("Image_CountryLogo"), "ImageView" )
    local label = tolua.cast( content:getChildByName("Label_CountryName"), "Label" )
    
    if mbIsHidden then
        label:setText( Constants.String.match_list.more_regions )
        logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."more-region.png" )
    else
        label:setText( Constants.String.match_list.less_regions )
        logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."less-region.png" )
    end
    
    mChildIndex = mChildIndex + 1

    return content:getSize().height
end

function toggleRegions( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local label = tolua.cast( sender:getChildByName("Label_CountryName"), "Label" )
        local logo = tolua.cast( sender:getChildByName("Image_CountryLogo"), "ImageView" )

        if label:getStringValue() == Constants.String.match_list.more_regions then
            label:setText( Constants.String.match_list.less_regions )
            logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."less-region.png" )
            -- show default regions
            mbIsHidden = false
        else
            label:setText( Constants.String.match_list.more_regions )
            logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."more-region.png" )
            -- hide non-default regions
            mbIsHidden = true
        end
        initCountryList()
    end
end
