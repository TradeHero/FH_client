module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local TeamConfig = require("scripts.config.Team")
local Logic = require("scripts.Logic").getInstance()


local mWidget
local mTotalHeight
local mHomeTeamName
local mAwayTeamName


function loadFrame( parent, jsonResponse )
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsFrame.json")
    parent:addChild( mWidget )

    local match = Logic:getSelectedMatch()
    mHomeTeamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( match["HomeTeamId"] ) )
    mAwayTeamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( match["AwayTeamId"] ) )

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Stats"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    mTotalHeight = 0
    addAgainstInfo( jsonResponse["Statistics"], contentContainer )
    addLast6Info( jsonResponse["Statistics"], contentContainer )
    addFormTableInfo( jsonResponse["Statistics"], contentContainer )

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
	tolua.cast( titleBar:getChildByName("Label_home"), "Label" ):setText( Constants.String.match_center.home )
	tolua.cast( titleBar:getChildByName("Label_VS"), "Label" ):setText( Constants.String.match_center.VS )
	tolua.cast( titleBar:getChildByName("Label_away"), "Label" ):setText( Constants.String.match_center.away )

	-- Add the against info
	local againstInfo = jsonResponse["LastGamesAgainst"]
	if againstInfo ~= nil and type( againstInfo ) == "table" and table.getn( againstInfo ) > 0 then
		-- Add the against info.
	else
		-- No data available.
		local nodata = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsNoContent.json")
		contentContainer:addChild( nodata )
		mTotalHeight = mTotalHeight + nodata:getSize().height
		tolua.cast( nodata:getChildByName("Label_nodata"), "Label" ):setText( Constants.String.match_center.against_content_nodata )
	end

	-- Add the diagram
	local diagram = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsVSDiagram.json")
	contentContainer:addChild( diagram )
	mTotalHeight = mTotalHeight + diagram:getSize().height
	tolua.cast( diagram:getChildByName("Label_home_wins"), "Label" ):setText( string.format( Constants.String.match_center.against_diagram_wins, mHomeTeamName ) )
	tolua.cast( diagram:getChildByName("Label_away_wins"), "Label" ):setText( string.format( Constants.String.match_center.against_diagram_wins, mAwayTeamName ) )
	tolua.cast( diagram:getChildByName("Label_draw"), "Label" ):setText( Constants.String.match_center.against_diagram_draw )
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
				local content = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsL6Content.json")
				contentContainer:addChild( content )
				mTotalHeight = mTotalHeight + content:getSize().height
				
				local dateLabel = tolua.cast( content:getChildByName("Label_date"), "Label" )
				local resultLabel = tolua.cast( content:getChildByName("Label_result"), "Label" )
				local teamNameLabel = tolua.cast( content:getChildByName("Label_teamName"), "Label" )
				local scoreLabel = tolua.cast( content:getChildByName("Label_score"), "Label" )

				dateLabel:setText( os.date( "%x", info["StartTime"] ))
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
	addMatchInfo( jsonResponse["LastHomeGames"] )
	

	-- Add away team last 6 info title.
	local titleBar = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterStatsL6AwayTitle.json")
	contentContainer:addChild( titleBar )
	mTotalHeight = mTotalHeight + titleBar:getSize().height
	tolua.cast( titleBar:getChildByName("Label_team"), "Label" ):setText( mAwayTeamName )
	tolua.cast( titleBar:getChildByName("Label_title"), "Label" ):setText( Constants.String.match_center.last6_away_title )

	-- Add home team last 6 info content.
	addMatchInfo( jsonResponse["LastAwayGames"] )

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

end

--[[
	"Statistics": {

      "LeagueTable": [

         {

            "TeamId": 32586,

            "Position": 3,

            "Points": 62,

            "NumberOfGames": 29,

            "NumberOfGamesWon": 19,

            "NumberOfGamesDrawn": 5,

            "NumberOfGamesLost": 5

         },

         {

            "TeamId": 32584,

            "Position": 10,

            "Points": 37,

            "NumberOfGames": 29,

            "NumberOfGamesWon": 9,

            "NumberOfGamesDrawn": 10,

            "NumberOfGamesLost": 10

         }

      ],

      "GoalStats": [

         {

            "TeamId": 32586,

            "OverTotal_15": 23,

            "OverTotal_25": 15,

            "OverTotal_35": 11,

            "UnderTotal_15": 23,

            "UnderTotal_25": 15,

            "UnderTotal_35": 11,

            "OverHome_15": 23,

            "OverHome_25": 15,

            "OverHome_35": 11,

            "UnderHome_15": 23,

            "UnderHome_25": 15,

            "UnderHome_35": 11,

            "OverAway_15": 23,

            "OverAway_25": 15,

            "OverAway_35": 11,

            "UnderAway_15": 23,

            "UnderAway_25": 15,

            "UnderAway_35": 11

         },

         {

            "TeamId": 32584,

            "OverTotal_15": 20,

            "OverTotal_25": 11,

            "OverTotal_35": 7,

            "UnderTotal_15": 20,

            "UnderTotal_25": 11,

            "UnderTotal_35": 7,

            "OverHome_15": 20,

            "OverHome_25": 11,

            "OverHome_35": 7,

            "UnderHome_15": 20,

            "UnderHome_25": 11,

            "UnderHome_35": 7,

            "OverAway_15": 20,

            "OverAway_25": 11,

            "OverAway_35": 7,

            "UnderAway_15": 20,

            "UnderAway_25": 11,

            "UnderAway_35": 7

         }

      ],

      "TeamForm": [

         {

            "TeamId": 32586,

            "NumberOfGames": 6,

            "NumberOfGamesWon": 4,

            "NumberOfGamesDrawn": 1,

            "NumberOfGamesLost": 1

         },

         {

            "TeamId": 32584,

            "NumberOfGames": 6,

            "NumberOfGamesWon": 2,

            "NumberOfGamesDrawn": 2,

            "NumberOfGamesLost": 2

         }

      ],

      "LastHomeGames": [

         {

            "StartTime": 1426953600,

            "OpponentTeamId": 32581,

            "HomeGoals": 2,

            "AwayGoals": 0

         },

         {

            "StartTime": 1425848400,

            "OpponentTeamId": 32578,

            "HomeGoals": 1,

            "AwayGoals": 1

         },

         {

            "StartTime": 1424548800,

            "OpponentTeamId": 32580,

            "HomeGoals": 3,

            "AwayGoals": 0

         },

         {

            "StartTime": 1423324800,

            "OpponentTeamId": 32576,

            "HomeGoals": 4,

            "AwayGoals": 0

         },

         {

            "StartTime": 1422129600,

            "OpponentTeamId": 32587,

            "HomeGoals": 3,

            "AwayGoals": 1

         }

      ],

      "LastAwayGames": [

         {

            "StartTime": 1428184800,

            "OpponentTeamId": 32595,

            "HomeGoals": 1,

            "AwayGoals": 1

         },

         {

            "StartTime": 1426538700,

            "OpponentTeamId": 32581,

            "HomeGoals": 0,

            "AwayGoals": 1

         },

         {

            "StartTime": 1425211200,

            "OpponentTeamId": 32578,

            "HomeGoals": 2,

            "AwayGoals": 0

         },

         {

            "StartTime": 1423860300,

            "OpponentTeamId": 32580,

            "HomeGoals": 2,

            "AwayGoals": 2

         },

         {

            "StartTime": 1422720000,

            "OpponentTeamId": 32576,

            "HomeGoals": 4,

            "AwayGoals": 1

         }

      ],

      "LastGamesAgainst": []
--]]