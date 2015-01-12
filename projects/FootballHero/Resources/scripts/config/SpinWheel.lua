module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")


Prizes = {
	{ ["id"] = 1, ["prizeID"] = 1, ["text"] = "+3000\nPOINTS", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-point.png" },
	
	{ ["id"] = 2, ["prizeID"] = 4, ["text"] = "Amazon\nGift Card\nUS$ 1.00", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-cash.png" },

	{ ["id"] = 3, ["prizeID"] = 1, ["text"] = "+3000\nPOINTS", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-point.png" },

	{ ["id"] = 4, ["prizeID"] = 8, ["text"] = "Lucky Draw\nMessi\nSigned Jersey", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-messi.png", ["fontSizeOffset"] = -3 },

	{ ["id"] = 5, ["prizeID"] = 5, ["text"] = "Amazon\nGift Card\nUS$ 2.00", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-cash.png" },

	{ ["id"] = 6, ["prizeID"] = 1, ["text"] = "+3000\nPOINTS", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-point.png" },

	{ ["id"] = 7, ["prizeID"] = 7, ["text"] = "Xiaomi\nPhone", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-xiaomi.png" },

	{ ["id"] = 8, ["prizeID"] = 6, ["text"] = "Amazon\nGift Card\nUS$ 5.00", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-cash.png" },

	{ ["id"] = 9, ["prizeID"] = 1, ["text"] = "+3000\nPOINTS", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-point.png" },

	{ ["id"] = 10, ["prizeID"] = 9, ["text"] = "Ronaldo\nSigned Jersey", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-ronaldo.png" },

	{ ["id"] = 11, ["prizeID"] = 2, ["text"] = "+8000\nPOINTS", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-point.png" },

	{ ["id"] = 12, ["prizeID"] = 1, ["text"] = "+3000\nPOINTS", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-point.png" },

	{ ["id"] = 13, ["prizeID"] = 3, ["text"] = "+12000\nPOINTS", ["image"] = Constants.SPINWHEEL_IMAGE_PATH.."img-point.png" },
}

function getStopAngleByPrizeID( prizeID )
	local prizesWithThisID = {}
	for i = 1, table.getn( Prizes ) do
		local prize = Prizes[i]
		if prize["prizeID"] == prizeID then
			table.insert( prizesWithThisID, prize )
		end
	end

	local selectedPrize
	if table.getn( prizesWithThisID ) > 1 then
		local randomIndex = math.random( table.getn( prizesWithThisID ) )
		selectedPrize = prizesWithThisID[randomIndex]
	else
		selectedPrize = prizesWithThisID[1]
	end

	local range = 360 / 13
	local borderWidth = 2

	return ( selectedPrize["id"] - 1 ) * range + borderWidth + math.random( range - borderWidth * 2 )
end