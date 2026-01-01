import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../data/data_buku.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isSubmitting = false;

  // Controllers untuk Cerita
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _ayatController = TextEditingController();
  final TextEditingController _isiAyatController = TextEditingController();

  // Controllers untuk Detail Item
  final TextEditingController _itemJudulController = TextEditingController();
  final TextEditingController _itemIsiController = TextEditingController();

  String? _selectedImageName;
  String? _selectedAudioName;
  String? _selectedItemImageName;
  String? _selectedItemAudioName;

  // List untuk Quiz
  List<Map<String, dynamic>> _quizList = [];

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

  void _addQuiz() {
    if (_quizList.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 5 quiz per cerita!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final pertanyaanController = TextEditingController();
        final pilihan1Controller = TextEditingController();
        final pilihan2Controller = TextEditingController();
        final pilihan3Controller = TextEditingController();
        String? selectedJawaban;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Tambah Quiz ${_quizList.length + 1}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: pertanyaanController,
                      decoration: const InputDecoration(
                        labelText: 'Pertanyaan',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pilihan1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Pilihan 1',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pilihan2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Pilihan 2',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pilihan3Controller,
                      decoration: const InputDecoration(
                        labelText: 'Pilihan 3',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Jawaban Benar',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('Pilihan 1')),
                        DropdownMenuItem(value: '2', child: Text('Pilihan 2')),
                        DropdownMenuItem(value: '3', child: Text('Pilihan 3')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedJawaban = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (pertanyaanController.text.trim().isEmpty ||
                        pilihan1Controller.text.trim().isEmpty ||
                        pilihan2Controller.text.trim().isEmpty ||
                        pilihan3Controller.text.trim().isEmpty ||
                        selectedJawaban == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lengkapi semua field!')),
                      );
                      return;
                    }

                    List<String> pilihan = [
                      pilihan1Controller.text.trim(),
                      pilihan2Controller.text.trim(),
                      pilihan3Controller.text.trim(),
                    ];

                    String jawaban = pilihan[int.parse(selectedJawaban!) - 1];

                    setState(() {
                      _quizList.add({
                        'pertanyaan': pertanyaanController.text.trim(),
                        'pilihan': pilihan,
                        'jawaban': jawaban,
                      });
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeQuiz(int index) {
    setState(() {
      _quizList.removeAt(index);
    });
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
        content: SingleChildScrollView(
          child: Text('''
DATA TELAH DIUPLOAD!
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

    if (_quizList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 quiz!')),
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
        'quiz': _quizList,
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
        _quizList.clear();
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
                'Tambah Cerita Baru',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '1 Cerita = 1 Detail Item + 1-5 Quiz',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

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
              const Divider(),
              const SizedBox(height: 16),

              // QUIZ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quiz (${_quizList.length}/5)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _quizList.length < 5 ? _addQuiz : null,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_quizList.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Belum ada quiz\nTambahkan minimal 1 quiz',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _quizList.length,
                  itemBuilder: (context, index) {
                    final quiz = _quizList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('Quiz ${index + 1}'),
                        subtitle: Text(
                          '${quiz['pertanyaan'].substring(0, quiz['pertanyaan'].length > 50 ? 50 : quiz['pertanyaan'].length)}...\nJawaban: ${quiz['jawaban']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeQuiz(index),
                        ),
                      ),
                    );
                  },
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
