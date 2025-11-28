import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String birthDate;
  final String city;
  final String gender;
  final List<String> favoriteGenres;
  final List<String> favoriteArtists;
  final String bio;
  final Color cardColor;
  final int compatibilityScore; // YENİ: Backend bu puanı gönderiyor, alalım.

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.city,
    required this.gender,
    required this.favoriteGenres,
    required this.favoriteArtists,
    required this.bio,
    required this.cardColor,
    this.compatibilityScore = 0,
  });

  // --- API'DEN GELEN JSON'I ÇEVİREN METOD ---
  // user_profile.dart içindeki fromJson metodunu güncelle:

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['user_id'].toString(),
      firstName: json['name'] ?? '',
      lastName: json['surname'] ?? '',
      birthDate: json['birth_date'] ?? '2000-01-01',
      city: json['city'] ?? 'Bilinmiyor',
      gender: json['sex'] ?? 'Belirtilmemiş',
      bio: json['biography'] ?? '',

      // Skoru al (Backend int döndürüyor ama bazen string gelebilir, garantiye alalım)
      compatibilityScore:
          int.tryParse(json['compatibility_score'].toString()) ?? 0,

      // --- BURAYI GÜNCELLE: Listeleri JSON'dan al ---
      favoriteGenres:
          json['genres'] != null ? List<String>.from(json['genres']) : [],

      favoriteArtists:
          json['artists'] != null ? List<String>.from(json['artists']) : [],

      // Renk ataması (Aynı kalsın)
      cardColor:
          Colors.primaries[json['user_id'] % Colors.primaries.length].shade100,
    );
  }

  // Yaş hesaplayıcı (Değişmedi)
  int get age {
    try {
      final DateTime birth = DateTime.parse(birthDate);
      final DateTime today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month ||
          (today.month == birth.month && today.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 18;
    }
  }
}
