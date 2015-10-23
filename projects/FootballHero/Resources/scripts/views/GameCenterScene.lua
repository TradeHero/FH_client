module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.GameCenterHeader")
local SMIS = require("scripts.SMIS")
local Logic = require("scripts.Logic").getInstance()

local mWidget
local mContentHeight

local ENTER_GAME_EVENT_LIST = {
    { Event.Enter_Spin_the_Wheel, nil },
    { Event.Enter_Lucky8, nil },
}

local GAMECENTER_TITLE_AND_DES = {
    { Constants.String.spinWheel.wheel_title, Constants.String.spinWheel.wheel_sub_des },
    { Constants.String.lucky8.lucky8_title, Constants.String.lucky8.lucky8_sub_des },
}

local GAME_IMAGE_PATH = {
    Constants.SPINWHEEL_IMAGE_PATH .. "img-stw.png",
    Constants.LUCKY8_IMAGE_PATH .. "img-lucky8.png",
}

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/GameCenterScene.json")
    mWidget = widget
 
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, Constants.String.lucky8.game_center_title, false )
    Navigator.loadFrame( widget )
    initCells( table.getn( ENTER_GAME_EVENT_LIST ) )
end

function initCells( cellNum )
    mContentHeight = 0
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    for i = 1, cellNum do
        local eventHandler = function ( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                enterGame( i )
            end
        end

        local content = SceneManager.widgetFromJsonFile( "scenes/GameCenterCell.json" )
        local panelFade = content:getChildByName( "Panel_Fade" )
        local gameImage = tolua.cast( panelFade:getChildByName("Image_Icon"), "ImageView" )
        gameImage:loadTexture( GAME_IMAGE_PATH[i] )
        CCLuaLog("image:" .. GAME_IMAGE_PATH[i])
        
        local gameTitle = tolua.cast( panelFade:getChildByName("TextField_Title"), "TextField" )
        gameTitle:setText( GAMECENTER_TITLE_AND_DES[i][1] )
        
        local gameDes = tolua.cast( panelFade:getChildByName("TextField_Content"), "TextField" )
        gameDes:setText( GAMECENTER_TITLE_AND_DES[i][2] )

        contentContainer:addChild( content )
        mContentHeight = mContentHeight + content:getSize().height
        content:addTouchEventListener( eventHandler )
        updateContentContainer( mContentHeight, content )
    end

    if not Logic:getBetBlock() then
        WebviewDelegate:sharedDelegate():openWebpage(  "http://spiritrain.tk/gamecenter.html", 0, mContentHeight + 120 , 640, 320)
    end

    -- ad banner
    -- local betHandler = function ( sender, eventType )
    --     if eventType == TOUCH_EVENT_ENDED then
    --         EventManager:postEvent( Event.Enter_Bet365 )
    --     end
    -- end
    -- local content = SceneManager.widgetFromJsonFile( "scenes/Bet365Cell.json" )
    -- local adImage = tolua.cast( content:getChildByName("Image_Ad"), "ImageView" )
    -- local url = "https://www.bet365affiliates.com/AffiliateBanners/Games/Promos/LOTR/en-GB/ROI/STD/700x300_6.gif"
    -- contentContainer:addChild( content )
    -- mContentHeight = mContentHeight + adImage:getSize().height
    -- content:addTouchEventListener( betHandler )
    -- updateContentContainer( mContentHeight, content )

    -- local handler = function( filePath )
    --     if filePath ~= nil and mWidget ~= nil and adImage ~= nil then
    --         local safeLoadTexture = function()
    --            adImage:loadTexture( filePath )
    --         end
    --         xpcall( safeLoadTexture, function ( msg )  end )
    --     end
    -- end
    -- SMIS.getSMImagePath( url, handler )
end

function updateContentContainer( contentHeight, content )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new(0, contentHeight) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function enterGame( index )
    EventManager:postEvent( ENTER_GAME_EVENT_LIST[index][1], ENTER_GAME_EVENT_LIST[index][2] )
end

function EnterOrExit( eventType )
    CCLuaLog("EnterOrExit:" .. eventType)
    if eventType == "enter" then
    elseif eventType == "exit" then
        if not Logic:getBetBlock() then
            WebviewDelegate:sharedDelegate():closeWebpage()
        end
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end
