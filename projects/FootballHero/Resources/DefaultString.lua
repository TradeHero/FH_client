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
StringDefaultSubTableList = {
  "button",
  "choice",
  "community",
  "error",
  "event",
  "history",
  "info",
  "leaderboard",
  "league_chat",
  "match_center",
  "match_list",
  "match_prediction",
  "month",
  "minigame",
  "spinWheel",
  "push_notification",
  "settings",
}

local StringsDefault = {
  button = {
    cancel = "Cancel",
    confirm = "Confirm!",
    create = "Create!",
    enable = "Enable",
    forget_password = "Forgot Password?",
    go = "Go!",
    join = "Join",
    no = "No",
    no_thanks = "No, thanks.",
    ok = "OK",
    play_now = "Play Now!",
    register = "Register",
    share = "Share",
    sign_in = "Sign In",
    yes = "Yes",
    rate_now = "Rate now",
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
  email_confirm = "E-mail Address Confirm",
  email_signin = "Sign in with Email",
  enter_email = "Please enter your email address.",
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
    email_not_match = "Email do not match.",
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
    predict_now = "Predict Now",
    prizes = "Prizes",
    ranking_monthly = "Monthly",
    ranking_overall = "Season",
    ranking_dropdown_week = "Week %d: %d %s-%d %s",
    ranking_weekly = "Weekly",
    status_qualified = "- qualified",
    status_unqualified = "- unqualified",
    total_players = "Total Players",
  },
  facebook_signin = "Sign in with Facebook",
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
    leave_comment1 = "Let us know how we could improve!",
    leave_comment2 = "Email us your feedback",
    like_fh1 = "Do you like FootballHero so far?",
    like_fh2 = "Please take a moment to rate the app.",
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
    stats_gain_rate = "Gain %",
    stats_l = "L",
    stats_last_ten = "Last 10",
    stats_lose = "Lose",
    stats_w = "W",
    stats_win = "Win",
    stats_win_rate = "Win %",
    win_ratio_desc = "%d%% won (%d predictions)",
    win_ratio_title = "Win Ratio",
  },
  league_chat = {
    english = "English League",
    facebook = "Like us on Facebook",
    feedback = "Feedback & Comments",
    german = "German League",
    italian = "Italian League",
    others = "Other Competitions",
    spanish = "Spanish League",
    uefa = "Uefa Leagues",
  },
  login_success = "Login success.\nLoading data, please wait...",
  marketing_message_1 = "Congratulations on making your first prediction!",
  marketing_message_2 = "Now challenge your friends in your own mini-competition!",
  marketing_message_3 = "Who will rise to the top?",
  match_center = {
    just_now = "Just Now",
    less = "less",
    load_comments = "Load more comments...",
    make_prediction = "Make a prediction!",
    more = "More",
    played = "Played %d out of %d",
    prediction_made = "Prediction made",
    share_body = "", -- TODO
    share_title = "", -- TODO
    time_days = "%d days",
    time_hours = "%d hrs",
    time_minutes = "%d mins",
    title = "Match Center",
    title_discussion = "Discussion",
    title_meetings = "Last Meetings",
    write_comment = "Write a comment...",
    write_discussion = "Write a new discussion...",
  },
  match_list = {
    draw = "Draw",
    most_popular = "Most Popular",
    played = "Played",
    special = "Special",
    todays_matches = "Today's Matches",
    total_fans = "Total Fans",
    upcoming_matches = "Upcoming Matches",
  },
  match_prediction = {
    balance = "Balance",
    facebook = "Facebook",
    hint_tap = "Tap to make a prediction!",
    prediction_summary = "Prediction Summary",
    share = "Share with your friends",
    stake = "Stake",
    stand_to_win = "Stand to Win",
    team_to_win = "Which team will win?",
    will_total_goals = "Will total goals be %d or more?",
    will_win_by = "Will %s win by %d goals or more?",
    win = "Win",
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
    iPhone6_winner = "Samsung Note Edge Winner",
    no_one_won = "No one has won an Samsung Note Edge yet.",
    rules = "Rules",
    shoot_to_win_won = "You have won!",
    title = "Shoot-to-Win Challenge",
    winners = "Past Winners",
  },
  spinWheel = {
    wheel_title = "Spin-the-Wheel",
    spin_daily = "One spin daily",
    spin_bonus = "BONUS SPIN",
    balance_title = "Balance",
    winners = "Past Winners",
    no_one_won = "No one has won any prize yet.",
    ticket_balance_1 = "%d ticket",
    ticket_balance_2 = "%d tickets",
    money_balance = "US$ %s Amazon Gift Card",
    money_payout_success_notification = "Your request has been processed. Please allow 2 - 4 weeks to receive the gift card via your email address.",
    leave_message = "Come back tomorrow for another spin.",
    claimVirtualPrize = "Congratulations! You have won a %s. Please contact our support.",
  },
  num_of_points = "%d Points",
  optional = "(Optional)",
  password = "Password",
  password_confirm = "Confirm Password",
  push_notification = {
    match_result = ". Match results",
    new_participant = ". New participant alert",
    points_won = ". Points won or lost",
    prediction_summary = ". Predictions' summary",
    question_competition = "Do you want to receive push notification for this competition?",
    question_prediction = "Do you want to receive push notification for all your predictions?",
    receive = "You will receive:",
  },
  quit_title = "Are you sure you want to quit?",
  quit_desc = "Tap back again to quit.",
  quit_cancel = "Stay",
  settings = {
    faq = "FAQ",
    general = "General News",
    logout = "Logout",
    prediction = "Prediction",
    push_notification = "Push Notification",
    send_feedback = "Send Feedback",
    sound_effects = "Sound Effects",
    sound_settings = "Sound Settings",
    sounds = "Sounds",
    title = "Settings",
  },
  share_body = "Can you beat me? Join my competition on FootballHero. Code: %s  www.footballheroapp.com/download",
  share_title = "Join %s's competition on FootballHero",
  share_type_email = "Email",
  share_type_facebook = "Facebook",
  share_type_SMS = "SMS",
  share_type_title = "Share your competition using...",
  support_email = "support@footballheroapp.com",
  support_title = "FootballHero - Support",
  today = "Today",
  terms_agree = "By Signing in, you are indicating that you have read and agree to FOOTBALL HERO'S",
  top_performers = "Top Performers",
  unknown_name = "Unknown Name",
  unknown_team = "Unknown Team",
  updating_files = "Updating %s ...",
  user_name = "Username",
  vs = "VS",
}

local modename = "DefaultString"
local proxy = {}
local mt    = {
    __index = StringsDefault,
    __newindex =  function (t ,k ,v)
        print("StringsDefault are read-only!")
    end
}
setmetatable(proxy,mt)
_G[modename] = proxy
package.loaded[modename] = proxy

function extendsStringDefault()
  local mt = {
    __index = function( table, key )
        if StringsDefault[key] then
          return StringsDefault[key]
        end
      return "Nil"
    end
  } 
  return mt
end

function extendsStringDefaultSubTable( name )
  local mt = {
    __index = function( table, key ) 
        if StringsDefault[name][key] then
          return StringsDefault[name][key]
        end
      return "Nil"
    end
  }
  return mt
end