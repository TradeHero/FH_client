module(..., package.seeall)

local mErrors = {}
mErrors["GENERAL_1"] = { ["Exceptional"] = true }
mErrors["GENERAL_2"] = { ["Exceptional"] = true }

mErrors["SIGNIN_1"] = { ["Exceptional"] = false }
mErrors["SIGNIN_2"] = { ["Exceptional"] = false }
mErrors["SIGNIN_3"] = { ["Exceptional"] = false }
mErrors["SIGNIN_4"] = { ["Exceptional"] = false }

mErrors["VERSION_1"] = { ["Exceptional"] = true }
mErrors["VERSION_2"] = { ["Exceptional"] = false }

mErrors["FACEBOOK_1"] = { ["Exceptional"] = false }
mErrors["FACEBOOK_2"] = { ["Exceptional"] = false }
mErrors["FACEBOOK_3"] = { ["Exceptional"] = true }
mErrors["FACEBOOK_4"] = { ["Exceptional"] = true }
mErrors["FACEBOOK_5"] = { ["Exceptional"] = false }

mErrors["COUPON_1"] = { ["Exceptional"] = true }
mErrors["COUPON_2"] = { ["Exceptional"] = true }
mErrors["COUPON_3"] = { ["Exceptional"] = true }
mErrors["COUPON_4"] = { ["Exceptional"] = true }
mErrors["COUPON_5"] = { ["Exceptional"] = true }

mErrors["LEADERBOARD_1"] = { ["Exceptional"] = true }
mErrors["LEADERBOARD_2"] = { ["Exceptional"] = true }

mErrors["LEAGUE_1"] = { ["Exceptional"] = true }

mErrors["COUNTRY_1"] = { ["Exceptional"] = true }

mErrors["COMPETITION_1"] = { ["Exceptional"] = false }
mErrors["COMPETITION_2"] = { ["Exceptional"] = true }
mErrors["COMPETITION_3"] = { ["Exceptional"] = false }
mErrors["COMPETITION_4"] = { ["Exceptional"] = false }
mErrors["COMPETITION_5"] = { ["Exceptional"] = true }
mErrors["COMPETITION_6"] = { ["Exceptional"] = true }
mErrors["COMPETITION_7"] = { ["Exceptional"] = true }
mErrors["COMPETITION_8"] = { ["Exceptional"] = true }

mErrors["DISCUSSION_1"] = { ["Exceptional"] = true }
mErrors["DISCUSSION_2"] = { ["Exceptional"] = true }
mErrors["DISCUSSION_3"] = { ["Exceptional"] = true }

mErrors["WHEEL_1"] = { ["Exceptional"] = true }
mErrors["WHEEL_2"] = { ["Exceptional"] = true }
mErrors["WHEEL_3"] = { ["Exceptional"] = true }
mErrors["WHEEL_4"] = { ["Exceptional"] = true }
mErrors["WHEEL_5"] = { ["Exceptional"] = true }
mErrors["WHEEL_6"] = { ["Exceptional"] = true }

function isExceptionalErrorByCode( code )
	if mErrors[code] then
		return mErrors[code]["Exceptional"]
	end
	return false
end