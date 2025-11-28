import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class FollowingScreen extends StatefulWidget {
  final int currentUserId;

  const FollowingScreen({super.key, required this.currentUserId});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  late Future<List<UserProfile>> _followingFuture;

  @override
  void initState() {
    super.initState();
    _followingFuture = ApiService.getFollowingList(widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beğendiklerim"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<UserProfile>>(
        future: _followingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.heart_broken, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Henüz kimseyi beğenmedin.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(user.firstName[0],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple)),
                ),
                title: Text(
                  "${user.firstName} ${user.lastName}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${user.city} · ${user.age} Yaş"),
                trailing: const Icon(Icons.favorite, color: Colors.red),
              );
            },
          );
        },
      ),
    );
  }
}
