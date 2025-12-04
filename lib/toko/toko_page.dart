import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; 
import '../user_data.dart'; 

class TokoPage extends StatefulWidget {
  const TokoPage({super.key});

  @override
  State<TokoPage> createState() => _TokoPageState();
}

class _TokoPageState extends State<TokoPage> {
  final Color primaryColor = const Color(0xFF137FEC);
  final Color bgDark = const Color(0xFF101922);
  final Color bgCardDark = const Color(0xFF1F2937);
  final Color textGray = const Color(0xFF9CA3AF);

  final List<Map<String, dynamic>> _shopItems = [
    {
      'category': 'Skin Kartu',
      'type': 'skin',
      'items': [
        {'id': 'pastel', 'title': 'Tema Pastel', 'desc': 'Tampilan lembut & ceria', 'price': 100, 'icon': Icons.palette, 'color': Colors.pinkAccent},
        {'id': 'dark', 'title': 'Mode Gelap', 'desc': 'Nyaman di mata', 'price': 100, 'icon': Icons.dark_mode, 'color': Colors.grey},
        {'id': 'galaxy', 'title': 'Tema Galaksi', 'desc': 'Jelajahi luar angkasa', 'price': 150, 'icon': Icons.public, 'color': Colors.indigo},
        {'id': 'vintage', 'title': 'Kertas Vintage', 'desc': 'Nuansa klasik', 'price': 150, 'icon': Icons.description, 'color': Colors.orangeAccent},
      ]
    },
    {
      'category': 'Lencana Profil',
      'type': 'badge',
      'items': [
        {'id': 'book_worm', 'title': 'Si Kutu Buku', 'desc': 'Aktif belajar', 'price': 200, 'icon': Icons.menu_book, 'color': Colors.green},
        {'id': 'memory_master', 'title': 'Master Hafalan', 'desc': 'Ingatan super tajam', 'price': 250, 'icon': Icons.psychology, 'color': Colors.purple},
        {'id': 'record_breaker', 'title': 'Pemecah Rekor', 'desc': 'Konsisten rekor', 'price': 300, 'icon': Icons.emoji_events, 'color': Colors.amber},
        {'id': 'streak_king', 'title': 'Sang Streaker', 'desc': 'Streak panjang', 'price': 350, 'icon': Icons.local_fire_department, 'color': Colors.redAccent},
        {'id': 'expert', 'title': 'Ahli Materi', 'desc': 'Master kelas', 'price': 400, 'icon': Icons.school, 'color': Colors.blue},
      ]
    },
    {
      'category': 'Booster',
      'type': 'booster',
      'items': [
        {'id': 'multiplier', 'title': 'Pengganda Poin', 'desc': '2x Poin (24 Jam)', 'price': 75, 'icon': Icons.arrow_upward, 'color': Colors.blue},
        {'id': 'freeze', 'title': 'Freeze Streak', 'desc': 'Amankan streakmu', 'price': 175, 'icon': Icons.ac_unit, 'color': Colors.cyan},
      ]
    }
  ];

  void _showConfirmDialog(String type, String id, String itemName, int price, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: bgCardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text("Konfirmasi Penukaran", style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text("Yakin ingin menukarkan item ini?", textAlign: TextAlign.center, style: GoogleFonts.lexend(color: textGray, fontSize: 14)),
              const SizedBox(height: 4),
              Text("$itemName (-$price Koin)", textAlign: TextAlign.center, style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text("Nanti aja", style: GoogleFonts.lexend(color: textGray)))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        Navigator.pop(context); 
                        _processPurchase(type, id, itemName, price); 
                      },
                      child: Text("Yakin", style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _processPurchase(String type, String id, String itemName, int price) {
    String result = context.read<UserData>().buyShopItem(type, id, price, itemName);

    if (result == "success") {
      _showSuccessDialog(itemName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.redAccent, duration: const Duration(seconds: 2))
      );
    }
  }

  void _showSuccessDialog(String itemName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: bgCardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 60, color: Colors.greenAccent),
              const SizedBox(height: 16),
              Text("Berhasil!", style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text("Selamat kamu menukarkan item\n$itemName", textAlign: TextAlign.center, style: GoogleFonts.lexend(color: textGray, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Oke", style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: GridPainter())),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Toko', style: GoogleFonts.lexend(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.yellow, size: 18),
                            const SizedBox(width: 6),
                            Consumer<UserData>(builder: (context, userData, child) {
                                return Text("${userData.coins}", style: GoogleFonts.lexend(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Consumer<UserData>( 
                      builder: (context, userData, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._shopItems.map((cat) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(padding: const EdgeInsets.only(bottom: 12, top: 8), child: Text(cat['category'], style: GoogleFonts.lexend(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                                  ...cat['items'].map<Widget>((item) => _buildItemCard(item, cat['type'], userData)).toList(),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                            const SizedBox(height: 80),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, String type, UserData userData) {
    bool isOwned = false;
    
    // --- LOGIKA TAMPILAN KHUSUS UNTUK FREEZE STREAK ---
    String displayTitle = item['title'];
    
    if (type == 'skin') {
      isOwned = userData.skins.any((s) => s['id'] == item['id'] && s['isOwned']);
    } else if (type == 'badge') {
      isOwned = userData.badges.any((b) => b['id'] == item['id'] && b['isOwned']);
    } else if (type == 'booster' && item['id'] == 'freeze') {
      // Jika Freeze Streak, tambahkan jumlah xN di judul
      int count = userData.freezeStreakCount;
      if (count > 0) {
        displayTitle = "${item['title']} x$count";
      }
    }
    // --------------------------------------------------
    
    bool canBuy = userData.coins >= item['price'];
    bool multiplierActive = (item['id'] == 'multiplier' && userData.isMultiplierActive);
    
    Color btnColor = primaryColor;
    String btnText = "${item['price']}";
    IconData? btnIcon = Icons.monetization_on;

    if (type != 'booster' && isOwned) {
      btnColor = Colors.green.withOpacity(0.2);
      btnText = "Milik Anda";
      btnIcon = Icons.check;
    } else if (multiplierActive) {
      btnColor = Colors.grey.withOpacity(0.2);
      btnText = "Aktif";
      btnIcon = Icons.timer;
    } else if (!canBuy) {
      btnColor = Colors.white.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgCardDark.withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Container(height: 48, width: 48, decoration: BoxDecoration(color: item['color'].withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(item['icon'], color: item['color'], size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(displayTitle, style: GoogleFonts.lexend(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), 
            const SizedBox(height: 2), 
            Text(item['desc'], style: GoogleFonts.lexend(color: textGray, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)])),
          
          InkWell(
            onTap: (isOwned && type != 'booster') || (multiplierActive) ? null : () => _showConfirmDialog(type, item['id'], item['title'], item['price'], item['icon'], item['color']),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: btnColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isOwned ? Colors.green.withOpacity(0.5) : Colors.transparent)),
              child: Row(children: [Icon(btnIcon, size: 14, color: (isOwned || multiplierActive) ? Colors.white : (canBuy ? Colors.white : Colors.yellow)), const SizedBox(width: 4), Text(btnText, style: GoogleFonts.lexend(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]),
            ),
          ),
        ],
      ),
    );
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