module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
-- local EventManager = require("scripts.events.EventManager").getInstance()
-- local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
-- local RequestUtils = require("scripts.RequestUtils")

local mWidget
local gameContent = {}

function loadFrame( parent, jsonResponse )
    -- local gameInfo =  jsonResponse["TeamGameDtos"]
    -- local expertInfo =  jsonResponse["ExpertDtos"]
    local info = {}
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityTimelineFrame.json")
    parent:addChild( mWidget )
    mWidget:registerScriptHandler( EnterOrExit )

    initContent( info )
end

function exitFrame()
    mWidget = nil
end

function isShown()
    return mWidget ~= nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end


function initContent( info )
    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    for i = 1, 10 do
        local content = SceneManager.widgetFromJsonFile("scenes/CommunityTimelineContent.json")
        local panel = tolua.cast( content:getChildByName("Panel_Content"), "Layout" )

        local imageProfile = tolua.cast( panel:getChildByName("Image_Profile"), "ImageView" )
        local labelName = tolua.cast( panel:getChildByName("Label_Name"), "Label" )
        local labelTime = tolua.cast( panel:getChildByName("Label_Time"), "Label" )
        local labelMsg = tolua.cast( panel:getChildByName("Label_Msg"), "Label" )
        local imagePic = tolua.cast( panel:getChildByName("Image_Pic"), "ImageView" )

        local profileUrl = nil

        labelName:setText( "Name" .. i)
        labelTime:setText( i .. " Month ago")
        labelMsg:setText( "Test 123123123 1231231231123 132123123123 12312313")

        local seqArray = CCArray:create()
        seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
        seqArray:addObject( CCCallFuncN:create( function()
            if type( profileUrl ) ~= "userdata" and profileUrl ~= nil then
                local handler = function( filePath )
                    if filePath ~= nil and mWidget ~= nil and imageProfile ~= nil then
                        local safeLoadTexture = function()
                            imageProfile:loadTexture( filePath )
                        end
                        xpcall( safeLoadTexture, function ( msg )  end )
                    end
                end
                SMIS.getSMImagePath( profileUrl, handler )
            end
        end ) )
        mWidget:runAction( CCSequence:create( seqArray ) )


        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        gameContent[i] = content
        contentHeight = contentHeight + content:getSize().height
    end
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end
