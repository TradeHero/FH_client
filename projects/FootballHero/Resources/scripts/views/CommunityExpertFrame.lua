module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")
local SMIS = require("scripts.SMIS")

local mWidget
local gameContent = {}

function loadFrame( parent, jsonResponse )
    local gameInfo =  jsonResponse["TeamGameDtos"]
    local expertInfo =  jsonResponse["ExpertDtos"]
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityExpertFrame.json")
    parent:addChild( mWidget )
    mWidget:registerScriptHandler( EnterOrExit )

    initExpert( expertInfo )
    initContent( gameInfo , expertInfo )

    --[[expert[{"Id":88398,
                "DisplayName":"Michael Gulgun",
                "PictureUrl":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpf1/v/t1.0-1/p200x200/10304791_294737007364470_1553892509341301836_n.jpg?oh=85018632db0fe88350a9210cf4529937&oe=5506FB46&__gda__=1426140576_26b2dc86e9ed06a520ee4ac763c4ebd9",
                "PickTeamIds":[
                    {"GameId":310790,"PickId":-1,"BigBet":false},
                    {"GameId":310796,"PickId":-1,"BigBet":false},
                    {"GameId":310794,"PickId":-1,"BigBet":false},
                    {"GameId":321661,"PickId":-1,"BigBet":false},
                    {"GameId":310788,"PickId":-1,"BigBet":false},
                    {"GameId":310797,"PickId":-1,"BigBet":false},
                    {"GameId":310795,"PickId":-1,"BigBet":false},
                    {"GameId":321740,"PickId":-1,"BigBet":false},
                    {"GameId":327059,"PickId":-1,"BigBet":false},
                    {"GameId":310789,"PickId":-1,"BigBet":false}],
                "IsFollowed":false}
    ]]
    --[[{"Id":310796,
        "StartTime":1436094000,
        "HomeTeamId":13487,
        "AwayTeamId":4037,
        "Line":null}
    ]]

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


function initContent( gameInfo , expertInfo )
   -- matches
    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
 
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Expert"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )



    for i = 1, 10 do    
        local homeTeamID = TeamConfig.getConfigIdByKey(gameInfo[i]["HomeTeamId"])
        local awayTeamID = TeamConfig.getConfigIdByKey(gameInfo[i]["AwayTeamId"])
        local timeDisplay = os.date( "%b-%d %H:%M", gameInfo[i]["StartTime"] )
        local lineAH = tonumber( gameInfo[i]["Line"] )

        local homeTeamName = TeamConfig.getTeamName( homeTeamID )
        local homeTeamLogo = TeamConfig.getLogo( homeTeamID, true )
        local awayTeamName = TeamConfig.getTeamName( awayTeamID )
        local awayTeamLogo = TeamConfig.getLogo( awayTeamID, false )

        local content = SceneManager.widgetFromJsonFile("scenes/CommunityExpertContent.json")
        local gamePanel = tolua.cast( content:getChildByName("Panel_Game"), "Layout" )

        local labelTime = tolua.cast( gamePanel:getChildByName("Label_Time"), "Label" )
        labelTime:setText( timeDisplay )
        local imageHomeTeam = tolua.cast( gamePanel:getChildByName("Image_Home"), "ImageView" )
        imageHomeTeam:loadTexture( homeTeamLogo )
        local imageAwayTeam = tolua.cast( gamePanel:getChildByName("Image_Away"), "ImageView" )
        imageAwayTeam:loadTexture( awayTeamLogo )
        local labelHomeAH =  tolua.cast( gamePanel:getChildByName("Label_HomeAH"), "Label" )
        local labelAwayAH =  tolua.cast( gamePanel:getChildByName("Label_AwayAH"), "Label" )
 --       CCLuaLog("AH:" .. lineAH .. "\tLine:" .. gameInfo[i]["Line"] )
        
        if lineAH == nil then
            labelHomeAH:setVisible( false )
            labelAwayAH:setVisible( false )
        elseif lineAH > 0 then
            labelHomeAH:setText( "A.H. -" .. lineAH )
            labelAwayAH:setVisible( false )
        elseif lineAH < 0 then
            labelAwayAH:setText( "A.H. -" .. -lineAH )
            labelHomeAH:setVisible( false )
        else
            labelHomeAH:setText( "A.H. -0" )
            labelAwayAH:setVisible( false )
        end


        --{"Id":149019,"DisplayName":"SpiritRain","PictureUrl":null,"PickTeamIds":[{"GameId":310790,"PickId":0},{"GameId":317692,"PickId":0},{"GameId":317691,"PickId":0},{"GameId":317690,"PickId":0},{"GameId":317689,"PickId":0},{"GameId":317688,"PickId":0},{"GameId":317687,"PickId":0},{"GameId":327059,"PickId":0},{"GameId":284714,"PickId":0},{"GameId":310789,"PickId":0}],"IsBeenFollowed":false}
        for j=1,4 do
            local expertPanel = tolua.cast( content:getChildByName("Panel_Expert" .. j), "Layout" )
            local nameLabel = tolua.cast( expertPanel:getChildByName("Label_Team"), "Label" )
            local logoImage = tolua.cast( expertPanel:getChildByName("Image_Team"), "ImageView" )
            local bigbetImage = tolua.cast( expertPanel:getChildByName("Image_Stake"), "ImageView" )
            local pickId = expertInfo[j]["PickTeamIds"][i]["PickId"]
            local isBigBet = expertInfo[j]["PickTeamIds"][i]["BigBet"]
            local isFollowed = expertInfo[j]["IsFollowed"] 
--            CCLuaLog( "Gameid:".. expertInfo[j]["PickTeamIds"][i]["GameId"] .. "\tPick:" .. expertInfo[j]["PickTeamIds"][i]["PickId"])
            bigbetImage:setVisible( isBigBet )
            if isFollowed then
                expertPanel:setBackGroundColorOpacity( 35 )
            end

            if pickId == 0 then
                if string.len( homeTeamName ) > 20 then
                   nameLabel:setFontSize( 14 )
                end
                nameLabel:setText(homeTeamName)
                logoImage:loadTexture( homeTeamLogo )
            elseif pickId == 1 then
                if string.len( awayTeamName ) > 20 then
                   nameLabel:setFontSize( 14 )
                end
                nameLabel:setText(awayTeamName)
                logoImage:loadTexture( awayTeamLogo )
            elseif pickId == -1 then
                nameLabel:setText("None")
            else
                nameLabel:setText("Error")
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

function followExpert( )
--    local followCheckBox = tolua.cast( expertPanel:getChildByName("CheckBox_Follow"), "CheckBox" )

end

function initExpert( expertInfo )
    local expertContainer = mWidget:getChildByName("Panel_Expert")
    for i=1,4 do
        CCLuaLog( "id:" .. expertInfo[i]["Id"] )
        CCLuaLog( "DisplayName:" .. expertInfo[i]["DisplayName"] )
        CCLuaLog( "PictureUrl:" .. tostring(expertInfo[i]["PictureUrl"]) )

        local expertPicUrl = expertInfo[i]["PictureUrl"]

        local expertPanel = expertContainer:getChildByName("Panel_Expert"..i)
        local nameLabel = tolua.cast( expertPanel:getChildByName("Label_Name"), "Label" )
        nameLabel:setText( expertInfo[i]["DisplayName"] )

        local expertPhotoHandler = function ( sender, eventType )
            print(eventType)
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Enter_Expert_History, { expertInfo[i]["Id"] } )
            end
        end

        local photoImage = tolua.cast( expertPanel:getChildByName("Image_Photo"), "ImageView" )
        photoImage:addTouchEventListener (expertPhotoHandler)

        local seqArray = CCArray:create()
        seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
        seqArray:addObject( CCCallFuncN:create( function()
            if type( expertPicUrl ) ~= "userdata"  then
                local handler = function( filePath )
                    if filePath ~= nil and mWidget ~= nil and photoImage ~= nil then
                        local safeLoadTexture = function()
                            photoImage:loadTexture( filePath )
                        end
                        xpcall( safeLoadTexture, function ( msg )  end )
                    end
                end
                SMIS.getSMImagePath( expertPicUrl, handler )
            end
        end ) )
        mWidget:runAction( CCSequence:create( seqArray ) )

        local followCheckBox = tolua.cast( expertPanel:getChildByName("CheckBox_Follow"), "CheckBox" )
        local followEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Do_Follow_Expert, { expertInfo[i]["Id"] , not followCheckBox:getSelectedState() , followExpert } )
                local check = tolua.cast( sender, "CheckBox")
                local expertPanel = tolua.cast( expertContainer:getChildByName("Panel_Expert"..i), "Layout" )
                if check:getSelectedState()  then
                    expertPanel:setBackGroundColorOpacity( 35 )
                    for j=1,10 do
                        local panel = tolua.cast( gameContent[j]:getChildByName("Panel_Expert" .. i), "Layout" )
                        panel:setBackGroundColorOpacity( 70 )
                    end
                else  
                    expertPanel:setBackGroundColorOpacity( 0 )
                    for j=1,10 do
                        local panel = tolua.cast( gameContent[j]:getChildByName("Panel_Expert" .. i), "Layout" )
                        panel:setBackGroundColorOpacity( 35 )
                    end
                end
            end
        end
        followCheckBox:setSelectedState( expertInfo[i]["IsFollowed"] )
        followCheckBox:addTouchEventListener(followEventHandler)
    end
end

