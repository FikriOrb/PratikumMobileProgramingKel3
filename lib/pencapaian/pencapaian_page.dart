import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../user_data.dart';

class PencapaianPage extends StatelessWidget {
  const PencapaianPage({super.key});

  final Color bgDark = const Color(0xFF101922);
  final Color bgCardDark = const Color(0xFF1F2937);
  final Color primaryColor = const Color(0xFF137FEC);
  final Color textGray = const Color(0xFF9CA3AF);
  final Color gold = const Color(0xFFFACC15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(child: CustomPaint(painter: GridPainter())),
          
          SafeArea(
            child: Consumer<UserData>(
              builder: (context, userData, child) {
                return Column(
                  children: [
                    // --- HEADER (UPDATED) ---
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Pencapaian", style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text("Selesaikan misi untuk naik level!", style: GoogleFonts.lexend(fontSize: 14, color: textGray)),
                            ],
                          ),
                          
                          // --- INDIKATOR KOIN (Pengganti Piala) ---
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.yellow, size: 20),
                                const SizedBox(width: 6),
                                // Ambil data koin langsung dari Provider (karena kita sudah di dalam Consumer)
                                Text(
                                  "${userData.coins} Coins", 
                                  style: GoogleFonts.lexend(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    // --- LIST MISI ---
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: userData.missions.length,
                        itemBuilder: (context, index) {
                          return _buildMissionCard(context, userData, index);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, UserData userData, int index) {
    final mission = userData.missions[index];
    int current = mission['current'];
    int target = mission['target'];
    bool isCompleted = current >= target;
    
    // Hitung progress
    double progress = (target == 0) ? 0 : (current / target);
    if (progress > 1.0) progress = 1.0;

    String desc = mission['desc'].toString().replaceAll('{target}', target.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCardDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? gold.withOpacity(0.5) : Colors.white10,
        ),
        boxShadow: isCompleted ? [BoxShadow(color: gold.withOpacity(0.1), blurRadius: 12)] : [],
      ),
      child: Row(
        children: [
          // ICON & LEVEL
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted ? gold.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  mission['icon'],
                  color: isCompleted ? gold : primaryColor,
                  size: 24,
                ),
              ),
              // Badge Level
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white24)),
                child: Text("Lv.${mission['level']}", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(width: 16),

          // INFO & PROGRESS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission['title'],
                  style: GoogleFonts.lexend(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.lexend(fontSize: 12, color: textGray),
                ),
                const SizedBox(height: 12),
                
                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black26,
                          color: isCompleted ? gold : primaryColor,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$current/$target",
                      style: GoogleFonts.lexend(fontSize: 10, color: isCompleted ? gold : textGray, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ACTION BUTTON
          if (isCompleted)
            InkWell( // Tombol Klaim
              onTap: () {
                userData.claimMissionReward(index);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Level Up! Target baru telah ditetapkan."), backgroundColor: Colors.green));
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: gold.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))]
                ),
                child: Column(
                  children: [
                    Text("KLAIM", style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                    Text("+${mission['reward']}", style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),
            )
          else
            // Indikator Hadiah
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.monetization_on, size: 14, color: Colors.yellow),
                  Text("${mission['reward']}", style: GoogleFonts.lexend(fontSize: 12, color: Colors.white70)),
                ],
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