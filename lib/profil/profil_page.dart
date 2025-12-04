import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../user_data.dart';
import 'pengaturan/pengaturan.dart';
import 'pengaturan/edit_profil.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final Color primaryColor = const Color(0xFF137FEC);
  final Color bgCardDark = const Color(0xFF1F2937);
  final Color textGray = const Color(0xFF9CA3AF);
  final Color gold = const Color(0xFFFACC15);

  // --- DIALOG KELOLA (PASANG/COPOT) ---
  // (Tidak ada perubahan logika di sini, scroll gridview tetap jalan)
  void _showManageDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCardDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Consumer<UserData>(
          builder: (context, userData, child) {
            var myBadges =
                userData.badges.where((b) => b['isOwned'] == true).toList();

            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text("Pasang / Copot Lencana",
                      style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text("Klik untuk memilih lencana yang aktif.",
                      style: GoogleFonts.lexend(fontSize: 12, color: textGray)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12),
                      itemCount: myBadges.length,
                      itemBuilder: (context, index) {
                        var badge = myBadges[index];
                        bool isEquipped = badge['isEquipped'];
                        return GestureDetector(
                          onTap: () => userData.toggleBadgeEquip(badge['id']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isEquipped
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.black12,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isEquipped
                                      ? primaryColor
                                      : Colors.white10,
                                  width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(badge['icon'],
                                    color: badge['color'], size: 32),
                                const SizedBox(height: 8),
                                Text(badge['title'],
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                        fontSize: 10, color: Colors.white)),
                                if (isEquipped)
                                  const Icon(Icons.check_circle,
                                      color: Colors.blueAccent, size: 16)
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- FUNGSI REORDER ---
  void _onReorder(int oldIndex, int newIndex, UserData userData) {
    userData.reorderBadges(oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        // HAPUS SingleChildScrollView di sini agar layout statis
        child: Consumer<UserData>(
          builder: (context, userData, child) {
            return Column(
              children: [
                // --- BAGIAN STATIS (TIDAK BISA SCROLL) ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profil',
                              style: GoogleFonts.lexend(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsPage())),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: bgCardDark.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.white10)),
                                child: const Icon(Icons.settings_outlined,
                                    color: Colors.white, size: 22)),
                          )
                        ],
                      ),
                      const SizedBox(height: 28),

                      // AVATAR
                      Stack(children: [
                        CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                NetworkImage(userData.profileImage)),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditProfilePage())),
                                child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color(0xFF101922),
                                            width: 3)),
                                    child: const Icon(Icons.edit,
                                        size: 18, color: Colors.white))))
                      ]),
                      const SizedBox(height: 16),
                      Text(userData.username,
                          style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      Text(userData.email,
                          style: GoogleFonts.lexend(
                              color: textGray, fontSize: 14)),

                      const SizedBox(height: 28),

                      // STAT CARDS
                      Row(children: [
                        Expanded(
                            child: _buildStatCard(Icons.monetization_on, gold,
                                "${userData.coins}", "Koin")),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildStatCard(
                                Icons.local_fire_department,
                                Colors.orange,
                                "${userData.streak} Hari",
                                "Streak")),
                      ]),

                      const SizedBox(height: 32),

                      // BADGE HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pencapaian',
                              style: GoogleFonts.lexend(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          InkWell(
                            onTap: () => _showManageDialog(),
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(children: [
                                  Icon(Icons.edit,
                                      size: 14, color: textGray),
                                  const SizedBox(width: 4),
                                  Text("Kelola",
                                      style: GoogleFonts.lexend(
                                          color: textGray, fontSize: 12))
                                ])),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Geser icon garis (≡) untuk atur urutan Top 3.",
                          style: TextStyle(color: textGray, fontSize: 10)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // --- BAGIAN SCROLLABLE (PENCAPAIAN) ---
                // Menggunakan Expanded agar sisa layar dipakai oleh List
                Expanded(
                  child: userData.equippedBadges.isEmpty
                      ? Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                              color: bgCardDark.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10)),
                          child: Column(children: [
                            Icon(Icons.emoji_events_outlined,
                                size: 48, color: textGray.withOpacity(0.3)),
                            Text("Belum ada lencana",
                                style: TextStyle(color: textGray))
                          ]))
                      : ReorderableListView.builder(
                          // Hapus shrinkWrap agar list mengisi ruang Expanded
                          // shrinkWrap: true, <--- HAPUS INI
                          
                          // Ubah physics agar bisa discroll
                          physics: const BouncingScrollPhysics(),
                          
                          // Tambahkan padding di sini agar item paling bawah tidak tertutup nav bar
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          
                          itemCount: userData.equippedBadges.length,
                          onReorder: (oldIndex, newIndex) =>
                              _onReorder(oldIndex, newIndex, userData),
                          itemBuilder: (context, index) {
                            var b = userData.equippedBadges[index];
                            return Container(
                              key: ValueKey(b['id']), // Key Unik Wajib
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: bgCardDark.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10)),
                              child: Row(
                                children: [
                                  // --- TOMBOL GESER AKTIF ---
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          right: 12, top: 8, bottom: 8),
                                      color: Colors.transparent, // Hit test area
                                      child: Icon(Icons.drag_handle,
                                          color: textGray),
                                    ),
                                  ),
                                  // -------------------------------
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: b['color'].withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Icon(b['icon'],
                                          color: b['color'], size: 24)),
                                  const SizedBox(width: 12),
                                  Text(b['title'],
                                      style: GoogleFonts.lexend(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  if (index < 3) ...[
                                    const Spacer(),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: const Text("BERANDA",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold)))
                                  ]
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, Color color, String val, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bgCardDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: textGray))
      ]),
    );
  }
}