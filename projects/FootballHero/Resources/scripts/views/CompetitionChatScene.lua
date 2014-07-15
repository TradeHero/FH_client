module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")


local mWidget
local mContainerHeight
local MESSAGE_CONTAINER_NAME = "messageContainer"

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/Chat.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    local messages = {}
    table.insert( messages, { ["name"] = "Sam", ["message"] = "China will win." })
    initMessage( messages )

    local backBt = widget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    local sendBt = widget:getChildByName("send")
    sendBt:addTouchEventListener( sendEventHandler )

    local messageInput = ViewUtils.createTextInput( mWidget:getChildByName( MESSAGE_CONTAINER_NAME ), "", 470, 45 )
    messageInput:setFontColor( ccc3( 0, 0, 0 ) )
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

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        WebviewDelegate:sharedDelegate():closeWebpage()
        EventManager:popHistory()
    end
end

function sendEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local messageInput = mWidget:getChildByName( MESSAGE_CONTAINER_NAME ):getNodeByTag( 1 )
        local message = messageInput:getText()
        messageInput:setText("")
        if string.len( message ) > 0 then
            local messages = {}
            table.insert( messages, { ["name"] = "Seb", ["message"] = message })
            addMessage( messages )
        end
    end
end

function initMessage( messages )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    mContainerHeight = 0

    for i = 1, table.getn( messages ) do
        local content = createMessageContent( messages[i] )
        
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        mContainerHeight = mContainerHeight + content:getSize().height
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, mContainerHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function addMessage( messages )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)

    for i = 1, table.getn( messages ) do
        local content = createMessageContent( messages[i] )
        
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        mContainerHeight = mContainerHeight + content:getSize().height
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, mContainerHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    contentContainer:jumpToBottom()
end


local index = 1
function createMessageContent( message )
    local name = message["name"]
    -- Todo according to the name of the sender
    local content
    if index % 2 == 0 then
        content = SceneManager.widgetFromJsonFile("scenes/ChatMessageContent.json")
        relayoutChatMessage( content, message, false )
    else
        content = SceneManager.widgetFromJsonFile("scenes/ChatMyMessageContent.json")
        relayoutChatMessage( content, message, true )
    end

    index = index + 1
    return content
end

function relayoutChatMessage( content, message, isMe )
    local messageTextMaxWidth = 500
    local messageTextHeight = 28
    local messageTextMinWidth = 170
    local messageBgNTextOffset = ccp( 50, 70 )
    local messagePanelNTextOffset = ccp( 140, 90 )
    local messageNameNTextOffsetY = 50
    local messageTimeNTextOffsetX = 50

    if isMe then
        messageBgNTextOffset = ccp( 50, 30 )
        messagePanelNTextOffset = ccp( 140, 50 )
    end

    local name = message["name"]
    local text = message["message"]
    local time = message["time"]

    local messageBg = tolua.cast( content:getChildByName("bg"), "ImageView" )
    local messageLabel = tolua.cast( content:getChildByName("message"), "Label" )
    local messageName = tolua.cast( content:getChildByName("name"), "Label" )
    local messageTime = tolua.cast( content:getChildByName("time"), "Label" )
    messageName:setText( name )
    messageLabel:setText( text )
    local originSize = messageLabel:getSize()

    local messageNamePositionX = messageName:getPositionX()
    local messageTimePositionY = messageTime:getPositionY()
    if originSize.width > messageTextMaxWidth then
        local messageBlockHeight = math.ceil( originSize.width / messageTextMaxWidth ) * messageTextHeight
        messageLabel:setTextAreaSize( CCSize:new( messageTextMaxWidth, messageBlockHeight ) )
        messageBg:setSize( CCSize:new( messageTextMaxWidth + messageBgNTextOffset.x, messageBlockHeight + messageBgNTextOffset.y ) )
        content:setSize( CCSize:new( messageTextMaxWidth + messagePanelNTextOffset.x, messageBlockHeight + messagePanelNTextOffset.y ) )
        messageName:setPosition( ccp( messageNamePositionX, messageBlockHeight + messageNameNTextOffsetY ) )
    else
        local textWidth = math.max( originSize.width, messageTextMinWidth )

        messageBg:setSize( CCSize:new( textWidth + messageBgNTextOffset.x, messageTextHeight + messageBgNTextOffset.y ) )
        content:setSize( CCSize:new( textWidth + messagePanelNTextOffset.x, messageTextHeight + messagePanelNTextOffset.y ) )
        messageName:setPosition( ccp( messageNamePositionX, messageTextHeight + messageNameNTextOffsetY ) )
        if not isMe then
            messageTime:setPosition( ccp( textWidth + messageTimeNTextOffsetX, messageTimePositionY ) )
        end
    end
end