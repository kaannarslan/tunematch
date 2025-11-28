import mysql.connector
import os
from dotenv import load_dotenv

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


# --- BU YARDIMCI FONKSİYONLARI DOSYANIN EN ALTINA EKLE ---

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

# --- MEVCUT get_matches_for_user FONKSİYONUNU GÜNCELLE ---

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
                other_user.city, other_user.birth_date, other_user.sex, other_user.biography
            
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