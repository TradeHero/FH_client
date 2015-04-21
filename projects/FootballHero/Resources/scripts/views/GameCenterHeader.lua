module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame( parent, titleText, bHasBackBtn )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/GameCenterHeader.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    parent:addChild( widget )

	local title = tolua.cast( widget:getChildByName("Label_Title"), "Label" )
    if titleText ~= nil then
        title:setText( titleText )
        local titleImg = tolua.cast( widget:getChildByName("Image_Title"), "ImageView" )
        titleImg:setEnabled( false )
    else
        title:setEnabled( false )
    end

	local btnBalance = tolua.cast( widget:getChildByName("Button_Balance"), "Button" )
    btnBalance:addTouchEventListener( balanceEventHandler )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function balanceEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		EventManager:postEvent( Event.Enter_Spin_balance )
	end
end

