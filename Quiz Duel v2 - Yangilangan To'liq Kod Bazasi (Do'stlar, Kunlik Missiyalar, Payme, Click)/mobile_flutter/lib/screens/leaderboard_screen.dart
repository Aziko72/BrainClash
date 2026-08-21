import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/localization_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    final loc = Provider.of<LocalizationService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(loc.text('leaderboard'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Weekly Prize Announcement Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4F46E5), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.military_tech, color: Colors.amber, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.text('rank_1_prize'), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(loc.text('rank_2_3_prize'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(loc.text('rank_top_prize'), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Leaderboard List
          ...game.leaderboard.map((player) {
            final rank = player['rank'] as int;
            Color badgeColor = const Color(0xFF334155);
            if (rank == 1) badgeColor = Colors.amber;
            if (rank == 2) badgeColor = Colors.grey.shade400;
            if (rank == 3) badgeColor = Colors.brown.shade300;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: rank <= 3 ? badgeColor.withOpacity(0.5) : const Color(0xFF334155),
                  width: rank <= 3 ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badgeColor.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        "$rank",
                        style: TextStyle(
                          color: rank <= 3 ? badgeColor : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF0F172A),
                    child: Text(
                      (player['username'] as String).substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              player['fullname'],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (player['is_vip'] == true) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                            ],
                          ],
                        ),
                        Text(
                          "${loc.text('level')}: ${player['level']} • ${player['prize']}",
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${player['rating']} pts",
                    style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
