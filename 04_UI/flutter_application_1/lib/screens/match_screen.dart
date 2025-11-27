import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../data/mock_data.dart';
import '../widgets/profile_card.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final CardSwiperController controller = CardSwiperController();

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    // Kaydırılan kullanıcıyı listeden alıyoruz
    final swipedUser = mockUsers[previousIndex];

    if (direction == CardSwiperDirection.right) {
      // SAĞA KAYDIRMA (BEĞENİ)
      // DİKKAT: Burada artık swipedUser.name yerine swipedUser.firstName kullanıyoruz.
      debugPrint('${swipedUser.firstName} ${swipedUser.lastName} beğenildi!');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Kullanıcıya sadece ismiyle hitap ediyoruz
          content: Text(
              '${swipedUser.firstName} ile müzik zevkiniz eşleşiyor olabilir! 🎵'),
          duration: const Duration(milliseconds: 500),
          backgroundColor: Colors.green, // Beğeni olduğu için yeşil renk
        ),
      );
    } else if (direction == CardSwiperDirection.left) {
      // SOLA KAYDIRMA (PAS)
      debugPrint('${swipedUser.firstName} geçildi.');
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
        // İsterseniz buraya bir de filtre ikonu ekleyebiliriz ileride
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filtreleme ekranı buraya gelecek
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Filtreleme yakında...")));
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: mockUsers.isEmpty
                  ? const Center(child: Text("Görüntülenecek kimse kalmadı."))
                  : CardSwiper(
                      controller: controller,
                      cardsCount: mockUsers.length,
                      onSwipe: _onSwipe,
                      numberOfCardsDisplayed: 3,
                      backCardOffset: const Offset(0, 40),
                      padding: const EdgeInsets.all(24.0),
                      cardBuilder: (context,
                          index,
                          horizontalThresholdPercentage,
                          verticalThresholdPercentage) {
                        return ProfileCard(user: mockUsers[index]);
                      },
                    ),
            ),

            // Alt Butonlar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "pass",
                    onPressed: () => controller.swipe(CardSwiperDirection.left),
                    backgroundColor: Colors.red[100],
                    elevation: 0,
                    child: const Icon(Icons.close, color: Colors.red, size: 30),
                  ),
                  FloatingActionButton(
                    heroTag: "like",
                    onPressed: () =>
                        controller.swipe(CardSwiperDirection.right),
                    backgroundColor: Colors.green[100],
                    elevation: 0,
                    child: const Icon(Icons.favorite,
                        color: Colors.green, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
