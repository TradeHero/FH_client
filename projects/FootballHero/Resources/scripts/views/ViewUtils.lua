module(..., package.seeall)

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