import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/question_model.dart';
import '../models/shop_item_model.dart';

enum GameStatus { idle, searching, inRound, roundResult, finished }

class DailyQuest {
  final int id;
  final String titleUz;
  final String titleRu;
  final String titleEn;
  final int target;
  int current;
  final int rewardCoins;
  bool isClaimed;

  DailyQuest({
    required this.id,
    required this.titleUz,
    required this.titleRu,
    required this.titleEn,
    required this.target,
    this.current = 0,
    required this.rewardCoins,
    this.isClaimed = false,
  });

  bool get isCompleted => current >= target;
}

class GameService extends ChangeNotifier {
  UserModel? currentUser;
  GameStatus gameStatus = GameStatus.idle;
  String currentLanguage = 'uz'; // 'uz', 'ru', 'en'

  // Duel State
  UserModel? opponent;
  int currentRound = 1;
  int totalRounds = 5;
  QuestionModel? currentQuestion;
  int myScore = 0;
  int opponentScore = 0;
  double timeLeft = 10.0;
  Timer? timer;
  String? mySelectedOption;
  String? opponentSelectedOption;
  bool? isMyAnswerCorrect;
  String? roundExplanation;
  String? correctOption;

  // Live Emotes & Reactions
  String? myLiveEmote;
  String? opponentLiveEmote;

  // Custom Friend Room Code
  String? activeRoomCode;

  // Boosters inventory
  int booster5050Count = 3;
  int boosterTimeCount = 2;
  List<String> disabledOptions = [];

  // Data lists
  List<ShopItemModel> shopItems = [];
  List<Map<String, dynamic>> leaderboard = [];
  List<DailyQuest> dailyQuests = [];
  int streakDays = 5;

  GameService() {
    initDemoUser();
    loadShopAndLeaderboard();
    initDailyQuests();
  }

  void initDailyQuests() {
    dailyQuests = [
      DailyQuest(
        id: 1,
        titleUz: "Bugun 3 ta duelda g'alaba qozon",
        titleRu: "Выиграть 3 дуэли сегодня",
        titleEn: "Win 3 duels today",
        target: 3,
        current: 2,
        rewardCoins: 50,
      ),
      DailyQuest(
        id: 2,
        titleUz: "Do'st bilan 1 ta duel o'yna",
        titleRu: "Сыграть 1 дуэль с другом",
        titleEn: "Play 1 duel with a friend",
        target: 1,
        current: 0,
        rewardCoins: 30,
      ),
      DailyQuest(
        id: 3,
        titleUz: "50/50 boosterini 1 marta ishlat",
        titleRu: "Использовать бустер 50/50",
        titleEn: "Use 50/50 booster once",
        target: 1,
        current: 1,
        rewardCoins: 25,
      ),
    ];
  }

  void claimQuest(int id) {
    final q = dailyQuests.firstWhere((element) => element.id == id);
    if (q.isCompleted && !q.isClaimed) {
      q.isClaimed = true;
      currentUser?.coins += q.rewardCoins;
      notifyListeners();
    }
  }

  void sendEmote(String emote) {
    myLiveEmote = emote;
    notifyListeners();
    Timer(const Duration(seconds: 2), () {
      myLiveEmote = null;
      notifyListeners();
    });

    // Simulate opponent reacting sometimes
    if (Random().nextBool()) {
      Timer(const Duration(milliseconds: 900), () {
        List<String> emotes = ["🔥", "😂", "👏", "😱", "😎"];
        opponentLiveEmote = emotes[Random().nextInt(emotes.length)];
        notifyListeners();
        Timer(const Duration(seconds: 2), () {
          opponentLiveEmote = null;
          notifyListeners();
        });
      });
    }
  }

  String createFriendRoom() {
    activeRoomCode = "QD-${1000 + Random().nextInt(9000)}";
    notifyListeners();
    return activeRoomCode!;
  }

  void setLanguage(String lang) {
    currentLanguage = lang;
    notifyListeners();
  }

  void initDemoUser() {
    currentUser = UserModel(
      id: 101,
      username: "aziz_champion",
      fullname: "Azizbek Islomov",
      avatarUrl: "https://api.dicebear.com/7.x/bottts/svg?seed=Aziz",
      coins: 1250,
      energy: 8,
      maxEnergy: 10,
      xp: 450,
      level: 5,
      ratingScore: 1680,
      totalWins: 34,
      totalMatches: 42,
      isVip: true,
    );
    notifyListeners();
  }

