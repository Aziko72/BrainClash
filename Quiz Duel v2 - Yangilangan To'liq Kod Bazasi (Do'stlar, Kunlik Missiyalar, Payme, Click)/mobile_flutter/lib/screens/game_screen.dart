import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/localization_service.dart';
import 'result_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    final loc = Provider.of<LocalizationService>(context);
    final user = game.currentUser;
    final opponent = game.opponent;
    final q = game.currentQuestion;

    if (game.gameStatus == GameStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
      });
    }

    if (user == null || opponent == null || q == null) {
      return const Scaffold(backgroundColor: Color(0xFF0F172A), body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Top Score Bar (Player 1 VS Player 2 with Live Emotes)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // My Card
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF2563EB),
                            child: Text(user.username.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text("${game.myScore} ${loc.text('ball')}", style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      if (game.myLiveEmote != null)
                        Positioned(
                          top: -24,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Text(game.myLiveEmote!, style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                    ],
                  ),

                  // Round indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Text(
                      "${game.currentRound} / ${game.totalRounds}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),

                  // Opponent Card
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(opponent.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text("${game.opponentScore} ${loc.text('ball')}", style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFE11D48),
                            child: Text(opponent.username.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      if (game.opponentLiveEmote != null)
                        Positioned(
                          top: -24,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Text(game.opponentLiveEmote!, style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Animated Timer Progress Bar
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(4)),
                  ),
                  FractionallySizedBox(
                    widthFactor: (game.timeLeft / 10.0).clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: game.timeLeft > 3 ? [Colors.blueAccent, Colors.purpleAccent] : [Colors.orange, Colors.red],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "${game.timeLeft.toStringAsFixed(1)}s",
                style: TextStyle(color: game.timeLeft > 3 ? Colors.white70 : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 14),

              // Question Card
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Center(
                    child: Text(
                      q.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Boosters & Emotes Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Boosters
                  Row(
                    children: [
                      ActionChip(
                        backgroundColor: const Color(0xFF1E293B),
                        avatar: const Icon(Icons.flaky, color: Colors.cyanAccent, size: 16),
                        label: Text("${loc.text('booster_5050')} (${game.booster5050Count})", style: const TextStyle(color: Colors.white, fontSize: 11)),
                        onPressed: game.disabledOptions.isEmpty && game.booster5050Count > 0 ? () => game.use5050Booster() : null,
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        backgroundColor: const Color(0xFF1E293B),
                        avatar: const Icon(Icons.more_time, color: Colors.amberAccent, size: 16),
                        label: Text("${loc.text('booster_time')} (${game.boosterTimeCount})", style: const TextStyle(color: Colors.white, fontSize: 11)),
                        onPressed: game.boosterTimeCount > 0 ? () => game.useTimeBooster() : null,
                      ),
                    ],
                  ),

                  // Quick Emotes Buttons
                  Row(
                    children: ["🔥", "😂", "👏", "😱"].map((em) {
                      return GestureDetector(
                        onTap: () => game.sendEmote(em),
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
                          child: Text(em, style: const TextStyle(fontSize: 16)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 4 Options Grid/List
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildOptionButton(context, game, "A", q.optionA),
                    const SizedBox(height: 6),
                    _buildOptionButton(context, game, "B", q.optionB),
                    const SizedBox(height: 6),
                    _buildOptionButton(context, game, "C", q.optionC),
                    const SizedBox(height: 6),
                    _buildOptionButton(context, game, "D", q.optionD),
                  ],
                ),
              ),

              // Explanation Footer (Shown on Round Result)
              if (game.gameStatus == GameStatus.roundResult && game.roundExplanation != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    "${loc.text('explanation')}: ${game.roundExplanation}",
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, GameService game, String key, String text) {
    final isDisabled = game.disabledOptions.contains(key);
    final isSelected = game.mySelectedOption == key;
    final isRoundDone = game.gameStatus == GameStatus.roundResult;
    final isCorrect = game.correctOption == key;

    Color bgColor = const Color(0xFF1E293B);
    Color borderColor = const Color(0xFF334155);

    if (isRoundDone) {
      if (isCorrect) {
        bgColor = const Color(0xFF059669).withOpacity(0.3);
        borderColor = const Color(0xFF059669);
      } else if (isSelected && !isCorrect) {
        bgColor = const Color(0xFFDC2626).withOpacity(0.3);
        borderColor = const Color(0xFFDC2626);
      }
    } else if (isSelected) {
      bgColor = const Color(0xFF4F46E5).withOpacity(0.4);
      borderColor = const Color(0xFF4F46E5);
    }

    if (isDisabled) {
      bgColor = Colors.black26;
      borderColor = Colors.transparent;
    }

    return Expanded(
      child: GestureDetector(
        onTap: (!isDisabled && game.mySelectedOption == null && game.gameStatus == GameStatus.inRound)
            ? () => game.submitAnswer(key)
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor.withOpacity(0.3),
                ),
                child: Center(
                  child: Text(
                    key,
                    style: TextStyle(
                      color: isDisabled ? Colors.white24 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isDisabled ? Colors.white24 : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isRoundDone && isCorrect)
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
              if (isRoundDone && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
