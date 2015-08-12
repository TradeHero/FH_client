module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Header = require("scripts.views.HeaderFrame")
local SMIS = require("scripts.SMIS")
local Constants = require("scripts.Constants")

local mWidget
local mFollows

function loadFrame( jsonResponse )
    mFollows = jsonResponse
    local nFollow = table.getn( mFollows ) 
--    CCLuaLog ( "follows:" .. nFollow )

    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SettingsFollowListScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Header.loadFrame( mWidget, Constants.String.settings.follow_user , true )


    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    if nFollow == 0 then
        local userName = Constants.String.settings.follow_user_none
    
        contentHeight = contentHeight + addFollow( contentContainer, 1, userName )
    else
        for i = 1, nFollow do
            -- local userID = "userID" .. i
            -- local userName = "userName" .. i
            local userID = mFollows[i]["UserId"]
            local userName = mFollows[i]["DisplayName"]
            local pictureUrl = mFollows[i]["PictureUrl"]

            contentHeight = contentHeight + addFollow( contentContainer, i, userName, userID , pictureUrl)
        end
    end            
  
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

end

function addFollow( contentContainer, i, userName, userID , pictureUrl)
    local content = SceneManager.widgetFromJsonFile("scenes/SettingsFollowContentFrame.json")
    local lblName = tolua.cast( content:getChildByName("Label_Name"), "Label" )
    local logo = tolua.cast( content:getChildByName("Image_Photo"), "ImageView" )
    local remove = tolua.cast( content:getChildByName("Button_Remove"), "Button" )
    if userID == nil then
       remove:setEnabled( false )
    end

    lblName:setText( userName )
 --   logo:loadTexture( teamLogo )

    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        if type( pictureUrl ) ~= "userdata" and pictureUrl ~= "" then
            local handler = function( filePath )
                if filePath ~= nil and mWidget ~= nil and logo ~= nil then
                    local safeLoadTexture = function()
                        logo:loadTexture( filePath )
                    end
                    xpcall( safeLoadTexture, function ( msg )  end )
                end
            end
            SMIS.getSMImagePath( pictureUrl, handler )
        end
    end ) )
    mWidget:runAction( CCSequence:create( seqArray ) )

    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            local remove = tolua.cast( sender, "Button" )
            local successEventHandler = function( jsonResponse )
                removeFollow( content, userID )
            end
            EventManager:postEvent( Event.Do_Follow_Expert, { userID , false , successEventHandler } )
         end
    end
    remove:addTouchEventListener( eventHandler )

    contentContainer:addChild( content )
 
    return content:getSize().height
end


function removeFollow( content, removeKey )

    for i = 1, table.getn( mFollows ) do
        local userID = mFollows[i]["UserId"]
        
        if userID == removeKey then
            table.remove( mFollows, i )
            break
        end
    end

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    local innnerContainerHeight = contentContainer:getInnerContainerSize().height
    local contentHeight = content:getSize().height
    contentContainer:removeChild( content, true )

    contentContainer:setInnerContainerSize( CCSize:new( 0, innnerContainerHeight - contentHeight ) )
    if table.getn( mFollows ) == 0 then
        local userName = Constants.String.settings.follow_user_none
    
        contentHeight = contentHeight + addFollow( contentContainer, 1, userName )
        contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    end
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
    
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
