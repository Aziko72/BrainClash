import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/localization_service.dart';
import 'matchmaking_screen.dart';
import 'shop_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showFriendRoomDialog(BuildContext context, GameService game, LocalizationService loc) {
    String code = game.createFriendRoom();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.text('create_room_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.text('share_code'), textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4F46E5), width: 2),
              ),
              child: Text(code, style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.share, color: Colors.white, size: 18),
              label: const Text("Telegram orqali ulashish", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(ctx);
                game.startSearchingMatch(isFriend: true);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchmakingScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    final loc = Provider.of<LocalizationService>(context);
    final user = game.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: User Profile + Language Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: user.isVip
                                  ? const LinearGradient(colors: [Colors.amber, Colors.orange])
                                  : const LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFF1E293B),
                              child: Text(
                                user.username.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          if (user.isVip)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.amber,
                                child: Icon(Icons.star, size: 10, color: Colors.black),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullname,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              if (user.isVip) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.amber, width: 0.8),
                                  ),
                                  child: const Text("VIP", style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            "${loc.text('level')}: ${user.level} • ${loc.text('rating')}: ${user.ratingScore}",
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Language Switcher
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: loc.currentLocale,
                        dropdownColor: const Color(0xFF1E293B),
                        icon: const Icon(Icons.language, color: Colors.white70, size: 16),
                        items: const [
                          DropdownMenuItem(value: 'uz', child: Text("🇺🇿 UZB", style: TextStyle(fontSize: 12, color: Colors.white))),
                          DropdownMenuItem(value: 'ru', child: Text("🇷🇺 РУС", style: TextStyle(fontSize: 12, color: Colors.white))),
                          DropdownMenuItem(value: 'en', child: Text("🇬🇧 ENG", style: TextStyle(fontSize: 12, color: Colors.white))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            loc.setLocale(val);
                            game.setLanguage(val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Currency & Streak Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Streak Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Text("🔥", style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text("${game.streakDays} kunlik seriya", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      // Energy Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text("${user.energy}/${user.maxEnergy}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Coins Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amberAccent, size: 16),
                            const SizedBox(width: 4),
                            Text("${user.coins}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Weekly Tournament Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 16),
                              const SizedBox(width: 4),
                              Text(loc.text('weekly_tournament'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Text(loc.text('ends_in'), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(loc.text('prize_pool'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(loc.text('tournament_desc'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 1v1 Random Duel Button
              GestureDetector(
                onTap: () {
                  if (user.energy <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.text('energy_depleted'))));
                    return;
                  }
                  game.startSearchingMatch();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchmakingScreen()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFF43F5E)]),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFE11D48).withOpacity(0.5), blurRadius: 18, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.sports_esports, color: Colors.white, size: 40),
                      const SizedBox(height: 6),
                      Text(loc.text('start_duel'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                      const SizedBox(height: 2),
                      Text(loc.text('duel_desc'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Play With Friend Button
              GestureDetector(
                onTap: () => _showFriendRoomDialog(context, game, loc),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.people, color: Color(0xFF38BDF8), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.text('play_with_friend'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(loc.text('play_with_friend_desc'), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Daily Quests Section
              Text(loc.text('daily_quests'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ...game.dailyQuests.map((quest) {
                String title = loc.currentLocale == 'ru' ? quest.titleRu : (loc.currentLocale == 'en' ? quest.titleEn : quest.titleUz);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text("${quest.current}/${quest.target} • Mukofot: +${quest.rewardCoins} Tanga", style: const TextStyle(color: Colors.amberAccent, fontSize: 11)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: quest.isCompleted && !quest.isClaimed ? const Color(0xFF10B981) : const Color(0xFF334155),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: quest.isCompleted && !quest.isClaimed ? () => game.claimQuest(quest.id) : null,
                        child: Text(
                          quest.isClaimed ? loc.text('claimed') : loc.text('claim'),
                          style: TextStyle(color: quest.isCompleted && !quest.isClaimed ? Colors.white : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 14),

              // Bottom Grid: Shop & Leaderboard
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shopping_bag, color: Colors.amber, size: 24),
                            const SizedBox(height: 8),
                            Text(loc.text('shop_vip'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(loc.text('shop_vip_desc'), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.military_tech, color: Colors.cyanAccent, size: 24),
                            const SizedBox(height: 8),
                            Text(loc.text('leaderboard'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(loc.text('leaderboard_desc'), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
