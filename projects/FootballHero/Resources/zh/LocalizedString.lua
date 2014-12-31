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
    cancel = "Cancel",
    confirm = "Confirm!",
    create = "Create!",
    enable = "Enable",
    forget_password = "Forgot Password?",
    go = "Go!",
    join = "Join",
    ok = "OK",
    no = "No",
    no_thanks = "No, thanks.",
    play_now = "Play Now!",
    register = "Register",
    share = "Share",
    sign_in = "Sign In",
    yes = "Yes",
    rate_now = "Rate now",
  },
  chat_hint = "点击开始聊天！",
  chat_room_title = "Select Chatroom",
  choice = {
    leave_comp_desc = "确定要退出当前比赛吗？",
    leave_comp_no = "Stay",
    leave_comp_title = "退出比赛",
    leave_comp_yes = "Leave",
  },
  community = {
    copy = "COPY",
    desc_create_comp = "在比赛选定的联赛中预测的球赛会自动加入到你的比赛记录中",
    disclaimer = "*** Disclaimer - Apple is not a sponsor nor is involved in any way.",
    enter_comp_code = "输入比赛邀请码",
    invite_code = "Invitation Code:",
    label_call_to_arm = "您还未加入任何比赛，\n创建比赛并邀请好友加入！",
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
    title_competition = "比赛",
    title_create_comp = "的比赛",
    title_description = "Description",
    title_details = "Details",
    title_duration = "Duration",
    title_eligible = "Eligible Leagues/Cups",
    title_leaderboard = "榜单",
    title_joined_comp = "Joined Competitions",
    title_join_comp = "Join a Competition",
    title_rules = "Rules",
    title_top_performers = "Top Performers",
  },
  duration_to = "%s 至 %s",
  duration_forever = "无限期",
  email = "邮箱地址",
  email_signin = "Sign in with Email",
  enter_email = "Please enter your email address.",
  error = {
    bad_email_format = "错误的邮箱格式",
    blank_comp_id = "比赛ID不能为空",
    blank_desc = "描述信息不能为空",
    blank_email = "邮箱未填写",
    blank_league = "未选择联赛",
    blank_password = "密码不能为空",
    blank_title = "标题不能为空",
    blank_token = "比赛邀请码不能为空",
    blank_user_name = "用户名不能为空",
    go_to_store = "前往市场",
    invalid_month = "月份为1至12的数字",
    login_failed = "登录失败，请重试",
    match_completed = "已完成本场比赛的预测",
    no_email = "邮箱账号未设置",
    no_sms = "手机短信未设置",
    password_long = "密码长度超出限制",
    password_not_match = "密码错误",
    password_short = "密码长度过短.",
	title_default = "Oops! You've got an error",
    updating_failed = "配置文件升级失败，请重试",
  },
  event = {
    hint_qualified = "已拥有获奖资格",
    hint_unqualified = "再预测%d场比赛即可拥有获奖资格",
    predict_now = "Predict Now",
    prizes = "Prizes",
    ranking_monthly = "Monthly",
    ranking_overall = "Season",
    ranking_dropdown_week = "Week %d: %d %s-%d %s",
    ranking_weekly = "Weekly",
    status_qualified = "- 已拥有获奖资格",
    status_unqualified = "- 未取得获奖资格",
    total_players = "Total Players",
  },
  facebook_signin = "Sign in with Facebook",
  first_name = "名字",
  first_name_optional = "名字 (可选填)",
  football_hero = "FootballHero",
  friends = "朋友",
  history = {
    lost = "负",
    lost_colon = "负:",
    lost_small = "负",
    predictions_all = "所有预测",
    predictions_closed = "已预测的比赛",
    predictions_open = "正在预测的比赛",
    show_all = "显示所有",
    total_goals = "总进球数是否会达到 %d 或更多?",
    which_team = "哪支球队会获得胜利?",
    win_by = "%s 会净胜 %d 球或更多吗?",
    won = "胜",
    won_colon = "胜:",
    won_small = "胜",
    no_open_prediction = "你还没有\n 正在预测的比赛",
    no_open_prediction_others = "没有正在预测的比赛",
    no_closed_prediction = "你还没有\n 已预测的比赛",
    no_closed_prediction_others = "没有已预测的比赛",
    total_points = "Total Points: %d",
    show_all = "Show All",
    stake = "Stake: %d Points",
    win_count = "%d of %d",
  },
  info = {
    announcement_title = "Announcement",
    competition_not_started = "Competition begins %s.",
    join_code_copied = "比赛邀请码已复制",
    leave_comment1 = "Let us know how we could improve!",
    leave_comment2 = "Email us your feedback",
    like_fh1 = "Do you like FootballHero so far?",
    like_fh2 = "Please take a moment to rate the app.",
    new_version = "请下载并升级新版本！",
    odds_not_ready = "Odds will be updated soon.\nPlease check again later.",
    predictions_entered = "已完成本场比赛的预测",
    shared_to_fb = "比赛已经分享到Facebook！",
    shared_to_fb_minigame = "You have shared your minigame to Facebook!",
    star_bet = "每过12小时你可以进行一次投入三倍分数的比赛预测",
    title = "提示",
  },
  last_name = "姓氏",
  last_name_optional = "姓氏 (可选填)",
  leaderboard = {
    gain_per_prediction_desc = "%d%% 收益 (%d 场预测)",
    gain_per_prediction_title = "场均收益率榜",
    high_score_desc = "%d 分 (%d 场预测)",
    high_score_title = "高分榜",
    me_score = "%d won",
    min_prediction = "At least %d predictions",
    stats = {
      gain_rate = "Gain %",
      l = "L",
      last_ten = "Last 10",
      lose = "Lose",
      w = "W",
      win = "Win",
      win_rate = "Win %",
    },
    win_ratio_desc = "%d%% 胜率 (%d 场预测)",
    win_ratio_title = "胜率榜",
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
  login_success = "登陆成功.\n数据加载中...",
  marketing_message_1 = "Congratulations on making your first prediction!",
  marketing_message_2 = "Now challenge your friends in your own mini-competition!",
  marketing_message_3 = "Who will rise to the top?",
  match_list = {
    draw = "Draw",
    most_popular = "热门比赛",
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
  message_hint = "在此输入消息",
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
  num_of_points = "%d 分",
  optional = "(Optional)",
  password = "密码",
  password_confirm = "确认密码",
  push_notification = {
    match_result = ". Match results",
    new_participant = ". New participant alert",
    points_won = ". Points won or lost",
    prediction_summary = ". Predictions' summary",
    question_competition = "Do you want to receive push notification for this competition?",
    question_prediction = "Do you want to receive push notification for all your predictions?",
    receive = "You will receive:",
  },
  quit_title = "您确定要退出波神吗?",
  quit_desc = "再次点击返回退出",
  quit_cancel = "取消",
  settings = {
    faq = "常见问题",
    general = "General News",
    logout = "注销",
    prediction = "Prediction",
    push_notification = "信息推送",
    send_feedback = "发送反馈",
    sound_effects = "Sound Effects",
    sound_settings = "Sound Settings",
    sounds = "音效",
    title = "Settings",
  },
  share_body = "嘿！你能比我预测得更准吗？加入我在波神创建的比分预测大赛吧！邀请码: %s  www.footballheroapp.com/download",
  share_title = "加入%s创建的波神比赛",
  share_type_email = "Email",
  share_type_facebook = "Facebook",
  share_type_SMS = "SMS",
  share_type_title = "Share your competition using...",
  support_email = "support@footballheroapp.com",
  support_title = "用户反馈",
  today = "Today",
  terms_agree = "By Signing in, you are indicating that you have read and agree to FOOTBALL HERO'S",
  top_performers = "最佳预测帝",
  unknown_name = "未知姓名",
  unknown_team = "未知球队",
  updating_files = "正在升级 %s ...",
  user_name = "用户名",
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