import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../user_data.dart'; // Import UserData

class PrivacyPage extends StatelessWidget { // Jadi Stateless karena state di Provider
  const PrivacyPage({super.key});

  final Color bgDark = const Color(0xFF101922);
  final Color bgCardDark = const Color(0xFF1F2937);
  final Color primaryColor = const Color(0xFF137FEC);

  // --- FUNGSI PILIH VISIBILITAS ---
  void _showVisibilityDialog(BuildContext context, UserData userData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Siapa yang bisa melihat profilmu?", style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              _buildRadioOption(context, userData, "Publik", "Semua orang bisa melihat"),
              _buildRadioOption(context, userData, "Teman", "Hanya teman yang bisa melihat"),
              _buildRadioOption(context, userData, "Pribadi", "Hanya saya yang bisa melihat"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadioOption(BuildContext context, UserData userData, String value, String subtitle) {
    return ListTile(
      title: Text(value, style: GoogleFonts.lexend(color: Colors.white)),
      subtitle: Text(subtitle, style: GoogleFonts.lexend(color: Colors.grey, fontSize: 12)),
      trailing: userData.visibility == value ? Icon(Icons.check_circle, color: primaryColor) : null,
      onTap: () {
        userData.setVisibility(value); // Simpan ke Provider
        Navigator.pop(context);
      },
    );
  }

  // --- FUNGSI DAFTAR BLOKIR ---
  void _showBlockedList(BuildContext context, UserData userData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        // Kita butuh Consumer lagi di sini agar list update real-time saat dihapus
        return Consumer<UserData>(
          builder: (context, ud, child) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text("Daftar Blokir", style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ud.blockedUsers.isEmpty 
                    ? Center(child: Text("Tidak ada pengguna diblokir", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: ud.blockedUsers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                            title: Text(ud.blockedUsers[index], style: const TextStyle(color: Colors.white)),
                            trailing: TextButton(
                              onPressed: () => ud.unblockUser(index), // Hapus dari Provider
                              child: const Text("Buka Blokir", style: TextStyle(color: Colors.redAccent)),
                            ),
                          );
                        },
                      ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Privasi",
          style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<UserData>( // Gunakan Consumer
        builder: (context, userData, child) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // 1. Visibilitas Profil
              _buildItem(
                "Visibilitas Profil", 
                userData.visibility, 
                Icons.visibility, 
                onTap: () => _showVisibilityDialog(context, userData)
              ),
              
              // 2. Status Online
              _buildSwitchItem(
                "Status Online", 
                userData.isOnline ? "Aktif" : "Disembunyikan", 
                Icons.circle_notifications,
                userData.isOnline,
                (val) => userData.toggleOnlineStatus(val)
              ),
              
              // 3. Daftar Blokir
              _buildItem(
                "Daftar Blokir", 
                "${userData.blockedUsers.length} Pengguna", 
                Icons.block,
                onTap: () => _showBlockedList(context, userData)
              ),
              
              const SizedBox(height: 24),
              
              _buildItem("Kebijakan Privasi", "", Icons.privacy_tip_outlined, onTap: (){}),
              _buildItem("Ketentuan Layanan", "", Icons.description_outlined, onTap: (){}),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(String title, String subtitle, IconData icon, {required VoidCallback onTap, bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bgCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDanger ? Colors.redAccent.withOpacity(0.5) : Colors.white10),
        ),
        child: ListTile(
          leading: Icon(icon, color: isDanger ? Colors.redAccent : Colors.white70),
          title: Text(title, style: GoogleFonts.lexend(color: isDanger ? Colors.redAccent : Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          trailing: subtitle.isNotEmpty 
              ? Text(subtitle, style: GoogleFonts.lexend(color: Colors.white54, fontSize: 12))
              : const Icon(Icons.chevron_right, color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.white70),
        title: Text(title, style: GoogleFonts.lexend(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: GoogleFonts.lexend(color: Colors.white54, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
      ),
    );
  }
}