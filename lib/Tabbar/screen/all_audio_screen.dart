import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

import '../model/media_meta.dart';

/// All Audio Screen
class AllAudioScreen extends StatefulWidget {
  const AllAudioScreen({super.key});

  @override
  State<AllAudioScreen> createState() => _AllAudioScreenState();
}

class _AllAudioScreenState extends State<AllAudioScreen> {
  List<AudioMeta> _allAudios = [];
  bool _isLoading = true;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadAudios();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadAudios() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString('audios_v1');
      List<AudioMeta> localAudios = [];
      if (localData != null) {
        final list = jsonDecode(localData) as List<dynamic>;
        localAudios = list
            .map((e) => AudioMeta.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final storageRef = FirebaseStorage.instance.ref().child('recordings');
      final listResult = await storageRef.listAll();
      final newAudioMetas = <AudioMeta>[];

      for (var ref in listResult.items) {
        final audioId = ref.name;
        final localAudio = localAudios.firstWhere(
              (a) => a.id == audioId,
          orElse: () => AudioMeta(id: audioId),
        );

        if (localAudio.audioPath != null &&
            await File(localAudio.audioPath!).exists()) {
          newAudioMetas.add(localAudio);
        } else {
          final appDocDir = await getApplicationDocumentsDirectory();
          final localFile = File('${appDocDir.path}/$audioId');
          try {
            await ref.writeToFile(localFile);
            newAudioMetas.add(AudioMeta(id: audioId, audioPath: localFile.path));
          } on FirebaseException catch (e) {
            debugPrint('Error downloading audio: $e');
            newAudioMetas.add(AudioMeta(id: audioId));
          }
        }
      }

      setState(() {
        _allAudios = newAudioMetas;
        _isLoading = false;
      });

      final encoded = jsonEncode(_allAudios.map((e) => e.toJson()).toList());
      await prefs.setString('audios_v1', encoded);
    } catch (e) {
      debugPrint('Failed to load audios: $e');
      setState(() => _isLoading = false);
    }
  }

  void _playAudio(String path) async {
    try {
      await _player.setFilePath(path);
      _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to play audio")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_allAudios.isEmpty) {
      return Center(
        child: Text(
          'No audios found in recordings.',
          style: GoogleFonts.workSans(fontSize: 16, color: Colors.grey),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _allAudios.length,
        itemBuilder: (context, index) {
          final meta = _allAudios[index];
          return ListTile(
            leading: const Icon(Icons.audiotrack, color: Colors.blue),
            title: Text(meta.id,
                style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
            subtitle: Text(meta.audioPath ?? 'Not downloaded',
                style: GoogleFonts.workSans()),
            onTap: () {
              if (meta.audioPath != null) {
                _playAudio(meta.audioPath!);
              }
            },
          );
        },
      );
    }
  }
}