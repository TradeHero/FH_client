module(..., package.seeall)

Strings = {
  chat_hint = "点击开始聊天！",
  league_chat = {
    feedback = "反馈",
    spanish = "西班牙联赛",
    others = "其他联赛",
  },
  enter_email = "请输入你的Email地址",
  match_center = {
    just_now = "刚刚",
    played = "玩了%d/%d",
  },
  email_signin = "邮箱注册",
  unknown_team = "未知球队",
  leaderboard = {
    gain_per_prediction_title = "场均收益率榜",
    gain_per_prediction_desc = "%d%% 收益 (%d 场预测)",
    high_score_desc = "%d 分 (%d 场预测)",
    high_score_title = "高分榜",
    win_ratio_desc = "%d%% 胜率 (%d 场预测)",
    win_ratio_title = "胜率榜",
  },
  last_name = "姓氏",
  password_confirm = "确认密码",
  login_success = "登陆成功.\n数据加载中...",
  event = {
    hint_unqualified = "再预测%d场比赛即可拥有获奖资格",
    status_unqualified = "- 未取得获奖资格",
    status_qualified = "- 已拥有获奖资格",
    hint_qualified = "已拥有获奖资格",
  },
  duration_forever = "无限期",
  updating_files = "正在升级 %s ...",
  unknown_name = "未知姓名",
  duration_to = "%s 至 %s",
  last_name_optional = "姓氏 (可选填)",
  community = {
    title_competition = "比赛",
    label_call_to_arm = "您还未加入任何比赛，\n创建比赛并邀请好友加入！",
    enter_comp_code = "输入比赛邀请码",
    title_leaderboard = "榜单",
    desc_create_comp = "在比赛选定的联赛中预测的球赛会自动加入到你的比赛记录中",
    title_create_comp = "的比赛",
  },
  first_name = "名字",
  share_type_title = "分享",
  match_list = {
    most_popular = "热门比赛",
  },
  settings = {
    faq = "常见问题",
    sounds = "音效",
    logout = "注销",
    send_feedback = "发送反馈",
    push_notification = "信息推送",
  },
  top_performers = "最佳预测帝",
  user_name = "用户名",
  num_of_points = "%d 分",
  share_title = "加入%s创建的波神比赛",
  quit_cancel = "取消",
  quit_title = "您确定要退出波神吗?",
  choice = {
    leave_comp_title = "退出比赛",
    leave_comp_desc = "确定要退出当前比赛吗？",
  },
  support_title = "用户反馈",
  vs = "VS",
  share_body = "嘿！你能比我预测得更准吗？加入我在波神创建的比分预测大赛吧！邀请码: %s  www.footballheroapp.com/download",
  support_email = "support@footballheroapp.com",
  password = "密码",
  email = "邮箱地址",
  friends = "朋友",
  history = {
    show_all = "显示所有",
    won_small = "胜",
    predictions_closed = "已预测的比赛",
    lost = "负",
    won_colon = "胜:",
    predictions_open = "正在预测的比赛",
    win_by = "%s 会净胜 %d 球或更多吗?",
    total_goals = "总进球数是否会达到 %d 或更多?",
    won = "胜",
    predictions_all = "所有预测",
    no_open_prediction = "你还没有\n 正在预测的比赛",
    no_open_prediction_others = "没有正在预测的比赛",
    lost_small = "负",
    lost_colon = "负:",
    no_closed_prediction_others = "没有已预测的比赛",
    no_closed_prediction = "你还没有\n 已预测的比赛",
    which_team = "哪支球队会获得胜利?",
  },
  first_name_optional = "名字 (可选填)",
  optional = "(Optional)",
  message_hint = "在此输入消息",
  quit_desc = "再次点击返回退出",
  error = {
    bad_email_format = "错误的邮箱格式",
    blank_password = "密码不能为空",
    no_sms = "手机短信未设置",
    blank_league = "未选择联赛",
    invalid_month = "月份为1至12的数字",
    blank_token = "比赛邀请码不能为空",
    blank_email = "邮箱未填写",
    blank_title = "标题不能为空",
    updating_failed = "配置文件升级失败，请重试",
    blank_comp_id = "比赛ID不能为空",
    blank_desc = "描述信息不能为空",
    password_short = "密码长度过短.",
    password_not_match = "密码错误",
    password_long = "密码长度超出限制",
    blank_user_name = "用户名不能为空",
    no_email = "邮箱账号未设置",
    go_to_store = "前往市场",
    login_failed = "登录失败，请重试",
    match_completed = "已完成本场比赛的预测",
  },
  info = {
    star_bet = "每过12小时你可以进行一次投入三倍分数的比赛预测",
    new_version = "请下载并升级新版本！",
    join_code_copied = "比赛邀请码已复制",
    title = "提示",
    shared_to_fb = "比赛已经分享到Facebook！",
    predictions_entered = "已完成本场比赛的预测",
  },
}


require "DefaultString"

setmetatable( Strings, extendsStringDefault() )
for i = 1 , table.getn( StringDefaultSubTableList ) do
    local subTableTitle = StringDefaultSubTableList[i]
    if Strings[subTableTitle] then
        setmetatable( Strings[subTableTitle], extendsStringDefaultSubTable(subTableTitle) )  
    end
end

CCLuaLog("Load zh string.")