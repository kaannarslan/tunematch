import 'package:flutter/material.dart';
import '../models/user_profile.dart';

final List<UserProfile> mockUsers = [
  UserProfile(
    id: '1',
    firstName: 'Melis',
    lastName: 'Yılmaz',
    birthDate: '1999-05-20',
    city: 'İstanbul',
    gender: 'Kadın',
    favoriteGenres: ['Indie Rock', 'Alternatif'],
    favoriteArtists: ['Arctic Monkeys', 'Yüzyüzeyken Konuşuruz', 'Tame Impala'],
    bio: 'Gitar soloları benim terapi yöntemim.',
    cardColor: const Color(0xFFFFCDD2),
  ),
  UserProfile(
    id: '2',
    firstName: 'Can',
    lastName: 'Demir',
    birthDate: '1996-11-14',
    city: 'Ankara',
    gender: 'Erkek',
    favoriteGenres: ['Techno', 'Deep House'],
    favoriteArtists: ['Charlotte de Witte', 'Solomun', 'Carl Cox'],
    bio: 'Hafta sonları Berlin modundayım.',
    cardColor: const Color(0xFFC5CAE9),
  ),
  UserProfile(
    id: '3',
    firstName: 'Zeynep',
    lastName: 'Kaya',
    birthDate: '2001-02-10',
    city: 'İzmir',
    gender: 'Kadın',
    favoriteGenres: ['Pop', 'R&B'],
    favoriteArtists: ['Mabel Matiz', 'The Weeknd', 'Sezen Aksu'],
    bio: 'Eski şarkıların tadı bir başka.',
    cardColor: const Color(0xFFC8E6C9),
  ),
];
