from flask import Flask, request, jsonify
import db_manager as db

app = Flask(__name__)


# ==========================================
# 1. KULLANICI İŞLEMLERİ (AUTH & PROFILE)
# ==========================================

@app.route('/api/register', methods=['POST'])
def register():
    data = request.json

    new_user_id, error_message = db.add_user(
        name=data.get('name'),
        surname=data.get('surname'),
        email=data.get('email'),
        password_hash=data.get('password'),
        birth_date=data.get('birth_date'),  # 'YYYY-MM-DD'
        sex=data.get('F'),
        city=data.get('city'),
    )

    if new_user_id:
        # Başarılı ise favorileri ekle
        genres = data.get('genres', [])
        artists = data.get('artists', [])

        if genres: db.add_user_genres(new_user_id, genres)
        if artists: db.add_user_artists(new_user_id, artists)

        return jsonify({"status": "success", "message": "Kayıt başarılı"}), 201
    else:
        # HATA VARSA: Gerçek hatayı Flutter'a gönder
        return jsonify({"status": "error", "message": f"Hata Detayı: {error_message}"}), 400


@app.route('/api/login', methods=['POST'])
def login():
    """Giriş yapma."""
    data = request.json
    email = data.get('email')
    password = data.get('password')

    user = db.get_user_by_email(email)

    if user and user['password_hash'] == password:
        return jsonify({
            "status": "success",
            "user_id": user['user_id'],
            "name": user['name'],
            "surname": user['surname'],
            "photo": user['profile_photo'],
            "city": user['city'],
            "biography": user['biography']
        }), 200
    else:
        return jsonify({"status": "error", "message": "Hatalı email veya şifre"}), 401


@app.route('/api/user/update', methods=['POST'])
def update_profile():
    """Profil güncelleme."""
    data = request.json
    user_id = data.get('user_id')

    if not user_id:
        return jsonify({"status": "error", "message": "User ID gerekli"}), 400

    success = db.update_user_profile(
        user_id=user_id,
        city=data.get('city'),
        biography=data.get('biography'),
        profile_photo=data.get('profile_photo')
    )

    if success:
        return jsonify({"status": "success", "message": "Profil güncellendi"}), 200
    else:
        return jsonify({"status": "error", "message": "Güncelleme hatası"}), 500


# ==========================================
# 2. İÇERİK VE ETKİLEŞİM (SEARCH & ACTIONS)
# ==========================================

@app.route('/api/search/artist', methods=['GET'])
def search_artist():
    """Sanatçı arama: /api/search/artist?q=Megadeth"""
    keyword = request.args.get('q')
    if not keyword:
        return jsonify({"status": "error", "data": []}), 400

    results = db.search_artist(keyword)
    return jsonify({"status": "success", "data": results}), 200


@app.route('/api/favorite/artist', methods=['POST'])
def add_favorite():
    """Sanatçıyı favorilere ekleme."""
    data = request.json
    user_id = data.get('user_id')
    artist_id = data.get('artist_id')
    level = data.get('level', 10)  # Varsayılan puan 10

    if db.add_favorite_artist(user_id, artist_id, level):
        return jsonify({"status": "success", "message": "Favorilere eklendi"}), 200
    else:
        return jsonify({"status": "error", "message": "İşlem başarısız"}), 500


@app.route('/api/listen', methods=['POST'])
def listen_song():
    """Şarkı dinleme simülasyonu (Play tuşuna basınca)."""
    data = request.json
    user_id = data.get('user_id')
    song_id = data.get('song_id')

    # db_manager'a son eklediğimiz fonksiyonu çağırıyoruz
    # (Eğer db_manager'a eklemediysen bu satır hata verir, eklediğinden emin ol)
    if hasattr(db, 'log_song_listen') and db.log_song_listen(user_id, song_id):
        return jsonify({"status": "success", "message": "Dinleme kaydedildi"}), 200
    else:
        # Fonksiyon yoksa veya hata verdiyse
        return jsonify({"status": "error", "message": "Kaydedilemedi"}), 500


# ==========================================
# 3. EŞLEŞME ALGORİTMASI (MATCHING)
# ==========================================

@app.route('/api/matches/<int:user_id>', methods=['GET'])
def get_matches(user_id):
    """Kullanıcı için en uyumlu kişileri getirir."""
    matches = db.get_matches_for_user(user_id)

    if matches:
        return jsonify({"status": "success", "data": matches}), 200
    else:
        return jsonify({"status": "success", "data": [], "message": "Henüz eşleşme yok"}), 200
    
@app.route('/api/follow', methods=['POST'])
def follow_user():
    data = request.json
    follower_id = data.get('follower_id')
    following_id = data.get('following_id') # ARTIK 'following_id' BEKLİYORUZ

    if not follower_id or not following_id:
        return jsonify({"status": "error", "message": "Eksik ID"}), 400

    if db.add_follow(follower_id, following_id):
        return jsonify({"status": "success", "message": "Takip edildi"}), 200
    else:
        return jsonify({"status": "error", "message": "İşlem başarısız"}), 500


@app.route('/api/following/<int:user_id>', methods=['GET'])
def get_following_list(user_id):
    """Takip edilenleri listeler."""
    users = db.get_followed_users(user_id)
    # Her zaman success dönüyoruz, liste boş olsa bile
    return jsonify({"status": "success", "data": users}), 200
# ==========================================
# LİSTELER
# ==========================================
@app.route('/api/genres', methods=['GET'])
def get_all_genres():
    genres = db.get_all_genres()
    return jsonify({"status": "success", "data": genres}), 200

@app.route('/api/artists', methods=['GET'])
def get_top_artists():
    limit = request.args.get('limit', default = 50, type=int)
    artists = db.get_top_artists(limit)
    return jsonify({"status": "success", "data": artists}), 200

@app.route('/api/search/song', methods=['GET'])
def search_song():
    keyword = request.args.get('q')
    if not keyword:
        return jsonify({"status": "error", "data": []}), 400
    results = db.search_songs(keyword)
    return jsonify({"status": "success", "data": results}), 200
# ==========================================
# SUNUCUYU BAŞLAT
# ==========================================
if __name__ == '__main__':
    # host='0.0.0.0' tüm ağa açar (Telefondan erişim için şart)
    # debug=True geliştirme modunu açar (Hata görünce konsola yazar)
    app.run(debug=True, host='0.0.0.0', port=8000)