import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PlayerScreen extends StatefulWidget {
  final int currentUserId;
  const PlayerScreen({super.key, required this.currentUserId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _songs = [];
  bool _isLoading = false;

  void _search(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    final results = await ApiService.searchSongs(query);
    setState(() {
      _songs = results;
      _isLoading = false;
    });
  }

  void _playSong(int songId, String title) async {
    await ApiService.listenToSong(widget.currentUserId, songId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎶 $title dinleniyor..."),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.deepPurple,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Şarkı Keşfet")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Şarkı ara (örn: Enter Sandman)",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _search(_searchController.text),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: _search,
            ),
          ),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: song['cover_url'] != null
                              ? NetworkImage(song['cover_url'])
                              : null,
                          child: song['cover_url'] == null ? const Icon(Icons.music_note) : null,
                        ),
                        title: Text(song['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(song['artist_name']),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_fill, color: Colors.deepPurple, size: 32),
                          onPressed: () => _playSong(song['song_id'], song['title']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}