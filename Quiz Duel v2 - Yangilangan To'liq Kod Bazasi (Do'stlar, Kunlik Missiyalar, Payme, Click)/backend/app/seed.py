from datetime import datetime, timedelta
from .database import SessionLocal, engine, Base
from .models import User, Category, Question, ShopItem

def seed_data():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    if db.query(Category).count() > 0:
        print("Baza allaqachon to'ldirilgan.")
        db.close()
        return

    # 1. Toifalar
    cat_tarix = Category(name="Tarix va Madaniyat", icon="history_edu", color="#E11D48")
    cat_it = Category(name="IT va Texnologiya", icon="terminal", color="#2563EB")
    cat_fan = Category(name="Fan va Tabiat", icon="science", color="#059669")
    cat_geografiya = Category(name="Geografiya va Sayyohlik", icon="public", color="#D97706")
    cat_sport = Category(name="Sport va Futbol", icon="sports_soccer", color="#7C3AED")
    cat_mantiq = Category(name="Mantiq va Topqirlik", icon="psychology", color="#0891B2")

    db.add_all([cat_tarix, cat_it, cat_fan, cat_geografiya, cat_sport, cat_mantiq])
    db.commit()

    # 2. Savollar
    questions = [
        # Tarix
        Question(
            category_id=cat_tarix.id,
            question_text="Amir Temur tavallud topgan Xo'ja Ilg'or qishlog'i hozirgi qaysi tumanda joylashgan?",
            option_a="Yakkabog'",
            option_b="Shahrisabz",
            option_c="Qamashi",
            option_d="Kitob",
            correct_option="A",
            explanation="Amir Temur 1336-yil 9-aprelda Kesh (Shahrisabz) yaqinidagi Xo'ja Ilg'or (hozirgi Yakkabog' tumani) qishlog'ida tug'ilgan."
        ),
        Question(
            category_id=cat_tarix.id,
            question_text="Al-Xorazmiy qaysi mashhur ilmiy akademiyada («Bayt ul-hikma») faoliyat yuritgan?",
            option_a="Qohira",
            option_b="Bag'dod",
            option_c="Damashq",
            option_d="Buxoro",
            correct_option="B",
            explanation="Al-Xorazmiy Bag'doddagi 'Donishmandlar uyi' (Bayt ul-hikma) akademiyasida rahbarlik qilgan."
        ),
        Question(
            category_id=cat_tarix.id,
            question_text="Mirzo Ulug'bek tomonidan barpo etilgan rasadxona qaysi shaharda joylashgan?",
            option_a="Buxoro",
            option_b="Xiva",
            option_c="Samarqand",
            option_d="Termiz",
            correct_option="C",
            explanation="Ulug'bek rasadxonasi 1424-1428 yillarda Samarqandda qurilgan."
        ),
        # IT
        Question(
            category_id=cat_it.id,
            question_text="Python dasturlash tili kim tomonidan yaratilgan?",
            option_a="Dennis Ritchie",
            option_b="Guido van Rossum",
            option_c="James Gosling",
            option_d="Bjarne Stroustrup",
            correct_option="B",
            explanation="Python 1991-yilda niderlandiyalik dasturchi Gvido van Rossum tomonidan yaratilgan."
        ),
        Question(
            category_id=cat_it.id,
            question_text="Sun'iy intellektda 'LLM' qisqartmasi nimani anglatadi?",
            option_a="Large Language Model",
            option_b="Logic Learning Machine",
            option_c="Linear Layer Method",
            option_d="Local Linguistic Matrix",
            correct_option="A",
            explanation="LLM — Katta til modeli (Large Language Model) hisoblanadi."
        ),
        Question(
            category_id=cat_it.id,
            question_text="O'zbekistonda startaplar uchun eng yirik IT hab qaysi?",
            option_a="IT Park Uzbekistan",
            option_b="InnoWeek",
            option_c="Digital Camp",
            option_d="Tashkent Tech",
            correct_option="A",
            explanation="IT Park — O'zbekistondagi axborot texnologiyalari va startaplarni rivojlantiruvchi asosiy ekotizimdir."
        ),
        # Geografiya
        Question(
            category_id=cat_geografiya.id,
            question_text="Dunyodagi eng chuqur chuchuk suvli ko'l qaysi?",
            option_a="Kaspiy",
            option_b="Baykal",
            option_c="Viktoriya",
            option_d="Yuqori ko'l",
            correct_option="B",
            explanation="Baykal ko'lining chuqurligi 1642 metrgacha yetadi."
        ),
        Question(
            category_id=cat_geografiya.id,
            question_text="O'zbekiston bilan chegaradosh nechta davlat bor?",
            option_a="4 ta",
            option_b="5 ta",
            option_c="6 ta",
            option_d="3 ta",
            correct_option="B",
            explanation="Qozog'iston, Qirg'iziston, Tojikiston, Turkmaniston va Afg'oniston."
        ),
        # Sport
        Question(
            category_id=cat_sport.id,
            question_text="Futbol bo'yicha 2022-yilgi Jahon chempionatida qaysi terma jamoa g'olib bo'ldi?",
            option_a="Fransiya",
            option_b="Braziliya",
            option_c="Argentina",
            option_d="Xorvatiya",
            correct_option="C",
            explanation="Argentina finalda Fransiyani penaltilar seriyasida mag'lub etib chempion bo'lgan."
        ),
        Question(
            category_id=cat_sport.id,
            question_text="Parij-2024 Olimpiadasida O'zbekiston delegatsiyasi umumjamoa hisobida nechanchi o'rinni egalladi?",
            option_a="13-o'rin",
            option_b="10-o'rin",
            option_c="15-o'rin",
            option_d="8-o'rin",
            correct_option="A",
            explanation="O'zbekiston 8 ta oltin, 2 ta kumush va 3 ta bronza medali bilan 13-o'rinni egalladi."
        ),
        # Mantiq
        Question(
            category_id=cat_mantiq.id,
            question_text="U qanchalik ko'p bo'lsa, siz shunchalik kam ko'rasiz. Bu nima?",
            option_a="Tuman / Zulmat",
            option_b="Qor",
            option_c="Yorug'lik",
            option_d="Ko'zoynak",
            correct_option="A",
            explanation="Zulmat yoki quyuq tuman qanchalik ko'paysa, ko'rish masofasi shunchalik kamayadi."
        ),
        Question(
            category_id=cat_mantiq.id,
            question_text="Bir poyezd soatiga 100 km tezlikda sharqqa harakatlanmoqda. Shamol esa g'arbdan esmoqda. Elektropoyezdning tutuni qaysi tomonga ketadi?",
            option_a="G'arbga",
            option_b="Sharqqa",
            option_c="Janubga",
            option_d="Elektropoyezdda tutun bo'lmaydi",
            correct_option="D",
            explanation="Chunki u elektropoyezd, unda tutun chiqmaydi."
        )
    ]
    db.add_all(questions)

    # 3. Do'kon mahsulotlari (Shop items)
    shop_items = [
        ShopItem(title="500 Tanga paketi", description="Kichik tangalar to'plami", item_type="COINS", price_uzs=5000, value=500, icon="monetization_on", is_popular=False),
        ShopItem(title="2,500 Tanga paketi", description="Eng ommabop tangalar to'plami (+20% bonus)", item_type="COINS", price_uzs=20000, value=2500, icon="paid", is_popular=True),
        ShopItem(title="10,000 Tanga paketi", description="Katta tangalar jamg'armasi", item_type="COINS", price_uzs=70000, value=10000, icon="savings", is_popular=False),
        
        ShopItem(title="To'liq Energiya (10 Jon)", description="Zudlik bilan energiyani to'ldirish", item_type="ENERGY", price_uzs=3000, coin_price=100, value=10, icon="bolt", is_popular=False),
        ShopItem(title="24 Soat Cheksiz Energiya", description="1 kun davomida cheklovsiz duellar", item_type="ENERGY", price_uzs=10000, coin_price=400, value=24, icon="all_inclusive", is_popular=True),
        
        ShopItem(title="50/50 Booster (5 dona)", description="2 ta xato variantni o'chirish", item_type="BOOSTER_5050", price_uzs=4000, coin_price=150, value=5, icon="flaky", is_popular=False),
        ShopItem(title="+5 Soniya Booster (5 dona)", description="Qo'shimcha o'ylash vaqti", item_type="BOOSTER_TIME", price_uzs=4000, coin_price=150, value=5, icon="more_time", is_popular=False),
        
        ShopItem(title="VIP Pass (1 oylik obuna)", description="Reklamasiz, 2x tanga, cheksiz energiya va Oltin ramka", item_type="VIP_PASS", price_uzs=39000, value=30, icon="workspace_premium", is_popular=True)
    ]
    db.add_all(shop_items)

    # 4. Sinov foydalanuvchilari (Leaderboard test uchun)
    demo_users = [
        User(username="jasur_quiz", fullname="Jasur Alimov", coins=3200, rating_score=1850, total_wins=42, total_matches=50, level=8, is_vip=True),
        User(username="malika_smart", fullname="Malika Karimova", coins=2100, rating_score=1720, total_wins=35, total_matches=45, level=7, is_vip=False),
        User(username="aziz_pro", fullname="Azizbek Islomov", coins=1500, rating_score=1640, total_wins=28, total_matches=36, level=6, is_vip=True),
        User(username="nodir_dev", fullname="Nodirbek Yoqubov", coins=800, rating_score=1450, total_wins=19, total_matches=30, level=4, is_vip=False),
        User(username="umid_genius", fullname="Umidjon Xoliqov", coins=650, rating_score=1310, total_wins=15, total_matches=25, level=3, is_vip=False),
    ]
    db.add_all(demo_users)

    db.commit()
    db.close()
    print("Ma'lumotlar bazasi muvaffaqiyatli to'ldirildi!")

if __name__ == "__main__":
    seed_data()
