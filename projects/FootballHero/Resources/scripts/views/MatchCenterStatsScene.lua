module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local TeamConfig = require("scripts.config.Team")
local Logic = require("scripts.Logic").getInstance()


local mWidget
local mTotalHeight
local mHomeTeamId
local mAwayTeamId
local mHomeTeamName
local mAwayTeamName


function loadFrame( parent, jsonResponse )
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsFrame.json")
    parent:addChild( mWidget )

    local match = Logic:getSelectedMatch()
    mHomeTeamId = match["HomeTeamId"]
    mAwayTeamId = match["AwayTeamId"]
    mHomeTeamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mHomeTeamId ) )
    mAwayTeamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mAwayTeamId ) )

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Stats"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    mTotalHeight = 0
    addAgainstInfo( jsonResponse["Statistics"], contentContainer )
    addLast6Info( jsonResponse["Statistics"], contentContainer )
    addFormTableInfo( jsonResponse["Statistics"], contentContainer )
    addOverUnderTable( jsonResponse["Statistics"], contentContainer )
    addLeagueTable( jsonResponse["Statistics"], contentContainer )

    contentContainer:setInnerContainerSize( CCSize:new( 0, mTotalHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function addAgainstInfo( jsonResponse, contentContainer )
	-- Add the titla bar
	local titleBar = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsVSTitle.json")
	contentContainer:addChild( titleBar )
	mTotalHeight = mTotalHeight + titleBar:getSize().height
	tolua.cast( titleBar:getChildByName("Label_date"), "Label" ):setText( Constants.String.match_center.against_title_date )
	tolua.cast( titleBar:getChildByName("Label_VS"), "Label" ):setText( Constants.String.match_center.against_title )

	-- Add the against info
	local againstInfo = jsonResponse["LastGamesAgainst"]
	if againstInfo ~= nil and type( againstInfo ) == "table" and table.getn( againstInfo ) > 0 then
		-- Add the against info.
    for i = 1, table.getn( againstInfo ) do
        local info = againstInfo[i]
        local content = SceneManager.widgetFromJsonFile("scenes/MatchCenterStatsVSContent.json")
        contentContainer:addChild( content )
        mTotalHeight = mTotalHeight + content:getSize().height
        
        local dateLabel = tolua.cast( content:getChildByName("Label_date"), "Label" )
        local dateHome = tolua.cast( content:getChildByName("Label_home"), "Label" )
        local dateAway = tolua.cast( content:getChildByName("Label_away"), "Label" )
        local dateScore = tolua.cast( content:getChildByName("Label_score"), "Label" )

        dateLabel:setText( os.date( "%d/%m/%Y", info["StartTime"] ) )
        dateHome:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( info["HomeTeamId"] ) ) )
        dateAway:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( info["AwayTeamId"] ) ) )
        dateScore:setText( info["ScoreString"])
    end
	else
		-- No data available.
		local nodata = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsNoContent.json")
		contentContainer:addChild( nodata )
		mTotalHeight = mTotalHeight + nodata:getSize().height
		tolua.cast( nodata:getChildByName("Label_nodata"), "Label" ):setText( Constants.String.match_center.against_content_nodata )
	end

--[[
	-- Add the diagram
	local diagram = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsVSDiagram.json")
	contentContainer:addChild( diagram )
	mTotalHeight = mTotalHeight + diagram:getSize().height
	tolua.cast( diagram:getChildByName("Label_home_wins"), "Label" ):setText( string.format( Constants.String.match_center.against_diagram_wins, mHomeTeamName ) )
	tolua.cast( diagram:getChildByName("Label_away_wins"), "Label" ):setText( string.format( Constants.String.match_center.against_diagram_wins, mAwayTeamName ) )
	tolua.cast( diagram:getChildByName("Label_draw"), "Label" ):setText( Constants.String.match_center.against_diagram_draw )
--]]

  -- Add the gap
  local gap = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsBlankGap.json")
  contentContainer:addChild( gap )
  mTotalHeight = mTotalHeight + gap:getSize().height
