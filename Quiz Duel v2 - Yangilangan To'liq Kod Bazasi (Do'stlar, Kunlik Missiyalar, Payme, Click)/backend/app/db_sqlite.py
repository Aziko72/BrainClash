import sqlite3
from datetime import datetime

DB_PATH = "/tmp/quiz_duel.db"

def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_connection()
    c = conn.cursor()

    # Users Table
    c.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        fullname TEXT,
        avatar_url TEXT,
        coins INTEGER DEFAULT 500,
        energy INTEGER DEFAULT 10,
        max_energy INTEGER DEFAULT 10,
        xp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        rating_score INTEGER DEFAULT 1000,
        total_wins INTEGER DEFAULT 0,
        total_matches INTEGER DEFAULT 0,
        is_vip INTEGER DEFAULT 0,
        preferred_lang TEXT DEFAULT 'uz',
        created_at TEXT
    )
    """)

    # Categories Table
    c.execute("""
    CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_uz TEXT NOT NULL,
        name_ru TEXT NOT NULL,
        name_en TEXT NOT NULL,
        icon TEXT,
        color TEXT
    )
    """)

    # Questions Table
    c.execute("""
    CREATE TABLE IF NOT EXISTS questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        lang TEXT NOT NULL DEFAULT 'uz',
        question_text TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_option TEXT NOT NULL,
        explanation TEXT,
        difficulty TEXT DEFAULT 'medium'
    )
    """)

    # User Seen Questions (Savollar hech qachon qaytalanmasligi uchun)
    c.execute("""
    CREATE TABLE IF NOT EXISTS user_seen_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        seen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, question_id)
    )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_seen_user ON user_seen_questions(user_id)")

    # Shop Items Table
    c.execute("""
    CREATE TABLE IF NOT EXISTS shop_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title_uz TEXT NOT NULL,
        title_ru TEXT NOT NULL,
        title_en TEXT NOT NULL,
        description_uz TEXT,
        description_ru TEXT,
        description_en TEXT,
        item_type TEXT NOT NULL,
        price_uzs INTEGER DEFAULT 0,
        coin_price INTEGER DEFAULT 0,
        value INTEGER DEFAULT 1,
        icon TEXT,
        is_popular INTEGER DEFAULT 0
    )
    """)

    # Payments & Invoices Table
    c.execute("""
    CREATE TABLE IF NOT EXISTS payment_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT UNIQUE NOT NULL,
        user_id INTEGER NOT NULL,
        shop_item_id INTEGER NOT NULL,
        payment_system TEXT NOT NULL, -- 'PAYME', 'CLICK', 'GOOGLE_PLAY'
        amount_uzs INTEGER NOT NULL,
        status TEXT DEFAULT 'PENDING', -- 'PENDING', 'SUCCESS', 'CANCELLED'
        external_trans_id TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # Check categories count
    c.execute("SELECT COUNT(*) as count FROM categories")
    if c.fetchone()["count"] == 0:
        c.executemany("""
        INSERT INTO categories (name_uz, name_ru, name_en, icon, color) VALUES (?, ?, ?, ?, ?)
        """, [
            ("Tarix va Madaniyat", "История и культура", "History & Culture", "history_edu", "#E11D48"),
            ("IT va Texnologiya", "IT и технологии", "IT & Technology", "terminal", "#2563EB"),
            ("Fan va Tabiat", "Наука и природа", "Science & Nature", "science", "#059669"),
            ("Geografiya va Sayyohlik", "География и туризм", "Geography & Travel", "public", "#D97706"),
            ("Sport va Futbol", "Спорт и футбол", "Sports & Football", "sports_soccer", "#7C3AED"),
            ("Mantiq va Topqirlik", "Логика и сообразительность", "Logic & Brain Teasers", "psychology", "#0891B2")
        ])

        # Initial Questions
        questions_data = [
            # Uzbek
            (1, 'uz', "Al-Xorazmiy qaysi mashhur ilmiy akademiyada («Bayt ul-hikma») faoliyat yuritgan?", "Qohira", "Bag'dod", "Damashq", "Buxoro", "B", "Al-Xorazmiy Bag'doddagi 'Donishmandlar uyi'da rahbarlik qilgan."),
            (2, 'uz', "Python dasturlash tili kim tomonidan yaratilgan?", "Dennis Ritchie", "Guido van Rossum", "James Gosling", "Bjarne Stroustrup", "B", "Python 1991-yilda Gvido van Rossum tomonidan yaratilgan."),
            (3, 'uz', "Dunyodagi eng chuqur chuchuk suvli ko'l qaysi?", "Kaspiy", "Baykal", "Viktoriya", "Yuqori ko'l", "B", "Baykal ko'lining chuqurligi 1642 metrgacha yetadi."),
            (4, 'uz', "Parij-2024 Olimpiadasida O'zbekiston umumjamoa hisobida nechanchi o'rinni egalladi?", "13-o'rin", "10-o'rin", "15-o'rin", "8-o'rin", "A", "O'zbekiston 8 ta oltin, 2 ta kumush va 3 ta bronza bilan 13-o'rinni oldi."),
            (5, 'uz', "Amir Temur tavallud topgan Xo'ja Ilg'or qishlog'i qaysi tumanda joylashgan?", "Yakkabog'", "Shahrisabz", "Qamashi", "Kitob", "A", "Amir Temur Yakkabog' tumanidagi Xo'ja Ilg'or qishlog'ida tug'ilgan."),
            
            # Russian
            (1, 'ru', "В какой знаменитой академии наук («Дом мудрости») работал Аль-Хорезми?", "Каир", "Багдад", "Дамаск", "Бухара", "B", "Аль-Хорезми руководил «Домом мудрости» в Багдаде."),
            (2, 'ru', "Кто является создателем языка программирования Python?", "Деннис Ритчи", "Гвидо ван Россум", "Джеймс Гослинг", "Бьёрн Страуструп", "B", "Python был создан в 1991 году Гвидо ван Россумом."),
            (3, 'ru', "Какое озеро является самым глубоким пресноводным озером в мире?", "Каспийское", "Байкал", "Виктория", "Верхнее", "B", "Глубина озера Байкал достигает 1642 метров."),
            (4, 'ru', "Какое место занял Узбекистан в общем зачете на Олимпиаде-2024 в Париже?", "13-е место", "10-е место", "15-е место", "8-е место", "A", "Узбекистан занял 13-е место с 8 золотыми медалями."),
            (5, 'ru', "В каком районе находится село Ходжа Илгар, где родился Амир Темур?", "Яккабагский", "Шахрисабзский", "Камашинский", "Китабский", "A", "Амир Темур родился в Яккабагском районе."),

            # English
            (1, 'en', "In which famous academy of sciences ('House of Wisdom') did Al-Khwarizmi work?", "Cairo", "Baghdad", "Damascus", "Bukhara", "B", "Al-Khwarizmi led the 'House of Wisdom' in Baghdad."),
            (2, 'en', "Who created the Python programming language?", "Dennis Ritchie", "Guido van Rossum", "James Gosling", "Bjarne Stroustrup", "B", "Python was created in 1991 by Guido van Rossum."),
            (3, 'en', "Which is the deepest freshwater lake in the world?", "Caspian Sea", "Lake Baikal", "Lake Victoria", "Lake Superior", "B", "Lake Baikal reaches a maximum depth of 1,642 meters."),
            (4, 'en', "What place did Uzbekistan achieve in the medal standings at Paris 2024 Olympics?", "13th Place", "10th Place", "15th Place", "8th Place", "A", "Uzbekistan finished 13th overall with 8 Gold medals."),
            (5, 'en', "In which district is the village of Khoja Ilgar, birthplace of Amir Timur, located?", "Yakkabag", "Shahrisabz", "Qamashi", "Kitob", "A", "Amir Timur was born in Yakkabag district.")
        ]

        c.executemany("""
        INSERT INTO questions (category_id, lang, question_text, option_a, option_b, option_c, option_d, correct_option, explanation)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, questions_data)

    conn.commit()
    conn.close()

if __name__ == "__main__":
    init_db()
    print("Database init done.")
