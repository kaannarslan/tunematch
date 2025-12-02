import mysql.connector
import os
from dotenv import load_dotenv
from datetime import date

load_dotenv()


# Create DB connection
def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host=os.getenv("DB_HOST", "localhost"),
            user=os.getenv("DB_USER", "root"), # .env dosyanızda DB_USER olduğundan emin olun
            password=os.getenv("DB_PASSWORD", ""),
            database=os.getenv("DB_NAME", "tunematch"),
            charset="utf8mb4"
        )
        return conn
    except mysql.connector.Error as err:
        print(f"Veritabanı bağlantı hatası: {err}")
        return None


# USER FUNCTIONS

# db_manager.py

# db_manager.py içindeki add_user fonksiyonunu bununla değiştir:

def add_user(name, surname, email, password_hash, birth_date, sex, city):
    conn = get_db_connection()
    if not conn: return None, "Veritabanına bağlanılamadı" # Değişiklik 1
    cursor = conn.cursor()

    try:
        query = """
            INSERT INTO Kullanici (name, surname, email, password_hash, birth_date, sex, city) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (name, surname, email, password_hash, birth_date, sex, city))
        conn.commit()

        new_user_id = cursor.lastrowid
        return new_user_id, None # Başarılı: (ID, HataYok)

    except mysql.connector.Error as err:
        print(f"\n---> SQL HATASI: {err}\n") # Terminale yaz
        return None, str(err) # Başarısız: (None, HataMesajı)
    finally:
        cursor.close()
        conn.close()

# ==========================================
# YENİ EKLENEN YARDIMCI FONKSİYONLAR (DÜZELTİLDİ)
# ==========================================

def get_id_by_name(table_name, name_value):
    """İsmi verilen (Rock, Tarkan vb.) kaydın ID'sini bulur."""
    conn = get_db_connection()
    if not conn: return None
    cursor = conn.cursor() # Varsayılan Tuple cursor

    try:
        # SQL Injection riskine karşı tablo adını format ile, değeri parametre ile veriyoruz
        query = f"SELECT * FROM {table_name} WHERE name = %s"
        cursor.execute(query, (name_value,))
        result = cursor.fetchone()

        # Result örneği: (1, 'Rock') -> Tuple
        if result:
            return result[0] # İlk sütun her zaman ID varsayıyoruz
        return None
    except Exception as e:
        print(f"ID Bulma Hatası ({table_name}): {e}")
        return None
    finally:
        cursor.close()
        conn.close()

def add_user_genres(user_id, genre_names):
    """Kullanıcının seçtiği türleri kaydeder."""
    conn = get_db_connection()
    if not conn: return
    cursor = conn.cursor()

    try:
        for genre_name in genre_names:
            # Genre tablosundan ID bul
            genre_id = get_id_by_name("Genre", genre_name)

            if genre_id:
                #IGNORE: Zaten ekliyse hata verme, geç
                query = "INSERT IGNORE INTO User_Liked_Genre (user_id, genre_id) VALUES (%s, %s)"
                cursor.execute(query, (user_id, genre_id))

        conn.commit()
        print(f"User {user_id} için türler eklendi.")
    except Exception as e:
        print(f"Genre ekleme hatası: {e}")
    finally:
        cursor.close()
        conn.close()

def add_user_artists(user_id, artist_names):
    """Kullanıcının seçtiği sanatçıları kaydeder."""
    conn = get_db_connection()
    if not conn: return
    cursor = conn.cursor()

    try:
        for artist_name in artist_names:
            # Artist tablosundan ID bul
            artist_id = get_id_by_name("Artist", artist_name)

            if artist_id:
                query = "INSERT INTO User_Favorite_Artist (user_id, artist_id, level) VALUES (%s, %s, 10) ON DUPLICATE KEY UPDATE level=10"
                cursor.execute(query, (user_id, artist_id))

        conn.commit()
        print(f"User {user_id} için sanatçılar eklendi.")
    except Exception as e:
        print(f"Artist ekleme hatası: {e}")
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

def search_songs(keyword):
    conn = get_db_connection()
    if not conn: return []
    cursor = conn.cursor(dictionary=True)

    try:
        search_term = f"%{keyword}%"
        query = """
                SELECT s.song_id, s.title, a.name as artist_name, al.cover_url
                FROM Song s
                JOIN Artist a ON s.artist_id = a.artist_id
                LEFT JOIN Album al ON s.album_id = al.album_id
                WHERE s.title LIKE %s
                ORDER BY s.title ASC
                LIMIT 20
            """
        cursor.execute(query, (search_term,))
        return cursor.fetchall()
    except Exception as e:
        print(f"Song Search Error: {e}")
        return []
    finally:
        cursor.close()
        conn.close()


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



