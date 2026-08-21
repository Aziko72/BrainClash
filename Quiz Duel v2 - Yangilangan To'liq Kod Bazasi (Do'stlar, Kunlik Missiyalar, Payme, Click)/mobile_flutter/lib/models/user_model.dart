class UserModel {
  final int id;
  final String username;
  final String fullname;
  final String avatarUrl;
  int coins;
  int energy;
  int maxEnergy;
  int xp;
  int level;
  int ratingScore;
  int totalWins;
  int totalMatches;
  bool isVip;

  UserModel({
    required this.id,
    required this.username,
    required this.fullname,
    required this.avatarUrl,
    required this.coins,
    required this.energy,
    required this.maxEnergy,
    required this.xp,
    required this.level,
    required this.ratingScore,
    required this.totalWins,
    required this.totalMatches,
    required this.isVip,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullname: json['fullname'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      coins: json['coins'] ?? 0,
      energy: json['energy'] ?? 0,
      maxEnergy: json['max_energy'] ?? 10,
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      ratingScore: json['rating_score'] ?? 1000,
      totalWins: json['total_wins'] ?? 0,
      totalMatches: json['total_matches'] ?? 0,
      isVip: (json['is_vip'] == 1 || json['is_vip'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullname': fullname,
      'avatar_url': avatarUrl,
      'coins': coins,
      'energy': energy,
      'max_energy': maxEnergy,
      'xp': xp,
      'level': level,
      'rating_score': ratingScore,
      'total_wins': totalWins,
      'total_matches': totalMatches,
      'is_vip': isVip,
    };
  }
}