  void loadShopAndLeaderboard() {
    shopItems = [
      ShopItemModel(id: 1, title: "500 Coins", description: "Starter Pack", itemType: "COINS", priceUzs: 5000, coinPrice: 0, value: 500, icon: "monetization_on", isPopular: false),
      ShopItemModel(id: 2, title: "2,500 Coins (+20% Bonus)", description: "Most Popular", itemType: "COINS", priceUzs: 20000, coinPrice: 0, value: 2500, icon: "paid", isPopular: true),
      ShopItemModel(id: 3, title: "10,000 Coins", description: "Mega Chest", itemType: "COINS", priceUzs: 70000, coinPrice: 0, value: 10000, icon: "savings", isPopular: false),
      ShopItemModel(id: 4, title: "Full Energy (10 Lives)", description: "Instant Refill", itemType: "ENERGY", priceUzs: 3000, coinPrice: 100, value: 10, icon: "bolt", isPopular: false),
      ShopItemModel(id: 5, title: "24h Unlimited Energy", description: "Play non-stop", itemType: "ENERGY", priceUzs: 10000, coinPrice: 400, value: 24, icon: "all_inclusive", isPopular: true),
      ShopItemModel(id: 6, title: "VIP Pass (1 Month)", description: "Ad-free, 2x Coins, Gold Frame", itemType: "VIP_PASS", priceUzs: 39000, coinPrice: 0, value: 30, icon: "workspace_premium", isPopular: true),
    ];

    leaderboard = [
      {"rank": 1, "username": "jasur_pro", "fullname": "Jasur Alimov", "rating": 2150, "prize": "1 000 000 UZS", "level": 12, "is_vip": true},
      {"rank": 2, "username": "malika_iq", "fullname": "Malika Karimova", "rating": 1980, "prize": "500 000 UZS", "level": 10, "is_vip": false},
      {"rank": 3, "username": "aziz_champion", "fullname": "Azizbek Islomov (You)", "rating": 1680, "prize": "250 000 UZS", "level": 5, "is_vip": true},
      {"rank": 4, "username": "nodir_dev", "fullname": "Nodir Yoqubov", "rating": 1520, "prize": "VIP Pass", "level": 6, "is_vip": false},
      {"rank": 5, "username": "umid_99", "fullname": "Umid Xoliqov", "rating": 1390, "prize": "VIP Pass", "level": 4, "is_vip": false},
    ];
  }

  // --- Duel Matchmaking Simulation ---
  void startSearchingMatch({bool isFriend = false}) {
    if (currentUser != null && currentUser!.energy <= 0) {
      return;
    }
    gameStatus = GameStatus.searching;
    notifyListeners();

    if (currentUser != null && currentUser!.energy > 0) {
      currentUser!.energy -= 1;
    }

    Timer(const Duration(seconds: 3), () {
      opponent = UserModel(
        id: 202,
        username: isFriend ? "dost_akmal" : "alex_smart",
        fullname: isFriend ? "Akmal Vohidov (Do'stingiz)" : "Alexander Smirnov",
        avatarUrl: "https://api.dicebear.com/7.x/bottts/svg?seed=Akmal",
        coins: 800,
        energy: 5,
        maxEnergy: 10,
        xp: 320,
        level: 4,
        ratingScore: 1650,
        totalWins: 22,
        totalMatches: 30,
        isVip: false,
      );

      myScore = 0;
      opponentScore = 0;
      currentRound = 1;
      gameStatus = GameStatus.inRound;
      loadRoundQuestion();
      notifyListeners();
    });
  }

