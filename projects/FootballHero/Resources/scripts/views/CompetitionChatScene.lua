module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local Logic = require("scripts.Logic").getInstance()

local mWidget
local mCompetitionId
local mContainerHeight
local mHasTodayMessage
local MESSAGE_CONTAINER_NAME = "messageContainer"
local RELOAD_DELAY_TIME = 5

-- DS for chatMessages: see ChatMessages
function loadFrame( competitionId, chatMessages )
    mCompetitionId = competitionId

    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/Chat.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( widget )

    mHasTodayMessage = false
    initMessage( chatMessages )

    local backBt = widget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    local sendBt = widget:getChildByName("send")
    sendBt:addTouchEventListener( sendEventHandler )

    local moreBt = widget:getChildByName("more")
    moreBt:addTouchEventListener( moreEventHandler )

    local messageInput = ViewUtils.createTextInput( mWidget:getChildByName( MESSAGE_CONTAINER_NAME ), "Type your message here", 470, 50 )

    initTitle();
    getLatestMessages()
end

function initTitle()    
    local title = tolua.cast( mWidget:getChildByName("title"), "Label" )
    local competitionDetail = Logic:getCompetitionDetail()
    title:setText( competitionDetail:getName() )
end

function getLatestMessages()
    EventManager:scheduledExecutor( doGetLatestMessages, RELOAD_DELAY_TIME )
end

local mLastGetLatestMessageTime = 0
function doGetLatestMessages()
    -- Only send the request when players are still in the chat UI.
    if mWidget ~= nil and os.time() - mLastGetLatestMessageTime >= RELOAD_DELAY_TIME then
        EventManager:postEvent( Event.Do_Get_Chat_Message, { mCompetitionId, Logic:getLastChatMessageTimestamp(), true, getLatestMessages } )
        mLastGetLatestMessageTime = os.time()
    end
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
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function moreEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Competition_More, { mCompetitionId } )
    end
end

function sendEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local messageInput = mWidget:getChildByName( MESSAGE_CONTAINER_NAME ):getNodeByTag( 1 )
        local message = messageInput:getText()
        messageInput:setText("")
        if string.len( message ) > 0 then
            EventManager:postEvent( Event.Do_Send_Chat_Message, { mCompetitionId, message } )
        end
    end
end

function initMessage( chatMessages )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    mContainerHeight = 0

    for k,v in pairs( chatMessages:getMessageDateList() ) do
        local content = SceneManager.widgetFromJsonFile("scenes/ChatMessageDate.json")
        local dateDisplay = tolua.cast( content:getChildByName("date"), "Label" )
        dateDisplay:setText( v["dateDisplay"] )
        
        -- Record whether there is message of today. So no more today will be added for addMessages()
        if v["dateDisplay"] == "Today" then
            mHasTodayMessage = true
        end

        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        mContainerHeight = mContainerHeight + content:getSize().height

        local messages = v["messages"]
        for i = 1, table.getn( messages ) do
            local content = createMessageContent( messages[i] )
            
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            mContainerHeight = mContainerHeight + content:getSize().height
        end
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, mContainerHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    contentContainer:jumpToBottom()
end

function addMessage( chatMessages )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)

    local chatMessageList = chatMessages:getMessageDateList()
    for k,v in pairs( chatMessageList ) do

        -- Add message must be happened today.
        -- There might be bug during mid-night, but who cares.
        if not mHasTodayMessage then
            local content = SceneManager.widgetFromJsonFile("scenes/ChatMessageDate.json")
            local dateDisplay = tolua.cast( content:getChildByName("date"), "Label" )
            dateDisplay:setText( v["dateDisplay"] )

            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            mContainerHeight = mContainerHeight + content:getSize().height
            
            mHasTodayMessage = true
        end

        local messages = v["messages"]
        for i = 1, table.getn( messages ) do
            local content = createMessageContent( messages[i] )
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            mContainerHeight = mContainerHeight + content:getSize().height
        end
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, mContainerHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    if next( chatMessageList ) then
        contentContainer:jumpToBottom()
    end
end


function createMessageContent( message )
    local name = message["UserName"]
    -- Todo according to the name of the sender
    local content
    if name == Logic:getDisplayName() then
        content = SceneManager.widgetFromJsonFile("scenes/ChatMyMessageContent.json")
        relayoutChatMessage( content, message, true )
    else
        content = SceneManager.widgetFromJsonFile("scenes/ChatMessageContent.json")
        relayoutChatMessage( content, message, false )
    end

    return content
end

function relayoutChatMessage( content, message, isMe )
    local messageTextMaxWidth = 500
    local messageTextHeight = 28
    local messageTextPaddingY = 8
    local messageTextMinWidth = 170
    local messageBgNTextOffset = ccp( 50, 70 )
    local messagePanelNTextOffset = ccp( 140, 90 )
    local messageNameNTextOffsetY = 50
    local messageTimeNTextOffsetX = 50

    if isMe then
        messageBgNTextOffset = ccp( 50, 30 )
        messagePanelNTextOffset = ccp( 140, 50 )
    end

    local name = message["UserName"]
    local text = message["MessageText"]
    local time = message["UnixTimeStamp"]

    local messageBg = tolua.cast( content:getChildByName("bg"), "ImageView" )
    local messageLabel = tolua.cast( content:getChildByName("message"), "Label" )
    local messageName = tolua.cast( content:getChildByName("name"), "Label" )
    local messageTime = tolua.cast( content:getChildByName("time"), "Label" )
    messageName:setText( name )
    messageLabel:setText( text )
    messageTime:setText( os.date( "%H:%M", time ) )
    local originSize = messageLabel:getSize()
    local messageNamePositionX = messageName:getPositionX()
    local messageTimePositionY = messageTime:getPositionY()
    if originSize.width > messageTextMaxWidth then
        local messageBlockHeight = math.ceil( originSize.width / messageTextMaxWidth ) * ( messageTextHeight + messageTextPaddingY )
        messageLabel:setTextAreaSize( CCSize:new( messageTextMaxWidth, messageBlockHeight ) )
        messageBg:setSize( CCSize:new( messageTextMaxWidth + messageBgNTextOffset.x, messageBlockHeight + messageBgNTextOffset.y ) )
        content:setSize( CCSize:new( messageTextMaxWidth + messagePanelNTextOffset.x, messageBlockHeight + messagePanelNTextOffset.y ) )
        messageName:setPosition( ccp( messageNamePositionX, messageBlockHeight + messageNameNTextOffsetY ) )
    else
        local textWidth = math.max( originSize.width, messageTextMinWidth )
        textWidth = math.max( textWidth, messageName:getSize().width )

        messageBg:setSize( CCSize:new( textWidth + messageBgNTextOffset.x, messageTextHeight + messageBgNTextOffset.y ) )
        content:setSize( CCSize:new( textWidth + messagePanelNTextOffset.x, messageTextHeight + messagePanelNTextOffset.y ) )
        messageName:setPosition( ccp( messageNamePositionX, messageTextHeight + messageNameNTextOffsetY ) )
        if not isMe then
            messageTime:setPosition( ccp( textWidth + messageTimeNTextOffsetX, messageTimePositionY ) )
        end
    end
end