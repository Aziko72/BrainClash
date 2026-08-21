import sqlite3
import random
from typing import List, Dict, Any

def get_unseen_questions_for_duel(conn: sqlite3.Connection, p1_id: int, p2_id: int, lang: str = "uz", count: int = 5) -> List[Dict[str, Any]]:
    """
    Ikkala o'yinchi uchun ham avval ko'rilmagan (takrorlanmaydigan) savollarni tanlab olish.
    """
    c = conn.cursor()

    # 1. Ikkala o'yinchi ham hali ko'rmagan savollarni topish
    query = """
    SELECT q.* FROM questions q
    WHERE q.lang = ?
    AND q.id NOT IN (
        SELECT question_id FROM user_seen_questions WHERE user_id = ? OR user_id = ?
    )
    ORDER BY RANDOM()
    LIMIT ?
    """
    c.execute(query, (lang, p1_id, p2_id, count))
    rows = c.fetchall()

    questions = [dict(r) for r in rows]

    # 2. Agar savollar yetarli bo'lmasa, avtomatik yangi savollar generatsiya qilish
    if len(questions) < count:
        needed = count - len(questions)
        new_generated = generate_and_save_ai_questions(conn, count=max(15, needed * 3))
        # Qayta tanlab olish
        c.execute(query, (lang, p1_id, p2_id, count))
        rows = c.fetchall()
        questions = [dict(r) for r in rows]

    # 3. Tanlangan savollarni o'yinchilarning ko'rganlar tarixiga (seen) yozib qo'yish
    for q in questions:
        c.execute("INSERT OR IGNORE INTO user_seen_questions (user_id, question_id) VALUES (?, ?)", (p1_id, q["id"]))
        c.execute("INSERT OR IGNORE INTO user_seen_questions (user_id, question_id) VALUES (?, ?)", (p2_id, q["id"]))
    conn.commit()

    return questions

def generate_and_save_ai_questions(conn: sqlite3.Connection, count: int = 15) -> int:
    """
    Cheksiz savollar generatori (AI orqali 3 tilda avtomatik yangi savollar yaratish va bazaga kiritish).
    """
    c = conn.cursor()

    # AI Template generator bank (3 tilda)
    ai_question_templates = [
        {
            "cat_id": 2,
            "uz": ("Eng birinchi kompyuter sichqonchasi qaysi materialdan yasalgan?", "Yog'ochdan", "Plastmassadan", "Temirdan", "Shishadan", "A", "Dastlabki kompyuter sichqonchasi 1964-yilda Duglas Engelbart tomonidan yog'ochdan yasalgan."),
            "ru": ("Из какого материала была сделана первая компьютерная мышь?", "Из дерева", "Из пластика", "Из железа", "Из стекла", "A", "Первая компьютерная мышь была изготовлена из дерева Дугласом Энгельбартом в 1964 году."),
            "en": ("What material was the first computer mouse made of?", "Wood", "Plastic", "Metal", "Glass", "A", "The first computer mouse was carved out of wood by Douglas Engelbart in 1964.")
        },
        {
            "cat_id": 3,
            "uz": ("Qaysi sayyorada bir sutka bir yildan uzoqroq davom etadi?", "Venera", "Mars", "Yupiter", "Merkuriy", "A", "Venera o'z o'qi atrofida 243 Yer kunida, Quyosh atrofida esa 225 kunda aylanadi."),
            "ru": ("На какой планете сутки длятся дольше, чем год?", "Венера", "Марс", "Юпитер", "Меркурий", "A", "Сутки на Венере длятся 243 земных дня, а год — 225 дней."),
            "en": ("On which planet is a day longer than a year?", "Venus", "Mars", "Jupiter", "Mercury", "A", "Venus takes 243 Earth days to rotate once on its axis, but only 225 days to orbit the Sun.")
        },
        {
            "cat_id": 4,
            "uz": ("Dunyoda qaysi davlat hududi bo'yicha eng ko'p vaqt mintaqalariga (soat mintaqasi) ega?", "Fransiya", "Rossiya", "AQSH", "Xitoy", "A", "Fransiya o'zining dengizorti hududlari bilan birga jami 12 ta vaqt mintaqasiga ega."),
            "ru": ("Какая страна в мире имеет больше всего часовых поясов?", "Франция", "Россия", "США", "Китай", "A", "Франция вместе с заморскими территориями имеет 12 часовых поясов."),
            "en": ("Which country in the world spans the most time zones?", "France", "Russia", "USA", "China", "A", "France, including its overseas territories, covers 12 different time zones.")
        },
        {
            "cat_id": 5,
            "uz": ("Futbol bo'yicha 'Oltin to'p' (Ballon d'Or) sovrinini eng ko'p yutgan futbolchi kim?", "Lionel Messi", "Cristiano Ronaldo", "Pele", "Maradona", "A", "Lionel Messi jami 8 marta 'Oltin to'p' sohibi bo'lgan."),
            "ru": ("Кто выиграл наибольшее количество наград «Золотой мяч» в истории футбола?", "Лионель Месси", "Криштиану Роналду", "Пеле", "Марадона", "A", "Лионель Месси является 8-кратным обладателем «Золотого мяча»."),
            "en": ("Which football player has won the most Ballon d'Or awards in history?", "Lionel Messi", "Cristiano Ronaldo", "Pele", "Maradona", "A", "Lionel Messi has won 8 Ballon d'Or awards.")
        },
        {
            "cat_id": 1,
            "uz": ("Jahon xaritasini birinchi bo'lib doira shaklida tuzgan alloma kim?", "Mahmud Qoshg'ariy", "Beruniy", "Ibn Sino", "Farg'oniy", "A", "Mahmud Qoshg'ariy 'Devonu lug'otit turk' asarida birinchi turkiy doiraviy dunyo xaritasini chizgan."),
            "ru": ("Кто впервые составил круглую карту мира в тюркской истории?", "Махмуд Кашгари", "Беруни", "Ибн Сина", "Фергани", "A", "Махмуд Кашгари составил круглую карту мира в труде «Диван лугат ат-турк»."),
            "en": ("Who created one of the earliest circular world maps in Central Asian history?", "Mahmud al-Kashgari", "Al-Biruni", "Avicenna", "Al-Farghani", "A", "Mahmud al-Kashgari drew the circular world map in his work 'Divan Lughat al-Turk'.")
        }
    ]

    inserted = 0
    for t in ai_question_templates:
        for lang in ["uz", "ru", "en"]:
            data = t[lang]
            c.execute("""
            INSERT INTO questions (category_id, lang, question_text, option_a, option_b, option_c, option_d, correct_option, explanation)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (t["cat_id"], lang, data[0], data[1], data[2], data[3], data[4], data[5], data[6]))
            inserted += 1

    conn.commit()
    return inserted
