module(..., package.seeall)

Strings = {
	chat_hint = "اضغط هنا لبدء الدردشة!",
	league_chat = {
		feedback = "الملاحظات والتعليقات",
		spanish = "الدوري الاسباني",
		others = "المسابقات الأخرى",
		italian = "الدوري الإيطالي",
		facebook = "سجل إعجابك بنا على Facebook",
		uefa = "الدوريات الأوروبية",
		german = "الدوري الألماني",
		english = "الدوري الإنجليزي",
	},
	button = {
		share = "مشاركة",
		cancel = "إلغاء",
		yes = "نعم",
		existing_user = "مستخدم موجود",
		enable = "تمكين",
		rate_now = "تصنيف الآن",
		new_user = "مستخدم جديد",
		no_thanks = "لا، شكرًا.",
		ok = "موافق",
		sign_in = "تسجيل الدخول",
		no = "لا",
		create = "إنشاء!",
		forget_password = "هل نسيت كلمة المرور؟",
		confirm = "تأكيد!",
		predict = "توقع!",
		join = "انضمام",
		register = "تسجيل",
		play_now = "العب الآن!",
		go = "اذهب!",
	},
	message_hint = "اكتب رسالتك هنا",
	friends = "الأصدقاء",
	marketing_message_1 = "تهنئتنا على صدق توقعك الأوّل!",
	push_notification = {
		receive = "سوف تتلقى:",
		prediction_summary = "ملخص التوقعات",
		match_result = "نتائج المباريات",
		question_competition = "هل ترغب في استلام الإخطارات اللحظية عن هذه المسابقة؟",
		question_prediction = "هل ترغب في استلام الإخطارات اللحظية عن كافة التوقعات؟",
		points_won = "نقاط الفوز أو الخسارة",
		new_participant = "تنبيه مشارك جديد",
	},
	enter_email = "يُرجى إدخال عنوان البريد الإلكتروني.",
	match_center = {
		played = "تم اللعب",
		just_now = "الآن",
		prediction_made = "تم تسجيل التوقع",
		title_meetings = "أحدث الاجتماعات",
		played_out_of = "%d من %d",
		share_title = "",
		less = "أقل",
		make_prediction = "سجل توقعك!",
		share_body = "",
		write_discussion = "قم بكتابة مناقشة جديدة...",
		load_comments = "حمل مزيد من التعليقات...",
		write_comment = "اكتب تعليق...",
		title = "مركز المباراة",
		time_hours = "%d ساعة",
		title_discussion = "مناقشة",
		more = "المزيد",
		time_days = "%d يوم",
		time_minutes = "%d دقيقة",
	},
	email_signin = "قم بتسجيل الدخول باستخدام البريد الإلكتروني",
	share_type_facebook = "Facebook",
	share_type_title = "شارك المسابقة الخاصة بك باستخدام...",
	unknown_team = "فريق غير معروف",
	leaderboard = {
		win_ratio_title = "نسبة الفوز",
		stats_win_rate = "فوز%",
		gain_per_prediction_title = "المكسب لكل توقع",
		stats_last_ten = "آخر 10 مباريات",
		me_score = "%d فوز",
		stats_l = "خسارة",
		win_ratio_desc = "%d%%فوز (%d توقعات)",
		stats_league = "الدوري",
		stats_w = "فوز",
		high_score_title = "أعلى رصيد",
		high_score_desc = "%d فوز (%d توقعات)",
		gain_per_prediction_desc = "%d%%مكسب (%d توقعات)",
		stats_win = "فوز",
		min_prediction = "توقعات بنسبة %d على أقل تقدير",
		stats_gain_rate = "مكسب%",
		stats_lose = "خسارة",
	},
	last_name = "الاسم الأخير",
	share_type_SMS = "رسالة نصية قصيرة",
	password_confirm = "قم بتأكيد كلمة المرور",
	spinWheel = {
		ticket_usage = "للسحب الأخير.",
		only_show_big_prize = "أظهر الجوائز الكبيرة فقط",
		winners = "الفائزون السابقون",
		collect_email_you_won = "لقد فزت",
		wheel_title = "قم بتدوير العجلة",
		collect_email_min = "الحد الأدنى للسحب 25 دولارًا أمريكيًا",
		ticket_balance_2 = "%d تذكرة",
		win_ticket_left = "يسار حتى السحب.",
		spin_daily = "قم بتدويرها مرة واحدة يوميًا",
		to_claim_prize = "للحصول على جائزة",
		balance_title = "الرصيد",
		wheel_sub_title = "قم بتدوير العجلة!",
		win_ticket_prize = "تذكرة سحب",
		collect_email_prize = "1 دولار أمريكي",
		share_description = "شارك اللعبة مع أصدقاءك وأحصل على دورة إضافية.",
		spin_bonus = "مكافأة دوارة",
		collect_email_towards_wallet = "تجاه رصيد الحساب الخاص بك",
		money_balance = "دولار أمريكي %s بطاقة Amazon Gift Card",
		please_contact = "يرجى الاتصال",
		won = "فوز",
		collect_email_label_title = "الحصول على جائزة",
		ticket_balance_1 = "%d تذكرة",
		ticket_you_have = "يمكنك",
		leave_message = "الرجوع غدًا للحصول على محاولة أخرى.",
		money_payout_limit = "25 دولار أمريكي للانسحاب على أقل تقدير.",
		money_payout_success_notification = "تم إرسال طلبك, يرجى الانتظار من أسبوعين إلى أربعة أسابيع لاستلام بطاقة الهدايا عبر البريد الإلكتروني الخاص بك.",
		claimVirtualPrize = "تهنئتنا! لقد فزت ب %s, يرجى الاتصال بفريق الدعم التابع لنا.",
		no_one_won = "لم يفُز أحد بأي جائزة حتى الآن.",
		come_back_in = "أعد الزيارة مرة أخرى في:",
		collect_email_description = "يُرجَى إدخال عنوان بريد إلكتروني صالح. إذ أن عناوين البريد الإلكتروني الزائفة سوف تُحرم من الفوز بالجوائز.",
		win_prizes = "اربح جوائز مغرية منھا توقيع ميسي وجوائز نقدية قيمة",
	},
	login_success = "تم تسجيل الدخول بنجاح \nجاري تحميل البيانات, يرجى الانتظار...",
	event = {
		hint_unqualified = "يجب أن تتوقع ما يزيد عن %d مباراة في هذه المسابقة حتى تصبح مؤهلاً للحصول على الجوائز.",
		ranking_dropdown_week = "أسبوع %1$d: %2$d %3$s-%4$d %5$s",
		ranking_dropdown_month = "%2$s %1$s",
		status_unqualified = "-unqualified",
		prizes = "الجوائز",
		predict_now = "سجل توقعاتك الآن",
		ranking_overall = "كل موسم",
		ranking_weekly = "أسبوعيًا",
		status_qualified = "-qualified",
		total_players = "العدد الكلي لللاعبين",
		ranking_monthly = "شهريًا",
		hint_qualified = "لقد تأهلت لتحصل على الجوائز",
	},
	user_name = "اسم المستخدم",
	facebook_signin = "سجل الدخول باستخدام Facebook",
	marketing_message_2 = "تحدى أصدقاءك في المسابقات الصغيرة الخاصة بك الآن!",
	duration_forever = "%s إلى ما لا نهاية",
	marketing_message_3 = "من الذي سوف يحتل الصدارة؟",
	match_list = {
		match_ended = "المباراة انتهت",
		played = "تم اللعب",
		most_popular = "الأكثر شيوعًا",
		date = "%b %, d و%A",
		special = "خاص",
		most_discussed = "الأكثر إثارة للمناقشات",
		more_regions = "أكثر المناطق",
		match_started = "المباراة بدأت",
		match_won = "فوز: %d نقطة",
		match_lost = "خسارة: %d نقطة",
		total_fans = "الجماهير",
		less_regions = "أقل المناطق",
		upcoming_matches = "المباريات القادمة",
		todays_matches = "مباريات اليوم",
		draw = "تعادل",
	},
	updating_files = "جاري تحديث %s...",
	info = {
		competition_not_started = "تبدأ المسابقة %s.",
		like_fh1 = "هل تعجبك FootballHero حتى الآن؟",
		predictions_entered = "لقد أتممت هذه المباراة.",
		coming_soon = "قريبًا!",
		join_code_copied = "يتم نسخ كود الانضمام إلى الحافظة.",
		shared_to_fb_minigame = "لقد قمت بمشاركة لعبتك الصغيرة عبر Facebook!",
		leave_comment2 = "ارسل لنا ملاحظاتك",
		star_bet = "يمكن استخدام 3 ملصقات على شكل نجوم كل 12 ساعة",
		odds_not_ready = "سيتم تحديث الاحتمالات قريبًا.\nيرجى التحقق مرة أخرى في وقت لاحق.",
		title = "معلومات",
		leave_comment1 = "يرجى إعلامنا عن كيفية التطور!",
		shared_to_fb = "تمت مشاركة المسابقة عبر Facebook.",
		announcement_title = "إعلان",
		like_fh2 = "يرجى قضاء دقيقة في تصنيف التطبيقات.",
		new_version = "يرجى تنزيل الإصدار الجديد وتحديثه!",
	},
	serverError = {
		COMPETITION_6 = "لم يتم العثور على بيانات إحصائية مجمعة لهذا العام/الشهر/ الأسبوع.",
		COUPON_3 = "لا يوجد توقعات على الكوبون, يتعذر وضع كوبون فارغ.",
		FACEBOOK_2 = "عفوًا! أنت غير مُتصل بحساب Facebook.",
		DEFAULT = "عفوًا! يرجى إعادة المحاولة...",
		COUPON_1 = "جائزة غير مسموح بها.",
		LEADERBOARD_2 = "عفوًا! يرجى إعادة المحاولة.",
		LEADERBOARD_1 = "عفوًا! لوحة نتائج غير صحيحة, يرجى إعادة المحاولة.",
		COUNTRY_1 = "عفوًا! حاول استخدام دولة أخرى.",
		COMPETITION_5 = "لم يتم تسجيل المستخدم في هذه المسابقة.",
		COMPETITION_3 = "رمز الانضمام غير موجود.",
		COMPETITION_2 = "المسابقة غير موجودة.",
		FACEBOOK_4 = "عفوًا! حساب Facebook مستخدم بالفعل.",
		WHEEL_3 = "يتعذر العثور على جائزة.",
		WHEEL_5 = "الكمية المطلوبة أقل من الحد الأدنى للعوائد.",
		SIGNIN_2 = "اسم مستخدم أو كلمة مرور غير صحيحة",
		FACEBOOK_3 = "عفوًا! حساب Facebook مستخدم بالفعل.",
		DISCUSSION_3 = "عفوًا! يرجى إعادة المحاولة.",
		COMPETITION_7 = "يتعذر الاشتراك في مسابقة وهي في وضع المعاينة.",
		GENERAL_2 = "عفوًا! معرِّف المستخدم الخاص بك غير صحيح.",
		VERSION_1 = "يرجي تحديث الإصدار الأخير في متجر التطبيقات.",
		WHEEL_4 = "المستخدم لم يقم بتدوير العجلة مطلقًا.",
		COUPON_4 = "تم اللعب بأحد التوقعات أو أكثر مُسبقًا.",
		SIGNIN_1 = "عفوًا! البريد الإلكتروني غير صالح.",
		VERSION_2 = "تم إضافة عدد من الخصائص الجديدة! يرجي تحديث لعبة FootballHero من متجر التطبيقات.",
		COMPETITION_4 = "أنت مُسجل بالفعل في هذه المسابقة.",
		WHEEL_2 = "يتعذر جمع احتمالات السعر.",
		FACEBOOK_1 = "عفوًا! يبدوا أن هناك خطأ ما. يرجى إعادة المحاولة.",
		WHEEL_1 = "لم يمر 24 ساعة على آخر مرة قمت بتدوير العجلة.",
		LEAGUE_1 = "عفوًا! حاول استخدام دوري آخر.",
		DISCUSSION_2 = "عفوًا! يرجى إعادة المحاولة.",
		DISCUSSION_1 = "عفوًا! يرجى إعادة المحاولة.",
		GENERAL_1 = "عفوًا! نرجو المعذرة. يرجى إعادة المحاولة.",
		SIGNIN_4 = "لا يمكن ترك خانة البريد الإلكتروني و/أو كلمة المرور فارغة.",
		COUPON_2 = "يوجد عدد كبير من التوقعات على الكوبون.",
		FACEBOOK_5 = "عفوًا! نرجو المعذرة. يرجى المحاولة مرة أخرى لاحقًا.",
		COMPETITION_8 = "تم الحصول على مشاركة الحوافز",
		COUPON_5 = "أحدث الرهانات الكبيرة كان قبل 12 ساعة.",
		COMPETITION_1 = "لقد قمت بإنشاء واحدة من المسابقات بهذا الاسم من قبل.",
		WHEEL_6 = "الكمية المطلوبة تتعدى الرصيد الخاص بك.",
		SIGNIN_3 = "عنوان البريد الإلكتروني غير موجود.",
	},
	duration_to = "%s إلى %s",
	terms_agree = "فور تسجيل الدخول، تقر بأنك قد قرأت ووافقت على شروط FOOTBALL HERO'S",
	last_name_optional = "الاسم الأخير (اختياري)",
	community = {
		share = "مشاركة",
		rules = "قواعد",
		title_leaderboard = "لوحة النتائج",
		enter_comp_code = "أدخل الرمز",
		all_competitions = "جميع الدوريات والكؤوس",
		title_joined_comp = "الانضمام للمسابقات",
		disclaimer = "*** بيان إخلاء المسؤولية - لا يمثل Apple راعيًا أو مشاركًا بأي حال من الأحوال.",
		copy = "نسخ",
		title_top_performers = "أفضل اللاعبين",
		label_months = "شهور",
		label_call_to_arm = "أنت غير مسجّل في أي \nمسابقة حتى الآن.\n\nأنشيء مسابقة جديدة وابدأ تحدي أصدقائك الآن!",
		title_duration = "المدة",
		label_ongoing = "جارية",
		title_rules = "قواعد اللعب",
		title_eligible = "الدوريات المؤهلة/الكؤوس",
		invite_code = "رمز الدعوة:",
		quit = "إنهاء",
		title_description = "الوصف",
		title_join_comp = "الانضمام إلى المسابقة",
		label_give_title = "ضع عنوان للمسابقة",
		title_create_comp = "المسابقات الصغيرة",
		label_select_league = "حدد الدوري",
		push = "الإخطارات اللحظية",
		title_details = "التفاصيل",
		title_competition = "المسابقات",
		label_how_long = "الى متى سوف تستمر؟",
		label_give_desc = "اختر وصفًا",
		desc_create_comp = "وترد التوقعات المحرزة في المسابقات المختارة تلقائيًا إلى المسابقة.",
		label_fb_share = "مشاركة عبر Facebook",
		label_new = "جديد",
	},
	first_name = "الاسم الأول",
	share_type_email = "البريد الإلكتروني",
	football_hero = "FootballHero",
	quit_title = "هل تريد الإنهاء بالتأكيد؟",
	optional = "(اختياري)",
	top_performers = "أفضل اللاعبين",
	settings = {
		prediction = "توقعات",
		sound_effects = "المؤثرات الصوتية",
		tap_to_edit = "انقر للتحرير",
		sounds = "الأصوات",
		send_feedback = "إرسال تعليق",
		select_league = "تحديد الدوري",
		select_language = "تحديد اللغة",
		set_favorite_tams = "تحديد الفرق المفضلة",
		phone = "رقم الهاتف",
		logout = "تسجيل الخروج",
		favorite_team_none = "لا توجد فرق مفضلة",
		email = "عنوان البريد الإلكتروني",
		sound_settings = "إعدادات الصوت",
		user_info = "معلومات المستخدم",
		title = "الإعدادات",
		push_notification = "الإخطارات اللحظية",
		others = "أخرى",
		general = "الأخبار العامة",
		faq = "الأسئلة الشائعة",
		favorite_team = "الفرق المفضّلة",
	},
	month = {
		m9 = "سبتمبر",
		m8 = "أغسطس",
		m12 = "ديسمبر",
		m10 = "أكتوبر",
		m3 = "مارس",
		m2 = "فبراير",
		m1 = "يناير",
		m11 = "نوفمبر",
		m4 = "أبريل",
		m5 = "مايو",
		m6 = "يونيو",
		m7 = "يوليو",
	},
	chat_room_title = "حدد غرفة الدردشة",
	num_of_points = "نقاط %d",
	share_title = "انضم إلى الذين لديهم %s من مسابقة FootballHero",
	quit_cancel = "استمرار",
	minigame = {
		friend_help = "الأصدقاء الذين قاموا بمعاونتك",
		ask_more_friends = "اسأل مزيد من الأصدقاء!",
		winners = "الفائزون السابقون",
		shoot_to_win_won = "لقد فزت!",
		current_score = "النقاط الحالية:",
		goal_to_win = "%d من الإهداف المتبقية للفوز",
		rules = "قواعد اللعب",
		no_one_won = "لم يفز شخص بأحد Samsung Note Edge حتى الآن.",
		title = "صوّب لتربح التحدي",
		call_to_action = "لم يحرز أي شخص أية أهداف لصالحك حتى الآن.",
		helped_to_score = "لقد ساعدك على إحراز %d من الأهداف",
		iPhone6_winner = "Samsung Note Edge Winner",
		failed_to_score = "فشلت في إحراز أية أهداف",
		ask_friends_help = "اسأل الأصدقاء للمساعدة!",
	},
	choice = {
		leave_comp_no = "استمرار",
		leave_comp_title = "خروج من المسابقة",
		leave_comp_yes = "مغادرة",
		leave_comp_desc = "هل تريد بالتأكيد الخروج من المسابقة؟",
	},
	support_title = "FootballHero - دعم",
	vs = "ضد",
	share_body = "هل بإمكانك هزيمتي؟ انضم لمسابقتي في FootballHero. الرمز: %s  www.footballheroapp.com/download",
	support_email = "support@footballheroapp.com",
	unknown_name = "اسم غير معروف",
	email = "عنوان البريد الإلكتروني",
	password = "كلمة المرور",
	history = {
		stake = "جائزة: نقاط %d",
		won_small = "فوز",
		predictions_closed = "توقعات مغلقة",
		lost = "خسارة",
		won_colon = "فوز:",
		total_points = "إجمالي النقاط: %d",
		predictions_open = "توقعات مفتوحة",
		win_by = "هل سيفوز %s برصيد %d من الأهداف أو أكثر؟",
		total_goals = "هل سيكون إجمالي رصيد الأهداف %d أو أكثر؟",
		won = "فوز",
		predictions_all = "كافة التوقعات",
		no_open_prediction = "لا يوجد لديك \nتوقعات مفتوحة حتى الآن.",
		show_all = "إظهار الكل",
		lost_colon = "خسارة:",
		no_open_prediction_others = "لا توجد توقعات مفتوحة",
		lost_small = "خسارة",
		win_count = "%d من %d",
		no_closed_prediction_others = "لا يوجد توقعات مغلقة",
		no_closed_prediction = "لا يوجد لديك \nتوقعات مغلقة حتى الآن.",
		which_team = "من الفريق الذي سيفوز؟",
	},
	first_name_optional = "الاسم الأول (اختياري)",
	email_confirm = "تأكيد عنوان البريد الإلكتروني",
	match_prediction = {
		share = "شارك اللعبة مع أصدقائك",
		hint_tap = "انقر لتسجيل توقع!",
		win = "فوز",
		team_to_win = "من الفريق الذي سيفوز؟",
		stand_to_win = "قادر على الفوز",
		will_total_goals = "هل سيكون إجمالي رصيد الأهداف %d أو أكثر؟",
		balance = "الرصيد",
		prediction_summary = "ملخص التوقعات",
		facebook = "Facebook",
		will_win_by = "هل سيفوز %s برصيد %d من الأهداف أو أكثر؟",
		stake = "جائزة",
	},
	quit_desc = "انقر على رجوع مرة أخرى للخروج.",
	error = {
		bad_email_format = "تنسيق رسالة بريد إلكتروني سيئ.",
		title_default = "عفوًا! يوجد لديك خطأ",
		blank_password = "خانة كلمة المرور فارغة.",
		no_sms = "لا يوجد لديك إعداد للرسائل النصية القصيرة.",
		blank_league = "لا يمكن ترك خانة الدوري المرغوب فارغة.",
		email_not_match = "البريد الإلكتروني غير مطابق.",
		invalid_month = "عدد الأشهر ليس رقمًا.",
		blank_token = "لا يمكن ترك خانة رمز المسابقة فارغة.",
		blank_email = "خانة البريد الإلكتروني فارغة.",
		blank_title = "لا يمكن ترك خانة العنوان فارغة.",
		password_short = "كلمة المرور أقصر مما ينبغي.",
		blank_comp_id = "لا يمكن ترك خانة المسابقة فارغة.",
		updating_failed = "فشل تحديث التهيئة. يرجى إعادة المحاولة.",
		password_not_match = "كلمة المرور غير مطابقة.",
		blank_desc = "لا يمكن ترك خانة الوصف فارغة.",
		password_long = "كلمة المرور أطول مما ينبغي.",
		blank_user_name = "خانة اسم المستخدم فارغة.",
		no_email = "لا يوجد لديك إعداد لحساب البريد الإلكتروني.",
		go_to_store = "يرجى الذهاب إلى المتجر.",
		login_failed = "فشل تسجيل الدخول. يرجى إعادة المحاولة.",
		match_completed = "لقد أتممت هذه المباراة.",
	},
	today = "اليوم",
}

require "DefaultString"

for i = 1 , table.getn( StringDefaultSubTableList ) do
    local subTableTitle = StringDefaultSubTableList[i]
    if Strings[subTableTitle] then
        setmetatable( Strings[subTableTitle], extendsStringDefaultSubTable(subTableTitle) )
    end
end
setmetatable( Strings, extendsStringDefault() )
CCLuaLog("Load ar string.")