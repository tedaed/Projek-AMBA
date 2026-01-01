import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/pages/Cerita/detail_item/detail_item_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class CeritaFirestore extends StatefulWidget {
  final String docId;

  const CeritaFirestore({
    super.key,
    required this.docId,
  });

  @override
  State<CeritaFirestore> createState() => _CeritaFirestoreState();
}

class _CeritaFirestoreState extends State<CeritaFirestore> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Map<String, dynamic>? ceritaData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('cerita')
          .doc(widget.docId)
          .get();

      if (doc.exists) {
        setState(() {
          ceritaData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _playPauseAudio() async {
    if (ceritaData == null || ceritaData!['audio'] == null) return;

    String audioPath = ceritaData!['audio'];

    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(
        AssetSource(audioPath.replaceFirst("assets/", "")),
      );
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 175, 255, 180),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (ceritaData == null) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 175, 255, 180),
        body: Center(child: Text('Data cerita tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 175, 255, 180),
      body: Column(
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
              onPressed: _playPauseAudio,
              child: Row(
                children: [
                  Icon(
                    isPlaying ? Icons.pause : Icons.volume_up,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isPlaying ? "Pause" : "Audio",
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
              ceritaData!['judul'] ?? '',
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              ceritaData!['ayat'] ?? '',
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              ceritaData!['isi_ayat'] ?? '',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "Lihat:",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: SizedBox(
              height: screenHeight * 0.058,
              child: Row(
                children: [
                  if (ceritaData!['detail_item'] != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        fixedSize: Size(
                          screenWidth * 0.375,
                          screenHeight * 0.055,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailItemFirestore(
                              docId: widget.docId,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            ceritaData!['detail_item']['judul'] ?? 'Detail',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.play_circle,
                            color: Colors.white,
                            size: screenWidth * 0.06,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    ceritaData!['gambar'] ?? 'assets/images/placeholder.jpg',
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
                        fixedSize: Size(
                          screenWidth * 0.46,
                          screenHeight * 0.055,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: screenWidth * 0.06,
                          ),
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
                        fixedSize: Size(
                          screenWidth * 0.37,
                          screenHeight * 0.055,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.home,
                            color: Colors.black,
                            size: screenWidth * 0.06,
                          ),
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
        ],
      ),
    );
  }
}
