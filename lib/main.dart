import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Define the GameCard model
class GameCard {
  final String frontSide;
  final String backSide;
  bool isFaceUp;
  bool isMatched;

  GameCard(this.frontSide, this.backSide, {this.isFaceUp = false, this.isMatched = false});
}

// Define the GameProvider class
class GameProvider extends ChangeNotifier {
  List<GameCard> cards = [];
  List<int> flippedIndices = [];

  GameProvider() {
    // Initialize 8 pairs of cards (for a 4x4 grid) with different front sides
    for (int i = 0; i < 8; i++) {
      cards.add(GameCard('assets/card_front_$i.png', 'assets/card_back.png'));
      cards.add(GameCard('assets/card_front_$i.png', 'assets/card_back.png')); // Matching pair
    }
    cards.shuffle(); // Shuffle cards
  }

  // Flip the card at the given index
  void flipCard(int index) {
    if (!cards[index].isMatched && flippedIndices.length < 2) {
      cards[index].isFaceUp = !cards[index].isFaceUp;
      flippedIndices.add(index);
      notifyListeners();

      if (flippedIndices.length == 2) {
        _checkForMatch();
      }
    }
  }

  // Check if the two flipped cards match
  void _checkForMatch() {
    final firstIndex = flippedIndices[0];
    final secondIndex = flippedIndices[1];

    if (cards[firstIndex].frontSide == cards[secondIndex].frontSide) {
      // Cards match, mark them as matched
      cards[firstIndex].isMatched = true;
      cards[secondIndex].isMatched = true;
      flippedIndices.clear();
    } else {
      // Cards don't match, flip them back after a delay
      Timer(const Duration(seconds: 1), () {
        cards[firstIndex].isFaceUp = false;
        cards[secondIndex].isFaceUp = false;
        flippedIndices.clear();
        notifyListeners();
      });
    }
  }

  // Check if all cards have been matched
  bool isGameWon() {
    return cards.every((card) => card.isMatched);
  }

  // Restart the game
  void restartGame() {
    cards = [];
    for (int i = 0; i < 8; i++) {
      cards.add(GameCard('assets/card_front_$i.png', 'assets/card_back.png'));
      cards.add(GameCard('assets/card_front_$i.png', 'assets/card_back.png')); // Matching pair
    }
    cards.shuffle();
    flippedIndices.clear();
    notifyListeners();
  }
}

// The main widget for the game
class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Card Matching Game'),
        ),
        body: Consumer<GameProvider>(
          builder: (context, provider, child) {
            // Automatically show victory dialog when game is won
            if (provider.isGameWon()) {
              Future.delayed(const Duration(milliseconds: 500), () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('You Win!'),
                    content: const Text('Congratulations, you matched all the cards!'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          provider.restartGame();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Play Again'),
                      ),
                    ],
                  ),
                );
              });
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4x4 grid
              ),
              itemCount: provider.cards.length,
              itemBuilder: (context, index) {
                final card = provider.cards[index];
                return GestureDetector(
                  onTap: () {
                    if (!card.isFaceUp && provider.flippedIndices.length < 2) {
                      provider.flipCard(index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: card.isFaceUp
                        ? Image.asset(card.frontSide) // Show the front of the card
                        : Image.asset(card.backSide), // Show the back of the card
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Main function to run the app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CardMatchingGame(),
    );
  }
}
