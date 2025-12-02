import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart'; // Modeli import etmeyi unutma

class ApiService {
  // Senin verdiğin IP ve 8000 Portu
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // 1. KAYIT OLMA
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Bir hata oluştu'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Sunucu hatası: $e'};
    }
  }

  // 2. GİRİŞ YAPMA
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Giriş başarısız'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // --- YENİ: EŞLEŞMELERİ GETİR ---
  static Future<List<UserProfile>> getMatches(int userId) async {
    final url = Uri.parse('$baseUrl/matches/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        // Backend { "status": "success", "data": [...] } dönüyor.
        if (decoded['status'] == 'success') {
          final List<dynamic> data = decoded['data'];

          // Gelen listeyi tek tek UserProfile objesine çeviriyoruz
          return data.map((json) => UserProfile.fromJson(json)).toList();
        }
      }
      // Hata veya boş durumunda boş liste dön
      return [];
    } catch (e) {
      print("Eşleşme çekme hatası: $e");
      return [];
    }
  }

  // --- TAKİP ETME (SAĞA KAYDIRMA) ---
  static Future<bool> followUser(int followerId, int followingId) async {
    final url = Uri.parse('$baseUrl/follow');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "follower_id": followerId,
          "following_id":
              followingId, // BURASI GÜNCELLENDİ (followed_id -> following_id)
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Follow hatası: $e");
      return false;
    }
  }

  // api_service.dart içine ekle:

  // --- TAKİP EDİLENLERİ GETİR ---
  static Future<List<UserProfile>> getFollowingList(int userId) async {
    final url = Uri.parse('$baseUrl/following/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success') {
          final List<dynamic> data = decoded['data'];
          return data.map((json) => UserProfile.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Takip listesi hatası: $e");
      return [];
    }
  }

  // PULL LISTS
  static Future<List<String>> getGenres() async {
    final url = Uri.parse('$baseUrl/genres');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return List<String>.from(decoded['data']);
      }
    } catch (e) {
      print("Genre çekme hatası: $e");
    }
    return [];
  }

  static Future<List<String>> getArtists() async {
    final url = Uri.parse('$baseUrl/artists');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return List<String>.from(decoded['data']);
      }
    } catch (e) {
      print("Artist çekme hatası: $e");
    }
    return [];
  }
  // Search songs
  static Future<List<dynamic>> searchSongs(String keyword) async {
    final url = Uri.parse('$baseUrl/search/song?q=$keyword');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'];
      }
    } catch (e) {
      print("Song search error: $e");
    }
    return [];
  }

  //Fake play button
  static Future<bool> listenToSong(int userId, int songId) async {
    final url = Uri.parse('$baseUrl/listen');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "song_id": songId
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Listen error: $e");
      return false;
    }
  }
// --- İSTATİSTİKLERİ GETİR ---
  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    final url = Uri.parse('$baseUrl/user/stats/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'];
      }
    } catch (e) {
      print("Stats error: $e");
    }
    // Hata olursa boş veri dönelim
    return {
      "total_songs": 0,
      "top_artist": "-",
      "top_genre": "-"
    };
  }
}
