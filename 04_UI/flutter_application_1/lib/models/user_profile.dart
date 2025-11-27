import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final String city;
  final String gender;
  final List<String> favoriteGenres; // ARTIK LİSTE (Birden çok tür)
  final List<String> favoriteArtists; // YENİ: Favori Sanatçılar Listesi
  final String bio;
  final Color cardColor;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.city,
    required this.gender,
    required this.favoriteGenres, // Constructor güncellendi
    required this.favoriteArtists, // Constructor güncellendi
    required this.bio,
    required this.cardColor,
  });
}
