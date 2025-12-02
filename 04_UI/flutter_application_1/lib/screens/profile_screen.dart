import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final int currentUserId;

  const ProfileScreen({super.key, required this.currentUserId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> _allGenres = [];
  List<String> _allArtists = [];
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final results = await Future.wait([
      ApiService.getUserStats(widget.currentUserId),
      ApiService.getGenres(),
      ApiService.getArtists(),
    ]);

    if (mounted) {
      setState(() {
        stats = results[0] as Map<String, dynamic>;
        _allGenres = results[1] as List<String>;
        _allArtists = results[2] as List<String>;
        isLoading = false;
      });
    }
  }
void _showMultiSelectDialog(String title, List<String> allItems, List<String> currentSelected, Function(List<String>) onConfirm) async {
    final List<String> tempSelected = List.from(currentSelected);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("$title Düzenle"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allItems.length,
                  itemBuilder: (context, index) {
                    final item = allItems[index];
                    final isSelected = tempSelected.contains(item);
                    return CheckboxListTile(
                      title: Text(item),
                      value: isSelected,
                      activeColor: Colors.deepPurple,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) tempSelected.add(item);
                          else tempSelected.remove(item);
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(child: const Text("İptal"), onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                    child: const Text("Kaydet"),
                    onPressed: () {
                      onConfirm(tempSelected);
                      Navigator.pop(context);
                    }),
              ],
            );
          },
        );
      },
    );
  }
  void _saveChanges() async {
    if (stats == null) return;
    List<String> currentGenres = List<String>.from(stats!['registered_fav_genres']);
    List<String> currentArtists = List<String>.from(stats!['registered_fav_artists']);

    bool success = await ApiService.updateFavorites(
        widget.currentUserId, currentGenres, currentArtists);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Profil güncellendi!" : "Hata oluştu"),
                 backgroundColor: success ? Colors.green : Colors.red)
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Müzik Kimliğim"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${stats?['name'] ?? ''} ${stats?['surname'] ?? ''}",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  // --- 1. KULLANICI KİMLİK KARTI ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // GÜNCELLEME: Her veriye ?? "..." koruması ekledik
                        _buildInfoItem("Şehir", stats?['city'] ?? "Bilinmiyor", Icons.location_city),
                        Container(height: 40, width: 1, color: Colors.white30),

                        _buildInfoItem("Yaş", "${stats?['age'] ?? '-'}", Icons.cake),
                        Container(height: 40, width: 1, color: Colors.white30),

                        _buildInfoItem("Cinsiyet", stats?['sex'] ?? "Belirtilmedi", Icons.person),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 2. DİNLEME ANALİZİ ---
                  const Text(
                    "Dinleme İstatistikleri",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        title: "Toplam Şarkı",
                        value: "${stats?['total_songs'] ?? 0}",
                        icon: Icons.headphones,
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        title: "Trend Sanatçın",
                        value: stats?['most_listened_artist'] ?? "Yok",
                        icon: Icons.trending_up,
                        color: Colors.red,
                      ),
                      _buildStatCard(
                        title: "Trend Türün",
                        value: stats?['most_listened_genre'] ?? "Yok",
                        icon: Icons.graphic_eq,
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        title: "Aktiflik",
                        value: "${stats?['active_days'] ?? 1} Gün",
                        icon: Icons.calendar_month,
                        color: Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- 3. KAYITLI FAVORİLER ---
                  const Text(
                    "Favorilerin (Kayıtlı)",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildChipSection("Sanatçılar", stats?['registered_fav_artists'] ?? [], _allArtists, Icons.mic, 'artist'),
                  const SizedBox(height: 16),
                  _buildChipSection("Türler", stats?['registered_fav_genres'] ?? [], _allGenres, Icons.category, 'genre'),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 24,
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildChipSection(String title, List<dynamic> items, List<String> allOptions, IconData icon, String type) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              // DÜZENLE BUTONU
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                onPressed: () {
                  // Şu anki seçili olanları String listesine çevir
                  List<String> currentList = List<String>.from(items);

                  _showMultiSelectDialog(title, allOptions, currentList, (newList) {
                    setState(() {
                      // Ekranı güncelle
                      if (type == 'genre') {
                        stats!['registered_fav_genres'] = newList;
                      } else {
                        stats!['registered_fav_artists'] = newList;
                      }
                    });
                    // Backend'e kaydet
                    _saveChanges();
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 12),
          items.isEmpty
              ? const Text("Seçim yok", style: TextStyle(color: Colors.grey))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items.map((item) => Chip(
                    label: Text(item.toString()),
                    backgroundColor: Colors.deepPurple.withOpacity(0.05),
                    labelStyle: const TextStyle(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  )).toList(),
                ),
        ],
      ),
    );
  }
}