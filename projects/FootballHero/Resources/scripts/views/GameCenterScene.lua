module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.HeaderFrame")
local SMIS = require("scripts.SMIS")
local SpinWheelConfig = require("scripts.config.SpinWheel")
local Logic = require("scripts.Logic").getInstance()

local mWidget
local mContentHeight

local ENTER_GAME_EVENT_LIST = {
    { Event.Enter_Spin_the_Wheel, nil },
    { Event.Enter_Lucky8, nil },
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
    Header.loadFrame( widget, Constants.String.lucky8.game_center_title, false, false, true )
    Navigator.loadFrame( widget )
    initCells( table.getn( ENTER_GAME_EVENT_LIST ) )
end

function refreshFrame( )
    initCells( table.getn( ENTER_GAME_EVENT_LIST ) )
end

function initCells( cellNum )
    mContentHeight = 0
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    local GAMECENTER_TITLE_AND_DES = {
        { Constants.String.spinWheel.wheel_title, Constants.String.spinWheel.wheel_sub_des },
        { Constants.String.lucky8.lucky8_title, Constants.String.lucky8.lucky8_sub_des },
    }

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
        
        local gameTitle = tolua.cast( panelFade:getChildByName("TextField_Title"), "TextField" )
        gameTitle:setText( GAMECENTER_TITLE_AND_DES[i][1] )
        
        local gameDes = tolua.cast( panelFade:getChildByName("TextField_Content"), "TextField" )
        gameDes:setText( GAMECENTER_TITLE_AND_DES[i][2] )

        local btnPlay = tolua.cast( panelFade:getChildByName("Button_Play"), "Button" )
        btnPlay:addTouchEventListener( eventHandler )

        contentContainer:addChild( content )
        mContentHeight = mContentHeight + content:getSize().height
        
        updateContentContainer( mContentHeight, content )
    end


    if not Logic:getBetBlock() then
    --     WebviewDelegate:sharedDelegate():openWebpage(  "http://spiritrain.tk/gamecenter.html", 0, mContentHeight + 120 , 640, 320)

        -- ad banner
        local betHandler = function ( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Enter_Bet365 )
            end
        end
        local url = "https://www.bet365affiliates.com/AffiliateBanners/Games/Promos/LOTR/en-GB/ROI/STD/700x300_6.gif"
        local content = SceneManager.widgetFromJsonFile( "scenes/Bet365Cell.json" )
        local adButton = tolua.cast( content:getChildByName("Button_Ad"), "Button" )
        adButton:addTouchEventListener( betHandler )
        adButton:loadTextureNormal( Constants.IMAGE_PATH .. "ads/banner_gamecenter.jpg" )
        
        contentContainer:addChild( content )
        mContentHeight = mContentHeight + adButton:getSize().height
        updateContentContainer( mContentHeight, content )

        local handler = function( filePath )
            if filePath ~= nil and mWidget ~= nil and adButton ~= nil then
                local safeLoadTexture = function()
                   adButton:loadTextureNormal( filePath )
                end
                xpcall( safeLoadTexture, function ( msg )  end )
            end
        end
        SMIS.getSMImagePath( url, handler )
    end
end

function updateContentContainer( contentHeight, content )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new(0, contentHeight) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function enterGame( index )
    if Logic:getTicket() > 0 then
        EventManager:postEvent( ENTER_GAME_EVENT_LIST[index][1], ENTER_GAME_EVENT_LIST[index][2] )
    else
        EventManager:postEvent( Event.Show_Get_Tickets )
    end
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
       -- if not Logic:getBetBlock() then
       --      WebviewDelegate:sharedDelegate():closeWebpage()
       -- end
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end
