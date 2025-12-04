import 'dart:convert';
import 'dart:io'; // Untuk File
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:http/http.dart' as http; // Import HTTP
import 'package:provider/provider.dart'; 
import '../../../user_data.dart'; 

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color bgDark = const Color(0xFF101922);
  final Color bgCardDark = const Color(0xFF1F2937);
  final Color primaryColor = const Color(0xFF137FEC);
  final Color textGray = const Color(0xFF9CA3AF);

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl; // Email biasanya read-only (tidak diubah sembarangan)
  late TextEditingController _bioCtrl;
  
  File? _imageFile; // File gambar dari galeri
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userData = context.read<UserData>();
    _nameCtrl = TextEditingController(text: userData.username);
    _emailCtrl = TextEditingController(text: userData.email);
    _bioCtrl = TextEditingController(text: userData.bio);
  }

  // 1. FUNGSI BUKA GALERI
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Simpan file di memori HP sementara
      });
    }
  }

  // 2. FUNGSI UPLOAD KE API PHP
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final userData = context.read<UserData>();

    try {
      // Siapkan request Multipart (karena kirim file)
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('http://10.0.2.2/learnify_api/update_profile.php') // GANTI IP SESUAIKAN
      );

      // Isi Data Teks
      request.fields['id'] = userData.id.toString(); // Kirim ID User
      request.fields['username'] = _nameCtrl.text;
      request.fields['bio'] = _bioCtrl.text;

      // Isi File Gambar (Jika user memilih gambar baru)
      if (_imageFile != null) {
        var pic = await http.MultipartFile.fromPath('image', _imageFile!.path);
        request.files.add(pic);
      }

      // Kirim Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      if (data['success'] == true) {
        // Update UserData di aplikasi dengan data baru dari server
        if (!mounted) return;
        context.read<UserData>().setUserDataFromApi(data['data']);
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.red));
      }

    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal terhubung ke server."), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil gambar profil saat ini (URL lama)
    String currentImage = context.read<UserData>().profileImage;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white))),
                  const SizedBox(width: 16),
                  Text("Edit Profil", style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // --- AVATAR DINAMIS ---
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: bgCardDark,
                          // Logika Tampilan:
                          // 1. Jika user baru pilih gambar dari galeri -> Tampilkan File(_imageFile)
                          // 2. Jika tidak -> Tampilkan NetworkImage dari UserData (URL Server)
                          backgroundImage: _imageFile != null 
                              ? FileImage(_imageFile!) as ImageProvider
                              : NetworkImage(currentImage),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: InkWell(
                            onTap: _pickImage, // Buka Galeri
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, border: Border.all(color: bgDark, width: 3)),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Ganti Foto", style: GoogleFonts.lexend(color: primaryColor, fontWeight: FontWeight.bold)),
                    
                    const SizedBox(height: 32),
                    
                    _buildInput("Username", _nameCtrl, icon: Icons.person_outline),
                    const SizedBox(height: 16),
                    // Email kita disable (readOnly) karena biasanya email tidak boleh ganti sembarangan
                    _buildInput("Email", _emailCtrl, icon: Icons.email_outlined, isReadOnly: true),
                    const SizedBox(height: 16),
                    _buildInput("Bio / Status", _bioCtrl, maxLines: 3, icon: Icons.info_outline),
                    
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("Simpan Perubahan", style: GoogleFonts.lexend(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {int maxLines = 1, required IconData icon, bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lexend(color: textGray, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          maxLines: maxLines,
          style: TextStyle(color: isReadOnly ? Colors.grey : Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: textGray),
            filled: true, fillColor: bgCardDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}