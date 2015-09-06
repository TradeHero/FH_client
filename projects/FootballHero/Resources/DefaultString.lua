--------------------------------------------------------------------------------
--         FILE:  LocalizedString.lua
--        USAGE:  
--  DESCRIPTION:  Localization string file for SportsHero
--                Only allow two tiers table. The third tier will be ignored.
--       AUTHOR:  Vincent Tee, <vincent@tradehero.mobi>
--      COMPANY:  MyHero
--      CREATED:  10/16/2014 11:40:20 AM GMT+8
--------------------------------------------------------------------------------

StringDefaultSubTableList = {
  "button",
  "choice",
  "community",
  "error",
  "serverError",
  "event",
  "handicap",
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
  "languages",
  "share",
  "sports",
}

StringsDefault = {
  button = {
    cancel = "Cancel",
    confirm = "Confirm!",
    create = "Create!",
    enable = "Enable",
    existing_user = "Existing User",
    forget_password = "Forgot Password?",
    go = "Go!",
    join = "Join",
    new_user = "New User",
    no = "No",
    no_thanks = "No, thanks.",
    ok = "OK",
    play_now = "Play Now!",
    predict = "Predict!",
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
    title = "Community",
    all_competitions = "All Leagues & Cups",
    copy = "COPY",
    desc_create_comp = "Predictions made in the selected league for the competition are automatically included in the competition.",
    disclaimer = "*** Disclaimer - Apple is not a sponsor nor is involved in any way.",
    enter_comp_code = "Enter Code",
    invite_code = "Invitation Code:",
    label_call_to_arm = "You are not in any \ncompetition yet.",
    label_fb_share = "Facebook Share",
    label_give_desc = "Give a description",
    label_give_title = "Give a title to your competition",
    label_how_long = "How long will it last?",
    label_months  = "months",
    label_new = "New",
    label_ongoing = "Ongoing",
    label_select_league = "Select a League",
    push = "PUSH NOTIFICATION",
    quit = "QUIT",
    rules = "RULES",
    share = "SHARE",
    title_competition = "Competitions",
    title_create_competition = "Create Competition",
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
    title_highlight = "Highlights",
    title_expert = "Team Expert",
    highlight_subtitle = "YOU ARE NOW LEAVING SportsHero",
    highlight_disclaimer = "SportsHero is not the owner of the content that you are about to watch.\n\nThe third party site and content you are about to visit is not hosted or created by SportsHero.\nFootballHero is not responsible for and cannot be held liable or accountable for any of the content hosted on the third party site.",
    title_video = "Videos",
    highlight_share_text = "Watch the highlights: %s %d - %d %s",
    video_share_text = "Watch: %s",
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
    video_not_available = "This video is no longer available.",
  },
  serverError = {
    DEFAULT = "Oops! Please try again...",
    GENERAL_1 = "Oops! We're sorry. Please try again.",
    GENERAL_2 = "Oops! Your User ID is invalid.",
    SIGNIN_1 = "Oops! Your email is invaild.",
    SIGNIN_2 = "Incorrect username or password.",
    SIGNIN_3 = "Email address does not exist.",
    SIGNIN_4 = "Email and/or password cannot be empty.",
    SIGNIN_6 = "Your account is banned!",
    SIGNIN_7 = "E-Mail already taken.",
    SIGNIN_8 = "Password too short. Minimum 6 characters!",
    SIGNIN_9 = "Password too long. Maximum 160 characters!",
    SIGNIN_10 = "Please fill in a display name.",
    SIGNIN_11 = "Display Name must be miniumum 3 characters long!",
    SIGNIN_12 = "Display Name must be maximum 20 characters long!",
    VERSION_1 = "Please update latest version in the app store.",
    VERSION_2 = "New features added! Please update SportsHero in the app store.",
    FACEBOOK_1 = "Oops! There seems to be an error. Please try again.",
    FACEBOOK_2 = "Oops! You are not connected to Facebook.",
    FACEBOOK_3 = "Oops! This Facebook account is already in use.",
    FACEBOOK_4 = "Oops! This Facebook account is already in use.",
    FACEBOOK_5 = "Oops! We're sorry. Please try again later.",
    COUPON_1 = "Stake not allowed.",
    COUPON_2 = "Too many predictions on coupon.",
    COUPON_3 = "No predictions on coupon. Cannot place empty coupon.",
    COUPON_4 = "One or more predictions were already played before.",
    COUPON_5 = "Last big bet was less than 12 hours ago.",
    LEADERBOARD_1 = "Oops! Invalid leaderboard. Please try again.",
    LEADERBOARD_2 = "Oops! Please try again.",
    LEAGUE_1 = "Oops! Try a different league.",
    COUNTRY_1 = "Oops! Try a different country.",
    COMPETITION_1 = "You already created a competition with that name before.",
    COMPETITION_2 = "The competition does not exist.",
    COMPETITION_3 = "Join token does not exist.",
    COMPETITION_4 = "You are already enrolled in this competition.",
    COMPETITION_5 = "User is not enrolled in this competition.",
    COMPETITION_6 = "No stats data for this year/month/week combination found.",
    COMPETITION_7 = "You cannot join a competition that is in preview mode.",
    COMPETITION_8 = "Share Bonus already claimed.",
    DISCUSSION_1 = "Oops! Please try again.",
    DISCUSSION_2 = "Oops! Please try again.",
    DISCUSSION_3 = "Oops! Please try again.",
    WHEEL_1 = "Your last spin was less than 24 hours ago.",
    WHEEL_2 = "Price probabilities don't add up.",
    WHEEL_3 = "Could not find a prize.",
    WHEEL_4 = "User has never spinned the wheel.",
    WHEEL_5 = "Requested amount is lower than minimum payout.",
    WHEEL_6 = "The requested amount is bigger than your balance.",
  },
  event = {
    hint_qualified = "Qualified for prizes",
    hint_unqualified = "You must predict on %d more matches in this competition to qualify for prizes.",
    predict_now = "Predict Now",
    prizes = "Prizes",
    ranking_monthly = "Monthly",
    ranking_overall = "Season",
    ranking_dropdown_month = "%1$s %2$s",
    ranking_dropdown_week = "Week %1$d: %2$d %3$s-%4$d %5$s",
    ranking_weekly = "Weekly",
    status_qualified = "- qualified",
    status_unqualified = "- unqualified",
    total_players = "Total Players",
  },
  facebook_signin = "Sign in with Facebook",
  first_name = "First Name",
  first_name_optional = "First Name (Optional)",
  football_hero = "SportsHero",
  friends = "Friends",
  handicap = {
    h0_yes = "You win if %s wins.\nYour bet is refunded on a draw.",
    h0_no = "You win if %s wins.\nYour bet is refunded on a draw.",
    h0_25_yes = "You win if %s wins.\nYou lose half your bet if %s draws.",
    h0_25_no = "You win if %s wins.\nYou win half your bet if %s draws.",
    h0_5_yes = "You win if %s wins.",
    h0_5_no = "You win if %s wins or draws.",
    h0_75_yes = "You win if %s wins by 2 goals or more.\nYou win half your bet if %s wins by 1 goal.",
    h0_75_no = "You win if %s wins or draws.\nYou lose half your bet if %s loses by 1 goal.",
    h1_yes = "You win if %s wins by 2 goals or more.\nYour bet is refunded if %s wins by 1 goal.",
    h1_no = "You win if %s wins or draw.\nYour bet is refunded if %s loses by 1 goal.",
    h1_25_yes = "You win if %s wins by 2 goals or more.\nYou lose half your bet if %s wins by 1 goal.",
    h1_25_no = "You win if %s draws or wins.\nYou win half your bet if %s loses by 1 goal.",
    h1_5_yes = "You win if %s wins by 2 goals or more.",
    h1_5_no = "You win if %s wins, draw or loses by 1 goal.",
    h1_75_yes = "You win if %s wins by 3 goals or more.\nYou win half your bet if %s wins by 2 goal.",
    h1_75_no = "You win if %s wins or draw.\nYou lose half your bet if %s loses by 2 goals.",
    hX_yes = "You win if %TeamName% wins by %LinePulsOne% goals or more.\nYour bet is refunded if %TeamName% wins by %Line% goals.",
    hX_no = "You win if %TeamName% wins, draws or loses by %LineMinusOne% goals or less.\nYour bet is refunded if %TeamName% loses by %Line% goals.",
    hX_25_yes = "You win if %TeamName% wins by %LinePulsOne% goals or more.\nYou lose half your bet if %TeamName% wins by %Line% goals.",
    hX_25_no = "You win if %TeamName% wins, draws or loses by %LineMinusOne% goals or less.\nYou win half your bet if %TeamName% loses by %Line% goals.",
    hX_5_yes = "You win if %TeamName% wins by %LinePulsOne% goals or more.",
    hX_5_no = "You win if %TeamName% wins, draws or loses by %Line% goals or less.",
    hX_75_yes = "You win if %TeamName% wins by %LinePulsTwo% goals or more.\nYou win half your bet if %TeamName% win by %LinePulsOne% goals.",
    hX_75_no = "You win if %TeamName% wins, draws or loses by %Line% goals or less.\nYou lose half your bet if %TeamName% loses by %LinePulsOne% goals.",
    name = "Asian Handicap",
    title = "Payment Outcome Summary",
    predict_on = "Predict on %s",
  },
  handicap_baseball = {
    h0_yes = "You win if %s wins.\nYour bet is refunded on a draw.",
    h0_no = "You win if %s wins.\nYour bet is refunded on a draw.",
    h0_25_yes = "You win if %s wins.\nYou lose half your bet if %s draws.",
    h0_25_no = "You win if %s wins.\nYou win half your bet if %s draws.",
    h0_5_yes = "You win if %s wins.",
    h0_5_no = "You win if %s wins.",
    h0_75_yes = "You win if %s wins by 2 runs or more.\nYou win half your bet if %s wins by 1 run.",
    h0_75_no = "You win if %s wins.\nYou lose half your bet if %s loses by 1 run.",
    h1_yes = "You win if %s wins by 2 runs or more.\nYour bet is refunded if %s wins by 1 run.",
    h1_no = "You win if %s wins.\nYour bet is refunded if %s loses by 1 run.",
    h1_25_yes = "You win if %s wins by 2 runs or more.\nYou lose half your bet if %s wins by 1 run.",
    h1_25_no = "You win if %s or wins.\nYou win half your bet if %s loses by 1 run.",
    h1_5_yes = "You win if %s wins by 2 runs or more.",
    h1_5_no = "You win if %s wins or loses by 1 run.",
    h1_75_yes = "You win if %s wins by 3 runs or more.\nYou win half your bet if %s wins by 2 run.",
    h1_75_no = "You win if %s wins.\nYou lose half your bet if %s loses by 2 runs.",
    hX_yes = "You win if %TeamName% wins by %LinePulsOne% runs or more.\nYour bet is refunded if %TeamName% wins by %Line% runs.",
    hX_no = "You win if %TeamName% wins or loses by %LineMinusOne% runs or less.\nYour bet is refunded if %TeamName% loses by %Line% runs.",
    hX_25_yes = "You win if %TeamName% wins by %LinePulsOne% runs or more.\nYou lose half your bet if %TeamName% wins by %Line% runs.",
    hX_25_no = "You win if %TeamName% wins or loses by %LineMinusOne% runs or less.\nYou win half your bet if %TeamName% loses by %Line% runs.",
    hX_5_yes = "You win if %TeamName% wins by %LinePulsOne% runs or more.",
    hX_5_no = "You win if %TeamName% wins or loses by %Line% runs or less.",
    hX_75_yes = "You win if %TeamName% wins by %LinePulsTwo% runs or more.\nYou win half your bet if %TeamName% win by %LinePulsOne% runs.",
    hX_75_no = "You win if %TeamName% wins or loses by %Line% runs or less.\nYou lose half your bet if %TeamName% loses by %LinePulsOne% runs.",
    name = "Handicap",
    title = "Payment Outcome Summary",
    predict_on = "Predict on %s",
  },
  history = {
    title = "My Picks",
    lost = "Lost",
    lost_colon = "Lost:",
    lost_small = "lost",
    predictions_all = "All Predictions",
    predictions_closed = "Closed Predictions",
    predictions_open = "Open Predictions",
    predictions_team = "Team Expert's Picks",
    push_colon = "Push:",
    refund = "refunded",
    show_all = "Show All",
    total_goals = "Will total goals be %d or more?",
    which_team = "Which team will win?",
    win_by = "Will %s win by %s goals or more?",
    win_by_line0 = "Will %s win on level handicap?",
    total_goals_baseball = "Will total runs be %d or more?",
    win_by_baseball = "Will %s win by %s runs or more?",
    win_by_line0_baseball = "Will %s win on level handicap?",
    won = "Won",
    won_colon = "Won:",
    won_small = "won",
    no_open_prediction = "You have no\n open predictions yet.",
    no_open_prediction_others = "No open predictions",
    no_closed_prediction = "You have no\n closed predictions yet.",
    no_closed_prediction_others = "No closed predictions",
    total_points = "%d",
    follows = "%d",
    show_all = "Show All",
    stake = "Stake: %d Points",
    win_count = "%d of %d",
    draw = "Draw",
  },
  info = {
    announcement_title = "Announcement",
    coming_soon = "Coming Soon!",
    competition_not_started = "Competition begins %s.",
    join_code_copied = "Join code is copied to clipboard.",
    leave_comment1 = "Let us know how we could improve!",
    leave_comment2 = "Email us your feedback",
    like_fh1 = "Do you like SportsHero so far?",
    like_fh2 = "Please take a moment to rate the app.",
    new_version = "Please download new version and update!",
    odds_not_ready = "Odds will be updated soon.\nPlease check again later.",
    predictions_entered = "You have completed this match.",
    shared_to_fb = "Competition is shared to Facebook.",
    shared_to_fb_minigame = "You have shared your minigame to Facebook!",
    single_discussion = "You can only write 1 discussion per match.",
    star_bet = "You can use 3 star stakes every 12 hours",
    title = "Info",
  },
  languages = {
    english = "English",
    indonesian = "Bahasa Indonesia",
    chinese = "中文",
    arabic = "العربية",
    thailand = "ไทย",
    spanish = "Spanish",
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
    stats_league = "League",
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
    group_chat = "Group Chat",
    bahasa_chat = "Bahasa Indonesia",
    thai_chat = "Thai",
    chinese_chat = "Chinese",
    arabic_chat = "Arabic",
    football_chat = "Football",
    baseball_chat = "Baseball",
  },
  login_success = "Login success.\nLoading data, please wait...",
  marketing_message_1 = "Congratulations on making your first prediction!",
  marketing_message_2 = "Now challenge your friends in your own mini-competition!",
  marketing_message_3 = "Who will rise to the top?",
  match_center = {
    just_now = "Just Now",
    less = "less",
    load_comments = "Load more comments...",
    make_prediction = "Predict Now!",
    more = "More",
    played = "Played",
    played_out_of = "%d out of %d",
    post = "Post",
    prediction_made = "Prediction made",
    share_body = "", -- TODO
    share_title = "", -- TODO
    total = "Total",
    home = "Home",
    away = "Away",
    pos = "Pos",
    pts = "Pts",
    total_short = "T",
    home_short = "H",
    away_short = "A",
    VS = "VS",
    time_days = "%d days",
    time_hours = "%d hrs",
    time_minutes = "%d mins",
    title = "Match Center",
    title_discussion = "Discussion",
    title_meetings = "Statistics",
    write_comment = "Write a comment...",
    write_discussion = "Write a new discussion...",
    against_title_date = "Date",
    against_title = "Last Meetings",
    against_content_nodata = "No data available.",
    against_diagram_wins = "%s wins",
    against_diagram_draw = "Draw",
    last6_home_title = "Last 10 Home Results",
    last6_away_title = "Last 10 Away Results",
    formTable_title = "Form Table",
    formTable_played = "P",
    formTable_won = "W",
    formTable_draw = "D",
    formTable_lost = "L",
    overunder_title = "Over/Under",
    overunder_played = "Played",
    overunder_over = "Over",
    overunder_under = "Under",
    leagueTable_title = "League Table",
  },
  match_list = {
    date = "%b %d, %A",
    draw = "Draw",
    less_regions = "Less Regions",
    match_ended = "Match Ended",
    match_lost = "LOST: %d Pts",
    match_started = "Match Started",
    match_won = "WON: %d Pts",
    more_regions = "More Regions",
    most_discussed = "Most Discussed",
    most_popular = "Most Popular",
    team_expert = "Team Expert",
    played = "Played",
    special = "Special",
    todays_matches = "Today's Matches",
    total_fans = "Fans",
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
    will_win_by = "Will %s win by %s goals or more?",
    will_win_by_line0 = "Will %s win on level handicap?",
    will_total_goals_baseball = "Will total runs be %d or more?",
    will_win_by_baseball = "Will %s win by %s runs or more?",
    will_win_by_line0_baseball = "Will %s win on level handicap?",
    win = "Win",
    answer_match_win = "I have predicted %s to win.",
    answer_match_draw = "I have predicted a draw.",
    answer_total_goal_yes = "I have predicted the game to have %s goals or more.",
    answer_total_goal_no = "I have predicted the game to have %s goals or less.",
    answer_asian_handicap_yes = "I have predicted %s wins by %s goals or more.",
    answer_asian_handicap_no = "I have predicted %s wins by %s goals or less.",
  },
  message_hint = "Type your message here",
  month = {
    m1 = "January",
    m2 = "February",
    m3 = "March",
    m4 = "April",
    m5 = "May",
    m6 = "June",
    m7 = "July",
    m8 = "August",
    m9 = "September",
    m10 = "October",
    m11 = "November",
    m12 = "December",
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
  lucky8 = {
    draw = "Draw",
    game_center_title = "Game Center",
    lucky8_title     = "Lucky 8",
    lucky8_sub_des   = "Predict random 8 games daily and win $500 if you guess all 8 matches correctly!",
    btn_picks_title  = "Your Picks",
    btn_rules_title  = "Rules",
    btn_submit_title = "Submit!",
    won_prize_btn_claim = "Claim prize",
    won_prize_won_txt = "WON",
    game_started = "game started",
    pending = "Pending confirmation",
    select_all_matches = "please select all matches.",
    lucky8_rule = "1. You are allowed one entry per day.\n\n2. Predict 8 games correctly and win prizes.\n\n3. Getting all 8 matches correct will win you $500* while getting 7 right will get you a token amount of $5. 6 correct will get you $1.\n\n4. Max prize pool per day is $500. If there is more than one daily winner, the prize pool will be split among the winners. (Example - if there are 2 winners, each will receive $250).\n\n5. Winnings will be credited to your balance page.\n\n6. You can only withdraw when your balance has more than $25 in the account.\n\n7. Judge's decision is Final.\n\n8. Multiple accounts user will be banned and disqualified from winning any prizes. Please refrain from opening more than one SportsHero account.",
  },
  spinWheel = {
    wheel_title = "Spin-the-Wheel",
    wheel_sub_des = "Get your daily spin to win prizes including Messi Signed Jersey and Real Cash!",
    wheel_sub_title = "Spin-the-Wheel!",
    spin_daily = "One spin daily",
    spin_bonus = "BONUS SPIN",
    balance_title = "Balance",
    come_back_in = "Come back in:",
    winners = "Past Winners",
    won = "WON",
    no_one_won = "No one has won any prize yet.",
    ticket_you_have = "You have",
    ticket_balance_1 = "%d ticket",
    ticket_balance_2 = "%d tickets",
    ticket_usage = "for the latest lucky draw.",
    money_balance = "US$ %.2f",
    money_payout_success_notification = "Your request has been processed. Please allow 2 - 4 weeks to receive the gift card via your email address.",
    money_payout_limit = "Minimum US$25.00 for withdrawal.",
    leave_message = "Come back tomorrow for another spin.",
    claimVirtualPrize = "Congratulations! You have won a %s. Please contact our support.",
    collect_email_label_title = "Claim Prize",
    collect_email_you_won = "You have won",
    collect_email_prize = "1 US Dollar",
    collect_email_towards_wallet = "Please check you account balance",
    collect_email_description = "Please submit a valid email address. Fake email addresses will be disqualified from winning prizes.",
    collect_email_min = "Minimum withdrawal is US$25",
    share_description = "Share with your friends and get an additional spin.",
    win_ticket_prize = "Luck Draw Ticket",
    win_ticket_left = "left till draw.",
    only_show_big_prize = "Only show big prize",
    please_contact = "Please contact",
    to_claim_prize = "to claim prize.",
    win_prizes = "Win attractive prizes including Messi Signed Jersey & Real Cash!",
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
    edit = "Edit",
    email = "E-mail Address",
    faq = "FAQ",
    favorite_team = "Favorite Teams",
    favorite_team_none = "No Favorite Teams",
    general = "General News",
    logout = "Logout",
    others = "Others",
    phone = "Phone number",
    prediction = "Prediction",
    push_notification = "Push Notification",
    select_language = "Select Language",
    select_league = "Select League",
    send_feedback = "Send Feedback",
    set_favorite_tams = "Set My Favorite Teams",
    sound_effects = "Sound Effects",
    sound_settings = "Sound Settings",
    sounds = "Sounds",
    tap_to_edit = "Tap to Edit",
    title = "Settings",
    user_info = "User Information",
  },
  share_body = "Can you beat me? Join my competition on SportsHero. Code: %s  www.footballheroapp.com/download",
  share_title = "Join %s's competition on SportsHero",
  share_type_email = "Email",
  share_type_facebook = "Facebook",
  share_type_SMS = "SMS",
  share_type_title = "Share your competition using...",
  support_email = "support@footballheroapp.com",
  support_title = "SportsHero - Support",
  today = "Today",
  terms_agree = "By Signing in, you are indicating that you have read and agree to FOOTBALL HERO'S",
  top_performers = "Top Performers",
  unknown_name = "Unknown Name",
  unknown_team = "Unknown Team",
  updating_files = "Updating %s ...",
  user_name = "Username",
  vs = "VS",
  share = {
    spinTheWheel_content = "I won a prize in Spin-The-Wheel game! Win $$$, Messi & Ronaldo Signed Jerseys! www.footballheroapp.com/download",
    competition_content = "I joined a SportsHero Prediction competition. Win $$$, Messi & Ronaldo Signed Jerseys! www.footballheroapp.com/download",
    competition_seacup15_content = "I joined a SEA Games Football Challenge. Win $$$, Messi & Ronaldo Signed Jerseys! www.footballheroapp.com/download",
    competition_americacup15_content = "I joined a COPA America Cup Challenge. Win $$$, Messi & Ronaldo Signed Jerseys! www.footballheroapp.com/download",
    prediction_football_content = "%s Win $$$, Messi & Ronaldo Signed Jerseys! www.footballheroapp.com/download",
    prediction_baseball_content = "%s Win $$$, Messi & Ronaldo Signed Jerseys! www.footballheroapp.com/download",
    predResult_content = "SportsHero: %s\nCLICK HERE TO PLAY! www.footballheroapp.com/download",
    video_content = "%s.\nCLICK HERE TO WATCH! www.footballheroapp.com/download",
    share_app_content = "Predict on your favourite sports matches and win prizes for free Download SportsHero now!",
    spinTheWheel_title = "SportsHero - I won a prize in Spin-The-Wheel game!",
    competition_title = "SportsHero - I joined a soccer prediction competition.",
    prediction_title = "SportsHero - %s",
    predResult_title = "SportsHero - %s",
    video_title = "SportsHero - %s",
    share_app_title = "SportsHero - Social Sports Prediction Game",
  },
  sports = {
    football = "Football",
    basketball = "Basketball",
    baseball = "Baseball",
    afootball = "Amercian Football",
  },
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
        return nil
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
        return nil
    end
  }
  return mt
end