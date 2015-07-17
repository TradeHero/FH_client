module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Header = require("scripts.views.HeaderFrame")
local SportsConfig = require("scripts.config.Sports")


local mWidget
local mSportChangeEventHandler

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SideMenu.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addSideMenuWidget( widget )

    initScene( widget )
    updateSelectedSport()
end

function setSportChangeEventHanlder( handler )
	mSportChangeEventHandler = handler
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function initScene()
	local sportsScrollView = tolua.cast( mWidget:getChildByName( "ScrollView_Sports" ), "ScrollView" )
	sportsScrollView:removeAllChildrenWithCleanup( true )
	local allSports = SportsConfig.getAllSports()

	for i = 1, table.getn( allSports ) do
		local sport = allSports[i]
		local sportPanel = SceneManager.widgetFromJsonFile("scenes/SideMenuContent.json")

		local icon = tolua.cast( sportPanel:getChildByName("Image_icon"), "ImageView" )
		local name = tolua.cast( sportPanel:getChildByName("Label_name"), "Label" )

		sportPanel:setName( sport["key"] )
		icon:loadTexture( SportsConfig.getSportLogoPathByIndex( i ) )
		name:setText( Constants.String.sports[sport["key"]] )

		sportPanel:addTouchEventListener( function ( sender, eventType )
		    if eventType == TOUCH_EVENT_ENDED then
		        switchToSport( sport["key"] )
		    end
		end )

		sportsScrollView:addChild( sportPanel )
	end

    local layout = tolua.cast( sportsScrollView, "Layout" )
    layout:requestDoLayout()
end

function updateSelectedSport()
	local allSports = SportsConfig.getAllSports()
	local selectedSportKey = SportsConfig.getCurrentSportKey()
	local sportsScrollView = tolua.cast( mWidget:getChildByName( "ScrollView_Sports" ), "ScrollView" )

	for i = 1, table.getn( allSports ) do
		local sport = allSports[i]
		local sportPanel = tolua.cast( sportsScrollView:getChildByName( sport["key"] ), "Layout" )
		if sport["key"] == selectedSportKey then
			sportPanel:setBackGroundColorOpacity( 255 )
		else
			sportPanel:setBackGroundColorOpacity( 0 )
		end
	end
end

function switchToSport( sportKey )
	SceneManager.closeSideMenu()
	if SportsConfig.getCurrentSportKey() == sportKey then
		return
	end

	SportsConfig.setCurrentSportByKey( sportKey )
	if mSportChangeEventHandler then
		mSportChangeEventHandler()
		mSportChangeEventHandler = nil
	end
end