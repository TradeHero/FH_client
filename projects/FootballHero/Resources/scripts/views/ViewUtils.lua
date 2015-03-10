module(..., package.seeall)

local Constants = require("scripts.Constants")

local inputWidth = 400
local inputHeight = 50
local FONT_NAME = "Newgtbxc"
local FONT_SIZE = 30

function createTextInput( container, placeholderText, width, height, fontName, fontSize )
	width = width or inputWidth
	height = height or inputHeight
	fontName = fontName or FONT_NAME
	fontSize = fontSize or FONT_SIZE

    local textInput = CCEditBox:create( CCSizeMake( width, height ), CCScale9Sprite:create() )
    container:addNode( textInput, 0, 1 )
    textInput:setPosition( width / 2, height / 2 )
    textInput:setFont(fontName, fontSize)
    textInput:setPlaceHolder( placeholderText )

    return textInput
end

function getYesNoText( line, homeTeam, awayTeam )
    local bHomeFav = line <= 0
    local absLine = math.abs( line )
    
    if absLine < 2 then
        local keyLine = string.gsub( absLine, "%.", "_" )
        local keyYes = "h"..keyLine.."_yes"
        local keyNo = "h"..keyLine.."_no"
        local textYes
        local textNo
        if bHomeFav then
            textYes = string.format( Constants.String.handicap[keyYes], homeTeam, homeTeam )
            textNo = string.format( Constants.String.handicap[keyNo], awayTeam, awayTeam )
        else
            textYes = string.format( Constants.String.handicap[keyYes], awayTeam, awayTeam )
            textNo = string.format( Constants.String.handicap[keyNo], homeTeam, homeTeam )
        end
        return textYes, textNo
    else
        local keyLine
        if string.find( absLine, "%." ) then
            keyLine = string.gsub( absLine, "%d+%.", "X_" )
        else
            keyLine = "X"
        end
        local keyYes = "h"..keyLine.."_yes"
        local keyNo = "h"..keyLine.."_no"
        local textYes
        local textNo
        if bHomeFav then
            textYes = string.gsub( Constants.String.handicap[keyYes], "%%TeamName%%", homeTeam )
            textNo = string.gsub( Constants.String.handicap[keyNo], "%%TeamName%%", awayTeam )
        else
            textYes = string.gsub( Constants.String.handicap[keyYes], "%%TeamName%%", awayTeam )
            textNo = string.gsub( Constants.String.handicap[keyNo], "%%TeamName%%", homeTeam )
        end
        
        textYes = string.gsub( textYes, "%%Line%%", math.floor( absLine ) )
        textYes = string.gsub( textYes, "%%LinePulsOne%%", math.floor( absLine ) + 1 )
        textYes = string.gsub( textYes, "%%LineMinusOne%%", math.floor( absLine ) - 1 )
        textYes = string.gsub( textYes, "%%LinePulsTwo%%", math.floor( absLine ) + 2 )
        
        textNo = string.gsub( textNo, "%%Line%%", math.floor( absLine ) )
        textNo = string.gsub( textNo, "%%LinePulsOne%%", math.floor( absLine ) + 1 )
        textNo = string.gsub( textNo, "%%LineMinusOne%%", math.floor( absLine ) - 1 )
        textNo = string.gsub( textNo, "%%LinePulsTwo%%", math.floor( absLine ) + 2 )

        return textYes, textNo
    end
end