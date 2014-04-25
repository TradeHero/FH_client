module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")

local mWidget
local NAV_BT_NUM = 4

function loadFrame( parent )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/Navigator.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    parent:addChild( widget )

    for i = 1, NAV_BT_NUM do
    	local navBt = widget:getChildByName("nav"..i)
    	navBt:addTouchEventListener( navEventHandler )
    end

    chooseNav( 1 )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function navEventHandler( sender, eventType )
	local navIndex = 1
	for i = 1, NAV_BT_NUM do
		if sender == mWidget:getChildByName("nav"..i) then
			navIndex = i
		end
	end

	chooseNav( navIndex )
end

function chooseNav( index )
	for i = 1, NAV_BT_NUM do
		local navBt = mWidget:getChildByName("nav"..i)
		if i == index then
			navBt:setFocused( true )
		else
			navBt:setFocused( false )
		end
	end
end