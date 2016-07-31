module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local PrizeConfig = require("scripts.config.Prize")

local mWidget

function loadFrame( mToken )
--    initPrize(mToken)
    if mToken == "olympic2016" then
        initOlympic()
    else
        initNamePrize(mToken)
    end
end

function initNamePrize(mToken)
    local widget = SceneManager.secondLayerWidgetFromJsonFile("scenes/PrizeNameFrame.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    widget = tolua.cast( widget, "Layout" )
    widget:setBackGroundImage( Constants.COMPETITION_IMAGE_PATH.. Constants.PrizeBgPrefix .. mToken ..".png" )

    local btnBack = mWidget:getChildByName("Button_Back")
    btnBack:addTouchEventListener( backEventHandler )

    local btnOk = mWidget:getChildByName("Button_OK")
    btnOk:addTouchEventListener( backEventHandler )

    local logo = tolua.cast( mWidget:getChildByName("Image_logo"), "ImageView" )
    logo:loadTexture( Constants.COMPETITION_IMAGE_PATH.. Constants.PrizeLogoPrefix .. mToken ..".png" )

    local item = tolua.cast( mWidget:getChildByName("Image_item"), "ImageView" ) 
    item:loadTexture( Constants.COMPETITION_IMAGE_PATH.. Constants.PrizeItemPrefix .. mToken ..".png" )

    local scroll = tolua.cast( mWidget:getChildByName( "ScrollView" ), "ScrollView" )
    local contentHeight = 150
    local mPrizeConfig = {
        { ["token"] = "euro2016", ["prize1"] = "Win a Messi Signed Jersey", ["prize2"] = "A Signed Football Card" },
        { ["token"] = "americacup2016", ["prize1"] = "Win a Maradona Signed Jersey", ["prize2"] = "A Signed Football Card" },
        { ["token"] = "olympic2016", ["prize1"] = "Win a Maradona Signed Jersey", ["prize2"] = "A Signed Football Card" },
    }

    for i = 1, table.getn( PrizeConfig.PrizeContent ) do
        local num, text
        CCLuaLog( PrizeConfig.PrizeContent[i]["token"] )
        if mToken == PrizeConfig.PrizeContent[i]["token"] then
            local static = tolua.cast( scroll:getChildByName("Panel_static"), "Layout" )
            local prizes = PrizeConfig.PrizeContent[i]["prizes"]
            text = tolua.cast( static:getChildByName("Label_Prize1"), "Label" )
            text:setText( PrizeConfig.PrizeContent[i]["1st"] )

            for j=1,table.getn(prizes) do
                local content = SceneManager.widgetFromJsonFile("scenes/PrizeContent.json")
                num = tolua.cast( content:getChildByName("Label_num"), "Label" )
                num:setText( j+1 .. "rd Prize" )
                text = tolua.cast( content:getChildByName("Label_text"), "Label" )
                text:setText( prizes[j] )
                scroll:addChild( content )
                contentHeight = contentHeight + content:getSize().height
            end
            scroll:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
            local layout = tolua.cast( scroll, "Layout" )
            scroll:requestDoLayout()
        end
    end   
end

function initPrize(mToken)
    local widget = SceneManager.secondLayerWidgetFromJsonFile("scenes/PrizeFrame.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    widget = tolua.cast( widget, "Layout" )
    widget:setBackGroundImage( Constants.COMPETITION_IMAGE_PATH.. Constants.PrizeBgPrefix .. mToken ..".png" )

    local btnBack = mWidget:getChildByName("Button_Back")
    btnBack:addTouchEventListener( backEventHandler )

    local btnOk = mWidget:getChildByName("Button_OK")
    btnOk:addTouchEventListener( backEventHandler )

    local logo = tolua.cast( mWidget:getChildByName("Image_logo"), "ImageView" )
    logo:loadTexture( Constants.COMPETITION_IMAGE_PATH.. Constants.PrizeLogoPrefix .. mToken ..".png" )

    local item = tolua.cast( mWidget:getChildByName("Image_item"), "ImageView" ) 
    item:loadTexture( Constants.COMPETITION_IMAGE_PATH.. Constants.PrizeItemPrefix .. mToken ..".png" )

    local mPrizeConfig = {
        { ["token"] = "euro2016", ["prize1"] = "Win a Messi Signed Jersey", ["prize2"] = "A Signed Football Card" },
        { ["token"] = "americacup2016", ["prize1"] = "Win a Maradona Signed Jersey", ["prize2"] = "A Signed Football Card" },
        { ["token"] = "olympic2016", ["prize1"] = "Win a Maradona Signed Jersey", ["prize2"] = "A Signed Football Card" },
    }

    for i = 1, table.getn( mPrizeConfig ) do
        local text
        if mToken == mPrizeConfig[i]["token"] then
            text = tolua.cast( mWidget:getChildByName("Label_Prize1"), "Label" )
            text:setText( mPrizeConfig[i]["prize1"] )
            for j=2,10 do
                text = tolua.cast( mWidget:getChildByName("Label_Prize"..j), "Label" )
                text:setText( mPrizeConfig[i]["prize2"] )
            end
        end
    end   
end
function initOlympic()
    local widget = SceneManager.secondLayerWidgetFromJsonFile("scenes/PrizeOlympic.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    widget = tolua.cast( widget, "Layout" )

    local btnBack = mWidget:getChildByName("Button_Back")
    btnBack:addTouchEventListener( backEventHandler )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end
