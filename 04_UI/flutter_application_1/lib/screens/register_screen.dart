import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'match_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllerlar
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cityController = TextEditingController();

  // Seçimler
  String? _selectedGender;
  final List<String> _genders = ['Kadın', 'Erkek', 'Belirtmek İstemiyorum'];
  List<String> _selectedGenres = [];
  List<String> _selectedArtists = [];
  bool _isLoading = false;

  List<String> _allGenres = [];
  List<String> _topArtists = [];
  bool _isDataLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatabaseData();
  }

  void _loadDatabaseData() async {
    final results = await Future.wait([
      ApiService.getGenres(),
      ApiService.getArtists(),
    ]);

    if (mounted) {
      setState(() {
        _allGenres = results[0];
        _topArtists = results[1];
        _isDataLoading = false;
      });
    }
  }
  // // Veri Havuzları
  // final List<String> _allGenres = [
  //   'Rock',
  //   'Pop',
  //   'Jazz',
  //   'Hip Hop',
  //   'Techno',
  //   'Klasik',
  //   'Indie',
  //   'Metal',
  //   'R&B',
  //   'Arabesk'
  // ];
  // final List<String> _allArtists = [
  //   'The Weeknd',
  //   'Arctic Monkeys',
  //   'Sezen Aksu',
  //   'Müslüm Gürses',
  //   'Taylor Swift',
  //   'Duman',
  //   'Ezhel',
  //   'Metallica'
  // ];

  // --- TARİH SEÇİCİ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDialog(
      context: context,
      builder: (context) {
        return DatePickerDialog(
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
      },
    );

    if (picked != null) {
      // YYYY-MM-DD Formatı
      String formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _birthDateController.text = formattedDate;
      });
    }
  }

  // --- ÇOKLU SEÇİM PENCERESİ ---
  void _showMultiSelectDialog(String title, List<String> items,
      List<String> selectedItems, Function(List<String>) onConfirm) async {
    final List<String> tempSelected = List.from(selectedItems);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
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
                          if (value == true)
                            tempSelected.add(item);
                          else
                            tempSelected.remove(item);
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                    child: const Text("İptal"),
                    onPressed: () => Navigator.pop(context)),
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

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGenres.isEmpty || _selectedArtists.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lütfen müzik zevkinizi seçin.")));
        return;
      }

      setState(() => _isLoading = true);

      final userData = {
        "name": _firstNameController.text,
        "surname": _lastNameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "birth_date": _birthDateController.text,
        "sex": _selectedGender,
        "city": _cityController.text,
        "genres": _selectedGenres,
        "artists": _selectedArtists,
      };

      final result = await ApiService.register(userData);

      setState(() => _isLoading = false);

      if (result['success']) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Kayıt Başarılı!")));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MatchScreen()),
            (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message']), backgroundColor: Colors.red));
      }
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

                // AD - SOYAD
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

                // EMAIL - ŞİFRE
                TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        labelText: "E-posta",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Zorunlu" : null),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: "Şifre",
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v!.length < 6 ? "En az 6 karakter" : null),
                const SizedBox(height: 16),

                // TARİH - ŞEHİR
                Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: TextFormField(
                            controller: _birthDateController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            decoration: const InputDecoration(
                                labelText: "Doğum Tarihi",
                                prefixIcon: Icon(Icons.calendar_month),
                                border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? "Zorunlu" : null)),
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 3,
                        child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                                labelText: "Şehir",
                                prefixIcon: Icon(Icons.location_city),
                                border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? "Zorunlu" : null)),
                  ],
                ),
                const SizedBox(height: 16),

                // CİNSİYET
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                      labelText: "Cinsiyet",
                      prefixIcon: Icon(Icons.wc),
                      border: OutlineInputBorder()),
                  items: _genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGender = v),
                  validator: (v) => v == null ? "Seçiniz" : null,
                ),

                const Divider(height: 40),
                const Text("Müzik Zevkin",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                //TÜR SEÇİMİ
                _isDataLoading
                    ? const Center(child: CircularProgressIndicator())
                : InkWell(
                  onTap: () => _showMultiSelectDialog(
                      "Müzik Türü",
                      _allGenres,
                      _selectedGenres,
                      (list) => setState(() => _selectedGenres = list)),
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
                            child: Text(
                                _selectedGenres.isEmpty
                                    ? "Türleri seç..."
                                    : _selectedGenres.join(", "),
                                overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // SANATÇI SEÇİMİ
                InkWell(
                  onTap: () => _showMultiSelectDialog(
                      "Sanatçı",
                      _topArtists,
                      _selectedArtists,
                      (list) => setState(() => _selectedArtists = list)),
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
                            child: Text(
                                _selectedArtists.isEmpty
                                    ? "Sanatçıları seç..."
                                    : _selectedArtists.join(", "),
                                overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.mic_external_on),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Kayıt Ol",
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
