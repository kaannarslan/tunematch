import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart'; // Modeli import etmeyi unutma

class ApiService {
  // Senin verdiğin IP ve 8000 Portu
  static const String baseUrl = 'http://10.3.142.209:8000/api';

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
}
