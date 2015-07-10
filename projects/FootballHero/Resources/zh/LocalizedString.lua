module(..., package.seeall)

Strings = {
    share = {
        prediction_content = "%s 赢得了 $$$, 梅西&罗纳尔多亲笔签名球衣！www.footballheroapp.com/download",
        spinTheWheel_title = "FootballHero - 我在'超级转转转'中赢得了奖金！",
        spinTheWheel_content = "我在'超级转转转'中赢得了 $$$, 梅西&罗纳尔多亲笔签名球衣！www.footballheroapp.com/download",
        competition_content = "我参加了FootballHero球赛竞猜，赢得了 $$$, 梅西&罗纳尔多亲笔签名球衣！www.footballheroapp.com/download",
        competition_title = "FootballHero - 我在FootbellHero中参加了足球竞彩大赛！",
        prediction_title = "FootballHero - %s",
    },
    handicap = {
        h1_yes = "得分条件是%s的胜球数大于2球 \n 若胜球数为1球则退还积分",
        h0_yes = "得分条件是%s获胜 \n 若平局则退还积分",
        hX_no = "得分条件是%TeamName%获胜,平分,或输球数小于%LineMinusOne% \n 若输球数达到%Line%则退还积分",
        hX_25_yes = "得分条件是%TeamName%的胜球数达到%LinePulsOne% \n 若胜球数为%Line%则损失一半积分",
        hX_75_yes = "得分条件是%TeamName%的胜球数达到%LinePulsTwo% \n 若胜球数为%LinePulsOne%则赢一半积分",
        predict_on = "预测 %s",
        h0_75_yes = "得分条件是%s的胜球数达到2球 \n 若胜球数为1球则赢一半积分",
        h0_5_yes = "得分条件是%s获胜",
        h1_5_no = "得分条件是%s获胜, 负球数少于一球",
        h1_75_no = "得分条件是%s获胜或打平, 负球数到达2球则损失一半积分",
        h1_75_yes = "得分条件是%s胜球数到达3个\n 胜球数为两个时则赢一半积分",
        h0_75_no = "得分条件是%s获胜或平局 \n 若负球数为1个则损失一半积分",
        hX_25_no = "得分条件是%TeamName%的负球数少于%LineMinusOne% \n 若负球数达到%Line%则赢一半积分",
        h1_25_no = "得分条件是%s平局或获胜 \n 输球数为1个时赢一半积分",
        h0_25_no = "得分条件是%s获胜 \n 若平局则赢一半积分",
        h0_5_no = "得分条件是%s平局或获胜",
        h0_no = "得分条件是%s获胜 \n 平均则退回积分",
        h0_25_yes = "得分条件是%s获胜 \n 平局则损失一半积分",
        h1_25_yes = "得分条件是%s的胜球数达到2个，赢球数为1时损失一半积分",
        h1_no = "得分条件是%s获胜或平局 \n 弱若负球数为1个则退还积分",
        hX_5_yes = "得分条件是%TeamName%的胜球数达到%LinePulsOne%",
        title = "积分概览",
        h1_5_yes = "得分条件是%s的胜球数达到2个",
        hX_5_no = "得分条件是%TeamName%的负球数少于%Line%",
        hX_75_no = "得分条件是%TeamName%的负球数少于%Line% \n %TeamName%的负球数达到%LinePulsOne%则损失一半积分",
        name = "亚洲让分盘",
        hX_yes = "得分条件是%TeamName%的胜球数达到%LinePulsOne% \n 若胜球数为%Line%则退还积分",
    },
    chat_hint = "点击开始聊天！",
    league_chat = {
        german = "德国联赛",
        spanish = "西班牙联赛",
        others = "其他比赛",
        italian = "意大利联赛",
        bahasa_chat = "Bahasa Indonesia",
        feedback = "反馈与建议",
        arabic_chat = "Arabic",
        group_chat = "群组讨论",
        thai_chat = "Thai",
        facebook = "在Facebook上给我们点个赞",
        uefa = "欧洲足协赛事",
        chinese_chat = "中文",
        english = "英格兰联赛",
    },
    last_name = "姓氏",
    error = {
        bad_email_format = "错误的邮箱格式",
        title_default = "加载失败请重试！",
        blank_password = "密码不能为空",
        no_sms = "手机短信未设置",
        blank_league = "未选择联赛",
        email_not_match = "邮箱地址不匹配",
        invalid_month = "月份为1至12的数字",
        blank_token = "比赛邀请码不能为空",
        blank_email = "邮箱未填写",
        blank_title = "标题不能为空",
        blank_desc = "描述信息不能为空",
        blank_comp_id = "比赛ID不能为空",
        updating_failed = "配置文件升级失败，请重试",
        login_failed = "登录失败，请重试",
        go_to_store = "前往市场",
        password_long = "密码长度超出限制",
        blank_user_name = "用户名不能为空",
        no_email = "邮箱账号未设置",
        password_not_match = "密码错误",
        password_short = "密码长度过短.",
        match_completed = "已完成本场比赛的预测",
    },
    email_signin = "邮箱登录",
    quit_title = " 确定退出？",
    today = "今日",
    enter_email = "请输入邮箱地址",
    match_center = {
        last6_away_title = "最近6场客场比赛结果",
        against_diagram_wins = "%s 胜",
        title_discussion = "讨论",
        prediction_made = "已预测",
        home_short = "主",
        overunder_over = "大盘",
        formTable_lost = "负",
        home = "主场",
        VS = "VS",
        played_out_of = "%d 共 %d",
        write_comment = "评论一下",
        post = "提交",
        total = "所有",
        more = "更多内容",
        overunder_title = "大小盘",
        overunder_under = "小盘",
        load_comments = "加载更多评论",
        title = "比赛中心",
        time_hours = "%d 小时",
        away_short = "客",
        formTable_draw = "平",
        pos = "名",
        against_content_nodata = "暂无数据",
        played = "已押",
        formTable_title = "数据表",
        total_short = "总",
        just_now = "刚刚发布",
        overunder_played = "次数",
        title_meetings = "历史交战记录",
        share_title = "",
        less = "合并内容",
        time_days = "%d 天",
        share_body = "",
        against_title_date = "日期",
        write_discussion = "创建新的话题",
        against_diagram_draw = "平",
        last6_home_title = "最近6场主场比赛结果",
        away = "客场",
        pts = "分",
        formTable_won = "胜",
        leagueTable_title = "联赛表",
        make_prediction = "开始预测！",
        formTable_played = "场次",
        time_minutes = "%d 分",
    },
    button = {
        share = "分享",
        cancel = "取消",
        yes = "是",
        register = "注册",
        enable = "允许",
        rate_now = "去评分",
        new_user = "新用户",
        no_thanks = "否",
        ok = "是",
        sign_in = "登录",
        no = "否",
        play_now = "开始游戏！",
        forget_password = "忘记密码？",
        confirm = "确认！",
        predict = "开始预测！",
        join = "加入",
        existing_user = "已注册用户",
        create = "创建！",
        go = "开始！",
    },
    share_type_facebook = "Facebook",
    share_type_title = "通过以下方式分享比赛给你的朋友",
    unknown_team = "未知球队",
    leaderboard = {
        min_prediction = "至少 %d 场预测",
        stats_win_rate = "胜 %",
        gain_per_prediction_title = "场均收益率榜",
        stats_last_ten = "最近10场",
        me_score = "%d 胜",
        stats_l = "负",
        win_ratio_desc = "%d%% 胜率 (%d 场预测)",
        win_ratio_title = "胜率榜",
        stats_league = "联赛",
        high_score_title = "高分榜",
        high_score_desc = "%d 分 (%d 场预测)",
        gain_per_prediction_desc = "%d%% 收益 (%d 场预测)",
        stats_win = "胜",
        stats_w = "胜",
        stats_gain_rate = "收益率 %",
        stats_lose = "负",
    },
    optional = "(Optional)",
    share_type_SMS = "短信分享",
    password_confirm = "确认密码",
    spinWheel = {
        ticket_usage = "最新兑换券抽取",
        only_show_big_prize = "仅显示大奖",
        winners = "胜者记录",
        collect_email_you_won = "你赢得了",
        collect_email_towards_wallet = "根据账户余额",
        wheel_title = "超级转转转",
        collect_email_description = "请提交正确的邮箱地址，不合法的邮箱地址会导致您失去获奖机会。",
        ticket_balance_2 = "%d 张兑换券",
        win_ticket_left = "剩余",
        spin_daily = "每日一次转盘次数",
        come_back_in = "下一次游戏时间：",
        please_contact = "联系我们",
        wheel_sub_title = "超级转转转！",
        win_ticket_prize = "幸运兑换券",
        no_one_won = "暂无玩家获奖",
        share_description = "分享给朋友获取更多转盘次数！",
        money_payout_success_notification = "请求已处理！你会在接下来的2至4周内通过邮件的方式收到礼品卡！",
        spin_bonus = "奖励旋转次数",
        money_balance = "%s 美元亚马逊礼品卡",
        leave_message = "明天可以拥有更多转盘次数！",
        collect_email_min = "最小提现金额为 US￥25",
        collect_email_label_title = "奖品发放",
        ticket_balance_1 = "%d 张兑换券",
        ticket_you_have = "你拥有",
        won = "胜",
        money_payout_limit = "提现的最少金额量为25美元",
        win_prizes = "奖品包括梅西签名球衣，大量现金奖励！",
        claimVirtualPrize = "恭喜！您赢得了一个 %s. 请联系客户服务邮箱！",
        balance_title = "我的积分",
        collect_email_prize = "1 美元",
        to_claim_prize = "获奖者通道",
    },
    login_success = "登录成功.\n数据加载中...",
    event = {
        hint_unqualified = "再预测%d场比赛即可拥有获奖资格",
        ranking_dropdown_week = "周 %1$d: %3$d月 %2$s日-%5$d月 %4$s日",
        hint_qualified = "已拥有获奖资格",
        ranking_monthly = "月榜",
        status_unqualified = "- 未取得获奖资格",
        total_players = "总玩家数",
        prizes = "奖品",
        ranking_weekly = "周榜",
        ranking_overall = "季度榜",
        status_qualified = "- 已拥有获奖资格",
        predict_now = "开始预测",
        ranking_dropdown_month = "%2$s年 %1$s",
    },
    friends = "朋友",
    facebook_signin = "Facebook账号登录",
    marketing_message_2 = "现在邀请朋友加入到你创建的预测游戏中来吧",
    duration_forever = "无限期",
    marketing_message_3 = "谁会成为预测第一人？",
    push_notification = {
        receive = "你会收到:",
        prediction_summary = "预测汇总",
        match_result = "比赛规则",
        question_competition = "是否开启本场比赛的信息推送",
        question_prediction = "是否开启所有预测的信息推送",
        points_won = "得失分汇总",
        new_participant = "新加入用户通知",
    },
    updating_files = "正在升级 %s ...",
    duration_to = "%s 至 %s",
    unknown_name = "未知姓名",
    match_list = {
        match_ended = "比赛结束",
        played = "已预测",
        most_popular = "热门比赛",
        date = "%b月 %d日, %A",
        special = "精选",
        most_discussed = "热门话题",
        more_regions = "更多地区",
        match_started = "已开始比赛",
        less_regions = "折叠显示",
        match_lost = "亏损: %d 分",
        total_fans = "关注者",
        upcoming_matches = "即将开赛",
        todays_matches = "今日赛事",
        match_won = "赢得: %d 分",
        draw = "平局",
        team_expert = "砖家",
    },
    terms_agree = "登录即表示您同意FootballHero的相关服务条款",
    last_name_optional = "姓氏 (可选填)",
    community = {
        share = "分享",
        rules = "规则",
        label_call_to_arm = "您还未加入任何比赛，\n创建比赛并邀请好友加入！",
        enter_comp_code = "输入比赛邀请码",
        all_competitions = "全部联赛 & 杯赛",
        title_create_competition = "创建比赛",
        title_joined_comp = "已加入的比赛",
        disclaimer = "** 免责声明 - 苹果非此内容赞助者且不以任何形式参与其中",
        copy = "复制",
        title_top_performers = "最佳预测",
        label_new = "新",
        title_competition = "比赛",
        title_leaderboard = "榜单",
        label_how_long = "设定比赛时间",
        label_ongoing = "正在进行",
        title_rules = "比赛规则",
        title_eligible = "可加入联赛/杯赛",
        invite_code = "邀请码：",
        label_months = "月份",
        title_duration = "比赛时间",
        title_join_comp = "加入比赛",
        label_give_title = "添加比赛名称",
        title_create_comp = "的比赛",
        label_select_league = "选择联赛",
        push = "推送消息",
        title_details = "详细信息",
        title_description = "比赛描述",
        quit = "退出",
        label_give_desc = "添加描述信息",
        desc_create_comp = "在比赛选定的联赛中预测的球赛会自动加入到你的比赛记录中",
        label_fb_share = "分享到 Facebook",
    },
    first_name = "名字",
    share_type_email = "邮件分享",
    football_hero = "FootballHero",
    info = {
        competition_not_started = "比赛开始于 %s",
        like_fh1 = "喜欢FootballHero吗？",
        predictions_entered = "已完成本场比赛的预测",
        single_discussion = "每场比赛只能创建一个话题",
        title = "提示",
        join_code_copied = "比赛邀请码已复制",
        shared_to_fb_minigame = "minigame已经分享至Facebook！",
        leave_comment2 = "通过Email反馈给我们",
        coming_soon = "即将到来！",
        odds_not_ready = "暂无更新，请稍后重试！",
        shared_to_fb = "比赛已经分享到Facebook！",
        leave_comment1 = "提出建议与意见！",
        new_version = "请下载并升级新版本！",
        announcement_title = "申明",
        like_fh2 = "给我们一个好评吧~",
        star_bet = "每过12小时你可以进行一次投入三倍分数的比赛预测",
    },
    month = {
        m9 = "九月",
        m8 = "八月",
        m12 = "十二月",
        m10 = "十月",
        m3 = "三月",
        m2 = "二月",
        m1 = "一月",
        m11 = "十一月",
        m4 = "四月",
        m5 = "五月",
        m6 = "六月",
        m7 = "七月",
    },
    minigame = {
        friend_help = "已经帮助过你的朋友",
        ask_more_friends = "寻求更多的帮助！",
        winners = "胜者记录",
        ask_friends_help = "找朋友来帮忙！",
        shoot_to_win_won = "你赢了！",
        failed_to_score = "未能获得任何进球",
        rules = "规则说明",
        helped_to_score = "已经帮助你获得了 %d 个进球",
        no_one_won = "暂无玩家赢得 Samsung Note Edge",
        call_to_action = "暂未有人帮你获得过进球",
        title = "进球赢奖品-挑战活动",
        iPhone6_winner = "Samsung Note Edge 获得者",
        goal_to_win = "还需要 %d 个进球",
        current_score = "当前进球数:",
    },
    settings = {
        faq = "常见问题",
        sound_effects = "音效",
        tap_to_edit = "编辑头像",
        sounds = "音效",
        send_feedback = "发送反馈",
        select_league = "选择联赛",
        select_language = "选择语言",
        sound_settings = "声音设置",
        edit = "编辑",
        phone = "手机号码",
        logout = "注销",
        favorite_team_none = "无最爱球队",
        favorite_team = "最爱球队",
        push_notification = "信息推送",
        title = "设置",
        user_info = "用户信息",
        general = "系统通知",
        set_favorite_tams = "选择最爱球队",
        prediction = "预测消息",
        others = "更多设置",
        email = "邮箱地址",
    },
    top_performers = "最佳预测帝",
    chat_room_title = "选择聊天室",
    num_of_points = "%d 分",
    share_title = "加入%s创建的FootballHero比赛",
    quit_cancel = "取消",
    password = "密码",
    choice = {
        leave_comp_no = "继续",
        leave_comp_title = "退出比赛",
        leave_comp_yes = "退出",
        leave_comp_desc = "确定要退出当前比赛吗？",
    },
    support_title = "用户反馈",
    vs = "VS",
    share_body = "嘿！你能比我预测得更准吗？加入我在FootballHero创建的比分预测大赛吧！邀请码: %s  www.footballheroapp.com/download",
    support_email = "support@footballheroapp.com",
    serverError = {
        COMPETITION_6 = "日期数据未找到！",
        COUPON_3 = "No predictions on coupon. Cannot place empty coupon.",
        FACEBOOK_2 = "您还未连接到Facebook！",
        DEFAULT = "抱歉请重试！",
        COUPON_1 = "押分数量不合法！",
        LEADERBOARD_2 = "抱歉请重试！",
        LEADERBOARD_1 = "排行榜不合法，请重试！",
        COUNTRY_1 = "请选择其他的国家！",
        COMPETITION_5 = "用户未加入当前比赛！",
        COMPETITION_3 = "邀请码不存在！",
        COMPETITION_2 = "比赛不存在！",
        FACEBOOK_4 = "该Facebook账号已经在使用！",
        WHEEL_3 = "未找到奖励！",
        WHEEL_5 = "请求数量小于最小数额！",
        SIGNIN_2 = "用户名/密码错误！",
        FACEBOOK_3 = "该Facebook账号已经在使用！",
        DISCUSSION_3 = "抱歉请重试！",
        COMPETITION_7 = "不能加入到预览模式的比赛中！",
        GENERAL_2 = "用户ID不合法！",
        SIGNIN_3 = "邮箱不存在",
        WHEEL_6 = "请求数量大于可以用数额！",
        COUPON_4 = "已经参与过一场或一场以上的预测！",
        SIGNIN_1 = "您的邮箱地址无效！",
        VERSION_2 = "请下载新版本的FootballHero获取新特性！",
        COMPETITION_4 = "您已加入当前的比赛！",
        COMPETITION_1 = "您已经创建过相同名字的比赛了",
        FACEBOOK_1 = "软件发生了错误！请重试！",
        WHEEL_1 = "距离上一次使用转盘次数时间小于一天！",
        LEAGUE_1 = "请选择其他的联赛！",
        DISCUSSION_2 = "请重试！",
        COMPETITION_8 = "分享奖励已发放！",
        GENERAL_1 = "抱歉请重试！",
        SIGNIN_4 = "邮箱/密码不能为空",
        COUPON_2 = "Too many predictions on coupon.",
        FACEBOOK_5 = "抱歉请重试！",
        DISCUSSION_1 = "请重试！",
        COUPON_5 = "距离上一次使用三倍押分时间小于12小时！",
        WHEEL_2 = "Price probabilities don't add up.",
        WHEEL_4 = "用户还未使用过转盘次数",
        VERSION_1 = "请在app store中下载最新版本的软件",
    },
    email = "邮箱地址",
    user_name = "用户名",
    history = {
        show_all = "显示所有",
        won_small = "胜",
        predictions_closed = "已预测的比赛",
        win_by_line0 = "Will %s win on level handicap?",
        lost = "负",
        won_colon = "胜:",
        refund = "refunded",
        total_points = "总分数: %d",
        predictions_open = "正在预测的比赛",
        draw = "平",
        push_colon = "Push:",
        win_by = "%s 会净胜 %s 球或更多吗?",
        total_goals = "总进球数是否会达到 %d 或更多?",
        won = "胜",
        predictions_all = "所有预测",
        no_open_prediction = "你还没有\n 正在预测的比赛",
        which_team = "哪支球队会获得胜利?",
        no_closed_prediction = "你还没有\n 已预测的比赛",
        no_open_prediction_others = "没有正在预测的比赛",
        lost_small = "负",
        win_count = "%d 中 %d",
        no_closed_prediction_others = "没有已预测的比赛",
        lost_colon = "负:",
        stake = "押分: %d 分",
    },
    first_name_optional = "名字 (可选填)",
    email_confirm = "确认邮箱地址",
    match_prediction = {
        will_win_by = "%s 会净胜 %s 球或更多吗?",
        stake = "押分",
        win = "胜",
        team_to_win = "哪支球队会获得胜利",
        stand_to_win = "押分此项",
        will_total_goals = "总进球数是否会达到 %d 球或更多?",
        balance = "可用分数",
        prediction_summary = "预测汇总",
        facebook = "Facebook",
        answer_match_draw = "我预测是平局",
        answer_total_goal_yes = "我预测比赛总进球数会多于等于%s个",
        answer_match_win = "我预测%s会获胜",
        answer_total_goal_no = "我预测比赛总进球数会少于等于%s个",
        share = "分享给好友",
        answer_asian_handicap_yes = "我预测%s的胜球数会达到%s个",
        hint_tap = "开始预测",
        will_win_by_line0 = "Will %s win on level handicap?",
        answer_asian_handicap_no = "我预测%s的胜球数会少于等于%s个",
    },
    quit_desc = "再次点击返回退出",
    message_hint = "在此输入消息",
    marketing_message_1 = "恭喜！你刚刚完成了你的第一场预测！",
}



require "DefaultString"

for i = 1 , table.getn( StringDefaultSubTableList ) do
    local subTableTitle = StringDefaultSubTableList[i]
    if Strings[subTableTitle] then
        setmetatable( Strings[subTableTitle], extendsStringDefaultSubTable(subTableTitle) )  
    end
end
setmetatable( Strings, extendsStringDefault() )

CCLuaLog("Load zh string.")