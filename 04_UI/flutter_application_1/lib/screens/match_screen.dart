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
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final swipedUser = mockUsers[previousIndex];
    if (direction == CardSwiperDirection.right) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${swipedUser.firstName} beğenildi! 🎵'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 500)),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Müzik Eşleşmesi",
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: mockUsers.isEmpty
                  ? const Center(child: Text("Kimse kalmadı."))
                  : CardSwiper(
                      controller: controller,
                      cardsCount: mockUsers.length,
                      onSwipe: _onSwipe,
                      numberOfCardsDisplayed: 3,
                      backCardOffset: const Offset(0, 40),
                      padding: const EdgeInsets.all(24.0),
                      cardBuilder: (context, index, h, v) =>
                          ProfileCard(user: mockUsers[index]),
                    ),
            ),
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
                      child: const Icon(Icons.close, color: Colors.red)),
                  FloatingActionButton(
                      heroTag: "like",
                      onPressed: () =>
                          controller.swipe(CardSwiperDirection.right),
                      backgroundColor: Colors.green[100],
                      child: const Icon(Icons.favorite, color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
