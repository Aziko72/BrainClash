import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/localization_service.dart';
import '../models/shop_item_model.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  void _showPaymentOptions(BuildContext context, ShopItemModel item, GameService game, LocalizationService loc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${item.title} — To'lov turini tanlang",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "Narxi: ${item.priceUzs} UZS",
                style: const TextStyle(color: Colors.amberAccent, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Payme Button
              _buildPaymentTile(
                title: "Payme",
                subtitle: "Uzcard / Humo / Visa orqali to'lash",
                iconUrl: "https://payme.uz/favicon.ico",
                color: const Color(0xFF00CCCC),
                onTap: () {
                  Navigator.pop(ctx);
                  game.purchaseItem(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF00CCCC),
                      content: Text("Payme orqali ${item.title} to'lovi muvaffaqiyatli amalga oshirildi!"),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Click Button
              _buildPaymentTile(
                title: "Click Up",
                subtitle: "Click ilovasi yoki USSD orqali to'lash",
                iconUrl: "https://click.uz/favicon.ico",
                color: const Color(0xFF0073FF),
                onTap: () {
                  Navigator.pop(ctx);
                  game.purchaseItem(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF0073FF),
                      content: Text("Click orqali ${item.title} to'lovi muvaffaqiyatli amalga oshirildi!"),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Google Play / Apple Pay
              _buildPaymentTile(
                title: "Google Play / Apple In-App",
                subtitle: "Bir martalik to'lov yoki obuna",
                iconUrl: "",
                color: const Color(0xFF4F46E5),
                onTap: () {
                  Navigator.pop(ctx);
                  game.purchaseItem(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF4F46E5),
                      content: Text("In-App xarid ${item.title} muvaffaqiyatli yakunlandi!"),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentTile({
    required String title,
    required String subtitle,
    required String iconUrl,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(Icons.payment, color: color, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
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

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(loc.text('shop_vip'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amberAccent, size: 18),
                const SizedBox(width: 4),
                Text(
                  "${user?.coins ?? 0}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // VIP Pass Mega Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        Text(loc.text('vip_pass_title'), style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("30 D", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(loc.text('vip_features'), style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFD97706),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final vipItem = game.shopItems.firstWhere((i) => i.itemType == "VIP_PASS");
                      _showPaymentOptions(context, vipItem, game, loc);
                    },
                    child: Text(loc.text('vip_subscribe'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(loc.text('coins_lives'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Shop Items Grid
          ...game.shopItems.where((i) => i.itemType != "VIP_PASS").map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: item.isPopular ? Colors.amber.withOpacity(0.6) : const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.itemType == "COINS" ? Icons.monetization_on : Icons.bolt,
                      color: item.itemType == "COINS" ? Colors.amberAccent : Colors.cyanAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            if (item.isPopular) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                                child: const Text("TOP", style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(item.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (item.coinPrice > 0) {
                        game.purchaseItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${item.title} muvaffaqiyatli xarid qilindi!")),
                        );
                      } else {
                        _showPaymentOptions(context, item, game, loc);
                      }
                    },
                    child: Text(
                      item.coinPrice > 0 ? "${item.coinPrice} Tanga" : "${item.priceUzs ~/ 1000}k UZS",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
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
