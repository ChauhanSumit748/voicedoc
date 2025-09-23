import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voicedoc/modul/recording_modul.dart';
import '../VideoPlayer.dart';

class AllVideoScreen extends StatefulWidget {
  const AllVideoScreen({super.key});

  @override
  State<AllVideoScreen> createState() => _AllVideoScreenState();
}

class _AllVideoScreenState extends State<AllVideoScreen> {
  List<RecordingMeta> _allVideos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('recordings_v1');
    if (s != null) {
      final list = jsonDecode(s) as List<dynamic>;
      setState(() {
        _allVideos = list
            .map((e) => RecordingMeta.fromJson(Map<String, dynamic>.from(e)))
            .where((meta) => meta.videoPath != null)
            .toList();
      });
    }
  }

  Future<void> _deleteVideo(int index) async {
    final meta = _allVideos[index];

    // Delete video file from device if exists
    if (meta.videoPath != null) {
      final file = File(meta.videoPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // Remove from list and update SharedPreferences
    setState(() {
      _allVideos.removeAt(index);
    });

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_allVideos.map((e) => e.toJson()).toList());
    await prefs.setString('recordings_v1', encoded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Videos',
          style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _allVideos.isEmpty
          ? Center(
        child: Text(
          'No video recordings found.',
          style: GoogleFonts.workSans(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allVideos.length,
        itemBuilder: (context, index) {
          final meta = _allVideos[index];
          final dt = DateTime.fromMillisecondsSinceEpoch(meta.timestampMillis).toLocal();
          final date = '${dt.day}-${dt.month}-${dt.year}';
          final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.videocam, color: Colors.blue, size: 36),
              title: Text(meta.id, style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
              subtitle: Text('Recorded on $date at $time', style: GoogleFonts.workSans(fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.blue, size: 32),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(videoPath: meta.videoPath!),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Video'),
                          content: const Text('Are you sure you want to delete this video?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteVideo(index);
                                Navigator.pop(context);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
