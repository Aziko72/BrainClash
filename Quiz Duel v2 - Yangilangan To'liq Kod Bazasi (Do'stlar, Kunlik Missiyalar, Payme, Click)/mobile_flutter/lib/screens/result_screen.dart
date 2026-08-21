import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/localization_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    final loc = Provider.of<LocalizationService>(context);
    final isWinner = game.myScore > game.opponentScore;
    final isDraw = game.myScore == game.opponentScore;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy or Result Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isWinner ? Colors.amber.withOpacity(0.15) : (isDraw ? Colors.blue.withOpacity(0.15) : Colors.red.withOpacity(0.15)),
                    border: Border.all(
                      color: isWinner ? Colors.amber : (isDraw ? Colors.blueAccent : Colors.redAccent),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    isWinner ? Icons.emoji_events : (isDraw ? Icons.handshake : Icons.sentiment_dissatisfied),
                    size: 72,
                    color: isWinner ? Colors.amber : (isDraw ? Colors.blueAccent : Colors.redAccent),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  isWinner ? loc.text('victory') : (isDraw ? loc.text('draw') : loc.text('defeat')),
                  style: TextStyle(
                    color: isWinner ? Colors.amber : (isDraw ? Colors.blueAccent : Colors.redAccent),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "${game.myScore}  VS  ${game.opponentScore}",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                // Rewards Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amberAccent),
                              const SizedBox(width: 8),
                              Text(loc.text('coins_won'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                          Text(
                            isWinner ? "+50" : (isDraw ? "+20" : "+0"),
                            style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF334155), height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.military_tech, color: Colors.cyanAccent),
                              const SizedBox(width: 8),
                              Text(loc.text('rating_pts'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                          Text(
                            isWinner ? "+25" : (isDraw ? "+0" : "-15"),
                            style: TextStyle(
                              color: isWinner ? const Color(0xFF10B981) : (isDraw ? Colors.white70 : const Color(0xFFEF4444)),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF334155), height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                              const SizedBox(width: 8),
                              Text(loc.text('xp_won'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                          Text(
                            isWinner ? "+100 XP" : "+25 XP",
                            style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Return to Home button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      game.resetGame();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text(loc.text('return_home'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
