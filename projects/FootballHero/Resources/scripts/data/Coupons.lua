module(..., package.seeall)

Coupons = {}

--[[
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

function Coupons:addCoupon( id, message, shareOnFacebook )
    local idList = {}
    table.insert( idList, id )

    local coupon = {
        OutcomeIds = idList,
        Stake = 1000,
        Message = message,
        ShareOnFacebook = shareOnFacebook
    }

    table.insert( self.CouponForms, coupon )
end

function Coupons:getSize()
    return table.getn( self.CouponForms )
end