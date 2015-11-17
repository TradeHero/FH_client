module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local StoreConfig = require("scripts.config.Store")

local mWidget

function loadFrame( jsonResponse )
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/StoreFrame.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local backBt = mWidget:getChildByName("Panel_Title"):getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    Navigator.loadFrame( mWidget )

    initContent( jsonResponse )
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

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

--[{"Id":1,"Name":"A Couple of Tickets","Ticket":5,"Sp":0,"Level":1,"IsBestDeal":false},
-- {"Id":2,"Name":"Pile of Tickets","Ticket":15,"Sp":500,"Level":2,"IsBestDeal":false},
-- {"Id":3,"Name":"Box of Tickets","Ticket":30,"Sp":1000,"Level":4,"IsBestDeal":false},
-- {"Id":4,"Name":"Tickets Heaven","Ticket":50,"Sp":1000,"Level":7,"IsBestDeal":true},
-- {"Id":5,"Name":"Get free tickets!","Ticket":1,"Sp":0,"Level":0,"IsBestDeal":false}]
function initContent( products )
    tolua.cast( mWidget:getChildByName("Panel_Title"):getChildByName("Label_Title"), "Label" ):setText( Constants.String.store.title )

    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
 
    -- Prize Panel
    local container = mWidget:getChildByName("ScrollView")
    container:removeAllChildrenWithCleanup( true )

    for i = 1, table.getn( products ) - 1 do
        local content = SceneManager.widgetFromJsonFile("scenes/StoreContentFrame.json")
        local imageItem = tolua.cast( content:getChildByName("Image_Item"), "ImageView" )
        local imageBest = content:getChildByName("Image_Best")
        local labelTitle = tolua.cast( content:getChildByName("Label_Title"), "Label" )
        local labelDetail = tolua.cast( content:getChildByName("Label_Detail"), "Label" )
        local labelPrice = tolua.cast( content:getChildByName("Label_Pirce"), "Label" )
        local btnBuy = tolua.cast( content:getChildByName("Button_Buy"), "Button" )

--        imageItem:loadTexture("")

        labelTitle:setText( products[i]["Name"] )
        labelDetail:setText( string.format( Constants.String.store.detail, products[i]["Ticket"], products[i]["Sp"] ))
        labelPrice:setText( "$" .. ( 10 * products[i]["Level"] - 0.01) )

        if not products[i]["IsBestDeal"] then
            imageBest:setEnabled( false )
        end

        local payEventHandler = function ( ... )
            CCLuaLog("buy")
            EventManager:postEvent( Event.Do_Buy_Product, { products[i]["Id"] } )
        end

        local buyEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                CCLuaLog("buy handler")
                --EventManager:postEvent( Event.Do_Buy_Product, { products[i]["Id"] })
                Store:sharedDelegate():buy( products[i]["Level"] , payEventHandler)
            end
        end
        btnBuy:addTouchEventListener( buyEventHandler )

        content:setLayoutParameter( layoutParameter )
        container:addChild( content )
        contentHeight = contentHeight + content:getSize().height
    end
end



function refresh( moneyBalance )
end