module(..., package.seeall)

function action( param )
	local registerNameScene = require("scripts.views.RegisterNameScene")
    registerNameScene.loadFrame()

    if param ~= nil then
    	local userName = param[1]
	    if userName ~= nil then
	    	print("Add user name:"..userName)
	    	registerNameScene.setUserName( userName )
	    end
    end
end