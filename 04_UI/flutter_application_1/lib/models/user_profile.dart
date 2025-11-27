import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String birthDate; // YYYY-MM-DD
  final String city;
  final String gender;
  final List<String> favoriteGenres;
  final List<String> favoriteArtists;
  final String bio;
  final Color cardColor;

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
  });

  // Doğum tarihinden yaşı otomatik hesaplar
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
      return 18; // Hata olursa varsayılan
    }
  }
}
