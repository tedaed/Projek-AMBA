import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../data/data_buku.dart';
import '../data/data_quiz.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isUploadingBooks = false;
  bool _isUploadingQuizzes = false;
  bool _isSubmitting = false;

  // Controllers untuk Cerita
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _ayatController = TextEditingController();
  final TextEditingController _isiAyatController = TextEditingController();

  // Controllers untuk Detail Item (1 saja)
  final TextEditingController _itemJudulController = TextEditingController();
  final TextEditingController _itemIsiController = TextEditingController();

  String? _selectedImageName;
  String? _selectedAudioName;
  String? _selectedItemImageName;
  String? _selectedItemAudioName;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImageName = result.files.first.name;
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedAudioName = result.files.first.name;
      });
    }
  }

  Future<void> _pickItemImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedItemImageName = result.files.first.name;
      });
    }
  }

  Future<void> _pickItemAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedItemAudioName = result.files.first.name;
      });
    }
  }

  void _showCopyInstructions(
    String imageName,
    String audioName,
    String itemImageName,
    String itemAudioName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📁 Instruksi Copy File'),
        content: SingleChildScrollView(
          child: Text('''
LANGKAH 1: Copy file ke folder assets

GAMBAR CERITA:
File: $imageName
Ke: assets/cerita/images/$imageName

AUDIO NARASI CERITA:
File: $audioName
Ke: assets/cerita/audio/$audioName

GAMBAR DETAIL ITEM:
File: $itemImageName
Ke: assets/cerita/detail/images/$itemImageName

AUDIO DETAIL ITEM:
File: $itemAudioName
Ke: assets/cerita/detail/audio/$itemAudioName

LANGKAH 2: Update pubspec.yaml

Tambahkan:
  - assets/cerita/images/$imageName
  - assets/cerita/audio/$audioName
  - assets/cerita/detail/images/$itemImageName
  - assets/cerita/detail/audio/$itemAudioName

LANGKAH 3: Run command
flutter pub get

LANGKAH 4: Restart app

Data sudah tersimpan di Firestore!
'''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCerita() async {
    final judul = _judulController.text.trim();
    final ayat = _ayatController.text.trim();
    final isiAyat = _isiAyatController.text.trim();
    final itemJudul = _itemJudulController.text.trim();
    final itemIsi = _itemIsiController.text.trim();

    if (judul.isEmpty || ayat.isEmpty || isiAyat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field cerita!')),
      );
      return;
    }

    if (_selectedImageName == null || _selectedAudioName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar dan audio cerita!')),
      );
      return;
    }

    if (itemJudul.isEmpty || itemIsi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field detail item!')),
      );
      return;
    }

    if (_selectedItemImageName == null || _selectedItemAudioName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar dan audio detail item!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String imagePath = 'assets/cerita/images/$_selectedImageName';
      String audioPath = 'assets/cerita/audio/$_selectedAudioName';
      String itemImagePath = 'assets/cerita/detail/images/$_selectedItemImageName';
      String itemAudioPath = 'assets/cerita/detail/audio/$_selectedItemAudioName';

      await FirebaseFirestore.instance.collection('cerita').add({
        'judul': judul,
        'gambar': imagePath,
        'ayat': ayat,
        'isi_ayat': isiAyat,
        'audio': audioPath,
        'detail_item': {
          'judul': itemJudul,
          'isi': itemIsi,
          'gambar': itemImagePath,
          'audio': itemAudioPath,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      _showCopyInstructions(
        _selectedImageName!,
        _selectedAudioName!,
        _selectedItemImageName!,
        _selectedItemAudioName!,
      );

      // Clear form
      _judulController.clear();
      _ayatController.clear();
      _isiAyatController.clear();
      _itemJudulController.clear();
      _itemIsiController.clear();
      setState(() {
        _selectedImageName = null;
        _selectedAudioName = null;
        _selectedItemImageName = null;
        _selectedItemAudioName = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cerita berhasil ditambahkan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _uploadBooks() async {
    setState(() => _isUploadingBooks = true);
    try {
      await FirebaseFirestore.instance.collection('books').doc('data').set({
        'halaman': HALAMAN,
        'detail_item': DETAIL_ITEM,
        'ayat': AYAT,
        'audio_cerita': AUDIO_CERITA,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data buku berhasil diupload!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isUploadingBooks = false);
    }
  }

  Future<void> _uploadQuizzes() async {
    setState(() => _isUploadingQuizzes = true);
    try {
      await FirebaseFirestore.instance.collection('quizzes').doc('data').set({
        'list_quiz': LIST_QUIZ.map((item) => {
              'name': item[0],
              'questions': item[1].map((q) => {
                    'question': q.question,
                    'options': q.options,
                    'correctAnswer': q.correctAnswer,
                  }).toList(),
            }).toList(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data quiz berhasil diupload!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isUploadingQuizzes = false);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _ayatController.dispose();
    _isiAyatController.dispose();
    _itemJudulController.dispose();
    _itemIsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Upload Data ke Firestore',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isUploadingBooks ? null : _uploadBooks,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: _isUploadingBooks
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload Data Buku', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isUploadingQuizzes ? null : _uploadQuizzes,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                ),
                child: _isUploadingQuizzes
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload Data Quiz', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 40),
              const Divider(thickness: 2),
              const SizedBox(height: 20),

              const Text(
                'Tambah Cerita Baru',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '1 Cerita = 1 Detail Item',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // DATA CERITA
              const Text(
                'Data Cerita',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Cerita',
                  hintText: 'Pembuangan Di Mesir',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedImageName ?? 'Belum pilih gambar',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image, size: 18),
                    label: const Text('Pilih'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _ayatController,
                decoration: const InputDecoration(
                  labelText: 'Ayat',
                  hintText: 'Keluaran 2:1-10',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _isiAyatController,
                decoration: const InputDecoration(
                  labelText: 'Isi Ayat',
                  hintText: 'Teks lengkap...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedAudioName ?? 'Belum pilih audio',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickAudio,
                    icon: const Icon(Icons.audiotrack, size: 18),
                    label: const Text('Pilih'),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 16),

              // DETAIL ITEM
              const Text(
                'Detail Item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _itemJudulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Item',
                  hintText: 'Malaikat Tuhan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedItemImageName ?? 'Belum pilih gambar item',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickItemImage,
                    icon: const Icon(Icons.image, size: 18),
                    label: const Text('Pilih'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _itemIsiController,
                decoration: const InputDecoration(
                  labelText: 'Penjelasan Item',
                  hintText: 'Deskripsi detail item...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedItemAudioName ?? 'Belum pilih audio item',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickItemAudio,
                    icon: const Icon(Icons.audiotrack, size: 18),
                    label: const Text('Pilih'),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCerita,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.blue,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Cerita',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
