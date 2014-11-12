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
  chat_hint = "Tap here to start chatting!",
  choice = {
    leave_comp_desc = "Are you sure you want to leave the competition?",
    leave_comp_title = "Leave Competition",
  },
  community = {
    title_competition = "Competitions",
    title_leaderboard = "Leaderboard",
    label_call_to_arm = "You are not in any \ncompetition yet.\n\nCreate a new competition and\nchallenge your friends now!",
  },
  create_comp_desc = "Predictions made in the selected league for the competition are automatically included in the competition.",
  create_comp_title = "'s competition",
  duration_to = "%s to %s",
  duration_forever = "%s until forever",
  email = "E-mail Address",
  enter_comp_code = "Enter Code",
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
    updating_failed = "Update configurations failed. Please retry.",
  },
  event = {
    hint_qualified = "Qualified for prizes",
    hint_unqualified = "Predict on %d more matches to qualify",
    status_qualified = "- qualified",
    status_unqualified = "- unqualified",
  },
  favourite_team = "Your favourite team: ",
  first_name = "First Name",
  first_name_optional = "First Name (Optional)",
  friends = "Friends",
  history = {
    lost = "Lost",
    lost_colon = "Lost:",
    lost_small = "lost",
    predictions_closed = "Closed Predictions",
    predictions_open = "Open Predictions",
    total_goals = "Will total goals be %d or more?",
    which_team = "Which team will win?",
    win_by = "Will %s win by %d goals or more?",
    won = "Won",
    won_colon = "Won:",
    won_small = "won",
    no_open_prediction = "You have no\n open predictions yet.",
    no_closed_prediction = "You have no\n closed predictions yet.",
  },
  info = {
    new_version = "Please download new version and update!",
    shared_to_fb = "Competition is shared to Facebook.",
    title = "Info",
    join_code_copied = "Join code is copied to clipboard.",
    predictions_entered = "You have completed this match.",
  },
  last_name = "Last Name",
  last_name_optional = "Last Name (Optional)",
  leaderboard = {
    gain_per_prediction_desc = "%d%% gain (%d predictions)",
    gain_per_prediction_title = "Gain per Prediction",
    high_score_desc = "%d won (%d predictions)",
    high_score_title = "High Score",
    win_ratio_desc = "%d%% won (%d predictions)",
    win_ratio_title = "Win Ratio",
  },
  login_success = "Login success.\nLoading data, please wait...",
  message_hint = "Type your message here",
  most_popular = "Most Popular",
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