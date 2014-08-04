module(..., package.seeall)

Prediction = {}

--[[
oddId, answer, rewards, selected:getTextureFile()

{
    "OddId": 1010,
    "Answer": "Answer",
    "Rewards": 100,
    "AnswerImagePath": "path"
}

--]]

function Prediction:new( oddId, answer, rewards, answerImagePath )
	local obj = {
		OddId = oddId,
        Answer = answer,
        Rewards = rewards,
        AnswerImagePath = answerImagePath
	}

	setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "Prediction--"..k .. "__newindex not exist") end
    
    return obj 
end