def get_user_genres(user_id):
    conn = get_db_connection()
    if not conn: return []
    cursor = conn.cursor()
    # Genre tablosundan isimleri çekiyoruz
    query = """
        SELECT g.name 
        FROM User_Liked_Genre ulg
        JOIN Genre g ON ulg.genre_id = g.genre_id
        WHERE ulg.user_id = %s
    """
    cursor.execute(query, (user_id,))
    results = cursor.fetchall() # Örn: [('Rock',), ('Pop',)]
    cursor.close()
    conn.close()
    return [r[0] for r in results] # Listeyi temizle: ['Rock', 'Pop']

def get_user_artists(user_id):
    conn = get_db_connection()
    if not conn: return []
    cursor = conn.cursor()
    # Artist tablosundan isimleri çekiyoruz
    query = """
        SELECT a.name 
        FROM User_Favorite_Artist ufa
        JOIN Artist a ON ufa.artist_id = a.artist_id
        WHERE ufa.user_id = %s
    """
    cursor.execute(query, (user_id,))
    results = cursor.fetchall()
    cursor.close()
    conn.close()
    return [r[0] for r in results]


def get_matches_for_user(current_user_id):
    conn = get_db_connection()
    if not conn: return []
    cursor = conn.cursor(dictionary=True)

    try:
        # 1. SQL SORGUSU
        query = """
            SELECT 
                other_user.user_id,
                other_user.name,
                other_user.surname,
                other_user.city,
                other_user.birth_date,
                other_user.sex,
                other_user.biography,
                
                -- SKOR HESAPLAMA
                (
                    (COALESCE(COUNT(DISTINCT common_artists.artist_id), 0) * 10) + 
                    (COALESCE(COUNT(DISTINCT common_genres.genre_id), 0) * 3)
                ) as compatibility_score

            FROM Kullanici as other_user

            -- ORTAK SANATÇILAR
            LEFT JOIN (
                SELECT t2.user_id, t2.artist_id
                FROM User_Favorite_Artist t1
                JOIN User_Favorite_Artist t2 ON t1.artist_id = t2.artist_id
                WHERE t1.user_id = %s
            ) as common_artists ON other_user.user_id = common_artists.user_id

            -- ORTAK TÜRLER
            LEFT JOIN (
                SELECT t2.user_id, t2.genre_id
                FROM User_Liked_Genre t1
                JOIN User_Liked_Genre t2 ON t1.genre_id = t2.genre_id
                WHERE t1.user_id = %s
            ) as common_genres ON other_user.user_id = common_genres.user_id

            WHERE other_user.user_id != %s

            GROUP BY 
                other_user.user_id, other_user.name, other_user.surname, 
                other_user.city, other_user.birth_date, other_user.sex, other_user.biography, other_user.profile_photo
            
            -- FİLTRE GERİ GELDİ: Sadece puanı 0'dan büyük olanları getir
            HAVING compatibility_score > 0
            
            ORDER BY compatibility_score DESC
            LIMIT 20;
        """

        cursor.execute(query, (current_user_id, current_user_id, current_user_id))
        matches = cursor.fetchall()

        # 2. PYTHON TARAFI: DETAYLARI DOLDURMA
        for user in matches:
            # Tarih formatı düzeltme
            if user['birth_date']: user['birth_date'] = str(user['birth_date'])

            # Profil fotosu boşsa hata vermesin
            if 'profile_photo' not in user or not user['profile_photo']:
                 user['profile_photo'] = ""

            # Janra ve Sanatçıları listeye ekle (Kartlarda görünmesi için)
            user['genres'] = get_user_genres(user['user_id'])
            user['artists'] = get_user_artists(user['user_id'])

        return matches

    except mysql.connector.Error as err:
        print(f"Eşleşme Hatası: {err}")
        return []
    finally:
        cursor.close()
        conn.close()
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

def add_follow(follower_id, following_id):
    """Kullanıcının birini beğendiğini kaydeder."""
    conn = get_db_connection()
    if not conn: return False
    cursor = conn.cursor()

    try:
        # GÜNCELLEME: Sütun isimleri senin tablonla eşleşti (following_id)
        # INSERT IGNORE: Çift kayıt hatasını önler.
        # NOW(): O anki tarihi ve saati 'followed_at' sütununa basar.
        query = """
            INSERT IGNORE INTO Follow (follower_id, following_id, followed_at) 
            VALUES (%s, %s, NOW())
        """
        cursor.execute(query, (follower_id, following_id))
        conn.commit()
        return True
    except mysql.connector.Error as err:
        print(f"Follow Ekleme Hatası: {err}")
        return False
    finally:
        cursor.close()
        conn.close()

