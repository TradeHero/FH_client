module(..., package.seeall)

Prediction = {}

--[[
oddId, answer, rewards, selected:getTextureFile()

{
    "OddId": 1010,
    "Answer": "Answer",
    "Rewards": 100,
    "AnswerImagePath": "path"
    "PredictionType": "AH"
}

--]]

function Prediction:new( oddId, answer, rewards, answerImagePath, type, stake )
	local obj = {
		OddId = oddId,
        Answer = answer,
        Rewards = rewards,
        AnswerImagePath = answerImagePath,
        PredictionType = type,
        Stake = stake
	}

	setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "Prediction--"..k .. "__newindex not exist") end
    
    return obj 
end