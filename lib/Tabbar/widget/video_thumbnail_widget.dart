import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Video Thumbnail Widget
class VideoThumbnailWidget extends StatefulWidget {
  final String videoPath;
  const VideoThumbnailWidget({super.key, required this.videoPath});

  @override
  _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final tempDir = await getTemporaryDirectory();
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: widget.videoPath,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      quality: 75,
    );
    if (mounted) {
      setState(() {
        _thumbnailPath = thumbnailPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbnailPath != null) {
      return Image.file(
        File(_thumbnailPath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}