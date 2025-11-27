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
            spreadRadius: 2,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İsim ve Hesaplanan Yaş (user.age getter'ı çalışır)
            Text(
              '${user.firstName} ${user.lastName}, ${user.age}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on, size: 16, color: Colors.black54),
              Text(" ${user.city} · ${user.gender}",
                  style: const TextStyle(fontSize: 16))
            ]),

            const Divider(height: 24, thickness: 2),

            // --- FAVORİ TÜRLER ---
            const Text("🎵 Türler",
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: user.favoriteGenres
                  .map((genre) => Chip(
                        label:
                            Text(genre, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.white.withOpacity(0.5),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),

            const SizedBox(height: 12),

            // --- FAVORİ SANATÇILAR ---
            const Text("🎤 Sanatçılar",
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: user.favoriteArtists
                  .map((artist) => Chip(
                        avatar: CircleAvatar(
                            backgroundColor: Colors.black87,
                            child: Text(artist.isNotEmpty ? artist[0] : "?",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10))),
                        label: Text(artist,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.white.withOpacity(0.8),
                        padding: EdgeInsets.zero,
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
    );
  }
}
