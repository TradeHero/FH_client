module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget
local mbHasWebView

function loadFrame( parent, titleText, bHasBackBtn, bHasWebView )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/HeaderFrame.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    parent:addChild( widget )

    mbHasWebView = bHasWebView

	local title = tolua.cast( widget:getChildByName("Label_Title"), "Label" )
    if titleText ~= nil then
		title:setText( titleText )

		local titleImg = tolua.cast( widget:getChildByName("Image_Title"), "ImageView" )
		titleImg:setEnabled( false )
    else
    	title:setEnabled( false )
    end
	
	local backBt = widget:getChildByName("Button_Back")
    if bHasBackBtn then
        SceneManager.setKeypadBackListener( keypadBackEventHandler )
    	backBt:addTouchEventListener( backEventHandler )
    else
        SceneManager.clearKeypadBackListener()
    	backBt:setEnabled( false )
    end

	local settingsBt = widget:getChildByName("Button_Settings")
    settingsBt:addTouchEventListener( settingsEventHandler )

end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function settingsEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		EventManager:postEvent( Event.Enter_Settings )
	end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    if mbHasWebView then
        WebviewDelegate:sharedDelegate():closeWebpage()
    end
    EventManager:popHistory()
end
