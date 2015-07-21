module(..., package.seeall)

local Constants = require("scripts.Constants")
local LeagueConfig = require("scripts.config.League")
local SportsConfig = require("scripts.config.Sports")
local SceneManager = require("scripts.SceneManager")
local StatsDropDownFilter = require("scripts.views.StatsDropDownFilter")


local mCountryWidget
local mContainer
local mFilterCallback
local mCurrentChoosedIndex = Constants.STATS_SHOW_ALL

function loadFrame( container, filterCallback )
	mCountryWidget = "scenes/SportsDropdownContent.json"
	mContainer = container
	mFilterCallback = filterCallback

	initCountryList()
end

function initCountryList()
    local contentHeight = 0
    mContainer:removeAllChildrenWithCleanup( true )

    contentHeight = contentHeight + addSpecial()

    local sports = SportsConfig.getAllSports()
    for i = 1, table.getn( sports ) do
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                mCurrentChoosedIndex = i
                StatsDropDownFilter.initCountryList()
                mFilterCallback( mCurrentChoosedIndex, sender )
            end
        end

        local content = SceneManager.widgetFromJsonFile( mCountryWidget )
        mContainer:addChild( content )
        content:addTouchEventListener( eventHandler )

        local logo = tolua.cast( content:getChildByName("Image_SportLogo"), "ImageView" )
        local countryName = tolua.cast( content:getChildByName("Label_SportName"), "Label" )

        countryName:setText( Constants.String.sports[sports[i]["key"]] )
        logo:loadTexture( SportsConfig.getSportLogoPathByIndex( i ) )

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
            mCurrentChoosedIndex = Constants.STATS_SHOW_ALL
            StatsDropDownFilter.initCountryList()
            mFilterCallback( mCurrentChoosedIndex, sender )
        end
    end

    local content = SceneManager.widgetFromJsonFile( mCountryWidget )
    mContainer:addChild( content );
    content:addTouchEventListener( eventHandler )

    local logo = tolua.cast( content:getChildByName("Image_SportLogo"), "ImageView" )
    local countryName = tolua.cast( content:getChildByName("Label_SportName"), "Label" )
    
    countryName:setText( Constants.String.history.show_all )
    logo:loadTexture( Constants.IMAGE_PATH.."icn-allsports.png" )

    return content:getSize().height
end

function getCurrentChoosedSportIndex()
    return mCurrentChoosedIndex
end