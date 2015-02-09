module(..., package.seeall)

Strings = {
	chat_hint = "Masukkan pesan",
	league_chat = {
		feedback = "Masukan & Komentar",
		spanish = "Liga Spanyol",
		others = "Kompetisi Lainnya",
		italian = "Liga Itali",
		facebook = "Sukai kami di Facebook",
		uefa = "Liga UEFA",
		german = "Liga Jerman",
		english = "Liga Inggris",
	},
	email_signin = "Masuk dengan E-mail",
	error = {
		bad_email_format = "Format e-mail salah.",
		title_default = "Oops! Anda mendapatkan pesan error",
		blank_password = "Kata Sandi kosong.",
		no_sms = "Anda belum mengatur SMS Anda.",
		blank_league = "Liga yang terpilih tidak boleh kosong.",
		email_not_match = "Email tidak cocok",
		invalid_month = "Jumlah bulan bukan angka.",
		blank_token = "Kode Kompetisi tidak boleh kosong.",
		blank_email = "Alamat E-mail kosong.",
		blank_title = "Judul tidak boleh kosong.",
		blank_desc = "Deskripsi tidak boleh kosong.",
		blank_comp_id = "IdKompetisi tidak boleh kosong.",
		updating_failed = "Pembaruan konfigurasi gagal. Silahkan mencoba kembali.",
		login_failed = "Gagal masuk. Silahkan mecoba kembali.",
		go_to_store = "Pergi ke Toko.",
		password_long = "Kata sandi terlalu panjang.",
		blank_user_name = "Nama pengguna kosong.",
		no_email = "Anda belum mengatur akun E-mail Anda.",
		password_not_match = "Kata sandi tidak cocok.",
		password_short = "Kata sandi terlalu singkat.",
		match_completed = "Anda telah menyelesaikan pertandingan ini.",
	},
	today = "Hari Ini",
	password = "Kata Sandi",
	unknown_name = "Nama tidak diketahui",
	enter_email = "Masukkan e-mail Anda.",
	match_center = {
		played = "Telah bermain",
		title_discussion = "Diskusi",
		prediction_made = "Prediksi telah dibuat",
		title_meetings = "Pertemuan Terakhir",
		played_out_of = " %d dari %d",
		share_title = "",
		less = "lebih sedikit",
		more = "Lebih banyak",
		share_body = "",
		write_discussion = "Tulis diskusi baru…",
		load_comments = "Lihat komentar yang lain…",
		write_comment = "Tulis komentar…",
		title = "Pusat Pertandingan",
		time_hours = "%d jam",
		just_now = "Baru Saja",
		make_prediction = "Buat prediksi!",
		time_days = "%d hari",
		time_minutes = "%d menit",
	},
	button = {
		share = "Bagi",
		cancel = "Batal",
		yes = "Ya",
		register = "Mendaftar",
		enable = "Nyalakan",
		rate_now = "Nilai sekarang",
		new_user = "Pengguna Baru",
		no_thanks = "Tidak, terima kasih.",
		ok = "OK",
		sign_in = "Masuk",
		no = "Tidak",
		create = "Buat!",
		forget_password = "Lupa kata sandi Anda?",
		confirm = "OK!",
		predict = "Buat prediksi!",
		join = "Gabung",
		existing_user = "Pengguna Lama",
		play_now = "Main!",
		go = "Pergi!",
	},
	share_type_facebook = "Facebook",
	first_name_optional = "Nama Depan (Opsional)",
	unknown_team = "Tim tidak diketahui",
	leaderboard = {
		stats_league = "Liga",
		stats_w = "M",
		gain_per_prediction_title = "Untung per Prediksi",
		stats_last_ten = "10 Terakhir",
		me_score = "%d menang",
		stats_l = "K",
		win_ratio_desc = "%d%% menang (%d prediksi)",
		win_ratio_title = "Rasio Menang",
		stats_gain_rate = "%Untung",
		min_prediction = "Paling sedikit %d prediksi",
		high_score_desc = "%d menang (%d prediksi)",
		high_score_title = "Skor Tertinggi",
		stats_win = "Menang",
		gain_per_prediction_desc = "%d%% untung (%d prediksi)",
		stats_win_rate = "%Menang",
		stats_lose = "Kalah",
	},
	optional = "(Opsional)",
	history = {
		show_all = "Semua",
		won_small = "menang",
		predictions_closed = "Prediksi Tertutup",
		lost = "Kalah",
		won_colon = "Menang:",
		total_points = "Jumlah Poin: %d",
		predictions_open = "Prediksi Terbuka",
		win_by = "Akankah %s menang dengan selisih %d gol atau lebih?",
		total_goals = "Akankah total gol berjumlah %d atau lebih?",
		won = "Menang",
		predictions_all = "Semua Prediksi",
		no_open_prediction = "Anda belum memiliki\n pertandingan terbuka.",
		which_team = "Tim mana yang menang?",
		no_closed_prediction = "Anda belum memiliki\n pertandingan tertutup.",
		no_open_prediction_others = "Tidak ada pertandingan terbuka",
		lost_small = "kalah",
		win_count = "%d dari %d",
		no_closed_prediction_others = "Tidak ada pretending tertutup",
		lost_colon = "Kalah:",
		stake = "Taruhan: %d Poin",
	},
	password_confirm = "Konfirmasi Kata Sandi",
	spinWheel = {
		ticket_usage = "untuk lucky draw yang terbaru.",
		only_show_big_prize = "Hanya perlihatkan hadiah besar",
		winners = "Pemenang yang lalu",
		collect_email_you_won = "Anda telah menang",
		wheel_title = "Spin-the-Wheel",
		to_claim_prize = "untuk mengklaim hadiah.",
		ticket_balance_2 = "%d tiket",
		win_ticket_left = "yang tersisa sebelum pengundian.",
		spin_daily = "Satu putaran per hari",
		please_contact = "Silahkan menghubungi",
		share_description = "Bagi ke teman Anda dan dapatkan putaran tambahan.",
		wheel_sub_title = "Spin-the-Wheel!",
		win_ticket_prize = "Tiket Lucky Draw",
		collect_email_min = "Minimal US$25.00 untuk penarikan",
		balance_title = "Saldo",
		collect_email_prize = "1 Dolar US",
		collect_email_towards_wallet = "Silahkan periksa saldo Anda",
		money_balance = "US$ %d Amazon Gift Card",
		spin_bonus = "BONUS PUTARAN",
		won = "Menang",
		collect_email_label_title = "Klaim Hadiah",
		ticket_balance_1 = "%d tiket",
		ticket_you_have = "Anda memiliki",
		leave_message = "Kembali lagi besok untuk putaran yang baru.",
		money_payout_limit = "Minimal US$25.00 untuk penarikan.",
		money_payout_success_notification = "Permintaan Anda sedang diproses. Harap menunggu 2-4 minggu untuk menerima gift card melalui alamat email Anda.",
		claimVirtualPrize = "Selamat! Anda telah memenangkan %s. Silahkan menghubungi layanan bantuan kami. ",
		no_one_won = "Belum ada yang memenangkan hadiah.",
		come_back_in = "Kembali dalam:",
		collect_email_description = "Silahkan masukkan email yang benar. Email yang palsu akan di diskualifikasi dari hadiah.",
	},
	login_success = "Berhasil masuk.\nMemuat data, silahkan tunggu...",
	event = {
		hint_unqualified = "Buat prediksi di %d pertandingan lagi agar terkualifikasi untuk hadiah.",
		ranking_dropdown_week = "Minggu %1$d: %2$d %3$s-%4$d %5$s",
		ranking_dropdown_month = "%1$s %2$s",
		predict_now = "Buat Prediksi",
		prizes = "Hadiah",
		total_players = "Jumlah Pemain",
		ranking_monthly = "Bulanan",
		ranking_weekly = "Mingguan",
		ranking_overall = "Musim",
		status_qualified = "- berkualifikasi",
		status_unqualified = "- belum berkualifikasi",
		hint_qualified = "Berkualifikasi untuk hadiah",
	},
	friends = "Teman",
	facebook_signin = "Masuk dengan Facebook",
	email = "E-mail",
	duration_forever = "%s untuk selamanya",
	marketing_message_3 = "Siapa yang akan menjadi pemain terbaik?",
	match_list = {
		match_ended = "Permainan Usa",
		played = "Main",
		most_popular = "Paling Populer",
		draw = "Seri",
		special = "Spesial",
		most_discussed = "Paling Dibahas",
		more_regions = "Daerah Lainnya",
		todays_matches = "Pertandingan Hari Ini",
		match_won = "Menang: %d P",
		match_lost = "Kalah: %d P",
		total_fans = "Fans",
		less_regions = "Tutup",
		date = "%b %d, %A",
		upcoming_matches = "Pertandingan Akan Datang",
		match_started = "Berlangsung",
	},
	updating_files = "Memperbarui %s ...",
	last_name = "Nama Belakang",
	serverError = {
		COMPETITION_6 = "Tidak ada ditemukan kombinasi data statistik untuk tahun/bulan/minggu ini.",
		COUPON_3 = "Tidak ada prediksi pada kupon. Tidak dapat memasukkan kupon kosong. ",
		FACEBOOK_2 = "Oops! Anda tidak terhubung dengan Facebook.",
		DEFAULT = "Oops! Silahkan mencoba kembali…",
		COUPON_1 = "Taruhan tidak diizinkan. ",
		LEADERBOARD_2 = "Oops! Silahkan mencoba kembali.",
		LEADERBOARD_1 = "Oops! Papan pemain terbaik salah. Silahkan mencoba kembali.",
		COUNTRY_1 = "Oops! Silahkan mencoba negara yang berbeda.",
		COMPETITION_5 = "Pemain tidak terdaftar dalam kompetisi ini.",
		COMPETITION_3 = "Kode ikut serta tidak ada.",
		COMPETITION_2 = "Kompetisi ini tidak ada.",
		FACEBOOK_4 = "Oops! Akun Facebook ini telah digunakan.",
		WHEEL_3 = "Tidak dapat menemukan hadiah.",
		WHEEL_5 = "Jumlah yang diminta lebih kecil dari pembayaran minimal.",
		SIGNIN_2 = "Nama pengguna atau kata sandi salah. ",
		FACEBOOK_3 = "Oops! Akun Facebook ini telah digunakan.",
		DISCUSSION_3 = "Oops! Silahkan mencoba kembali.",
		COMPETITION_7 = "Anda tidak dapat mengikuti kompetisi dalam mode preview.",
		GENERAL_2 = "Oops! Nama pengguna Anda tidak benar.",
		VERSION_1 = "Silahkan unduh versi terbaru di app store.",
		WHEEL_4 = "Pengguna belum pernah memutar roda. ",
		COUPON_4 = "Satu atau lebih prediksi telah dimainkan sebelumnya.",
		SIGNIN_1 = "Oops! Email Anda tidak benar.",
		VERSION_2 = "Fitur baru telah ditambahkan! Silahkan perbaharui FootballHero di app store.",
		COMPETITION_4 = "Anda telah terdaftar dalam kompetisi ini. ",
		WHEEL_2 = "Kemungkinan harga tidak dapat ditambah.",
		FACEBOOK_1 = "Oops! Sepertinya terdapat kesalahan. Silahkan mencoba kembali. ",
		WHEEL_1 = "Putaran terakhir Anda kurang dari 24 jam yang lalu.",
		LEAGUE_1 = "Oops! Coba liga yang lain.",
		DISCUSSION_2 = "Oops! Silahkan mencoba kembali.",
		DISCUSSION_1 = "Oops! Silahkan mencoba kembali.",
		GENERAL_1 = "Oops! Kami minta maaf. Silahkan mencoba kembali.",
		SIGNIN_4 = "Email dan/atau kata sandi tidak boleh kosong.",
		COUPON_2 = "Terlalu banyak prediksi dalam kupon.",
		FACEBOOK_5 = "Oops! Kami minta maaf. Silahkan mencoba kembali.",
		COMPETITION_8 = "Bonus Share telah diklaim.",
		COUPON_5 = "Taruhan besar terakhir kurang dari 12 jam yang lalu.",
		COMPETITION_1 = "Anda telah membuat kompetisi dengan nama ini sebelumnya.",
		WHEEL_6 = "Jumlah yang diminta lebih besar dari saldo Anda.",
		SIGNIN_3 = "Alamat Email tidak ada.",
	},
	duration_to = "%s sampai %s",
	terms_agree = "Dengan masuk ke aplikasi, Anda menyatakan bahwa Anda telah membaca ketentuan dan setuju dengan ketentuan FootballHero",
	last_name_optional = "Nama Belakang (Opsional)",
	community = {
		share = "BAGI",
		rules = "PERATURAN",
		label_call_to_arm = "Anda belum berada di \nkompetisi manapun.\n\n Buat kompetisi yang baru dan\n tantang teman-teman Anda sekarang!",
		enter_comp_code = "Masukkan Kode",
		all_competitions = "Semua Liga",
		title_joined_comp = "Kompetisi yang diikuti",
		disclaimer = "*** Sangkalan - Apple bukan sponsor kami dan tidak terlibat dalam hal apapun.",
		copy = "SALIN",
		title_top_performers = "Pemain Terbaik",
		label_fb_share = "Bagi melalui Facebook",
		label_months = "bulan",
		title_duration = "Durasi",
		label_ongoing = "Tanpa berhenti",
		title_rules = "Peraturan",
		title_eligible = "Liga yang dapat dipilih",
		invite_code = "Kode Undangan:",
		label_how_long = "Berapa lama akan berlangsung?",
		push = "PEMBERITAHUAN OTOMATIS",
		title_details = "Rincian",
		title_competition = "Kompetisi",
		title_create_comp = "Kompetisi",
		label_select_league = "Pilih liga",
		label_give_title = "Berikan judul untuk kompetisi Anda",
		title_join_comp = "Gabung ke kompetisi",
		title_description = "Deskripsi",
		quit = "BERHENTI",
		label_give_desc = "Berikan deskripsi",
		desc_create_comp = "Predikisi yang telah dibuat dalam liga yang terpilih untuk kompetisi akan dimasukkan ke dalam kompetisi secara otomatis.",
		title_leaderboard = "Papan Pemain Terbaik",
	},
	first_name = "Nama Depan",
	share_body = "Dapatkah Anda mengalahkan Saya? Gabung ke dalam kompetisi Saya melalui FootballHero. Kode: %s  www.footballheroapp.com/download",
	football_hero = "FootballHero",
	info = {
		competition_not_started = "Kompetisi mulai %s.",
		like_fh1 = "Apakah Anda suka FootballHero sejauh ini?",
		predictions_entered = "Anda telah menyelesaikan pertandingan ini.",
		new_version = "Silahkan unduh versi terbaru!",
		odds_not_ready = "Kesempatan akan segera diperbarui.\nSilahkan memeriksa sesaat lagi.",
		announcement_title = "Pengumuman",
		leave_comment2 = "Email masukan Anda.",
		coming_soon = "Segera Hadir!",
		like_fh2 = "Silahkan nilai aplikasi ini.",
		title = "Keterangan",
		leave_comment1 = "Beritahu kami area yang bisa kami tingkatkan!",
		shared_to_fb = "Kompetisi telah dibagi ke Facebook.",
		shared_to_fb_minigame = "Anda telah membagi permainan Anda ke Facebook!",
		join_code_copied = "Kode untuk bergabung telah disalin ke clipboard.",
		star_bet = "Anda bisa menggunakan taruhan berbintang 3 setiap 12 jam",
	},
	month = {
		m9 = "September",
		m8 = "Agustus",
		m12 = "Desember",
		m11 = "November",
		m3 = "Maret",
		m2 = "Februari",
		m1 = "Januari",
		m10 = "Oktober",
		m4 = "April",
		m5 = "Mei",
		m6 = "Juni",
		m7 = "Juli",
	},
	minigame = {
		friend_help = "teman telah membantu Anda",
		ask_more_friends = "Minta teman-teman lainnya!",
		goal_to_win = "%d gol lagi untuk menang",
		current_score = "Skor Sekarang:",
		ask_friends_help = "Minta bantuan teman Anda!",
		failed_to_score = "Gagal untuk mencetak gol",
		rules = "Peraturan",
		helped_to_score = "telah membantu Anda untuk mencetak %d gol",
		title = "Shoot-to-Win Challenge",
		call_to_action = "Belum ada yang membantu Anda mencetak gol.",
		no_one_won = "Belum ada yang memenangkan Samsung Note Edge.",
		iPhone6_winner = "Pemenang Samsung Note Edge",
		shoot_to_win_won = "Anda menang!",
		winners = "Pemenang yang lalu",
	},
	settings = {
		edit = "Edit",
		faq = "Pertanyaan Umum",
		general = "Berita Umum",
		tap_to_edit = "Tekan untuk edit",
		sounds = "Suara",
		sound_settings = "Pengaturan Suara",
		select_league = "Pilih Liga",
		select_language = "Pilih bahasa",
		set_favorite_tams = "Tentukan Tim Favorit Saya",
		phone = "Nomor telepon",
		logout = "Keluar",
		favorite_team_none = "Tidak ada Tim Favorit",
		email = "Alamat E-mail",
		user_info = "Informasi pengguna",
		send_feedback = "Kirim Masukan",
		title = "Pengaturan",
		sound_effects = "Efek Suara",
		push_notification = "Pemberitahuan Otomatis",
		prediction = "Prediksi",
		others = "Lainnya",
		favorite_team = "Tim favorit",
	},
	top_performers = "Pemain Terbaik",
	chat_room_title = "Pilih Ruang Chat",
	num_of_points = "%d Poin",
	share_title = "Gabung ke kompetisi %s di FootballHero",
	quit_cancel = "Tinggal",
	push_notification = {
		receive = "Anda akan menerima:",
		prediction_summary = ". Ringkasan pertandingan",
		match_result = ". Hasil pertandingan",
		question_competition = "Apakah Anda ingin menerima pemberitahuan otomatis untuk kompetisi ini?",
		question_prediction = "Apakah Anda ingin menerima pemberitahuan otomatis untuk semua prediksi Anda?",
		points_won = ". Poin menang atau kalah",
		new_participant = ". Tanda peserta baru",
	},
	choice = {
		leave_comp_no = "Tinggal",
		leave_comp_title = "Keluar dari kompetisi",
		leave_comp_yes = "Keluar",
		leave_comp_desc = "Keluar dari kompetisi?",
	},
	support_title = "FootballHero - Bantuan",
	vs = "VS",
	share_type_email = "Email",
	support_email = "support@footballheroapp.com",
	quit_title = "Apakah Anda ingin keluar?",
	marketing_message_2 = "Sekarang tantang teman-teman Anda di kompetisi kecil Anda!",
	user_name = "Nama Pengguna",
	share_type_SMS = "SMS",
	share_type_title = "Bagi kompetisi melalui...",
	email_confirm = "Konfirmasi Email",
	match_prediction = {
		share = "Bagi ke teman Anda",
		hint_tap = "Tekan untuk membuat prediksi!",
		win = "Menang",
		team_to_win = "Tim mana yang menang?",
		stand_to_win = "Menangkan",
		will_total_goals = "Akankah total gol berjumlah %d atau lebih?",
		balance = "Saldo",
		prediction_summary = "Ringkasan Prediksi",
		facebook = "Facebook",
		stake = "Taruhan",
		will_win_by = "Akankah %s menang dengan selisih %d gol atau lebih?",
	},
	quit_desc = "Tekan sekali lagi untuk keluar.",
	message_hint = "Masukkan pesan",
	marketing_message_1 = "Selamat! Anda telah membuat prediksi pertama",
}

require "DefaultString"

for i = 1 , table.getn( StringDefaultSubTableList ) do
    local subTableTitle = StringDefaultSubTableList[i]
    if Strings[subTableTitle] then
        setmetatable( Strings[subTableTitle], extendsStringDefaultSubTable(subTableTitle) )  
    end
end
setmetatable( Strings, extendsStringDefault() )

CCLuaLog("Load bahasa string.")