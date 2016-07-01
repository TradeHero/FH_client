module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")

local mWidget

function loadFrame( jsonResponse, storeResponse )
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/StoreFrame.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local backBt = mWidget:getChildByName("Panel_Title"):getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    Navigator.loadFrame( mWidget )

    initContent( jsonResponse, storeResponse)
--    initContentWithoutStore(jsonResponse)
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
function initContent( products, storeResponse )
    tolua.cast( mWidget:getChildByName("Panel_Title"):getChildByName("Label_Title"), "Label" ):setText( Constants.String.store.title )
 
    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)

    local store = {}
    local count = table.getn( storeResponse )
    -- 为 store 传回结果排序
    for i=1, count do
        for j=1, count do
            if storeResponse[j]["id"] == Constants.StorePrefix .. products[i]["Level"] then
                store[i] = storeResponse[j]
            end
        end
    end
 
    -- Prize Panel
    local container = mWidget:getChildByName("ScrollView")
    container:removeAllChildrenWithCleanup( true )

    for i = 1, count do
        local content = SceneManager.widgetFromJsonFile("scenes/StoreContentFrame.json")
        local imageItem = tolua.cast( content:getChildByName("Image_Item"), "ImageView" )
        local imageBest = content:getChildByName("Image_Best")
        local labelTitle = tolua.cast( content:getChildByName("Label_Title"), "Label" )
        local labelDetail = tolua.cast( content:getChildByName("Label_Detail"), "Label" )
        local labelPrice = tolua.cast( content:getChildByName("Label_Pirce"), "Label" )
        local btnBuy = tolua.cast( content:getChildByName("Button_Buy"), "Button" )

        labelTitle:setText( store[i]["title"] )
        labelDetail:setText( string.format( Constants.String.store.detail, products[i]["Ticket"] ))
        labelPrice:setText( store[i]["symbol"] .. " " .. store[i]["price"] )
        

        if not products[i]["IsBestDeal"] then
            imageBest:setEnabled( false )
        end

        local payEventHandler = function ( ... )
            EventManager:postEvent( Event.Do_Buy_Product, { products[i]["Id"], store[i]["title"], store[i]["price"], store[i]["code"] } )
        end

        local buyEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                Store:sharedDelegate():buy( Constants.StorePrefix .. products[i]["Level"] , payEventHandler)
            end
        end
        btnBuy:addTouchEventListener( buyEventHandler )

        content:setLayoutParameter( layoutParameter )
        container:addChild( content )
        contentHeight = contentHeight + content:getSize().height
    end
end

function initContentWithoutStore( products )
    tolua.cast( mWidget:getChildByName("Panel_Title"):getChildByName("Label_Title"), "Label" ):setText( Constants.String.store.title )
 
    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
 
    -- Prize Panel
    local container = mWidget:getChildByName("ScrollView")
    container:removeAllChildrenWithCleanup( true )

    local count = table.getn( products )

    for i = 1, count do
        local content = SceneManager.widgetFromJsonFile("scenes/StoreContentFrame.json")
        local imageItem = tolua.cast( content:getChildByName("Image_Item"), "ImageView" )
        local imageBest = content:getChildByName("Image_Best")
        local labelTitle = tolua.cast( content:getChildByName("Label_Title"), "Label" )
        local labelDetail = tolua.cast( content:getChildByName("Label_Detail"), "Label" )
        local labelPrice = tolua.cast( content:getChildByName("Label_Pirce"), "Label" )
        local btnBuy = tolua.cast( content:getChildByName("Button_Buy"), "Button" )

        labelTitle:setText( products[i]["Name"] )
        labelDetail:setText( string.format( Constants.String.store.detail, products[i]["Ticket"] ))
        labelPrice:setText( "$" .. (products[i]["Ticket"] -1)..".99")
        

        if not products[i]["IsBestDeal"] then
            imageBest:setEnabled( false )
        end

        local payEventHandler = function ( ... )
            EventManager:postEvent( Event.Do_Buy_Product, { products[i]["Id"] } )
        end

        local buyEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
--                EventManager:postEvent( Event.Do_Buy_Product, { i })
                Store:sharedDelegate():buy( Constants.StorePrefix .. products[i]["Level"] , payEventHandler)
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