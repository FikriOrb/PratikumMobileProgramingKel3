import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:http/http.dart' as http; 
import 'package:provider/provider.dart';
import '../../user_data.dart';

class FlashcardGambarEditPage extends StatefulWidget {
  final String albumId; 

  const FlashcardGambarEditPage({super.key, required this.albumId});

  @override
  State<FlashcardGambarEditPage> createState() => _FlashcardGambarEditPageState();
}

class _FlashcardGambarEditPageState extends State<FlashcardGambarEditPage> {
  final Color bgDark = const Color(0xFF101922);
  final Color bgCard = const Color(0xFF1F2937);
  final Color textGray = const Color(0xFF9CA3AF);
  final Color primaryPurple = const Color(0xFFA855F7);

  final ImagePicker _picker = ImagePicker();

  void _updateItems(List<Map<String, String>> newItems) {
    context.read<UserData>().updateAlbumItems(widget.albumId, newItems);
  }

  List<Map<String, String>> _getCurrentItems() {
    var album = context.read<UserData>().getImageAlbumById(widget.albumId);
    List<Map<String, String>> items = [];
    if (album['items'] != null) {
      for (var item in album['items']) items.add(Map<String, String>.from(item));
    }
    return items;
  }

  // UPDATE: Terima parameter desc
  void _tambahItem(String imgUrl, String name, String desc) {
    List<Map<String, String>> items = _getCurrentItems();
    items.add({
      'img': imgUrl, 
      'name': name,
      'desc': desc // Simpan deskripsi
    });
    context.read<UserData>().incrementImageCount(); 
    _updateItems(items);
  }

  void _hapusItem(int index) {
    List<Map<String, String>> items = _getCurrentItems();
    items.removeAt(index);
    _updateItems(items);
  }

  // --- DIALOG FORM ---
  void _showFormDialog() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController descCtrl = TextEditingController(); // Controller Deskripsi
    
    File? selectedImage; 
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            
            Future<void> pickAndUploadImage() async {
              try {
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setStateDialog(() { selectedImage = File(pickedFile.path); });
                }
              } catch (e) { print("Error pilih gambar: $e"); }
            }

            Future<String?> uploadImageToServer(File image) async {
              try {
                var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2/learnify_api/upload_image.php'));
                var pic = await http.MultipartFile.fromPath('image', image.path);
                request.files.add(pic);
                var streamedResponse = await request.send();
                var response = await http.Response.fromStream(streamedResponse);
                var data = jsonDecode(response.body);
                if (data['success'] == true) return data['url'];
                return null;
              } catch (e) { return null; }
            }

            return Dialog(
              backgroundColor: bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tambah Gambar", style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 20),
                      Text("Foto / Gambar:", style: TextStyle(color: textGray, fontSize: 12)),
                      const SizedBox(height: 8),
                      
                      GestureDetector(
                        onTap: isUploading ? null : pickAndUploadImage,
                        child: Container(
                          height: 150, width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: selectedImage != null ? primaryPurple : Colors.white10, width: 1.5),
                            image: selectedImage != null ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover) : null,
                          ),
                          child: selectedImage == null
                              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_outlined, size: 40, color: textGray), const SizedBox(height: 8), Text("Ketuk untuk pilih gambar", textAlign: TextAlign.center, style: GoogleFonts.lexend(color: textGray, fontSize: 12))])
                              : Stack(children: [Positioned(right: 8, top: 8, child: CircleAvatar(backgroundColor: Colors.black54, radius: 16, child: Icon(Icons.edit, size: 16, color: Colors.white)))]),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text("Nama Benda:", style: TextStyle(color: textGray, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Contoh: Kucing")),
                      
                      const SizedBox(height: 16),
                      // --- INPUT DESKRIPSI (BARU) ---
                      Text("Deskripsi / Penjelasan:", style: TextStyle(color: textGray, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: descCtrl, 
                        style: const TextStyle(color: Colors.white), 
                        maxLines: 3, // Bisa multiline
                        decoration: _inputDecoration("Jelaskan tentang gambar ini...")
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: textGray))),
                          
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                            onPressed: isUploading ? null : () async {
                              if (nameCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama benda harus diisi!")));
                                return;
                              }
                              if (selectedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih gambar dulu!")));
                                return;
                              }

                              setStateDialog(() => isUploading = true);
                              String? uploadedUrl = await uploadImageToServer(selectedImage!);
                              setStateDialog(() => isUploading = false);

                              if (uploadedUrl != null) {
                                // Simpan Nama & Deskripsi
                                _tambahItem(uploadedUrl, nameCtrl.text, descCtrl.text);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil disimpan!"), backgroundColor: Colors.green));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal upload gambar."), backgroundColor: Colors.red));
                              }
                            },
                            child: isUploading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text("Simpan", style: GoogleFonts.lexend(color: Colors.white)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textGray.withOpacity(0.5)),
      filled: true, fillColor: Colors.black.withOpacity(0.2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, child) {
        var album = userData.getImageAlbumById(widget.albumId);
        if (album.isEmpty) return const Scaffold(body: Center(child: Text("Album tidak ditemukan")));
        
        String judulTopik = album['title'];
        List<Map<String, String>> items = [];
        if (album['items'] != null) {
          for (var item in album['items']) items.add(Map<String, String>.from(item));
        }

        return Scaffold(
          backgroundColor: bgDark,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(20), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white))),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Kelola Gambar", style: GoogleFonts.lexend(fontSize: 12, color: textGray)), Text(judulTopik, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis)])),
                      InkWell(onTap: _showFormDialog, borderRadius: BorderRadius.circular(20), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: primaryPurple, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white))),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(child: Text("Belum ada gambar.", style: TextStyle(color: textGray)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (c, i) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                              child: Row(
                                children: [
                                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item['img']!, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.white24)))),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name']!, style: GoogleFonts.lexend(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                                        // Preview Deskripsi Kecil
                                        Text(item['desc'] ?? "Tidak ada deskripsi", style: GoogleFonts.lexend(fontSize: 12, color: textGray), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  IconButton(icon: Icon(Icons.delete, color: textGray), onPressed: () => _hapusItem(index)),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}