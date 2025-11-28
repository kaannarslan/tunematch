// lib/widgets/profile_card.dart

import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileCard extends StatelessWidget {
  final UserProfile user;
  const ProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: user.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2)
        ],
      ),
      // --- STACK KULLANIYORUZ ---
      child: Stack(
        children: [
          // 1. MEVCUT İÇERİK (Padding ve Column)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İsim ve Yaş
                Text(
                  '${user.firstName} ${user.lastName}, ${user.age}',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on,
                      size: 16, color: Colors.black54),
                  Text(" ${user.city} · ${user.gender}",
                      style: const TextStyle(fontSize: 16))
                ]),

                const Divider(height: 24, thickness: 2),

                // Favori Türler
                const Text("🎵 Türler",
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: user.favoriteGenres
                      .map((genre) => Chip(
                            label: Text(genre,
                                style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.white.withOpacity(0.5),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),

                const SizedBox(height: 12),

                // Favori Sanatçılar
                const Text("🎤 Sanatçılar",
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: user.favoriteArtists
                      .map((artist) => Chip(
                            // --- DEĞİŞİKLİK BURADA ---
                            // 'avatar: CircleAvatar(...)' satırını tamamen sildik.

                            label: Text(artist,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.white.withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    4), // Yazı biraz ferahlasın diye padding ekledim
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),

                const Spacer(),

                // Biyografi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(user.bio,
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),

          // 2. YENİ EKLENEN SKOR ROZETİ (SAĞ ÜST KÖŞE)
          // 2. YENİ SKOR ROZETİ (SAĞ ÜST KÖŞE)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1)
                ],
              ),
              child: Row(
                children: [
                  // İkonu değiştirebilirsin (Şimşek, Yıldız veya Kalp)
                  const Icon(Icons.star_rounded,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "${user.compatibilityScore} Puan", // ARTIK % YOK, "Puan" VAR
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
