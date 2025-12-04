import 'dart:async'; // Wajib untuk Timer
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Import Halaman Fitur
import 'catatan/flashcard_catatan.dart';
import 'qna/flashcard_qna.dart';
import 'gambar/flashcard_gambar.dart';

// Import Halaman Navbar
import '../pencapaian/pencapaian_page.dart';
import '../toko/toko_page.dart';
import '../profil/profil_page.dart';
import '../user_data.dart'; 

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _selectedIndex = 0; 

  // --- VARIABEL LOGIKA STREAK ---
  int _nextDayIndex = 0; 
  int _weeksPassed = 0;

  // Timer 1: Cooldown (Waktu tunggu hadiah berikutnya)
  Timer? _cooldownTimer;
  Duration _timeLeft = const Duration(); 
  bool _isCooldown = false; 

  // Timer 2: Risk (Waktu hangus/reset jika telat klaim)
  Timer? _riskTimer;
  int _riskSeconds = 10; // Batas 10 Detik
  bool _isRisk = false; 

  // Scroll Controller
  final ScrollController _scrollController = ScrollController();

  // Data Hadiah
  late List<Map<String, dynamic>> dailyRewards;

  // Palet Warna
  final Color primaryColor = const Color(0xFF137FEC);
  final Color bgCardDark = const Color(0xFF1F2937);
  final Color textGray = const Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    dailyRewards = _getInitialRewards(0);
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel(); 
    _riskTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // --- DATA AWAL ---
  List<Map<String, dynamic>> _getInitialRewards(int weekOffset) {
    int startDay = (weekOffset * 7) + 1;
    return [
      {'day': 'Hari-$startDay', 'reward': 5, 'status': 'available', 'color': const Color(0xFF137FEC)}, 
      {'day': 'Hari-${startDay + 1}', 'reward': 10, 'status': 'locked', 'color': const Color(0xFF137FEC)},
      {'day': 'Hari-${startDay + 2}', 'reward': 15, 'status': 'locked', 'color': const Color(0xFF9CA3AF)},
      {'day': 'Hari-${startDay + 3}', 'reward': 20, 'status': 'locked', 'color': const Color(0xFF9CA3AF)},
      {'day': 'Hari-${startDay + 4}', 'reward': 25, 'status': 'locked', 'color': Colors.purpleAccent},
      {'day': 'Hari-${startDay + 5}', 'reward': 30, 'status': 'locked', 'color': const Color(0xFF9CA3AF)},
      {'day': 'Hari-${startDay + 6}', 'reward': 35, 'status': 'locked', 'color': Colors.orange},
    ];
  }

  // --- 1. LOGIKA COOLDOWN (BIRU) ---
  void _startCooldown() {
    _cooldownTimer?.cancel();
    _riskTimer?.cancel(); 

    setState(() {
      _isCooldown = true;
      _isRisk = false; 
      _timeLeft = const Duration(seconds: 5); // Simulasi 5 Detik
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_timeLeft.inSeconds > 0) {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        } else {
          // COOLDOWN SELESAI
          _cooldownTimer?.cancel();
          _isCooldown = false;
          
          if (_nextDayIndex >= dailyRewards.length) {
            // JIKA SUDAH HARI KE-7 SELESAI: MASUK MINGGU BARU
            setState(() {
               _weeksPassed++;
               dailyRewards = _getInitialRewards(_weeksPassed);
               _nextDayIndex = 0;
               dailyRewards[0]['status'] = 'available';
            });
            // [HAPUS NOTIF MINGGU BARU]
          } else {
            // Jika belum, buka hari berikutnya
            dailyRewards[_nextDayIndex]['status'] = 'available';
          }

          // SETELAH TERBUKA -> LANGSUNG HITUNG MUNDUR HANGUS
          _startRiskTimer(); 
        }
      });
    });
  }

  // --- 2. LOGIKA RISK (MERAH) ---
  void _startRiskTimer() {
    _riskTimer?.cancel();
    setState(() { _isRisk = true; _riskSeconds = 10; });

    _riskTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_riskSeconds > 0) {
          _riskSeconds--;
          // [HAPUS NOTIFIKASI 5 DETIK]
        } else {
          _riskTimer?.cancel();
          _attemptReset(); 
        }
      });
    });
  }

  // --- 3. CEK FREEZE STREAK ---
  void _attemptReset() {
    int freezeStock = context.read<UserData>().freezeStreakCount;

    if (freezeStock > 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: bgCardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [const Icon(Icons.ac_unit, color: Colors.cyan), const SizedBox(width: 8), const Text("Streak Beku?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
          content: Text("Streakmu akan hangus! Kamu punya $freezeStock Freeze Streak. Gunakan 1 untuk menyelamatkan streak?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); _executeReset(); }, 
              child: const Text("Biarkan Hangus", style: TextStyle(color: Colors.redAccent))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan), 
              onPressed: () {
                bool success = context.read<UserData>().useFreezeStreak();
                if (success) {
                  Navigator.pop(context);
                  // [HAPUS NOTIF STREAK SELAMAT]
                  _startRiskTimer(); 
                }
              }, 
              child: const Text("Gunakan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ),
          ],
        ),
      );
    } else {
      _executeReset();
    }
  }

  // --- 4. RESET TOTAL ---
  void _executeReset() {
    context.read<UserData>().resetStreak();
    setState(() {
      _isRisk = false;
      _isCooldown = false;
      _weeksPassed = 0;
      dailyRewards = _getInitialRewards(0);
      _nextDayIndex = 0;
      dailyRewards[0]['status'] = 'available';
    });

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => AlertDialog(
        backgroundColor: bgCardDark,
        title: const Text("🔥 Streak Padam!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text("Yah, kamu telat klaim! Streak kembali ke Hari-1.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); }, 
            child: const Text("Coba Lagi", style: TextStyle(color: Colors.white))
          )
        ],
      )
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  // --- FUNGSI KLAIM ---
  void _claimReward(int index) {
    if (dailyRewards[index]['status'] == 'available') {
      _riskTimer?.cancel(); 

      setState(() {
        context.read<UserData>().addCoins(dailyRewards[index]['reward'] as int);
        context.read<UserData>().incrementStreak();
        
        dailyRewards[index]['status'] = 'claimed';
        _nextDayIndex = index + 1; 
        _startCooldown();
      });
      // [HAPUS NOTIFIKASI "Streak Aman!"]
    }
  }

  // --- UI BUILDER ---
  Widget _buildBerandaContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Selamat Datang!", style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.yellow, size: 20), 
                    const SizedBox(width: 4), 
                    Consumer<UserData>(
                      builder: (context, userData, child) {
                        return Text("${userData.coins} Coins", style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold));
                      },
                    ),
                  ]
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgCardDark.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: Row(
              children: [
                Consumer<UserData>(builder: (context, userData, child) { return CircleAvatar(radius: 28, backgroundImage: NetworkImage(userData.profileImage)); }),
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer<UserData>(builder: (context, userData, child) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(userData.username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(userData.bio, style: TextStyle(fontSize: 14, color: textGray)),
                      
                      if (userData.equippedBadges.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: userData.equippedBadges.take(3).map((b) {
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: b['color'].withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: b['color'].withOpacity(0.3))),
                                child: Row(children: [
                                  Icon(b['icon'], size: 12, color: b['color']),
                                  const SizedBox(width: 4),
                                  Text(b['title'].split(' ')[0], style: TextStyle(color: b['color'], fontSize: 10, fontWeight: FontWeight.bold))
                                ]),
                              );
                            }).toList(),
                          ),
                        )
                      ]
                    ]);
                  }),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Masuk Harian
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Masuk Harian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  // Indikator Timer
                  if (_isCooldown)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [const Icon(Icons.hourglass_top, size: 14, color: Colors.blueAccent), const SizedBox(width: 4), Text("Buka: ${_formatDuration(_timeLeft)}", style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold))]),
                    )
                  else if (_isRisk)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent)),
                      child: Row(children: [const Icon(Icons.local_fire_department, size: 14, color: Colors.redAccent), const SizedBox(width: 4), Text("Hangus: $_riskSeconds dtk", style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold))]),
                    )
                ],
              ),
              const SizedBox(height: 4),
              _isRisk 
                ? const Text("Cepat klaim sebelum streakmu hilang!", style: TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold))
                : Text("Kumpulkan streak setiap hari!", style: TextStyle(fontSize: 14, color: textGray)),
            ],
          ),
          
          const SizedBox(height: 12),
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(dailyRewards.length, (index) => _buildDailyItem(index: index, data: dailyRewards[index])),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Menu
          Column(children: [
            _buildFlashCard("Flash Card: Catatan", "Belajar dari rangkuman dan catatan penting.", Icons.description, primaryColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FlashcardCatatanPage()))),
            const SizedBox(height: 16),
            _buildFlashCard("Flash Card: QnA", "Uji pemahamanmu dengan tanya jawab.", Icons.quiz, Colors.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FlashcardQnAPage()))),
            const SizedBox(height: 16),
            _buildFlashCard("Flash Card: Gambar", "Perkuat ingatan dengan materi visual.", Icons.image, Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FlashcardGambarPage()))),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [_buildBerandaContent(), const PencapaianPage(), const TokoPage(), const ProfilPage()];
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = screenWidth / 4;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xFF101922), child: CustomPaint(painter: GridPainter()))),
          SafeArea(bottom: false, child: IndexedStack(index: _selectedIndex, children: pages)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              decoration: BoxDecoration(color: const Color(0xFF101922).withOpacity(0.95), border: const Border(top: BorderSide(color: Colors.white10)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -5))]),
              child: Stack(
                children: [
                  AnimatedPositioned(duration: const Duration(milliseconds: 300), curve: Curves.elasticOut, left: _selectedIndex * itemWidth, top: 0, child: Container(width: itemWidth, height: 80, alignment: Alignment.topCenter, child: Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.8), blurRadius: 12)])))),
                  AnimatedPositioned(duration: const Duration(milliseconds: 300), curve: Curves.easeOut, left: _selectedIndex * itemWidth, bottom: 0, child: Container(width: itemWidth, height: 80, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [primaryColor.withOpacity(0.0), primaryColor.withOpacity(0.15)])))),
                  Row(children: [_buildNavItem(Icons.home_rounded, "Beranda", 0), _buildNavItem(Icons.emoji_events_rounded, "Pencapaian", 1), _buildNavItem(Icons.storefront_rounded, "Toko", 2), _buildNavItem(Icons.person_rounded, "Profil", 3)]),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return Expanded(child: GestureDetector(onTap: () => setState(() => _selectedIndex = index), behavior: HitTestBehavior.opaque, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [AnimatedContainer(duration: const Duration(milliseconds: 200), padding: EdgeInsets.all(isActive ? 10 : 0), decoration: BoxDecoration(color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent, shape: BoxShape.circle), child: AnimatedScale(scale: isActive ? 1.2 : 1.0, duration: const Duration(milliseconds: 200), child: Icon(icon, color: isActive ? primaryColor : Colors.grey, size: 26))), const SizedBox(height: 4), AnimatedDefaultTextStyle(duration: const Duration(milliseconds: 200), style: GoogleFonts.lexend(fontSize: 10, color: isActive ? primaryColor : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal), child: Text(label))])));
  }

  Widget _buildDailyItem({required int index, required Map<String, dynamic> data}) {
    String status = data['status']; 
    Color baseColor = data['color'];
    bool isClaimed = status == 'claimed';
    bool isAvailable = status == 'available';
    bool isNextWaiting = (index == _nextDayIndex);
    if (_isCooldown && _nextDayIndex >= dailyRewards.length) isNextWaiting = false;

    bool showRiskBorder = _isRisk && isAvailable;

    Color borderColor = (_isRisk && isAvailable) ? Colors.redAccent : Colors.transparent;
    Color boxColor = isClaimed ? baseColor.withOpacity(0.2) : (isAvailable ? baseColor : const Color(0xFF1F2937).withOpacity(0.5));
    Color textColor = isAvailable ? Colors.white : (isClaimed ? baseColor : Colors.grey);

    return GestureDetector(
      onTap: () {
        if (isNextWaiting && _isCooldown) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sabar ya, hadiah bisa diambil besok!")));
        } else {
           _claimReward(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80, margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(12), boxShadow: isAvailable ? [BoxShadow(color: baseColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : null, border: Border.all(color: borderColor, width: showRiskBorder ? 2 : 1)),
        child: Column(children: [
          Text(data['day'], style: TextStyle(fontSize: 10, color: isAvailable ? Colors.white : Colors.grey)), 
          const SizedBox(height: 8), 
          Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: isClaimed ? baseColor.withOpacity(0.3) : Colors.white.withOpacity(0.1), shape: BoxShape.circle), 
            child: (isNextWaiting && _isCooldown) 
              ? const Icon(Icons.hourglass_top, color: Colors.white, size: 18) 
              : Icon(isClaimed ? Icons.check : Icons.monetization_on, color: isClaimed ? baseColor : (isAvailable ? Colors.yellow : Colors.grey), size: 20)
          ), 
          const SizedBox(height: 8), 
          (isNextWaiting && _isCooldown)
              ? Text(_formatDuration(_timeLeft), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)) 
              : Text(isClaimed ? "Diklaim" : "+${data['reward']}", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12))
        ]),
      ),
    );
  }

  Widget _buildFlashCard(String title, String subtitle, IconData icon, Color themeColor, {required VoidCallback onTap}) {
    return BouncingButton(onTap: onTap, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: themeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: themeColor.withOpacity(0.3))), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 28)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: themeColor, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: themeColor.withOpacity(0.9), fontSize: 13, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis)]))])));
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    const double gridSize = 24.0;
    for (double x = 0; x < size.width; x += gridSize) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += gridSize) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BouncingButton({super.key, required this.child, required this.onTap});
  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut, child: widget.child),
    );
  }
}