end

function addLast6Info( jsonResponse, contentContainer )
	-- Add home team last 6 info title.
	local titleBar = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsL6HomeTitle.json")
	contentContainer:addChild( titleBar )
	mTotalHeight = mTotalHeight + titleBar:getSize().height
	tolua.cast( titleBar:getChildByName("Label_team"), "Label" ):setText( mHomeTeamName )
	tolua.cast( titleBar:getChildByName("Label_title"), "Label" ):setText( Constants.String.match_center.last6_home_title )

	-- Add home team last 6 info content.
	local addMatchInfo = function( info, isHome )
		if info ~= nil and type( info ) == "table" and table.getn( info ) > 0 then
			for i = 1, table.getn( info ) do
				local info = info[i]
				local content = SceneManager.widgetFromJsonFile("scenes/MatchCenterStatsL6Content.json")
				contentContainer:addChild( content )
				mTotalHeight = mTotalHeight + content:getSize().height
				
				local dateLabel = tolua.cast( content:getChildByName("Label_date"), "Label" )
				local resultLabel = tolua.cast( content:getChildByName("Label_result"), "Label" )
				local teamNameLabel = tolua.cast( content:getChildByName("Label_teamName"), "Label" )
				local scoreLabel = tolua.cast( content:getChildByName("Label_score"), "Label" )

				dateLabel:setText( os.date( "%d/%m/%Y", info["StartTime"] ) )
				teamNameLabel:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( info["OpponentTeamId"] ) ) )
				scoreLabel:setText( info["HomeGoals"]..":"..info["AwayGoals"] )
				local absGoals = info["HomeGoals"] - info["AwayGoals"]
				if not isHome then
					absGoals = absGoals * ( -1 )
				end
				if absGoals > 0 then
					resultLabel:setText( Constants.String.history.won )
				elseif absGoals < 0 then
					resultLabel:setText( Constants.String.history.lost )
				else
					resultLabel:setText( Constants.String.history.draw )
				end
			end
		else
			-- No data available.
			local nodata = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsNoContent.json")
			contentContainer:addChild( nodata )
			mTotalHeight = mTotalHeight + nodata:getSize().height
			tolua.cast( nodata:getChildByName("Label_nodata"), "Label" ):setText( Constants.String.match_center.against_content_nodata )
		end
	end
	addMatchInfo( jsonResponse["LastHomeGames"], true )
	

	-- Add away team last 6 info title.
	local titleBar = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsL6AwayTitle.json")
	contentContainer:addChild( titleBar )
	mTotalHeight = mTotalHeight + titleBar:getSize().height
	tolua.cast( titleBar:getChildByName("Label_team"), "Label" ):setText( mAwayTeamName )
	tolua.cast( titleBar:getChildByName("Label_title"), "Label" ):setText( Constants.String.match_center.last6_away_title )

	-- Add home team last 6 info content.
	addMatchInfo( jsonResponse["LastAwayGames"], false )

	-- Add the gap
	local gap = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsBlankGap.json")
	contentContainer:addChild( gap )
	mTotalHeight = mTotalHeight + gap:getSize().height
end

