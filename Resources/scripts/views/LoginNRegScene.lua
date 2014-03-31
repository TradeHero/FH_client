module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local MatchListScene = require("scripts.MatchListScene")

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LoginNReg/LoginNReg.ExportJson")
    SceneManager.clearNAddWidget(widget)

    local loginBt = widget:getChildByName("login")
    local registerBt = widget:getChildByName("register")

    loginBt:addTouchEventListener( loginEventHandler )
    registerBt:addTouchEventListener( registerEventHandler )
end

function loginEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        MatchListScene.loadFrame()
    end
end

function registerEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        MatchListScene.loadFrame()
    end
end