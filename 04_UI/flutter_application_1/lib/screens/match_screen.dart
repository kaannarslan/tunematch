import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../widgets/profile_card.dart';
import 'login_screen.dart'; // <-- BUNU EKLE
import 'following_screen.dart'; // <-- IMPORT EKLEMEYİ UNUTMA

class MatchScreen extends StatefulWidget {
  // Giriş yapan kullanıcının ID'sine ihtiyacımız var
  final int currentUserId;

  // Eğer ID gelmezse varsayılan 1 olsun (Test için)
  const MatchScreen({super.key, this.currentUserId = 1});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final CardSwiperController controller = CardSwiperController();

  // Gelecek olan kullanıcı listesi için bir "Future" değişkeni
  late Future<List<UserProfile>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    // Ekran açılır açılmaz veriyi çekmeye başla
    _matchesFuture = ApiService.getMatches(widget.currentUserId);
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
    List<UserProfile> users,
  ) {
    final swipedUser = users[previousIndex];

    if (direction == CardSwiperDirection.right) {
      // 1. Kullanıcıya Görsel Geri Bildirim Ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${swipedUser.firstName} beğenildi! 🎵'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 500)),
      );

      // 2. BACKEND'E İSTEK AT (Arka planda çalışır, UI'ı dondurmaz)
      // widget.currentUserId -> Beğenen (Biz)
      // int.parse(swipedUser.id) -> Beğenilen (Karttaki)
      ApiService.followUser(widget.currentUserId, int.parse(swipedUser.id));

      debugPrint(
          "Takip isteği gönderildi: ${widget.currentUserId} -> ${swipedUser.id}");
    }
    // Sola kaydırma (Pass) için şimdilik bir şey yapmıyoruz.

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- YENİ EKLENEN KISIM: GERİ DÖN TUŞU ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.deepPurple), // Geri oku ikonu
          onPressed: () {
            // Çıkış onayı sormak istersen buraya Dialog ekleyebiliriz.
            // Şimdilik direkt çıkış yapıyoruz:

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) =>
                  false, // Geriye dönük tüm sayfaları sil (Stack'i temizle)
            );
          },
          tooltip: "Çıkış Yap", // Uzun basınca çıkan yazı
        ),
        // ------------------------------------------

        title: const Text("Müzik Eşleşmesi",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        // --- YENİ EKLENEN KISIM: SAĞ ÜST BUTON ---
        actions: [
          IconButton(
            icon:
                const Icon(Icons.list_alt, color: Colors.deepPurple, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // currentUserId'yi parametre olarak geçiriyoruz
                  builder: (context) =>
                      FollowingScreen(currentUserId: widget.currentUserId),
                ),
              );
            },
            tooltip: "Beğendiklerim",
          ),
          const SizedBox(width: 8), // Biraz sağdan boşluk
        ],
        // -----------------------------------------
      ),
      body: SafeArea(
        child: FutureBuilder<List<UserProfile>>(
          future: _matchesFuture, // Takip edilecek işlem
          builder: (context, snapshot) {
            // 1. DURUM: Veri Yükleniyor
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. DURUM: Hata Çıktı
            if (snapshot.hasError) {
              return Center(child: Text("Hata oluştu: ${snapshot.error}"));
            }

            // 3. DURUM: Veri Geldi ama Liste Boş
            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return const Center(
                child: Text(
                  "Eşleşecek kimse bulunamadı.\nBiraz daha sanatçı beğenmelisin!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            // 4. DURUM: Veri Başarıyla Geldi -> Kartları Göster
            return Column(
              children: [
                Expanded(
                  child: CardSwiper(
                    controller: controller,
                    cardsCount: users.length,
                    onSwipe: (prev, curr, dir) =>
                        _onSwipe(prev, curr, dir, users),

                    // --- HATAYI ÇÖZEN KISIM ---
                    // Eğer kullanıcı sayısı 3'ten azsa, kullanıcı sayısı kadar göster.
                    // Eğer 3 veya fazlaysa, 3 tane göster.
                    numberOfCardsDisplayed: users.length < 3 ? users.length : 3,
                    // ---------------------------

                    backCardOffset: const Offset(0, 40),
                    padding: const EdgeInsets.all(24.0),
                    cardBuilder: (context, index, h, v) {
                      return ProfileCard(user: users[index]);
                    },
                  ),
                ),
                // Butonlar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: "pass",
                        onPressed: () =>
                            controller.swipe(CardSwiperDirection.left),
                        backgroundColor: Colors.red[100],
                        child: const Icon(Icons.close, color: Colors.red),
                      ),
                      FloatingActionButton(
                        heroTag: "like",
                        onPressed: () =>
                            controller.swipe(CardSwiperDirection.right),
                        backgroundColor: Colors.green[100],
                        child: const Icon(Icons.favorite, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
