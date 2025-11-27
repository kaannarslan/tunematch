import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()


# Create DB connection
def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host=os.getenv("DB_HOST", "localhost"),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASSWORD"),
            database=os.getenv("DB_NAME", "tunematch"),
            charset="utf8mb4"
        )
        return conn
    except mysql.connector.Error as err:
        print(f"Veritabanı bağlantı hatası: {err}")
        return None


# USER FUNCTIONS

def add_user(name, surname, email, password_hash, birth_date, sex, city):
    conn = get_db_connection()
    if not conn:
        return False
    cursor = conn.cursor()

    try:
        # INSERT
        query = """
                    INSERT INTO Kullanici (name, surname, email, password_hash, birth_date, sex, city) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """
        cursor.execute(query, (name, surname, email, password_hash, birth_date, sex, city))
        conn.commit()
        return True
    except mysql.connector.Error as err:
        print(f"Kayıt hatası: {err}")
        return False
    finally:
        cursor.close()
        conn.close()


def get_user_by_email(email):
    conn = get_db_connection()
    if not conn:
        return None
    cursor = conn.cursor(dictionary= True)
    query = "SELECT * FROM Kullanici WHERE email = %s"
    cursor.execute(query, (email,))
    user = cursor.fetchone()

    cursor.close()
    conn.close()
    return user


def update_user_profile(user_id, city, biography, profile_photo):
    conn = get_db_connection()
    if not conn: return False
    cursor = conn.cursor()

    try:
        query = """
                UPDATE Kullanici 
                SET city = %s, biography = %s, profile_photo = %s
                WHERE user_id = %s
            """
        cursor.execute(query, (city, biography, profile_photo, user_id))
        conn.commit()
        return True
    except mysql.connector.Error as err:
        print(f"Güncelleme hatası: {err}")
        return False
    finally:
        cursor.close()
        conn.close()

# SEARCH

def search_artist(keyword):
    conn = get_db_connection()
    if not conn:
        return []
    cursor = conn.cursor(dictionary=True)

    search_term = f"%{keyword}%"
    query = "SELECT * FROM Artist WHERE name LIKE %s ORDER BY popularity_score DESC LIMIT 10"

    cursor.execute(query, (search_term,))
    results = cursor.fetchall()

    cursor.close()
    conn.close()
    return results


def add_favorite_artist(user_id, artist_id, level = 10):
    conn = get_db_connection()
    if not conn:
        return False
    cursor = conn.cursor()

    try:
        query = """
                INSERT INTO User_Favorite_Artist (user_id, artist_id, level) 
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE level = %s
            """
        cursor.execute(query, (user_id, artist_id, level, level))
        conn.commit()
        return True
    except mysql.connector.Error as err:
        print(f"Favori ekleme hatası: {err}")
        return False
    finally:
        cursor.close()
        conn.close()


def get_matches_for_user(current_user_id):
    conn = get_db_connection()
    if not conn:
        return []
    cursor = conn.cursor(dictionary=True)

    query = """
            SELECT 
                other_user.user_id,
                other_user.name,
                other_user.surname,
                other_user.city,
                other_user.biography,
                (
                    (COUNT(DISTINCT common_artists.artist_id) * 10) + 
                    (COUNT(DISTINCT common_genres.genre_id) * 3)
                ) AS compatibility_score
            FROM Kullanici AS other_user

            -- JOIN 1: Ortak Sanatçılar
            LEFT JOIN (
                SELECT t2.user_id, t2.artist_id
                FROM User_Favorite_Artist t1
                JOIN User_Favorite_Artist t2 ON t1.artist_id = t2.artist_id
                WHERE t1.user_id = %s
            ) AS common_artists ON other_user.user_id = common_artists.user_id

            -- JOIN 2: Ortak Türler
            LEFT JOIN (
                SELECT t2.user_id, t2.genre_id
                FROM User_Liked_Genre t1
                JOIN User_Liked_Genre t2 ON t1.genre_id = t2.genre_id
                WHERE t1.user_id = %s
            ) AS common_genres ON other_user.user_id = common_genres.user_id

            WHERE other_user.user_id != %s
            GROUP BY other_user.user_id, other_user.name, other_user.surname, other_user.city, other_user.biography
            HAVING compatibility_score > 0
            ORDER BY compatibility_score DESC
            LIMIT 20;
        """
    cursor.execute(query, (current_user_id, current_user_id, current_user_id))
    matches = cursor.fetchall()

    cursor.close()
    conn.close()
    return matches

# HISTORY

def log_song_listen(user_id, song_id):
    conn = get_db_connection()
    if not conn: return False
    cursor = conn.cursor()

    try:
        query = """
                INSERT INTO Listening_History (user_id, song_id, play_count, last_played)
                VALUES (%s, %s, 1, NOW())
                ON DUPLICATE KEY UPDATE 
                    play_count = play_count + 1,
                    last_played = NOW()
            """
        cursor.execute(query, (user_id, song_id))
        conn.commit()
        return True
    except mysql.connector.Error as err:
        print(f"Dinleme geçmişi hatası: {err}")
        return False
    finally:
        cursor.close()
        conn.close()