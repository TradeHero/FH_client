module(..., package.seeall)

local Json = require("json")

Coupons = {}

--[[
Data need to be sent to server:

{
  "CouponForms":
  [
    {
      "OutcomeIds" : [2435033],
      "Stake" : 1000,
      "Message" : "My first bet",
      "ShareOnFacebook" : false
    }
  ]  
}

Whole Data :

{
  "CouponForms":
  [
    {
      "OutcomeIds" : [2435033],
      "Stake" : 1000,
      "Message" : "My first bet",
      "ShareOnFacebook" : false
      "Answer" : "Arsenal to win.", 
      "Reward": 4000, 
      "AnswerIcon": "XXXX.png"
    }
  ]  
}
--]]

function Coupons:new()
	local obj = {
		CouponForms = {}
	}

	setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "Coupons--"..k .. "__newindex not exist") end
    
    return obj 
end

function Coupons:addCoupon( id, message, shareOnFacebook, answer, reward, answerIcon )
    local idList = {}
    table.insert( idList, id )

    local coupon = {
        OutcomeIds = idList,
        Stake = 1000,
        Message = message,
        ShareOnFacebook = shareOnFacebook,
        Answer = answer,
        Reward = reward,
        AnswerIcon = answerIcon
    }

    table.insert( self.CouponForms, coupon )
end

function Coupons:getSize()
    return table.getn( self.CouponForms )
end

function Coupons:get( index )
    return self.CouponForms[index]
end

function Coupons:toString()
    local form = {}
    for i, v in ipairs( self.CouponForms ) do
        local coupon = {
            OutcomeIds = v["OutcomeIds"],
            Stake = v["Stake"],
            Message = v["message"],
            ShareOnFacebook = v["shareOnFacebook"]
        }

        table.insert( form, coupon )
    end

    return "{\"CouponForms\":"..Json.encode( form ).."}"
end