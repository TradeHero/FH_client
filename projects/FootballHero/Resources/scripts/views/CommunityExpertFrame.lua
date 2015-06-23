module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")

local mWidget
local gameContent = {}

function loadFrame( parent, expertInfo, gameInfo )
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityExpertFrame.json")
    parent:addChild( mWidget )
    mWidget:registerScriptHandler( EnterOrExit )
    print("load expert frame")

    gameInfo = {
        {
            ["Time"]= "2015/6/21 19:00",
            ["HomeTeamID"]= 21,
            ["AwayTeamID"]= 22,
            ["Expert1"]="Home",
            ["Expert2"]="Home",
            ["Expert3"]="Away",
            ["Expert4"]="Draw"
        },
        {
            ["Time"]= "2015/6/22 19:00",
            ["HomeTeamID"]= 286,
            ["AwayTeamID"]= 308,
            ["Expert1"]="Away",
            ["Expert2"]="Home",
            ["Expert3"]="Draw",
            ["Expert4"]="Away"
        },
        {
            ["Time"]= "2015/6/23 19:00",
            ["HomeTeamID"]= 4352,
            ["AwayTeamID"]= 4008,
            ["Expert1"]="Home",
            ["Expert2"]="Away",
            ["Expert3"]="Away",
            ["Expert4"]="Draw"
        },
        {
            ["Time"]= "2015/6/24 19:00",
            ["HomeTeamID"]= 643,
            ["AwayTeamID"]= 646,
            ["Expert1"]="Home",
            ["Expert2"]="Away",
            ["Expert3"]="Home",
            ["Expert4"]="Away"
        },
        {
            ["Time"]= "2015/6/25 19:00",
            ["HomeTeamID"]= 2889,
            ["AwayTeamID"]= 3609,
            ["Expert1"]="Away",
            ["Expert2"]="Home",
            ["Expert3"]="Away",
            ["Expert4"]="Home"
        },
        {
            ["Time"]= "2015/6/26 19:00",
            ["HomeTeamID"]= 1156,
            ["AwayTeamID"]= 1159,
            ["Expert1"]="Away",
            ["Expert2"]="Draw",
            ["Expert3"]="Home",
            ["Expert4"]="Away"
        },
       {
            ["Time"]= "2015/6/27 19:00",
            ["HomeTeamID"]= 181,
            ["AwayTeamID"]= 185,
            ["Expert1"]="Draw",
            ["Expert2"]="Away",
            ["Expert3"]="Away",
            ["Expert4"]="Away"
        },
        {
            ["Time"]= "2015/6/28 19:00",
            ["HomeTeamID"]= 2325,
            ["AwayTeamID"]= 2328,
            ["Expert1"]="Home",
            ["Expert2"]="Home",
            ["Expert3"]="Home",
            ["Expert4"]="Home"
        },
        {
            ["Time"]= "2015/6/29",
            ["HomeTeamID"]= 492,
            ["AwayTeamID"]= 496,
            ["Expert1"]="Away",
            ["Expert2"]="Away",
            ["Expert3"]="Away",
            ["Expert4"]="Away"
        },
        {
            ["Time"]= "2015/6/30 19:00",
            ["HomeTeamID"]= 553,
            ["AwayTeamID"]= 556,
            ["Expert1"]="Draw",
            ["Expert2"]="Draw",
            ["Expert3"]="Draw",
            ["Expert4"]="Draw"
        }

    }

    initContent( gameInfo )
    local expertInfo = {57382,83006,82996,83027}
    initExpert(expertInfo)

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


function initContent( gameInfo )
   -- matches
    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
 
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Expert"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    for i = 1, 10 do    
        local homeTeamID = TeamConfig.getConfigIdByKey(gameInfo[i]["HomeTeamID"])
        local awayTeamID = TeamConfig.getConfigIdByKey(gameInfo[i]["AwayTeamID"])
--        local timeDisplay = os.date( "%b %d %H:%M", gameInfo[i]["Time"] )

        local homeTeamName = TeamConfig.getTeamName( homeTeamID )
        local homeTeamLogo = TeamConfig.getLogo( homeTeamID, true )
        local awayTeamName = TeamConfig.getTeamName( awayTeamID )
        local awayTeamLogo = TeamConfig.getLogo( awayTeamID, false )

        local content = SceneManager.widgetFromJsonFile("scenes/CommunityExpertContent.json")
        local gamePanel = tolua.cast( content:getChildByName("Panel_Game"), "Layout" )

        local labelTime = tolua.cast( gamePanel:getChildByName("Label_Time"), "Label" )
        labelTime:setText( gameInfo[i]["Time"] )
        local imageHomeTeam = tolua.cast( gamePanel:getChildByName("Image_Home"), "ImageView" )
        imageHomeTeam:loadTexture( homeTeamLogo )
        local imageAwayTeam = tolua.cast( gamePanel:getChildByName("Image_Away"), "ImageView" )
        imageAwayTeam:loadTexture( awayTeamLogo )


        for j=1,4 do
            local expertPanel = content:getChildByName("Panel_Expert" .. j)
            local nameLabel = tolua.cast( expertPanel:getChildByName("Label_Team"), "Label" )
            local logoImage = tolua.cast( expertPanel:getChildByName("Image_Team"), "ImageView" )
            if gameInfo[i]["Expert"..j] == "Home" then
                nameLabel:setText(homeTeamName)
                logoImage:loadTexture( homeTeamLogo )
            elseif gameInfo[i]["Expert"..j] == "Away" then
                nameLabel:setText(awayTeamName)
                logoImage:loadTexture( awayTeamLogo )
            elseif gameInfo[i]["Expert"..j] == "Draw" then
                nameLabel:setText("Draw")
            else
            end
        end

        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        gameContent[i] = content
        contentHeight = contentHeight + content:getSize().height

    end
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initExpert( expertInfo )
    -- expert info
    -- 57382 sam
    -- 83006 david
    -- 82996 jason
    -- 83027 William
    local expertContainer = mWidget:getChildByName("Panel_Expert")
    for i=1,4 do
         local followEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
              --  EventManager:postEvent( Event.Enter_Create_Competition )
                for j=1,10 do
                    local panel = tolua.cast( gameContent[j]:getChildByName("PanelTeam"):getChildByName("Panel_Expert" .. i), "Layout" )
                    local check = tolua.cast( sender, "CheckBox")
                    if check:getSelectedState()  then
                        panel:setBackGroundColor(ccc3( 50, 50, 50 ))
                    else 
                        panel:setBackGroundColor(ccc3( 200, 200, 200 ))
                    end
                end
            end
        end
        local expertPanel = expertContainer:getChildByName("Panel_Expert"..i)
        local nameLabel = tolua.cast( expertPanel:getChildByName("Label_Name"), "Label" )
        nameLabel:setText( "ept" .. i )

        local expertPhotoHandler = function ( sender, eventType )
            print(eventType)
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Enter_History, { expertInfo[i] } )
            end
        end

        local photoImage = tolua.cast( expertPanel:getChildByName("Image_Photo"), "ImageView" )
        photoImage:addTouchEventListener (expertPhotoHandler)

        local followCheckBox = tolua.cast( expertPanel:getChildByName("CheckBox_Follow"), "CheckBox" )
--        followCheckBox:setSelectedState(true)
        followCheckBox:addTouchEventListener(followEventHandler)
    end
end