function addFormTableInfo( jsonResponse, contentContainer )
   -- Add the titla bar
   local formTable = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsFormTable.json")
   contentContainer:addChild( formTable )
   mTotalHeight = mTotalHeight + formTable:getSize().height
   tolua.cast( formTable:getChildByName("Label_homeTeam"), "Label" ):setText( mHomeTeamName )
   tolua.cast( formTable:getChildByName("Label_awayTeam"), "Label" ):setText( mAwayTeamName )
   tolua.cast( formTable:getChildByName("Label_formTable"), "Label" ):setText( Constants.String.match_center.formTable_title )
   tolua.cast( formTable:getChildByName("Label_P1"), "Label" ):setText( Constants.String.match_center.formTable_played )
   tolua.cast( formTable:getChildByName("Label_P2"), "Label" ):setText( Constants.String.match_center.formTable_played )
   tolua.cast( formTable:getChildByName("Label_W1"), "Label" ):setText( Constants.String.match_center.formTable_won )
   tolua.cast( formTable:getChildByName("Label_W2"), "Label" ):setText( Constants.String.match_center.formTable_won )
   tolua.cast( formTable:getChildByName("Label_D1"), "Label" ):setText( Constants.String.match_center.formTable_draw )
   tolua.cast( formTable:getChildByName("Label_D2"), "Label" ):setText( Constants.String.match_center.formTable_draw )
   tolua.cast( formTable:getChildByName("Label_L1"), "Label" ):setText( Constants.String.match_center.formTable_lost )
   tolua.cast( formTable:getChildByName("Label_L2"), "Label" ):setText( Constants.String.match_center.formTable_lost )
   tolua.cast( formTable:getChildByName("Label_total"), "Label" ):setText( Constants.String.match_center.total )
   tolua.cast( formTable:getChildByName("Label_home"), "Label" ):setText( Constants.String.match_center.home )
   tolua.cast( formTable:getChildByName("Label_away"), "Label" ):setText( Constants.String.match_center.away )

   local formTableData = jsonResponse["TeamForm"]
   if formTableData ~= nil and type( formTableData ) == "table" and table.getn( formTableData ) > 0 then
      for i = 1, table.getn( formTableData ) do
         local teamFormTableData = formTableData[i]
         if teamFormTableData ~= nil and type( teamFormTableData ) == "table" then
            local suffix
            if teamFormTableData["TeamId"] == mHomeTeamId then
              suffix = "1"
            else
              suffix = "2"
            end

            tolua.cast( formTable:getChildByName("Label_P_total"..suffix), "Label" ):setText( teamFormTableData["NumberOfGames"] )
            tolua.cast( formTable:getChildByName("Label_W_total"..suffix), "Label" ):setText( teamFormTableData["NumberOfGamesWon"] )
            tolua.cast( formTable:getChildByName("Label_D_total"..suffix), "Label" ):setText( teamFormTableData["NumberOfGamesDrawn"] )
            tolua.cast( formTable:getChildByName("Label_L_total"..suffix), "Label" ):setText( teamFormTableData["NumberOfGamesLost"] )

            tolua.cast( formTable:getChildByName("Label_P_home"..suffix), "Label" ):setText( teamFormTableData["NumberOfHomeGames"] )
            tolua.cast( formTable:getChildByName("Label_W_home"..suffix), "Label" ):setText( teamFormTableData["NumberOfHomeGamesWon"] )
            tolua.cast( formTable:getChildByName("Label_D_home"..suffix), "Label" ):setText( teamFormTableData["NumberOfHomeGamesDrawn"] )
            tolua.cast( formTable:getChildByName("Label_L_home"..suffix), "Label" ):setText( teamFormTableData["NumberOfHomeGamesLost"] )

            tolua.cast( formTable:getChildByName("Label_P_away"..suffix), "Label" ):setText( teamFormTableData["NumberOfAwayGames"] )
            tolua.cast( formTable:getChildByName("Label_W_away"..suffix), "Label" ):setText( teamFormTableData["NumberOfAwayGamesWon"] )
            tolua.cast( formTable:getChildByName("Label_D_away"..suffix), "Label" ):setText( teamFormTableData["NumberOfAwayGamesDrawn"] )
            tolua.cast( formTable:getChildByName("Label_L_away"..suffix), "Label" ):setText( teamFormTableData["NumberOfAwayGamesLost"] )
         end
      end
   end
end

