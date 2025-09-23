import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voicedoc/modul/recording_modul.dart';
import 'package:google_fonts/google_fonts.dart';
import '../PDF/AllPDF.dart';

class AllRecordingsScreen extends StatefulWidget {
  @override
  State<AllRecordingsScreen> createState() => _AllRecordingsScreenState();
}

class _AllRecordingsScreenState extends State<AllRecordingsScreen> {
  List<RecordingMeta> _all = [];
  int _perPage = 20;
  int _page = 1;
  final AudioPlayer _player = AudioPlayer();
  String? _playingPath;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('recordings_v1');
    if (s != null) {
      final list = jsonDecode(s) as List<dynamic>;
      setState(() {
        _all = list
            .map((e) => RecordingMeta.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
    }
  }

  Future<void> _playPause(RecordingMeta meta) async {
    try {
      if (_playingPath == meta.filePath) {
        await _player.pause();
        setState(() {
          _playingPath = null;
        });
      } else {
        await _player.stop();
        await _player.play(DeviceFileSource(meta.filePath));
        setState(() {
          _playingPath = meta.filePath;
        });
        _player.onPlayerComplete.listen((event) {
          setState(() {
            _playingPath = null;
          });
        });
      }
    } catch (e) {
      debugPrint('play error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cannot play file', style: GoogleFonts.workSans())));
    }
  }

  Future<void> _download(RecordingMeta meta) async {
    try {
      await Share.shareXFiles([XFile(meta.filePath)],
          text:
          '${meta.id} • ${DateTime.fromMillisecondsSinceEpoch(meta.timestampMillis).toLocal()}');
    } catch (e) {
      debugPrint('share error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cannot share file', style: GoogleFonts.workSans())));
    }
  }

  Future<void> _removeRecording(RecordingMeta meta) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _all.removeWhere((r) => r.filePath == meta.filePath);
    });
    final s = jsonEncode(_all.map((e) => e.toJson()).toList());
    await prefs.setString('recordings_v1', s);
  }

  List<RecordingMeta> get _paged {
    final start = (_page - 1) * _perPage;
    final end = (_page * _perPage).clamp(0, _all.length);
    if (start >= _all.length) return [];
    return _all.sublist(start, end);
  }

  void _prevPage() {
    if (_page > 1) setState(() => _page--);
  }

  void _nextPage() {
    final totalPages = (_all.length / _perPage).ceil().clamp(1, 9999);
    if (_page < totalPages) setState(() => _page++);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget _buildRow(RecordingMeta meta) {
    final dt =
    DateTime.fromMillisecondsSinceEpoch(meta.timestampMillis).toLocal();
    final date = '${dt.day}-${dt.month}-${dt.year}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${meta.id}  •  $date $time',
                style: GoogleFonts.workSans(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.indigo),
              onPressed: () => _download(meta),
            ),
            IconButton(
                icon: Icon(
                    _playingPath == meta.filePath
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.indigo),
                onPressed: () => _playPause(meta)),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () => _removeRecording(meta),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_all.isEmpty) ? 1 : (_all.length / _perPage).ceil();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3F51B5),
              Color(0xFF5C6BC0),
              Color(0xFF7986CB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(18),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Saved Recordings',
                    style: GoogleFonts.workSans(
                      textStyle: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Row me Show dropdown (left) aur PDF button (right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text('Show',
                              style:
                              GoogleFonts.workSans(color: Colors.white)),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _perPage,
                            dropdownColor: Colors.black,
                            style: GoogleFonts.workSans(color: Colors.white),
                            iconEnabledColor: Colors.white,
                            underline: Container(
                              height: 1,
                              color: Colors.white,
                            ),
                            items: [10, 20, 50, 100]
                                .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                '$e',
                                style: GoogleFonts.workSans(
                                    color: Colors.white),
                              ),
                            ))
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() {
                                _perPage = v;
                                _page = 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.picture_as_pdf,color: Colors.white,),
                      label: Text("All PDF",
                          style: GoogleFonts.workSans(color: Colors.white)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllPdfSaveScreen()),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Expanded(
                  child: _all.isEmpty
                      ? Center(
                      child: Text('No recordings saved',
                          style: GoogleFonts.workSans(color: Colors.white)))
                      : ListView(
                    children: _paged.map((r) => _buildRow(r)).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _page == 1 ? null : _prevPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Previous',
                            style: GoogleFonts.workSans(color: Colors.black)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Page $_page of $totalPages',
                        style: GoogleFonts.workSans(color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _page >= totalPages ? null : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Next',
                            style: GoogleFonts.workSans(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _downloadAllPrompt() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Download All', style: GoogleFonts.workSans()),
        content: Text(
          'This demo provides Download (share) per recording. To implement "download all" you can create a ZIP of all files and share it.',
          style: GoogleFonts.workSans(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.workSans()))
        ],
      ),
    );
  }
}
