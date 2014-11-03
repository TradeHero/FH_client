module(..., package.seeall)

CouponHistoryData = {}

--[[
{
   "open":[
      {
         "GameId":642,
         "HomeTeamId":229,
         "AwayTeamId":244,
         "Result":null,
         "ROI":-1.0,
         "Profit":0.00,
         "WinPercentage":0.0,
         "GameCouponsDTOs":[
            {
               "MarketTypeId":1,
               "CouponId":992,
               "Line":null,
               "OutcomeSide":1,
               "Odd":2.12,
               "Stake":1000.00,
               "Won":false,
               "Profit":0.00
            },
            {
               "MarketTypeId":2,
               "CouponId":993,
               "Line":2.5,
               "OutcomeSide":2,
               "Odd":1.95,
               "Stake":1000.00,
               "Won":false,
               "Profit":0.00
            },
            {
               "MarketTypeId":3,
               "CouponId":994,
               "Line":-0.5,
               "OutcomeSide":1,
               "Odd":2.20,
               "Stake":1000.00,
               "Won":false,
               "Profit":0.00
            }
         ]
      }
   ],
   "closed":[

   ],
   "balance":1000,
   "stats": {
        "Id": 246,
        "DisplayName": "vincent",
        "NumberOfCoupons": 57,
        "NumberOfCouponsWon": 36,
        "NumberOfCouponsLost": 19,
        "WinPercentage": 65.45,
        "Roi": 235.69,
        "Profit": 129630,
        "WinStreakCouponsWon": 0,
        "WinStreakCouponsLost": 0,
        "PictureUrl": ""
    }
}
--]]

function CouponHistoryData:new( rawDataObj )
	local obj = {
		OpenCoupon = rawDataObj["open"],
    ClosedCoupon = rawDataObj["closed"],
    Balance = rawDataObj["balance"],
    Stats = rawDataObj["stats"]
	}

	setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "CouponHistoryData--"..k .. "__newindex not exist") end
    
    return obj 
end

function CouponHistoryData:getOpenData()
  return self.OpenCoupon
end

function CouponHistoryData:getClosedData()
  return self.ClosedCoupon
end

function CouponHistoryData:getBalance()
  return self.Balance
end

function CouponHistoryData:getStats()
  return self.Stats
end