function addOverUnderTable( jsonResponse, contentContainer )
   -- Add the titla bar
   local overunderTable = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterOverUnderTable.json")
   contentContainer:addChild( overunderTable )
   mTotalHeight = mTotalHeight + overunderTable:getSize().height
   tolua.cast( overunderTable:getChildByName("Label_homeTeam"), "Label" ):setText( mHomeTeamName )
   tolua.cast( overunderTable:getChildByName("Label_awayTeam"), "Label" ):setText( mAwayTeamName )
   tolua.cast( overunderTable:getChildByName("Label_overunder"), "Label" ):setText( Constants.String.match_center.overunder_title )
   tolua.cast( overunderTable:getChildByName("Label_played1"), "Label" ):setText( Constants.String.match_center.overunder_played )
   tolua.cast( overunderTable:getChildByName("Label_over1"), "Label" ):setText( Constants.String.match_center.overunder_over )
   tolua.cast( overunderTable:getChildByName("Label_under1"), "Label" ):setText( Constants.String.match_center.overunder_under )
   tolua.cast( overunderTable:getChildByName("Label_played2"), "Label" ):setText( Constants.String.match_center.overunder_played )
   tolua.cast( overunderTable:getChildByName("Label_over2"), "Label" ):setText( Constants.String.match_center.overunder_over )
   tolua.cast( overunderTable:getChildByName("Label_under2"), "Label" ):setText( Constants.String.match_center.overunder_under )
   tolua.cast( overunderTable:getChildByName("Label_total"), "Label" ):setText( Constants.String.match_center.total )
   tolua.cast( overunderTable:getChildByName("Label_home"), "Label" ):setText( Constants.String.match_center.home )
   tolua.cast( overunderTable:getChildByName("Label_away"), "Label" ):setText( Constants.String.match_center.away )

   local updateTable = function( lineStr )
      local lineNum = tonumber( lineStr )
      tolua.cast( overunderTable:getChildByName("Label_line"), "Label" ):setText( lineNum / 10 )

      local formTableData = jsonResponse["GoalStats"]
      if formTableData ~= nil and type( formTableData ) == "table" and table.getn( formTableData ) > 0 then
         for i = 1, table.getn( formTableData ) do
            local teamFormTableData = formTableData[i]
            if teamFormTableData ~= nil and type( teamFormTableData ) == "table" then
              local suffix
              if teamFormTableData["TeamId"] == mHomeTeamId then
                 suffix = "1"
              else
                 suffix = "2"
              end

              tolua.cast( overunderTable:getChildByName("Label_P_total"..suffix), "Label" ):setText( teamFormTableData["OverTotal_"..lineStr] + teamFormTableData["UnderTotal_"..lineStr] )
              tolua.cast( overunderTable:getChildByName("Label_O_total"..suffix), "Label" ):setText( teamFormTableData["OverTotal_"..lineStr] )
              tolua.cast( overunderTable:getChildByName("Label_U_total"..suffix), "Label" ):setText( teamFormTableData["UnderTotal_"..lineStr] )

              tolua.cast( overunderTable:getChildByName("Label_P_home"..suffix), "Label" ):setText( teamFormTableData["OverHome_"..lineStr] + teamFormTableData["UnderHome_"..lineStr] )
              tolua.cast( overunderTable:getChildByName("Label_O_home"..suffix), "Label" ):setText( teamFormTableData["OverHome_"..lineStr] )
              tolua.cast( overunderTable:getChildByName("Label_U_home"..suffix), "Label" ):setText( teamFormTableData["UnderHome_"..lineStr] )

              tolua.cast( overunderTable:getChildByName("Label_P_away"..suffix), "Label" ):setText( teamFormTableData["OverAway_"..lineStr] + teamFormTableData["UnderAway_"..lineStr] )
              tolua.cast( overunderTable:getChildByName("Label_O_away"..suffix), "Label" ):setText( teamFormTableData["OverAway_"..lineStr] )
              tolua.cast( overunderTable:getChildByName("Label_U_away"..suffix), "Label" ):setText( teamFormTableData["UnderAway_"..lineStr] )
            end
         end
      end
   end

   local lines = { "15", "25", "35" }
   local currentLineIndex = 1
   updateTable( lines[currentLineIndex] )
   
   -- Add the button handler.
   local leftHandler = function( sender, eventType )
      if eventType == TOUCH_EVENT_ENDED then
         currentLineIndex = currentLineIndex - 1
         if currentLineIndex < 1 then
            currentLineIndex = table.getn( lines )
         end

         updateTable( lines[currentLineIndex] )
      end
   end

   local rightHandler = function( sender, eventType )
      if eventType == TOUCH_EVENT_ENDED then
         currentLineIndex = currentLineIndex + 1
         if currentLineIndex > table.getn( lines ) then
            currentLineIndex = 1
         end

         updateTable( lines[currentLineIndex] )
      end
   end

   local leftPanel = overunderTable:getChildByName( "Panel_Arrow_Left")
   local leftButton = leftPanel:getChildByName( "Button_Left")
   local rightPanel = overunderTable:getChildByName( "Panel_Arrow_Right")
   local rightButton = rightPanel:getChildByName( "Button_Right")
   leftPanel:addTouchEventListener( leftHandler )
   leftButton:addTouchEventListener( leftHandler )
   rightPanel:addTouchEventListener( rightHandler )
   rightButton:addTouchEventListener( rightHandler )
