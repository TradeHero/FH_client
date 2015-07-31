module(..., package.seeall)

Strings = {
    chat_hint = "แตะที่นี่เพื่อเริ่มการแชต!",
    league_chat = {
        feedback = "คำติชมและข้อคิดเห็น",
        spanish = "ลีกสเปน",
        others = "การแข่งขันอื่นๆ",
        italian = "ลีกอิตาลี",
        facebook = "ไลค์เราบนเฟซบุ๊ก",
        uefa = "ลีกยูฟ่า",
        german = "ลีกเยอรมัน",
        english = "ลีกอังกฤษ",
    },
    button = {
        share = "แบ่งปัน",
        cancel = "ยกเลิก",
        yes = "ใช่",
        existing_user = "ผู้ใช้ที่มีอยู่",
        enable = "เปิดใช้งาน",
        rate_now = "ให้คะแนนตอนนี้",
        new_user = "ผู้ใช้ใหม่",
        no_thanks = "ไม่ล่ะ ขอบคุณ",
        ok = "ตกลง",
        sign_in = "ลงชื่อเข้าใช้",
        no = "ไม่",
        create = "สร้าง!",
        forget_password = "ลืมรหัสผ่าน?",
        confirm = "ยืนยัน!",
        predict = "ทำนายผล!",
        join = "เข้าร่วม",
        register = "ลงทะเบียน",
        play_now = "เล่นเลย!",
        go = "ไป!",
    },
    message_hint = "พิมพ์ข้อความของคุณที่นี่",
    friends = "เพื่อน",
    marketing_message_1 = "ขอแสดงความยินดีในการทำนายครั้งแรกของคุณ!",
    push_notification = {
        receive = "คุณจะได้รับ:",
        prediction_summary = ". ผลสรุปของการทำนาย",
        match_result = ". ผลการแข่งขันแต่ละนัด",
        question_competition = "คุณต้องการรับการแจ้งเตือนแบบพุชสำหรับการแข่งขันนี้หรือไม่?",
        question_prediction = "คุณต้องการรับการแจ้งเตือนแบบพุชสำหรับการทำนายทั้งหมดของคุณหรือไม่?",
        points_won = ". คะแนนที่ชนะหรือแพ้",
        new_participant = ". แจ้งเตือนผู้เข้าร่วมใหม่",
    },
    enter_email = "กรุณาใส่ที่อยู่อีเมลของคุณ",
    match_center = {
        less = "น้อยกว่า",
        played = "เล่นไปแล้ว",
        make_prediction = "ทำนายผล!",
        time_days = "%d วัน",
        write_discussion = "เขียนหัวข้อสนทนาใหม่...",
        just_now = "เมื่อสักครู่",
        prediction_made = "ทำนายไปแล้ว",
        title_discussion = "หัวข้อสนทนา",
        load_comments = "ดาวน์โหลดความคิดเห็นเพิ่มเติม...",
        title_meetings = "การพบกันครั้งล่าสุด",
        title = "ศูนย์รวมข้อมูลการแข่งขัน",
        time_hours = "%d ชม.",
        played_out_of = "%d จาก %d",
        more = "เพิ่มเติม",
        write_comment = "เขียนความคิดเห็น...",
        time_minutes = "%d นาที",
    },
    email_signin = "ลงชื่อเข้าใช้ด้วยอีเมล",
    share_type_facebook = "เฟซบุ๊ก",
    share_type_title = "แบ่งปันการแข่งขันของคุณโดยใช้...",
    unknown_team = "ทีมที่ไม่รู้จัก",
    leaderboard = {
        win_ratio_title = "อัตราชนะ",
        stats_win_rate = "ชนะ %",
        gain_per_prediction_title = "ผลตอบแทนต่อการทำนาย",
        stats_last_ten = "10 ครั้งล่าสุด",
        me_score = "ชนะ %d ครั้ง",
        stats_l = "แพ้",
        win_ratio_desc = "ชนะ %d%% (การทำนาย %d ครั้ง)",
        stats_league = "ลีก",
        stats_w = "ชนะ",
        high_score_title = "คะแนนสูงสุด",
        high_score_desc = "ชนะ %d%% ครั้ง (การทำนาย %d ครั้ง)",
        gain_per_prediction_desc = "ผลตอบแทน %d%% (การทำนาย %d ครั้ง)",
        stats_win = "ชนะ",
        min_prediction = "ต้องมีการทำนายอย่างน้อย %d ครั้ง",
        stats_gain_rate = "ผลตอบแทน %",
        stats_lose = "แพ้",
    },
    last_name = "นามสกุล",
    share_type_SMS = "ข้อความ",
    password_confirm = "ยืนยันรหัสผ่าน",
    spinWheel = {
        ticket_usage = "สำหรับการจับรางวัลผู้โชคดีล่าสุด",
        only_show_big_prize = "แสดงเฉพาะรางวัลใหญ่เท่านั้น",
        winners = "ผู้ชนะครั้งก่อน",
        collect_email_you_won = "คุณได้รับ",
        wheel_title = "หมุน-วง-ล้อ",
        collect_email_min = "การถอนขั้นต่ำคือ 25 เหรียญสหรัฐฯ",
        ticket_balance_2 = "ตั๋ว %d ใบ",
        win_ticket_left = "เหลือจนถึงการจับรางวัล",
        spin_daily = "หมุนวงล้อหนึ่งครั้งต่อวัน",
        to_claim_prize = "เพื่อรับรางวัล",
        balance_title = "ยอดคงเหลือ",
        wheel_sub_title = "หมุน-วง-ล้อ!",
        win_ticket_prize = "ตั๋วจับรางวัลผู้โชคดี",
        collect_email_prize = "1 ดอลล่าร์สหรัฐฯ",
        share_description = "แบ่งปันกับเพื่อนของคุณเพื่อรับสิทธิ์หมุนวงล้อเพิ่ม",
        spin_bonus = "โบนัสสำหรับหมุนวงล้อ",
        collect_email_towards_wallet = "ไปยังยอดคงเหลือในบัญชีของคุณ",
        money_balance = "บัตรของขวัญ Amazon มูลค่า %s ดอลล่าร์สหรัฐฯ",
        please_contact = "กรุณาติดต่อ",
        won = "ชนะ",
        collect_email_label_title = "รับรางวัล",
        ticket_balance_1 = "ตั๋ว %d ใบ",
        ticket_you_have = "คุณมี",
        leave_message = "กลับมาหมุนวงล้ออีกครั้งวันพรุ่งนี้",
        money_payout_limit = "ยอดการถอนต่ำสุด 25 ดอลล่าร์สหรัฐฯ ต่อครั้ง",
        money_payout_success_notification = "คำร้องของคุณได้รับการดำเนินการแล้ว กรุณารอ 2-4 สัปดาห์เพื่อรับบัตรของขวัญผ่านทางอีเมลของคุณ",
        claimVirtualPrize = "ขอแสดงความยินดี! คุณได้รับ %s กรุณาติดต่อศูนย์ช่วยเหลือของเรา",
        no_one_won = "ยังไม่มีใครได้รับรางวัลใดๆ",
        come_back_in = "กลับมาอีกครั้งในอีก:",
        collect_email_description = "กรุณาใส่อีเมลที่ถูกต้อง อีเมลปลอมจะไม่ผ่านเกณฑ์การรับรางวัล",
        win_prizes = "รับรางวัลที่นาสนใจซึ่งประกอบดวยเสื้อพรอม ลายเซ็นเมสซี่ และเงินสดจริง",
    },
    login_success = "ลงชื่อเข้าใช้สำเร็จ \nกำลังดาวน์โหลดข้อมูล กรุณารอสักครู่...",
    event = {
        hint_unqualified = "คุณต้องทำนายอีก %d นัดในการแข่งขันนี้ เพื่อผ่านเกณฑ์การรับรางวัล",
        ranking_dropdown_week = "สัปดาห์ %1$d: %2$d %3$s-%4$d %5$s",
        ranking_dropdown_month = "%1$s %2$s",
        status_unqualified = "-ไม่ผ่านเกณฑ์",
        prizes = "ของรางวัล",
        predict_now = "ทำนายเลย",
        ranking_overall = "ฤดูกาล",
        ranking_weekly = "รายสัปดาห์",
        status_qualified = "-ผ่านเกณฑ์",
        total_players = "ผู้เล่นทั้งหมด",
        ranking_monthly = "รายเดือน",
        hint_qualified = "ผ่านเกณฑ์สำหรับของรางวัล",
    },
    user_name = "ชื่อผู้ใช้",
    facebook_signin = "ลงชื่อเข้าใช้ด้วยเฟซบุ๊ก",
    marketing_message_2 = "ท้าเพื่อนของคุณให้เข้าร่วมการแข่งขันฉบับย่อของคุณได้เลย!",
    duration_forever = "%s จนถึงตลอดไป",
    marketing_message_3 = "ใครจะพาคุณขึ้นไปถึงระดับสูงสุด?",
    match_list = {
        match_ended = "การแข่งขันเสร็จสิ้นแล้ว",
        played = "เล่นแล้ว",
        most_popular = "ที่ได้รับความนิยมสูงสุด",
        date = "%b %d, %A",
        special = "พิเศษ",
        most_discussed = "พูดถึงมากที่สุด",
        more_regions = "เพิ่มภูมิภาค",
        match_started = "การแข่งขันเริ่มแล้ว",
        match_won = "ชนะ: %d คะแนน",
        match_lost = "แพ้: %d คะแนน",
        total_fans = "แฟน",
        less_regions = "ลดภูมิภาค",
        upcoming_matches = "การแข่งขันที่กำลังจะมาถึง",
        todays_matches = "การแข่งขันของวันนี้",
        draw = "เสมอ",
    },
    updating_files = "กำลังอัพเดท %s ...",
    info = {
        competition_not_started = "การแข่งขันเริ่ม %s",
        like_fh1 = "ที่ผ่านมาคุณชอบ FootballHero หรือไม่?",
        predictions_entered = "คุณได้เสร็จสิ้นการแข่งขันนี้แล้ว",
        coming_soon = "เร็วๆ นี้!",
        join_code_copied = "รหัสเข้าร่วมได้ถูกคัดลอกไปยังคลิปบอร์ดแล้ว",
        shared_to_fb_minigame = "คุณได้แบ่งปันมินิเกมของคุณไปยังเฟซบุ๊กแล้ว!",
        leave_comment2 = "ส่งคำติชมของคุณมายังอีเมลของเรา",
        star_bet = "คุณสามารถใช้ดาวเดิมพัน 3 ดวง ได้ทุกๆ 12 ชม.",
        odds_not_ready = "ความเป็นต่อจะได้รับการอัพเดทเร็วๆนี้ \nกรุณาตรวจสอบใหม่ภายหลัง",
        title = "ข้อมูล",
        leave_comment1 = "บอกเราทีว่าจะต้องพัฒนาอย่างไรบ้าง!",
        shared_to_fb = "ได้แบ่งปันการแข่งขันไปยังเฟซบุ๊กแล้ว!",
        announcement_title = "ประกาศ",
        like_fh2 = "กรุณาสละเวลาให้คะแนนแอพพลิเคชั่น",
        new_version = "กรุณาดาวน์โหลดเวอร์ชั่นและการอัพเดทใหม่!",
    },
    serverError = {
        COMPETITION_6 = "ไม่พบข้อมูลสถิติของ ปี/เดือน/สัปดาห์ นี้",
        COUPON_3 = "คูปองยังไม่มีการทำนาย ไม่สามารถวางคูปองเปล่าได้",
        FACEBOOK_2 = "อุ๊ย! คุณยังไม่ได้เชื่อมต่อกับเฟซบุ๊ก",
        DEFAULT = "อุ๊ย! กรุณาลองใหม่อีกครั้ง...",
        COUPON_1 = "ไม่อนุญาตให้มีการเดิมพัน",
        LEADERBOARD_2 = "อุ๊ย! กรุณาลองใหม่อีกครั้ง",
        LEADERBOARD_1 = "อุ๊ย! ตารางผู้นำไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง",
        COUNTRY_1 = "อุ๊ย! ลองเลือกประเทศอื่น",
        COMPETITION_5 = "ผู้ใช้ยังไม่ได้เข้าร่วมการแข่งขันนี้",
        COMPETITION_3 = "ไม่มีจอยโทเคน (Join token)",
        COMPETITION_2 = "ไม่มีการแข่งขันนี้",
        FACEBOOK_4 = "อุ๊ย! บัญชีเฟซบุ๊กนี้ถูกใช้แล้ว",
        WHEEL_3 = "ไม่พบของรางวัล",
        WHEEL_5 = "ยอดที่ขอน้อยกว่ายอดการใช้จ่ายต่ำสุด",
        SIGNIN_2 = "ชื่อผู้ใช้ หรือรหัสผ่านไม่ถูกต้อง",
        FACEBOOK_3 = "อุ๊ย! บัญชีเฟซบุ๊กนี้ถูกใช้แล้ว",
        DISCUSSION_3 = "อุ๊ย! กรุณาลองใหม่อีกครั้ง",
        COMPETITION_7 = "คุณไม่สามารถเข้าร่วมการแข่งขันที่อยู่ในโหมดการแสดงตัวอย่างได้",
        GENERAL_2 = " อุ๊ย! ชื่อผู้ใช้ของคุณไม่ถูกต้อง",
        VERSION_1 = "กรุณาอัพเดทเวอร์ชั่นล่าสุดในแอพพลิเคชั่นสโตร์",
        WHEEL_4 = "ผู้ใช้ยังไม่เคยหมุนวงล้อเลย",
        COUPON_4 = "มีการทำนายไปแล้วหนึ่งครั้งหรือมากกว่าก่อนหน้านี้",
        SIGNIN_1 = "อุ๊ย! อีเมลของคุณไม่ถูกต้อง",
        VERSION_2 = "เพิ่มฟีเจอร์ใหม่แล้ว! กรุณาอัพเดท FootballHero ในแอพพลิเคชั่นสโตร์",
        COMPETITION_4 = "คุณได้เข้าร่วมการแข่งขันนี้แล้ว",
        WHEEL_2 = "ความน่าจะเป็นของราคาไม่น่าเชื่อถือ",
        FACEBOOK_1 = "อุ๊ย! ดูเหมือนว่าจะมีข้อผิดพลาด กรุณาลองใหม่อีกครั้ง",
        WHEEL_1 = "การหมุนวงล้อครั้งล่าสุดของคุณยังผ่านไปไม่ถึง 24 ชม.",
        LEAGUE_1 = "อุ๊ย! ลองเลือกลีกอื่น",
        DISCUSSION_2 = "อุ๊ย! กรุณาลองใหม่อีกครั้ง",
        DISCUSSION_1 = "อุ๊ย! กรุณาลองใหม่อีกครั้ง",
        GENERAL_1 = "อุ๊ย! ขออภัย กรุณาลองใหม่อีกครั้ง",
        SIGNIN_4 = "อีเมล และ/หรือรหัสผ่านไม่สามารถปล่อยว่างไว้ได้",
        COUPON_2 = "มีการทำนายมากเกินไปในคูปอง",
        FACEBOOK_5 = "อุ๊ย! ขออภัย กรุณาลองใหม่ภายหลัง",
        COMPETITION_8 = "โบนัสจากการแบ่งปันได้ถูกรับไปแล้ว",
        COUPON_5 = "การเดิมพันใหญ่ครั้งล่าสุดยังผ่านไปไม่ถึง 12 ชม.",
        COMPETITION_1 = "คุณได้สร้างการแข่งขันด้วยชื่อนี้ไปแล้วก่อนหน้านี้",
        WHEEL_6 = "ยอดที่ขอมากเกินกว่ายอดคงเหลือของคุณ",
        SIGNIN_3 = "ไม่มีที่อยู่อีเมลนี้",
    },
    duration_to = "%s ถึง %s",
    terms_agree = "การลงชื่อเข้าใช้ถือเป็นการยอมรับว่าคุณได้อ่านและตกลงกับ FOOTBALL HERO'S แล้ว",
    last_name_optional = "นามสกุล (ไม่จำเป็นต้องระบุ)",
    community = {
        share = "แบ่งปัน",
        rules = "กฎกติกา",
        title_leaderboard = "ตารางผู้นำ",
        enter_comp_code = "ใส่รหัส",
        all_competitions = "ลีกและถ้วยทั้งหมด",
        title_joined_comp = "การแข่งขันที่เข้าร่วม",
        disclaimer = "*** คำแถลงการณ์ปฏิเสธความรับผิดชอบ - Apple ไม่ได้เป็นผู้สนับสนุนและไม่มีส่วนเกี่ยวข้องใดๆ ทั้งสิ้น",
        copy = "คัดลอก",
        title_top_performers = "ผู้เล่นระดับสูงสุด",
        label_months = "เดือน",
        label_call_to_arm = "คุณยังไม่ได้อยู่ใน \nการแข่งขันใดๆ \n\nสร้างการแข่งขันใหม่และ\nท้าเพื่อนๆของคุณตอนนี้เลย!",
        title_duration = "ระยะเวลา",
        label_ongoing = "กำลังดำเนินอยู่",
        title_rules = "กฎกติกา",
        title_eligible = "ลีก/ถ้วย ที่เข้าเกณฑ์",
        invite_code = "รหัสการเชิญ:",
        quit = "ออก",
        title_description = "คำอธิบาย",
        title_join_comp = "เข้าร่วมการแข่งขัน",
        label_give_title = "ใส่ชื่อให้การแข่งขันของคุณ",
        title_create_comp = "การแข่งขัน s",
        label_select_league = "เลือกลีก",
        push = "การแจ้งเตือนแบบพุช",
        title_details = "รายละเอียด",
        title_competition = "การแข่งขัน",
        label_how_long = "มันจะอยู่ได้นานเท่าไหร่",
        label_give_desc = "ใส่คำอธิบาย",
        desc_create_comp = "การทำนายที่เกิดขึ้นในลีกที่เลือกสำหรับการแข่งขัน จะถูกรวมเข้าไปในการแข่งขันโดยอัตโนมัติ",
        label_fb_share = "แบ่งปันบนเฟซบุ๊ก",
        label_new = "ใหม่",
    },
    first_name = "ชื่อ",
    share_type_email = "อีเมล",
    football_hero = "FootballHero",
    quit_title = "คุณแน่ใจหรือที่จะออก?",
    optional = "(ตัวเลือก)",
    top_performers = "ผู้เล่นอันดับสูงสุด",
    settings = {
        edit = "ก้ไข",
        prediction = "การทำนาย",
        sound_effects = "เอฟเฟกต์เสียง",
        tap_to_edit = "แตะเพื่อแก้ไข",
        sounds = "เสียง",
        send_feedback = "ส่งคำติชม",
        select_league = "เลือกลีก",
        select_language = "เลือกภาษา",
        set_favorite_tams = "ตั้งค่าทีมที่ชื่นชอบของฉัน",
        phone = "เบอร์โทรศัพท์",
        logout = "ลงชื่อออก",
        favorite_team_none = "ไม่มีทีมที่ชื่นชอบ",
        email = "ที่อยู่อีเมล",
        sound_settings = "การตั้งค่าเสียง",
        user_info = "ข้อมูลผู้ใช้",
        title = "การตั้งค่า",
        push_notification = "การแจ้งเตือนแบบพุช",
        others = "อื่นๆ",
        general = "ข่าวทั่วไป",
        faq = "คำถามที่พบบ่อย",
        favorite_team = "ทีมที่ชอบ",
    },
    month = {
        m9 = "กันยายน",
        m8 = "สิงหาคม",
        m12 = "ธันวาคม",
        m10 = "ตุลาคม",
        m3 = "มีนาคม",
        m2 = "กุมภาพันธ์",
        m1 = "มกราคม",
        m11 = "พฤศจิกายน",
        m4 = "เมษายน",
        m5 = "พฤษภาคม",
        m6 = "มิถุนายน",
        m7 = "กรกฎาคม",
    },
    chat_room_title = "เลือกห้องแชต",
    num_of_points = "%d คะแนน",
    share_title = "เข้าร่วมการแข่งขันของ %s บน FootballHero",
    quit_cancel = "คงอยู่",
    minigame = {
        friend_help = "เพื่อนได้ช่วยเหลือคุณ",
        ask_more_friends = "ขอเพื่อนเพิ่ม!",
        winners = "ผู้ชนะครั้งก่อน",
        shoot_to_win_won = "คุณชนะ!",
        current_score = "คะแนนล่าสุด:",
        goal_to_win = "เหลืออีก %d ประตูจึงจะชนะ",
        rules = "กฎกติกา",
        no_one_won = "ยังไม่มีใครได้รับ Samsung Note Edge",
        title = "เกม ยิง-เพื่อ-ชนะ",
        call_to_action = "ยังไม่มีใครทำคะแนนให้คุณได้เลย",
        helped_to_score = "ได้ช่วยทำคะแนนให้คุณ %d ประตู",
        iPhone6_winner = "ผู้ชนะ Samsung Note Edge",
        failed_to_score = "ล้มเหลวในการทำประตู",
        ask_friends_help = "ขอให้เพื่อนช่วย!",
    },
    choice = {
        leave_comp_no = "คงอยู่",
        leave_comp_title = "ออกจากการแข่งขัน",
        leave_comp_yes = "ออก",
        leave_comp_desc = "คุณแน่ใจหรือที่จะออกจากการแข่งขัน?",
    },
    support_title = "FootballHero – สนับสนุน",
    vs = "กับ",
    share_body = "คุณสามารถเอาชนะฉันได้ไหม? เข้าร่วมการแข่งขันของฉันใน FootballHero รหัส: %s  www.footballheroapp.com/download",
    support_email = "support@footballheroapp.com",
    unknown_name = "ชื่อที่ไม่รู้จัก",
    email = "ที่อยู่อีเมล",
    password = "รหัสผ่าน",
    history = {
        stake = "การเดิมพัน: %d คะแนน",
        won_small = "ชนะ",
        predictions_closed = "การทำนายที่ปิดแล้ว",
        lost = "แพ้",
        won_colon = "ชนะ:",
        total_points = "%d",
        predictions_open = "การทำนายที่เปิดแล้ว",
        win_by = "%s จะชนะด้วยคะแนน %d ประตูหรือมากกว่า?",
        total_goals = "ประตูรวมจะเป็น %d หรือมากกว่า?",
        won = "ชนะ",
        predictions_all = "การทำนายทั้งหมด",
        no_open_prediction = "คุณยังไม่มี\nการทำนายที่เปิดแล้ว",
        show_all = "แสดงทั้งหมด",
        lost_colon = "แพ้:",
        no_open_prediction_others = "ไม่มีการทำนายที่เปิดแล้ว",
        lost_small = "แพ้",
        win_count = "%d จาก %d",
        no_closed_prediction_others = "ไม่มีการทำนายที่ปิดแล้ว",
        no_closed_prediction = "คุณยังไม่มี\nการทำนายที่ปิดแล้ว",
        which_team = "ทีมไหนจะชนะ?",
    },
    first_name_optional = "ชื่อ (ไม่จำเป็นต้องระบุ)",
    email_confirm = "ยืนยันที่อยู่อีเมล",
    match_prediction = {
        share = "แบ่งปันกับเพื่อนของคุณ",
        hint_tap = "แตะเพื่อทำการทำนาย!",
        win = "ชนะ",
        team_to_win = "ทีมไหนจะชนะ?",
        stand_to_win = "ยืนหยัดเพื่อชนะ",
        will_total_goals = "ประตูรวมจะเป็น %d หรือมากกว่า?",
        balance = "ยอดคงเหลือ",
        prediction_summary = "สรุปการทำนาย",
        facebook = "เฟซบุ๊ก",
        will_win_by = "%s จะชนะด้วยคะแนน %d ประตูหรือมากกว่า?",
        stake = "การเดิมพัน",
    },
    quit_desc = "แตะย้อนกลับอีกครั้งเพื่อออก",
    error = {
        bad_email_format = "รูปแบบอีเมลไม่ถูกต้อง",
        title_default = "อุ๊ย! คุณมีข้อผิดพลาด",
        blank_password = "ช่องรหัสผ่านว่างเปล่า",
        no_sms = "คุณยังไม่ได้ตั้งค่าข้อความ",
        blank_league = "ช่องเลือกลีกไม่สามารถว่างเปล่าได้",
        email_not_match = "อีเมลไม่ตรงกัน",
        invalid_month = "จำนวนเดือนไม่ใช่ตัวเลข",
        blank_token = "ช่องรหัสการแข่งขันไม่สามารถว่างเปล่าได้",
        blank_email = "ช่องอีเมลว่างเปล่า",
        blank_title = "ช่องคำนำหน้าชื่อไม่สามารถว่างเปล่าได้",
        password_short = "รหัสผ่านสั้นเกินไป",
        blank_comp_id = "ช่องชื่อการแข่งขันไม่สามารถว่างเปล่าได้",
        updating_failed = "การตั้งค่าการอัพเดทล้มเหลว กรุณาลองอีกครั้ง",
        password_not_match = "รหัสผ่านไม่ตรงกัน",
        blank_desc = "ช่องคำอธิบายไม่สามารถว่างเปล่าได้",
        password_long = "รหัสผ่านยาวเกินไป",
        blank_user_name = "ชื่อผู้ใช้ว่างเปล่า",
        no_email = "คุณยังไม่ได้ตั้งค่าบัญชีอีเมล",
        go_to_store = "ไปยังสโตร์",
        login_failed = "การลงชื่อเข้าใช้ล้มเหลว กรุณาลองอีกครั้ง",
        match_completed = "คุณได้เสร็จสิ้นการแข่งขันนี้แล้ว",
    },
    today = "วันนี้",
}

require "DefaultString"

for i = 1 , table.getn( StringDefaultSubTableList ) do
    local subTableTitle = StringDefaultSubTableList[i]
    if Strings[subTableTitle] then
        setmetatable( Strings[subTableTitle], extendsStringDefaultSubTable(subTableTitle) )
    end
end
setmetatable( Strings, extendsStringDefault() )
CCLuaLog("Load th string.")