  void loadRoundQuestion() {
    disabledOptions.clear();
    mySelectedOption = null;
    opponentSelectedOption = null;
    isMyAnswerCorrect = null;
    correctOption = null;
    roundExplanation = null;
    timeLeft = 10.0;
    gameStatus = GameStatus.inRound;

    final trilingualQuestions = {
      'uz': [
        QuestionModel(id: 1, text: "Al-Xorazmiy qaysi mashhur ilmiy akademiyada («Bayt ul-hikma») faoliyat yuritgan?", optionA: "Qohira", optionB: "Bag'dod", optionC: "Damashq", optionD: "Buxoro", correctOption: "B", explanation: "Al-Xorazmiy Bag'doddagi 'Donishmandlar uyi'da rahbarlik qilgan."),
        QuestionModel(id: 2, text: "Python dasturlash tili kim tomonidan yaratilgan?", optionA: "Dennis Ritchie", optionB: "Guido van Rossum", optionC: "James Gosling", optionD: "Bjarne Stroustrup", correctOption: "B", explanation: "Python 1991-yilda Gvido van Rossum tomonidan yaratilgan."),
        QuestionModel(id: 3, text: "Dunyodagi eng chuqur chuchuk suvli ko'l qaysi?", optionA: "Kaspiy", optionB: "Baykal", optionC: "Viktoriya", optionD: "Yuqori ko'l", correctOption: "B", explanation: "Baykal ko'lining chuqurligi 1642 metrgacha yetadi."),
        QuestionModel(id: 4, text: "Parij-2024 Olimpiadasida O'zbekiston umumjamoa hisobida nechanchi o'rinni egalladi?", optionA: "13-o'rin", optionB: "10-o'rin", optionC: "15-o'rin", optionD: "8-o'rin", correctOption: "A", explanation: "O'zbekiston 8 ta oltin, 2 ta kumush va 3 ta bronza bilan 13-o'rinni oldi."),
        QuestionModel(id: 5, text: "Amir Temur tavallud topgan Xo'ja Ilg'or qishlog'i qaysi tumanda joylashgan?", optionA: "Yakkabog'", optionB: "Shahrisabz", optionC: "Qamashi", optionD: "Kitob", correctOption: "A", explanation: "Amir Temur Yakkabog' tumanidagi Xo'ja Ilg'or qishlog'ida tug'ilgan."),
      ],
      'ru': [
        QuestionModel(id: 1, text: "В какой знаменитой академии наук («Дом мудрости») работал Аль-Хорезми?", optionA: "Каир", optionB: "Багдад", optionC: "Дамаск", optionD: "Бухара", correctOption: "B", explanation: "Аль-Хорезми руководил «Домом мудрости» в Багдаде."),
        QuestionModel(id: 2, text: "Кто является создателем языка программирования Python?", optionA: "Деннис Ритчи", optionB: "Гвидо ван Россум", optionC: "Джеймс Гослинг", optionD: "Бьёрн Страуструп", correctOption: "B", explanation: "Python был создан в 1991 году Гвидо ван Россумом."),
        QuestionModel(id: 3, text: "Какое озеро является самым глубоким пресноводным озером в мире?", optionA: "Каспийское", optionB: "Байкал", optionC: "Виктория", optionD: "Верхнее", correctOption: "B", explanation: "Глубина озера Байкал достигает 1642 метров."),
        QuestionModel(id: 4, text: "Какое место занял Узбекистан в общем зачете на Олимпиаде-2024 в Париже?", optionA: "13-е место", optionB: "10-е место", optionC: "15-е место", optionD: "8-е место", correctOption: "A", explanation: "Узбекистан занял 13-е место с 8 золотыми медалями."),
        QuestionModel(id: 5, text: "В каком районе находится село Ходжа Илгар, где родился Амир Темур?", optionA: "Яккабагский", optionB: "Шахрисабзский", optionC: "Камашинский", optionD: "Китабский", correctOption: "A", explanation: "Амир Темур родился в Яккабагском районе."),
      ],
      'en': [
        QuestionModel(id: 1, text: "In which famous academy of sciences ('House of Wisdom') did Al-Khwarizmi work?", optionA: "Cairo", optionB: "Baghdad", optionC: "Damascus", optionD: "Bukhara", correctOption: "B", explanation: "Al-Khwarizmi led the 'House of Wisdom' in Baghdad."),
        QuestionModel(id: 2, text: "Who created the Python programming language?", optionA: "Dennis Ritchie", optionB: "Guido van Rossum", optionC: "James Gosling", optionD: "Bjarne Stroustrup", correctOption: "B", explanation: "Python was created in 1991 by Guido van Rossum."),
        QuestionModel(id: 3, text: "Which is the deepest freshwater lake in the world?", optionA: "Caspian Sea", optionB: "Lake Baikal", optionC: "Lake Victoria", optionD: "Lake Superior", correctOption: "B", explanation: "Lake Baikal reaches a maximum depth of 1,642 meters."),
        QuestionModel(id: 4, text: "What place did Uzbekistan achieve in the medal standings at Paris 2024 Olympics?", optionA: "13th Place", optionB: "10th Place", optionC: "15th Place", optionD: "8th Place", correctOption: "A", explanation: "Uzbekistan finished 13th overall with 8 Gold medals."),
        QuestionModel(id: 5, text: "In which district is the village of Khoja Ilgar, birthplace of Amir Timur, located?", optionA: "Yakkabag", optionB: "Shahrisabz", optionC: "Qamashi", optionD: "Kitob", correctOption: "A", explanation: "Amir Timur was born in Yakkabag district."),
      ]
    };

    List<QuestionModel> sampleQuestions = trilingualQuestions[currentLanguage] ?? trilingualQuestions['uz']!;
    currentQuestion = sampleQuestions[(currentRound - 1) % sampleQuestions.length];

    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (timeLeft > 0.1) {
        timeLeft -= 0.1;
        notifyListeners();
      } else {
        timeLeft = 0.0;
        t.cancel();
        evaluateRound();
      }
    });

    double botAnswerTime = 2.0 + Random().nextDouble() * 4.0;
    Timer(Duration(milliseconds: (botAnswerTime * 1000).toInt()), () {
      if (gameStatus == GameStatus.inRound) {
        bool botCorrect = Random().nextBool();
        opponentSelectedOption = botCorrect ? currentQuestion!.correctOption : "C";
        if (botCorrect) {
          opponentScore += 100 + (10 - botAnswerTime).toInt() * 10;
        }
        notifyListeners();
      }
    });

    notifyListeners();
  }

  void submitAnswer(String option) {
    if (mySelectedOption != null || gameStatus != GameStatus.inRound) return;
    mySelectedOption = option;

    if (option == currentQuestion!.correctOption) {
      isMyAnswerCorrect = true;
      myScore += 100 + (timeLeft * 10).toInt();
    } else {
      isMyAnswerCorrect = false;
    }

    notifyListeners();

    Timer(const Duration(milliseconds: 800), () {
      evaluateRound();
    });
  }

  void use5050Booster() {
    if (booster5050Count <= 0 || currentQuestion == null || disabledOptions.isNotEmpty) return;
    booster5050Count--;
    String correct = currentQuestion!.correctOption!;
    List<String> wrong = ["A", "B", "C", "D"]..remove(correct);
    wrong.shuffle();
    disabledOptions = [wrong[0], wrong[1]];
    notifyListeners();
  }

  void useTimeBooster() {
    if (boosterTimeCount <= 0) return;
    boosterTimeCount--;
    timeLeft = min(10.0, timeLeft + 5.0);
    notifyListeners();
  }

  void evaluateRound() {
    timer?.cancel();
    gameStatus = GameStatus.roundResult;
    correctOption = currentQuestion!.correctOption;
    roundExplanation = currentQuestion!.explanation;
    notifyListeners();

    Timer(const Duration(seconds: 3), () {
      if (currentRound < totalRounds) {
        currentRound++;
        loadRoundQuestion();
      } else {
        finishGame();
      }
    });
  }

  void finishGame() {
    gameStatus = GameStatus.finished;
    if (myScore > opponentScore) {
      currentUser!.coins += 50 * (currentUser!.isVip ? 2 : 1);
      currentUser!.xp += 100;
      currentUser!.ratingScore += 25;
      currentUser!.totalWins += 1;
    } else if (myScore < opponentScore) {
      currentUser!.ratingScore = max(0, currentUser!.ratingScore - 15);
      currentUser!.xp += 25;
    }
    currentUser!.totalMatches += 1;
    notifyListeners();
  }

  void purchaseItem(ShopItemModel item) {
    if (item.coinPrice > 0 && currentUser!.coins >= item.coinPrice) {
      currentUser!.coins -= item.coinPrice;
    }
    if (item.itemType == "COINS") {
      currentUser!.coins += item.value;
    } else if (item.itemType == "ENERGY") {
      currentUser!.energy = min(currentUser!.maxEnergy, currentUser!.energy + item.value);
    } else if (item.itemType == "VIP_PASS") {
      currentUser!.isVip = true;
      currentUser!.energy = 20;
      currentUser!.maxEnergy = 20;
    }
    notifyListeners();
  }

  void cancelSearch() {
    gameStatus = GameStatus.idle;
    notifyListeners();
  }

  void resetGame() {
    gameStatus = GameStatus.idle;
    currentRound = 1;
    myScore = 0;
    opponentScore = 0;
    notifyListeners();
  }
}