end

function addLeagueTable( jsonResponse, contentContainer )
   local leagueTable = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterLeagueTable.json")
   contentContainer:addChild( leagueTable )
   mTotalHeight = mTotalHeight + leagueTable:getSize().height
   tolua.cast( leagueTable:getChildByName("Label_homeTeam"), "Label" ):setText( mHomeTeamName )
   tolua.cast( leagueTable:getChildByName("Label_awayTeam"), "Label" ):setText( mAwayTeamName )
   tolua.cast( leagueTable:getChildByName("Label_leagueTable"), "Label" ):setText( Constants.String.match_center.leagueTable_title )
   tolua.cast( leagueTable:getChildByName("Label_P1"), "Label" ):setText( Constants.String.match_center.formTable_played )
   tolua.cast( leagueTable:getChildByName("Label_P2"), "Label" ):setText( Constants.String.match_center.formTable_played )
   tolua.cast( leagueTable:getChildByName("Label_W1"), "Label" ):setText( Constants.String.match_center.formTable_won )
   tolua.cast( leagueTable:getChildByName("Label_W2"), "Label" ):setText( Constants.String.match_center.formTable_won )
   tolua.cast( leagueTable:getChildByName("Label_D1"), "Label" ):setText( Constants.String.match_center.formTable_draw )
   tolua.cast( leagueTable:getChildByName("Label_D2"), "Label" ):setText( Constants.String.match_center.formTable_draw )
   tolua.cast( leagueTable:getChildByName("Label_L1"), "Label" ):setText( Constants.String.match_center.formTable_lost )
   tolua.cast( leagueTable:getChildByName("Label_L2"), "Label" ):setText( Constants.String.match_center.formTable_lost )
   tolua.cast( leagueTable:getChildByName("Label_L1"), "Label" ):setText( Constants.String.match_center.formTable_lost )
   tolua.cast( leagueTable:getChildByName("Label_L2"), "Label" ):setText( Constants.String.match_center.formTable_lost )
   tolua.cast( leagueTable:getChildByName("Label_Pos1"), "Label" ):setText( Constants.String.match_center.pos )
   tolua.cast( leagueTable:getChildByName("Label_Pos2"), "Label" ):setText( Constants.String.match_center.pos )
   tolua.cast( leagueTable:getChildByName("Label_Pts1"), "Label" ):setText( Constants.String.match_center.pts )
   tolua.cast( leagueTable:getChildByName("Label_Pts2"), "Label" ):setText( Constants.String.match_center.pts )
   tolua.cast( leagueTable:getChildByName("Label_total"), "Label" ):setText( Constants.String.match_center.total_short )
   tolua.cast( leagueTable:getChildByName("Label_home"), "Label" ):setText( Constants.String.match_center.home_short )
   tolua.cast( leagueTable:getChildByName("Label_away"), "Label" ):setText( Constants.String.match_center.away_short )

   local leagueTableData = jsonResponse["LeagueTable"]
   if leagueTableData ~= nil and type( leagueTableData ) == "table" and table.getn( leagueTableData ) > 0 then
      for i = 1, table.getn( leagueTableData ) do
         local teamLeagueTableData = leagueTableData[i]
         if teamLeagueTableData ~= nil and type( teamLeagueTableData ) == "table" then
          local suffix
          if teamLeagueTableData["TeamId"] == mHomeTeamId then
            suffix = "1"
          else
            suffix = "2"
          end

          local posTotal = tolua.cast( leagueTable:getChildByName("Label_Pos_total"..suffix), "Label" )
          local posHome = tolua.cast( leagueTable:getChildByName("Label_Pos_home"..suffix), "Label" )
          local posAway = tolua.cast( leagueTable:getChildByName("Label_Pos_away"..suffix), "Label" )
          if teamLeagueTableData["PositionTotal"] > 0 then
            posTotal:setText( teamLeagueTableData["PositionTotal"] )
          else
            posTotal:setText( "--" )
          end

          if teamLeagueTableData["PositionHome"] > 0 then
            posHome:setText( teamLeagueTableData["PositionHome"] )
          else
            posHome:setText( "--" )
          end

          if teamLeagueTableData["PositionAway"] > 0 then
            posAway:setText( teamLeagueTableData["PositionAway"] )
          else
            posAway:setText( "--" )
          end

          tolua.cast( leagueTable:getChildByName("Label_P_total"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesTotal"] )
          tolua.cast( leagueTable:getChildByName("Label_W_total"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesWonTotal"] )
          tolua.cast( leagueTable:getChildByName("Label_D_total"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesDrawnTotal"] )
          tolua.cast( leagueTable:getChildByName("Label_L_total"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesLostTotal"] )
          tolua.cast( leagueTable:getChildByName("Label_Pts_total"..suffix), "Label" ):setText( teamLeagueTableData["PointsTotal"] )

          tolua.cast( leagueTable:getChildByName("Label_P_home"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesHome"] )
          tolua.cast( leagueTable:getChildByName("Label_W_home"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesWonHome"] )
          tolua.cast( leagueTable:getChildByName("Label_D_home"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesDrawnHome"] )
          tolua.cast( leagueTable:getChildByName("Label_L_home"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesLostHome"] )
          tolua.cast( leagueTable:getChildByName("Label_Pts_home"..suffix), "Label" ):setText( teamLeagueTableData["PointsHome"] )

          tolua.cast( leagueTable:getChildByName("Label_P_away"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesAway"] )
          tolua.cast( leagueTable:getChildByName("Label_W_away"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesWonAway"] )
          tolua.cast( leagueTable:getChildByName("Label_D_away"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesDrawnAway"] )
          tolua.cast( leagueTable:getChildByName("Label_L_away"..suffix), "Label" ):setText( teamLeagueTableData["NumberOfGamesLostAway"] )
          tolua.cast( leagueTable:getChildByName("Label_Pts_away"..suffix), "Label" ):setText( teamLeagueTableData["PointsAway"] )
         end 
      end
   end
end

--[[
	"Statistics": {

      "LeagueTable": [

         {

            "TeamId": 32588,

            "Position": 17,

            "Points": 26,

            "NumberOfGames": 29,

            "NumberOfGamesWon": 6,

            "NumberOfGamesDrawn": 8,

            "NumberOfGamesLost": 15

         },

         {

            "TeamId": 32583,

            "Position": 20,

            "Points": 18,

            "NumberOfGames": 29,

            "NumberOfGamesWon": 3,

            "NumberOfGamesDrawn": 9,

            "NumberOfGamesLost": 17

         }

      ],

      "GoalStats": [

         {

            "TeamId": 32588,

            "OverTotal_15": 18,

            "OverTotal_25": 13,

            "OverTotal_35": 6,

            "UnderTotal_15": 18,

            "UnderTotal_25": 13,

            "UnderTotal_35": 6,

            "OverHome_15": 18,

            "OverHome_25": 13,

            "OverHome_35": 6,

            "UnderHome_15": 18,

            "UnderHome_25": 13,

            "UnderHome_35": 6,

            "OverAway_15": 18,

            "OverAway_25": 13,

            "OverAway_35": 6,

            "UnderAway_15": 18,

            "UnderAway_25": 13,

            "UnderAway_35": 6

         },

         {

            "TeamId": 32583,

            "OverTotal_15": 22,

            "OverTotal_25": 12,

            "OverTotal_35": 5,

            "UnderTotal_15": 22,

            "UnderTotal_25": 12,

            "UnderTotal_35": 5,

            "OverHome_15": 22,

            "OverHome_25": 12,

            "OverHome_35": 5,

            "UnderHome_15": 22,

            "UnderHome_25": 12,

            "UnderHome_35": 5,

            "OverAway_15": 22,

            "OverAway_25": 12,

            "OverAway_35": 5,

            "UnderAway_15": 22,

            "UnderAway_25": 12,

            "UnderAway_35": 5

         }

      ],

      "TeamForm": [

         {

            "TeamId": 32588,

            "NumberOfGames": 6,

            "NumberOfGamesWon": 2,

            "NumberOfGamesDrawn": 2,

            "NumberOfGamesLost": 2,

            "NumberOfHomeGames": 3,

            "NumberOfHomeGamesWon": 1,

            "NumberOfHomeGamesDrawn": 1,

            "NumberOfHomeGamesLost": 1,

            "NumberOfAwayGames": 3,

            "NumberOfAwayGamesWon": 1,

            "NumberOfAwayGamesDrawn": 1,

            "NumberOfAwayGamesLost": 1

         },

         {

            "TeamId": 32583,

            "NumberOfGames": 6,

            "NumberOfGamesWon": 0,

            "NumberOfGamesDrawn": 0,

            "NumberOfGamesLost": 6,

            "NumberOfHomeGames": 3,

            "NumberOfHomeGamesWon": 0,

            "NumberOfHomeGamesDrawn": 0,

            "NumberOfHomeGamesLost": 3,

            "NumberOfAwayGames": 3,

            "NumberOfAwayGamesWon": 0,

            "NumberOfAwayGamesDrawn": 0,

            "NumberOfAwayGamesLost": 3

         }

      ],

      "LastHomeGames": [

         {

            "StartTime": 1427025600,

            "OpponentTeamId": 32579,

            "HomeGoals": 0,

            "AwayGoals": 0

         },

         {

            "StartTime": 1425744000,

            "OpponentTeamId": 32577,

            "HomeGoals": 3,

            "AwayGoals": 4

         },

         {

            "StartTime": 1424556000,

            "OpponentTeamId": 32582,

            "HomeGoals": 0,

            "AwayGoals": 2

         },

         {

            "StartTime": 1423255500,

            "OpponentTeamId": 32585,

            "HomeGoals": 2,

            "AwayGoals": 0

         },

         {

            "StartTime": 1422187200,

            "OpponentTeamId": 32589,

            "HomeGoals": 2,

            "AwayGoals": 2

         }

      ],

      "LastAwayGames": [

         {

            "StartTime": 1427050800,

            "OpponentTeamId": 32584,

            "HomeGoals": 3,

            "AwayGoals": 1

         },

         {

            "StartTime": 1426438800,

            "OpponentTeamId": 32595,

            "HomeGoals": 2,

            "AwayGoals": 0

         },

         {

            "StartTime": 1425069900,

            "OpponentTeamId": 32579,

            "HomeGoals": 1,

            "AwayGoals": 0

         },

         {

            "StartTime": 1423929600,

            "OpponentTeamId": 32577,

            "HomeGoals": 3,

            "AwayGoals": 0

         },

         {

            "StartTime": 1422741600,

            "OpponentTeamId": 32582,

            "HomeGoals": 1,

            "AwayGoals": 0

         }

      ],

      "LastGamesAgainst": []

   }
--]]