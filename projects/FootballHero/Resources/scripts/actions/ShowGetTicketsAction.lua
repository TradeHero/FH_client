module(..., package.seeall)

function action( param )
	local getTickets = require("scripts.views.GetTickets")
	local Constants = require("scripts.Constants")

	if getTickets.isShown() then
		-- Ignore or replace
	else
		getTickets.loadFrame()
	end
end