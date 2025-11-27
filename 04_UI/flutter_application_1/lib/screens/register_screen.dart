import 'package:flutter/material.dart';
import 'match_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Kadın', 'Erkek', 'Belirtmek İstemiyorum'];

  // --- SEÇİLENLERİ TUTACAK LİSTELER ---
  List<String> _selectedGenres = [];
  List<String> _selectedArtists = [];

  // --- ÖRNEK VERİ HAVUZU (Gerçekte API'den gelebilir) ---
  final List<String> _allGenres = [
    'Rock',
    'Pop',
    'Jazz',
    'Hip Hop',
    'Techno',
    'Klasik',
    'Indie',
    'Metal',
    'R&B',
    'Arabesk'
  ];

  final List<String> _allArtists = [
    'The Weeknd',
    'Arctic Monkeys',
    'Sezen Aksu',
    'Müslüm Gürses',
    'Taylor Swift',
    'Duman',
    'Ezhel',
    'Metallica',
    'Tarkan',
    'Daft Punk'
  ];

  // --- ÇOKLU SEÇİM PENCERESİ FONKSİYONU ---
  void _showMultiSelectDialog(String title, List<String> items,
      List<String> selectedItems, Function(List<String>) onConfirm) async {
    final List<String> tempSelected = List.from(selectedItems); // Geçici liste

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Dialog içinde state değişimi için gerekli
          builder: (context, setState) {
            return AlertDialog(
              title: Text("$title Seç"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = tempSelected.contains(item);
                    return CheckboxListTile(
                      title: Text(item),
                      value: isSelected,
                      activeColor: Colors.deepPurple,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelected.add(item);
                          } else {
                            tempSelected.remove(item);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("İptal"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Kaydet"),
                  onPressed: () {
                    onConfirm(tempSelected); // Seçimleri ana ekrana gönder
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGenres.isEmpty || _selectedArtists.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Lütfen en az bir müzik türü ve sanatçı seçin.")),
        );
        return;
      }

      // Kayıt başarılı
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MatchScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aramıza Katıl")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Profilini Oluştur",
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Ad - Soyad
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                                labelText: "Ad", border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? "Zorunlu" : null)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                                labelText: "Soyad",
                                border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? "Zorunlu" : null)),
                  ],
                ),
                const SizedBox(height: 16),

                // Yaş - Şehir
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Yaş", border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? "Zorunlu" : null)),
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 2,
                        child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                                labelText: "Şehir",
                                border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? "Zorunlu" : null)),
                  ],
                ),
                const SizedBox(height: 16),

                // Cinsiyet
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                      labelText: "Cinsiyet", border: OutlineInputBorder()),
                  items: _genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGender = v),
                ),
                const SizedBox(height: 24),

                const Divider(),
                const Text("Müzik Zevkin",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // --- MÜZİK TÜRÜ SEÇİM ALANI ---
                InkWell(
                  onTap: () => _showMultiSelectDialog(
                      "Müzik Türü", _allGenres, _selectedGenres, (list) {
                    setState(() => _selectedGenres = list);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _selectedGenres.isEmpty
                              ? const Text("Müzik türlerini seç...",
                                  style: TextStyle(color: Colors.black54))
                              : Text(_selectedGenres.join(", "),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- SANATÇI SEÇİM ALANI ---
                InkWell(
                  onTap: () => _showMultiSelectDialog(
                      "Sanatçı", _allArtists, _selectedArtists, (list) {
                    setState(() => _selectedArtists = list);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _selectedArtists.isEmpty
                              ? const Text("Favori sanatçılarını seç...",
                                  style: TextStyle(color: Colors.black54))
                              : Text(_selectedArtists.join(", "),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis),
                        ),
                        const Icon(Icons.mic_external_on),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Kayıt Ol",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