def get_followed_users(user_id):
    """Kullanıcının takip ettiği (beğendiği) kişilerin listesini getirir."""
    conn = get_db_connection()
    if not conn: return []
    cursor = conn.cursor(dictionary=True)

    try:
        # Follow tablosundaki following_id'yi Kullanici tablosundaki user_id ile eşleştiriyoruz
        query = """
            SELECT 
                k.user_id, k.name, k.surname, k.city, k.birth_date, k.sex, k.biography
            FROM Follow f
            JOIN Kullanici k ON f.following_id = k.user_id
            WHERE f.follower_id = %s
            ORDER BY f.followed_at DESC
        """
        cursor.execute(query, (user_id,))
        users = cursor.fetchall()

        # Tarih formatı ve boş alan düzeltmeleri (App çökmesin diye)
        for user in users:
            if user['birth_date']: user['birth_date'] = str(user['birth_date'])
            # Bu listede detaylı janra/artist göstermeye gerek yok ama
            # UserProfile modelimiz hata vermesin diye boş liste ekliyoruz
            user['genres'] = []
            user['artists'] = []
            user['compatibility_score'] = 0 # Bu ekranda skora gerek yok

        return users
    except mysql.connector.Error as err:
        print(f"Takip Listesi Hatası: {err}")
        return []
    finally:
        cursor.close()
        conn.close()

# SAVE FROM HARDCODING

def get_all_genres():
    conn = get_db_connection()
    if not conn: return []
    cursor = conn.cursor()
    try:
        cursor.execute("""
                        SELECT name
                        FROM Genre
                        ORDER BY name ASC
                        """)
        return [row[0] for row in cursor.fetchall()]
    except Exception as e:
        print(f"Genre List Error: {e}")
        return []
    finally:
        cursor.close()
        conn.close()

def get_top_artists(limit = 20):
    conn = get_db_connection()
    if not conn: return []
    cursor = conn.cursor()
    try:
        query = """
                        SELECT name
                        FROM Artist
                        ORDER BY popularity_score DESC
                        LIMIT %s
                        """
        cursor.execute(query, (limit,))
        return [row[0] for row in cursor.fetchall()]
    except Exception as e:
        print(f"Artists List Error: {e}")
        return []
    finally:
        cursor.close()
        conn.close()

# STATISTICS FOR PROFILE SCREEN
def get_user_statistics(user_id):
    conn = get_db_connection()
    if not conn: return None
    cursor = conn.cursor(dictionary=True)

    stats = {
        "total_songs": 0,
        "most_listened_artist": "Henüz Yok",
        "most_listened_genre": "Henüz Yok",
        "registered_fav_genres": [],  #Came from register screen
        "registered_fav_artists": [],  #Came from register screen
        "active_days": 1,
        "city": "Bilinmiyor",
        "sex": "-",
        "age": 18,
        "name": "",
        "surname": ""
    }

    try:
        cursor.execute("SELECT name, surname, city, sex, birth_date FROM Kullanici WHERE user_id = %s", (user_id,))
        user_info = cursor.fetchone()

        if user_info:
            stats["name"] = user_info['name']
            stats["surname"] = user_info['surname']
            stats["city"] = user_info['city']

            sex_map = {'M': 'Erkek', 'F': 'Kadın', 'Other': 'Diğer'}
            stats["sex"] = sex_map.get(user_info['sex'], user_info['sex'])

            if user_info['birth_date']:
                today = date.today()
                born = user_info['birth_date']
                stats["age"] = today.year - born.year - ((today.month, today.day) < (born.month, born.day))
        # 1. DİNLEME GEÇMİŞİ ANALİZİ (Listening history)
        cursor.execute("SELECT SUM(play_count) as total FROM Listening_History WHERE user_id = %s", (user_id,))
        res = cursor.fetchone()
        if res and res['total']:
            stats["total_songs"] = int(res['total'])

        # Most listened artists
        cursor.execute("""
            SELECT a.name 
            FROM Listening_History lh
            JOIN Song s ON lh.song_id = s.song_id
            JOIN Artist a ON s.artist_id = a.artist_id
            WHERE lh.user_id = %s
            GROUP BY a.artist_id, a.name
            ORDER BY SUM(lh.play_count) DESC
            LIMIT 1
        """, (user_id,))
        res = cursor.fetchone()
        if res: stats["most_listened_artist"] = res['name']

        # most listened genres
        cursor.execute("""
            SELECT g.name 
            FROM Listening_History lh
            JOIN Song s ON lh.song_id = s.song_id
            JOIN Artist_Genre ag ON s.artist_id = ag.artist_id
            JOIN Genre g ON ag.genre_id = g.genre_id
            WHERE lh.user_id = %s
            GROUP BY g.genre_id, g.name
            ORDER BY COUNT(*) DESC
            LIMIT 1
        """, (user_id,))
        res = cursor.fetchone()
        if res: stats["most_listened_genre"] = res['name']

        stats["registered_fav_genres"] = get_user_genres(user_id)
        stats["registered_fav_artists"] = get_user_artists(user_id)

        return stats

    except Exception as e:
        print(f"Stats Error: {e}")
        return stats
    finally:
        cursor.close()
        conn.close()