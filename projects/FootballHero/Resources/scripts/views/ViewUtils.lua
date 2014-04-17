module(..., package.seeall)

local inputWidth = 400
local inputHeight = 50
local FONT_NAME = "Newgtbxc"
local FONT_SIZE = 30

function createTextInput( container, placeholderText )
    local textInput = CCEditBox:create( CCSizeMake( inputWidth, inputHeight ), CCScale9Sprite:create() )
    container:addNode( textInput, 0, 1 )
    textInput:setPosition( inputWidth / 2, inputHeight / 2 )
    textInput:setFont(FONT_NAME, FONT_SIZE)
    textInput:setPlaceHolder( placeholderText )

    return textInput
end