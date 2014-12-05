module(..., package.seeall)

local Constants = require("scripts.Constants")
local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")
local SceneManager = require("scripts.SceneManager")

local mCountryNum = CountryConfig.getConfigNum()

local mCountryWidget
local mContainer
local mFilterCallback

local mChildIndex

function loadFrame( container, filterCallback )
	mCountryWidget = "scenes/CountryDropdownContent.json"
	mContainer = container
	mFilterCallback = filterCallback

	initCountryList()
end

function initCountryList()
    local contentHeight = 0

    contentHeight = contentHeight + addSpecial()

    for i = 1, mCountryNum do
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                mFilterCallback( i, sender )
            end
        end

        local content = SceneManager.widgetFromJsonFile( mCountryWidget )
        mContainer:addChild( content )
        content:addTouchEventListener( eventHandler )

        local logo = tolua.cast( content:getChildByName("Image_CountryLogo"), "ImageView" )
        local countryName = tolua.cast( content:getChildByName("Label_CountryName"), "Label" )

        countryName:setText( CountryConfig.getCountryName( i ) )
        logo:loadTexture( CountryConfig.getLogo( i ) )

        contentHeight = contentHeight + content:getSize().height
    end

    mContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( mContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end

function addSpecial()
    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            mFilterCallback( Constants.STATS_SHOW_ALL, sender )
        end
    end

    local content = SceneManager.widgetFromJsonFile( mCountryWidget );
    mContainer:addChild( content );
    content:addTouchEventListener( eventHandler )

    local logo = tolua.cast( content:getChildByName("Image_CountryLogo"), "ImageView" )
    local countryName = tolua.cast( content:getChildByName("Label_CountryName"), "Label" )
    
    countryName:setText( Constants.String.history.show_all )
    logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."favorite.png" )

    return content:getSize().height
end
