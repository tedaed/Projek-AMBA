import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/pages/quiz_page.dart';
import 'package:audioplayers/audioplayers.dart';

class DetailItemFirestore extends StatefulWidget {
  final String docId;

  const DetailItemFirestore({
    super.key,
    required this.docId,
  });

  @override
  State<DetailItemFirestore> createState() => _DetailItemFirestoreState();
}

class _DetailItemFirestoreState extends State<DetailItemFirestore> {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Map<String, dynamic>? ceritaData;
  Map<String, dynamic>? detailItem;
  bool isLoading = true;
  List<dynamic> quizList = [];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('cerita')
          .doc(widget.docId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          ceritaData = data;
          detailItem = data?['detail_item'];
          isLoading = false;
        });
      }

      final quizDoc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc('data')
          .get();
      
      if (quizDoc.exists) {
        setState(() {
          quizList = List<dynamic>.from(quizDoc.data()?['list_quiz'] ?? []);
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading data: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (detailItem == null || detailItem!['audio'] == null) return;

    final String audioPath = detailItem!['audio'];

    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } else {
      try {
        await _audioPlayer.play(
          AssetSource(audioPath.replaceFirst("assets/", "")),
        );
        setState(() => _isPlaying = true);
      } catch (e) {
        print("❌ Error saat memutar audio: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 175, 255, 180),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (detailItem == null) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 175, 255, 180),
        body: Center(child: Text('Detail item tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 175, 255, 180),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: screenHeight * 0.48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.07),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      fixedSize: Size(screenWidth * 0.4, screenHeight * 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: _toggleAudio,
                    child: Row(
                      children: [
                        Icon(
                          _isPlaying ? Icons.stop : Icons.volume_up,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isPlaying ? "Stop" : "Audio",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    detailItem!['judul'] ?? '',
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    detailItem!['isi'] ?? '',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back, size: screenWidth * 0.06),
                      ),
                      Text(
                        "Kembali",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      fixedSize: Size(screenWidth * 0.25, screenHeight * 0.055),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      int quizIndex = quizList.indexWhere(
                        (quiz) => quiz['name'] == detailItem!['judul'],
                      );

                      if (quizIndex != -1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizPage(
                              questions: quizList[quizIndex]['questions'],
                              namaQuiz: quizList[quizIndex]['name'],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quiz tidak tersedia')),
                        );
                      }
                    },
                    child: Text(
                      "Quiz",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: screenHeight * 0.4675,
              width: screenWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      detailItem!['gambar'] ?? 'assets/images/placeholder.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(220, 255, 255, 255),
                          fixedSize: Size(screenWidth * 0.46, screenHeight * 0.055),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          Navigator.pushNamed(context, '/daftar_cerita');
                        },
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back,
                                color: Colors.black, size: screenWidth * 0.06),
                            const SizedBox(width: 5),
                            Text(
                              "Daftar Cerita",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(220, 255, 255, 255),
                          fixedSize: Size(screenWidth * 0.37, screenHeight * 0.055),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        child: Row(
                          children: [
                            Icon(Icons.home,
                                color: Colors.black, size: screenWidth * 0.06),
                            const SizedBox(width: 8),
                            Text(
                              "Home",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
