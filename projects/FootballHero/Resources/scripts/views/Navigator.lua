module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local CommunityConfig = require("scripts.config.Community")
local FileUtils = require("scripts.FileUtils")
local Json = require("json")

local mWidget
local mLastSelectedId = 0
local NAV_BT_NUM = 5

local TAB_EVENT_LIST = {
	{ Event.Enter_Match_List, nil },
	{ Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_COMPETITION } },
	{ Event.Enter_History, nil },
	-- { Event.Enter_Spin_the_Wheel, nil },
	{ Event.Enter_GameCenter, nil },
	{ Event.Enter_League_Chat_List, nil },
}


function loadFrame( parent )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/Navigator.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    parent:addChild( widget )

    for i = 1, NAV_BT_NUM do
    	local navBt = widget:getChildByName("nav"..i)
    	navBt:addTouchEventListener( navEventHandler )
    end

    if mLastSelectedId == 0 then
    	mLastSelectedId = 1
    end
    chooseNav( mLastSelectedId )

    local serverContextText = FileUtils.readStringFromFile( Constants.SERVER_FILE )
    local serverContext = Json.decode( serverContextText )
    if not serverContext.useDev then
    	local devText = mWidget:getChildByName( "Label_DevMode" )
    	devText:setEnabled( false )
    end
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function navEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		local navIndex = 1
		for i = 1, NAV_BT_NUM do
			if sender == mWidget:getChildByName("nav"..i) then
				navIndex = i
			end
		end

		chooseNav( navIndex, true )
	end
end

function chooseNav( index, postMessage )
	mLastSelectedId = index
	postMessage = postMessage or false
	for i = 1, NAV_BT_NUM do
		local navBt = mWidget:getChildByName("nav"..i)
		if i == index then
			navBt:setFocused( true )
		else
			navBt:setFocused( false )
		end
	end

	if postMessage then
		EventManager:postEvent( TAB_EVENT_LIST[index][1], TAB_EVENT_LIST[index][2] )
	end
end