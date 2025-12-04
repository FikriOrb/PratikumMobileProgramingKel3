import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  // ==========================================================
  // 1. DATA USER & EKONOMI
  // ==========================================================
  int _coins = 1000;
  String _username = "User Baru";
  String _email = "user@learnify.com";
  String _bio = "Siap belajar hal baru!";
  String _profileImage = "https://ui-avatars.com/api/?name=User+Baru&background=random&size=128";

  // Booster Data
  DateTime? _multiplierEndTime;
  int _freezeStreakCount = 0;

  // Getters
  int _id = 0; // TAMBAHKAN INI
  int get id => _id; 
  int get coins => _coins;
  int get streak => _streak;
  String get username => _username;
  String get email => _email;
  String get bio => _bio;
  String get profileImage => _profileImage;
  bool get isMultiplierActive => _multiplierEndTime != null && DateTime.now().isBefore(_multiplierEndTime!);
  int get freezeStreakCount => _freezeStreakCount;

  // Streak Logic
  int _streak = 0;
  void incrementStreak() { _streak++; notifyListeners(); }
  void resetStreak() { _streak = 0; notifyListeners(); }

  bool useFreezeStreak() {
    if (_freezeStreakCount > 0) {
      _freezeStreakCount--;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ==========================================================
  // 2. DATA FLASHCARD CATATAN (NOTES)
  // ==========================================================
  List<Map<String, dynamic>> _flashcardDecks = [
    {
      'id': 'sample_note_1',
      'title': 'Contoh: Biologi Dasar',
      'cards': [
        'Sel adalah unit terkecil kehidupan.',
        'Mitokondria berfungsi sebagai penghasil energi.',
        'DNA membawa informasi genetik makhluk hidup.'
      ]
    }
  ];

  List<Map<String, dynamic>> get flashcardDecks => _flashcardDecks;

  Map<String, dynamic> getDeckById(String id) {
    return _flashcardDecks.firstWhere((d) => d['id'] == id, orElse: () => {});
  }

  void addDeck(String title) {
    _flashcardDecks.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'cards': <String>[],
    });
    notifyListeners();
  }

  void editDeckTitle(String id, String newTitle) {
    var deck = _flashcardDecks.firstWhere((d) => d['id'] == id);
    deck['title'] = newTitle;
    notifyListeners();
  }

  void deleteDeck(String id) {
    _flashcardDecks.removeWhere((d) => d['id'] == id);
    notifyListeners();
  }

  void reorderDecks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _flashcardDecks.removeAt(oldIndex);
    _flashcardDecks.insert(newIndex, item);
    notifyListeners();
  }

  void addCardToDeck(String deckId, String content) {
    var deck = _flashcardDecks.firstWhere((d) => d['id'] == deckId);
    (deck['cards'] as List<String>).add(content);
    incrementNoteCount(); 
    notifyListeners();
  }

  void editCardInDeck(String deckId, int cardIndex, String newContent) {
    var deck = _flashcardDecks.firstWhere((d) => d['id'] == deckId);
    (deck['cards'] as List<String>)[cardIndex] = newContent;
    notifyListeners();
  }

  void deleteCardFromDeck(String deckId, int cardIndex) {
    var deck = _flashcardDecks.firstWhere((d) => d['id'] == deckId);
    (deck['cards'] as List<String>).removeAt(cardIndex);
    notifyListeners();
  }

  // ==========================================================
  // 3. DATA FLASHCARD QnA (KUIS)
  // ==========================================================
  List<Map<String, dynamic>> _quizzes = [
    {
      'id': 'sample_quiz_1',
      'title': 'Contoh: Pengetahuan Umum',
      'questions': [
        {'q': 'Ibukota Indonesia?', 'a': 'Jakarta'},
        {'q': 'Berapa kaki laba-laba?', 'a': 'Delapan'},
        {'q': 'Warna langit saat cerah?', 'a': 'Biru'},
      ]
    }
  ];

  List<Map<String, dynamic>> get quizzes => _quizzes;

  Map<String, dynamic> getQuizById(String id) {
    return _quizzes.firstWhere((q) => q['id'] == id, orElse: () => {});
  }

  void addQuiz(String title) {
    _quizzes.add({
      'id': "quiz_${DateTime.now().millisecondsSinceEpoch}",
      'title': title,
      'questions': <Map<String, String>>[],
    });
    notifyListeners();
  }

  void editQuizTitle(String id, String newTitle) {
    var quiz = _quizzes.firstWhere((q) => q['id'] == id);
    quiz['title'] = newTitle;
    notifyListeners();
  }

  void deleteQuiz(String id) {
    _quizzes.removeWhere((q) => q['id'] == id);
    notifyListeners();
  }

  void reorderQuizzes(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _quizzes.removeAt(oldIndex);
    _quizzes.insert(newIndex, item);
    notifyListeners();
  }

  void updateQuizQuestions(String quizId, List<Map<String, String>> newQuestions) {
    var quiz = _quizzes.firstWhere((q) => q['id'] == quizId);
    quiz['questions'] = newQuestions;
    notifyListeners();
  }

  // ==========================================================
  // 4. DATA FLASHCARD GAMBAR (ALBUM)
  // ==========================================================
  List<Map<String, dynamic>> _imageAlbums = [
    {
      'id': 'sample_album',
      'title': 'Contoh: Hewan',
      'items': [
        {
          'img': 'https://cdn.pixabay.com/photo/2014/11/30/14/11/cat-551554_1280.jpg', 
          'name': 'Kucing',
          'desc': 'Kucing adalah hewan mamalia karnivora yang sering dijadikan hewan peliharaan. Mereka dikenal dengan kemampuan berburu dan sifatnya yang mandiri.'
        },
        {
          'img': 'https://cdn.pixabay.com/photo/2016/12/13/05/15/puppy-1903313_1280.jpg', 
          'name': 'Anjing',
          'desc': 'Anjing adalah hewan sosial yang setia. Mereka memiliki indra penciuman yang sangat tajam dan sering membantu manusia dalam berbagai tugas.'
        },
      ]
    }
  ];

  List<Map<String, dynamic>> get imageAlbums => _imageAlbums;

  Map<String, dynamic> getImageAlbumById(String id) {
    return _imageAlbums.firstWhere((a) => a['id'] == id, orElse: () => {});
  }

  void addImageAlbum(String title) {
    _imageAlbums.add({
      'id': "album_${DateTime.now().millisecondsSinceEpoch}",
      'title': title,
      'items': <Map<String, String>>[],
    });
    notifyListeners();
  }

  void editImageAlbumTitle(String id, String newTitle) {
    var album = _imageAlbums.firstWhere((a) => a['id'] == id);
    album['title'] = newTitle;
    notifyListeners();
  }

  void deleteImageAlbum(String id) {
    _imageAlbums.removeWhere((a) => a['id'] == id);
    notifyListeners();
  }

  void reorderImageAlbums(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _imageAlbums.removeAt(oldIndex);
    _imageAlbums.insert(newIndex, item);
    notifyListeners();
  }

  void updateAlbumItems(String albumId, List<Map<String, String>> newItems) {
    var album = _imageAlbums.firstWhere((a) => a['id'] == albumId);
    album['items'] = newItems;
    notifyListeners();
  }

  // ==========================================================
  // 5. INVENTORY & MISI
  // ==========================================================
  List<Map<String, dynamic>> skins = [
    {'id': 'default', 'name': 'Default', 'color': const Color(0xFF1F2937), 'border': Colors.white10, 'textColor': Colors.white, 'isOwned': true, 'isEquipped': true},
    {'id': 'pastel', 'name': 'Tema Pastel', 'color': const Color(0xFFFDF2F8), 'border': Colors.pinkAccent, 'textColor': Colors.pink, 'isOwned': false, 'isEquipped': false},
    {'id': 'dark', 'name': 'Mode Gelap', 'color': const Color(0xFF000000), 'border': Colors.grey, 'textColor': Colors.white, 'isOwned': false, 'isEquipped': false},
    {'id': 'galaxy', 'name': 'Tema Galaksi', 'color': const Color(0xFF1E1B4B), 'border': Colors.cyanAccent, 'textColor': Colors.cyanAccent, 'isOwned': false, 'isEquipped': false},
    {'id': 'vintage', 'name': 'Kertas Vintage', 'color': const Color(0xFFFEF3C7), 'border': Colors.orange, 'textColor': Colors.brown, 'isOwned': false, 'isEquipped': false},
  ];

  Map<String, dynamic> get activeSkin => skins.firstWhere((s) => s['isEquipped'] == true, orElse: () => skins[0]);

  List<Map<String, dynamic>> badges = [
    {'id': 'new_user', 'title': 'Pengguna Baru', 'icon': Icons.person_outline, 'color': Colors.blueAccent, 'isOwned': true, 'isEquipped': true},
    {'id': 'book_worm', 'title': 'Si Kutu Buku', 'icon': Icons.menu_book, 'color': Colors.green, 'isOwned': false, 'isEquipped': false},
    {'id': 'memory_master', 'title': 'Master Hafalan', 'icon': Icons.psychology, 'color': Colors.purple, 'isOwned': false, 'isEquipped': false},
    {'id': 'record_breaker', 'title': 'Pemecah Rekor', 'icon': Icons.emoji_events, 'color': Colors.amber, 'isOwned': false, 'isEquipped': false},
    {'id': 'streak_king', 'title': 'Sang Streaker', 'icon': Icons.local_fire_department, 'color': Colors.redAccent, 'isOwned': false, 'isEquipped': false},
    {'id': 'expert', 'title': 'Ahli Materi', 'icon': Icons.school, 'color': Colors.blue, 'isOwned': false, 'isEquipped': false},
  ];

  List<Map<String, dynamic>> get equippedBadges => badges.where((b) => b['isEquipped'] == true).toList();

  void reorderBadges(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    var equipped = badges.where((b) => b['isEquipped'] == true).toList();
    var unequipped = badges.where((b) => b['isEquipped'] == false).toList();
    var item = equipped.removeAt(oldIndex);
    equipped.insert(newIndex, item);
    badges = [...equipped, ...unequipped];
    notifyListeners();
  }

  void equipSkin(String id) {
    for (var s in skins) { s['isEquipped'] = (s['id'] == id); }
    notifyListeners();
  }

  void toggleBadgeEquip(String id) {
    int index = badges.indexWhere((b) => b['id'] == id);
    if (index != -1) { badges[index]['isEquipped'] = !badges[index]['isEquipped']; notifyListeners(); }
  }

  String buyShopItem(String category, String id, int price, String name) {
    if (_coins < price) return "Koin tidak cukup!";
    bool transactionSuccess = false;

    if (category == 'booster') {
      if (id == 'multiplier') {
        if (isMultiplierActive) return "Booster masih aktif!";
        _multiplierEndTime = DateTime.now().add(const Duration(hours: 24));
        transactionSuccess = true;
      } else if (id == 'freeze') {
        _freezeStreakCount++;
        transactionSuccess = true;
      }
    } else if (category == 'skin') {
      int index = skins.indexWhere((s) => s['id'] == id);
      if (index != -1 && !skins[index]['isOwned']) { skins[index]['isOwned'] = true; transactionSuccess = true; } 
      else { return "Item sudah dimiliki."; }
    } else if (category == 'badge') {
      int index = badges.indexWhere((b) => b['id'] == id);
      if (index != -1 && !badges[index]['isOwned']) { badges[index]['isOwned'] = true; transactionSuccess = true; } 
      else { return "Item sudah dimiliki."; }
    }

    if (transactionSuccess) {
      _coins -= price;
      incrementPurchase();
      notifyListeners();
      return "success";
    }
    return "Gagal membeli.";
  }

  void addCoins(int amount) {
    if (isMultiplierActive) amount *= 2;
    _coins += amount;
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (_coins >= amount) {
      _coins -= amount;
      incrementPurchase();
      notifyListeners();
      return true;
    }
    return false;
  }

  void updateProfile(String name, String email, String bio, String image) {
    _username = name; _email = email; _bio = bio; _profileImage = image;
    notifyListeners();
  }

  List<Map<String, dynamic>> _missions = [
    {'id': 'quiz_correct', 'title': 'Jenius Kuis', 'desc': 'Jawab benar {target} soal.', 'current': 0, 'target': 5, 'reward': 20, 'level': 1, 'icon': Icons.psychology},
    {'id': 'add_note', 'title': 'Penulis Handal', 'desc': 'Buat {target} catatan.', 'current': 0, 'target': 3, 'reward': 15, 'level': 1, 'icon': Icons.edit_note},
    {'id': 'study_time', 'title': 'Fokus Belajar', 'desc': 'Belajar {target} menit.', 'current': 0, 'target': 10, 'reward': 25, 'level': 1, 'icon': Icons.timer},
    {'id': 'add_image', 'title': 'Kolektor Visual', 'desc': 'Tambah {target} gambar.', 'current': 0, 'target': 3, 'reward': 15, 'level': 1, 'icon': Icons.image},
    {'id': 'buy_item', 'title': 'Sultan Belanja', 'desc': 'Beli {target} item.', 'current': 0, 'target': 1, 'reward': 50, 'level': 1, 'icon': Icons.shopping_bag},
  ];

  List<Map<String, dynamic>> get missions => _missions;

  void _incrementProgress(String missionId, int amount) {
    int index = _missions.indexWhere((m) => m['id'] == missionId);
    if (index != -1) {
      _missions[index]['current'] += amount;
      notifyListeners();
    }
  }

  void incrementQnACorrect() => _incrementProgress('quiz_correct', 1);
  void incrementNoteCount() => _incrementProgress('add_note', 1);
  void addStudyDuration(int minutes) => _incrementProgress('study_time', minutes);
  void incrementImageCount() => _incrementProgress('add_image', 1);
  void incrementPurchase() => _incrementProgress('buy_item', 1);

  void claimMissionReward(int index) {
    var mission = _missions[index];
    if (mission['current'] >= mission['target']) {
      addCoins(mission['reward']);
      mission['level'] += 1;
      int addTarget = (mission['id'] == 'study_time' ? 10 : (mission['id'] == 'buy_item' ? 1 : 3));
      if (mission['id'] == 'buy_item') {
         if (mission['target'] == 1) mission['target'] = 3;
         else mission['target'] += 3;
      } else {
         mission['target'] += addTarget;
      }
      mission['reward'] += 10;
      notifyListeners();
    }
  }

  // ==========================================================
  // 6. SETTINGS: NOTIFIKASI & PRIVASI
  // ==========================================================
  bool _studyReminder = true;
  bool _soundEffects = false;

  bool get studyReminder => _studyReminder;
  bool get soundEffects => _soundEffects;

  void toggleStudyReminder(bool value) { _studyReminder = value; notifyListeners(); }
  void toggleSoundEffects(bool value) { _soundEffects = value; notifyListeners(); }

  String _visibility = "Publik";
  bool _isOnline = true;
  List<String> _blockedUsers = ["Budi Santoso", "User Asing 123"];

  String get visibility => _visibility;
  bool get isOnline => _isOnline;
  List<String> get blockedUsers => _blockedUsers;

  void setVisibility(String value) { _visibility = value; notifyListeners(); }
  void toggleOnlineStatus(bool value) { _isOnline = value; notifyListeners(); }
  
  void unblockUser(int index) {
    _blockedUsers.removeAt(index);
    notifyListeners();
  }

  // ==========================================================
  // 7. KEAMANAN (PASSWORD)
  // ==========================================================
  String _password = "123456"; 

  bool validatePassword(String input) {
    return input == _password;
  }

  void changePassword(String newPass) {
    _password = newPass;
    notifyListeners();
  }

  // ==========================================================
  // 8. HAPUS AKUN (RESET TOTAL)
  // ==========================================================
  void deleteAccount() {
    // 1. Reset Profil
    _username = "User Baru";
    _email = "user@learnify.com";
    _bio = "Siap belajar hal baru!";
    _profileImage = "https://ui-avatars.com/api/?name=User+Baru&background=random&size=128";
    _coins = 1000;
    _streak = 0;
    _password = "123456"; 

    // 2. Reset Inventory
    for (var s in skins) {
      s['isOwned'] = (s['id'] == 'default');
      s['isEquipped'] = (s['id'] == 'default');
    }
    for (var b in badges) {
      b['isOwned'] = (b['id'] == 'new_user');
      b['isEquipped'] = (b['id'] == 'new_user');
    }

    // 3. Reset Data Belajar (Kembali ke Sample)
    _flashcardDecks = [
      {'id': 'sample_note_1', 'title': 'Contoh: Biologi Dasar', 'cards': ['Sel adalah unit terkecil kehidupan.', 'Mitokondria berfungsi sebagai penghasil energi.', 'DNA membawa informasi genetik makhluk hidup.']}
    ];
    
    _quizzes = [
      {'id': 'sample_quiz_1', 'title': 'Contoh: Pengetahuan Umum', 'questions': [{'q': 'Ibukota Indonesia?', 'a': 'Jakarta'}, {'q': 'Berapa kaki laba-laba?', 'a': 'Delapan'}, {'q': 'Warna langit saat cerah?', 'a': 'Biru'}]}
    ];

    _imageAlbums = [
      {'id': 'sample_album', 'title': 'Contoh: Hewan', 'items': [{'img': 'https://cdn.pixabay.com/photo/2014/11/30/14/11/cat-551554_1280.jpg', 'name': 'Kucing'}, {'img': 'https://cdn.pixabay.com/photo/2016/12/13/05/15/puppy-1903313_1280.jpg', 'name': 'Anjing'}]}
    ];

    // 4. Reset Misi
    for (var m in _missions) {
      m['current'] = 0;
      m['level'] = 1;
      // Note: Target & Reward disederhanakan resetnya
    }

    notifyListeners();
  }
  // ==========================================================
  // 10. FUNGSI KHUSUS LOGIN API (BARU)
  // ==========================================================
  void setUserDataFromApi(Map<String, dynamic> data) {
    _id = int.tryParse(data['id'].toString()) ?? 0; // SIMPAN ID
    _username = data['username'] ?? "User";
    _email = data['email'] ?? "";
    _bio = data['bio'] ?? "Siap belajar!";
    _profileImage = data['profile_image'] ?? "https://ui-avatars.com/api/?name=User";
    _coins = int.tryParse(data['coins'].toString()) ?? 0;
    
    notifyListeners();
  }
}