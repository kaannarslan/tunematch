import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../widgets/profile_card.dart';

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
    List<UserProfile> users, // Listeyi parametre olarak alıyoruz artık
  ) {
    final swipedUser = users[previousIndex];

    if (direction == CardSwiperDirection.right) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${swipedUser.firstName} beğenildi! 🎵'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 500)),
      );
      // BURAYA İLERİDE "BEĞENİ GÖNDER" API İSTEĞİ GELECEK
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Müzik Eşleşmesi",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                    // onSwipe fonksiyonuna users listesini de gönderiyoruz
                    onSwipe: (prev, curr, dir) =>
                        _onSwipe(prev, curr, dir, users),
                    numberOfCardsDisplayed: 3,
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
