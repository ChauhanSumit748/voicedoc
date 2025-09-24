import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../VideoPlayer.dart';
import '../model/media_meta.dart';
import '../widget/video_thumbnail_widget.dart';


/// All Video Screen
class AllVideoScreen extends StatefulWidget {
  const AllVideoScreen({super.key});

  @override
  State<AllVideoScreen> createState() => _AllVideoScreenState();
}

class _AllVideoScreenState extends State<AllVideoScreen> {
  List<VideoMeta> _allVideos = [];
  bool _isLoading = true;
  String? _loadingMessage;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Loading videos...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString('videos_v1');
      List<VideoMeta> localVideos = [];
      if (localData != null) {
        final list = jsonDecode(localData) as List<dynamic>;
        localVideos = list
            .map((e) => VideoMeta.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final storageRef = FirebaseStorage.instance.ref().child('videos');
      final listResult = await storageRef.listAll();
      final newVideoMetas = <VideoMeta>[];

      for (var ref in listResult.items) {
        final videoId = ref.name;
        final localVideo = localVideos.firstWhere(
              (v) => v.id == videoId,
          orElse: () => VideoMeta(id: videoId),
        );

        if (localVideo.videoPath != null &&
            await File(localVideo.videoPath!).exists()) {
          newVideoMetas.add(localVideo);
        } else {
          setState(() {
            _loadingMessage = 'Downloading $videoId...';
          });
          final appDocDir = await getApplicationDocumentsDirectory();
          final localFile = File('${appDocDir.path}/$videoId');
          try {
            await ref.writeToFile(localFile);
            newVideoMetas
                .add(VideoMeta(id: videoId, videoPath: localFile.path));
          } on FirebaseException catch (e) {
            debugPrint('Error downloading video: $e');
            newVideoMetas.add(VideoMeta(id: videoId));
          }
        }
      }

      setState(() {
        _allVideos = newVideoMetas;
        _isLoading = false;
      });

      final encoded =
      jsonEncode(_allVideos.map((e) => e.toJson()).toList());
      await prefs.setString('videos_v1', encoded);
    } catch (e) {
      debugPrint('Failed to load videos: $e');
      setState(() {
        _isLoading = false;
        _loadingMessage = 'Failed to load videos.';
      });
    }
  }

  void _playVideo(VideoMeta meta) {
    if (meta.videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Video file not found locally.',
            style: GoogleFonts.workSans()),
      ));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: meta.videoPath!),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, VideoMeta meta, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (meta.videoPath != null)
            GestureDetector(
              onTap: () => _playVideo(meta),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: VideoThumbnailWidget(videoPath: meta.videoPath!),
              ),
            ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                meta.id,
                style: GoogleFonts.workSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_loadingMessage ?? 'Loading...',
                style: GoogleFonts.workSans()),
          ],
        ),
      );
    } else if (_allVideos.isEmpty) {
      return Center(
        child: Text(
          'No videos found.',
          style: GoogleFonts.workSans(fontSize: 16, color: Colors.grey),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _allVideos.length,
          itemBuilder: (context, index) {
            return _buildGridItem(context, _allVideos[index], index);
          },
        ),
      );
    }
  }
}

