--------------------------------------------------------------------------------
--         FILE:  LocalizedString.lua
--        USAGE:  
--  DESCRIPTION:  Localization string file for FootballHero
--       AUTHOR:  Vincent Tee, <vincent@tradehero.mobi>
--      COMPANY:  MyHero
--      CREATED:  10/16/2014 11:40:20 AM GMT+8
--------------------------------------------------------------------------------


-----------------------------------------------------------------------------
-- Imports and dependencies
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
-- Module declaration
-----------------------------------------------------------------------------
local M = {}

M.en = {
  button = {
    create = "Create!",
    go = "Go!",
    join = "Join",
    play_now = "Play Now!",
    share = "Share",
  },
  chat_hint = "Tap here to start chatting!",
  chat_room_title = "Select Chatroom",
  choice = {
    leave_comp_desc = "Are you sure you want to leave the competition?",
    leave_comp_no = "Stay",
    leave_comp_title = "Leave Competition",
    leave_comp_yes = "Leave",
  },
  community = {
    copy = "COPY",
    desc_create_comp = "Predictions made in the selected league for the competition are automatically included in the competition.",
    disclaimer = "*** Disclaimer - Apple is not a sponsor nor is involved in any way.",
    enter_comp_code = "Enter Code",
    invite_code = "Invitation Code:",
    label_call_to_arm = "You are not in any \ncompetition yet.\n\nCreate a new competition and\nchallenge your friends now!",
    label_fb_share = "Facebook Share",
    label_give_desc = "Give a description",
    label_give_title = "Give a title to your competition",
    label_how_long = "How long will it last?",
    label_months  = "months",
    label_ongoing = "Ongoing",
    label_select_league = "Select a League",
    push = "PUSH NOTIFICATION",
    quit = "QUIT",
    rules = "RULES",
    share = "SHARE",
    title_competition = "Competitions",
    title_create_comp = "'s competition",
    title_description = "Description",
    title_details = "Details",
    title_duration = "Duration",
    title_eligible = "Eligible Leagues/Cups",
    title_leaderboard = "Leaderboard",
    title_joined_comp = "Joined Competitions",
    title_join_comp = "Join a Competition",
    title_rules = "Rules",
    title_top_performers = "Top Performers",
  },
  duration_to = "%s to %s",
  duration_forever = "%s until forever",
  email = "E-mail Address",
  error = {
    bad_email_format = "Bad email format.",
    blank_comp_id = "CompetitionId cannot be blank.",
    blank_desc = "Description cannot be blank.",
    blank_email = "Email is blank.",
    blank_league = "Selected League cannot be blank.",
    blank_password = "Password is blank.",
    blank_title = "Title cannot be blank.",
    blank_token = "Competition code cannot be blank.",
    blank_user_name = "User name is blank.",
    go_to_store = "Go to Store.",
    invalid_month = "Number of months is not a number.",
    login_failed = "Login failed. Please retry.",
    match_completed = "You have completed this match.",
    no_email = "You have no email account set up.",
    no_sms = "You have no SMS set up.",
    password_long = "Password too long.",
    password_not_match = "Passwords do not match.",
    password_short = "Password too short.",
    title_default = "Oops! You've got an error",
    updating_failed = "Update configurations failed. Please retry.",
  },
  event = {
    hint_qualified = "Qualified for prizes",
    hint_unqualified = "You must predict on %d more matches in this competition to qualify for prizes.",
    ranking_monthly = "Monthly",
    ranking_overall = "Season",
    ranking_dropdown_week = "Week %d: %d %s-%d %s",
    ranking_weekly = "Weekly",
    status_qualified = "- qualified",
    status_unqualified = "- unqualified",
  },
  favourite_team = "Your favourite team: ",
  first_name = "First Name",
  first_name_optional = "First Name (Optional)",
  football_hero = "FootballHero",
  friends = "Friends",
  history = {
    lost = "Lost",
    lost_colon = "Lost:",
    lost_small = "lost",
    predictions_all = "All Predictions",
    predictions_closed = "Closed Predictions",
    predictions_open = "Open Predictions",
    show_all = "Show All",
    total_goals = "Will total goals be %d or more?",
    which_team = "Which team will win?",
    win_by = "Will %s win by %d goals or more?",
    won = "Won",
    won_colon = "Won:",
    won_small = "won",
    no_open_prediction = "You have no\n open predictions yet.",
    no_open_prediction_others = "No open predictions",
    no_closed_prediction = "You have no\n closed predictions yet.",
    no_closed_prediction_others = "No closed predictions",
    total_points = "Total Points: %d",
    show_all = "Show All",
    stake = "Stake: %d Points",
    win_count = "%d of %d",
  },
  info = {
    announcement_title = "Announcement",
    competition_not_started = "Competition begins %s.",
    join_code_copied = "Join code is copied to clipboard.",
    new_version = "Please download new version and update!",
    odds_not_ready = "Odds will be updated soon.\nPlease check again later.",
    predictions_entered = "You have completed this match.",
    shared_to_fb = "Competition is shared to Facebook.",
    shared_to_fb_minigame = "You have shared your minigame to Facebook!",
    star_bet = "You can use 3 star stakes every 12 hours",
    title = "Info",
  },
  last_name = "Last Name",
  last_name_optional = "Last Name (Optional)",
  leaderboard = {
    gain_per_prediction_desc = "%d%% gain (%d predictions)",
    gain_per_prediction_title = "Gain per Prediction",
    high_score_desc = "%d won (%d predictions)",
    high_score_title = "High Score",
    me_score = "%d won",
    min_prediction = "At least %d predictions",
    stats = {
      gain_rate = "Gain %",
      last_ten = "Last 10",
      lose = "Lose",
      win = "Win",
      win_rate = "Win %",
    },
    win_ratio_desc = "%d%% won (%d predictions)",
    win_ratio_title = "Win Ratio",
  },
  league_chat = {
    english = "English League",
    spanish = "Spanish League",
    italian = "Italian League",
    german = "German League",
    uefa = "Uefa Leagues",
    others = "Other Competitions",
    feedback = "Feedback & Comments",
  },
  login_success = "Login success.\nLoading data, please wait...",
  marketing_message_1 = "Congratulations on making your first prediction!",
  marketing_message_2 = "Now challenge your friends in your own mini-competition!",
  marketing_message_3 = "Who will rise to the top?",
  match_list = {
    draw = "Draw",
    most_popular = "Most Popular",
    played = "Played",
    special = "Special",
    todays_matches = "Today's Matches",
    total_fans = "Total Fans",
  },
  match_prediction = {
    balance = "Balance",
    stake = "Stake",
    stand_to_win = "Stand to Win",
    team_to_win = "Which team will win?",
  },
  message_hint = "Type your message here",
  month = {
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  },
  minigame = {
    ask_friends_help = "Ask friends to help!",
    ask_more_friends = "Ask more friends!",
    call_to_action = "No one has scored any goals for you yet.",
    current_score = "Current Score:",
    failed_to_score = "failed to score any goals",
    friend_help = "friend(s) have helped you",
    goal_to_win = "%d goals remaining to win",
    helped_to_score = "has helped you to score %d goals",
    iPhone6_winner = "iPhone 6 Winner",
    no_one_won = "No one has won an iPhone 6 yet.",
    rules = "Rules",
    shoot_to_win_won = "You have won!",
    title = "Shoot-to-Win Challenge",
    winners = "Past Winners",
  },
  num_of_points = "%d Points",
  password = "Password",
  password_confirm = "Confirm Password",
  quit_title = "Are you sure you want to quit?",
  quit_desc = "Tap back again to quit.",
  quit_cancel = "Stay",
  select_fav_team = "Please select your favourite team.",
  settings = {
    push_notification = "Push Notification",
    sounds = "Sounds",
    send_feedback = "Send Feedback",
    faq = "FAQ",
    logout = "Logout",
  },
  share_body = "Can you beat me? Join my competition on FootballHero. Code: %s  www.footballheroapp.com/download",
  share_title = "Join %s's competition on FootballHero",
  support_email = "support@footballheroapp.com",
  support_title = "FootballHero - Support",
  today = "Today",
  top_performers = "Top Performers",
  unknown_name = "Unknown Name",
  unknown_team = "Unknown Team",
  updating_files = "Updating %s ...",
  user_name = "Username",
  vs = "VS",

}

M.zh = {
  
}

local modename = "LocalizedString"
local proxy = {}
local mt    = {
    __index = M,
    __newindex =  function (t ,k ,v)
        print("LocalizedString is read-only!")
    end
}
setmetatable(proxy,mt)
_G[modename] = proxy
package.loaded[modename] = proxy