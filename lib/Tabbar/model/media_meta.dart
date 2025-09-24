import 'dart:convert';

/// Video Meta Model
class VideoMeta {
  final String id;
  final String? videoPath;
  VideoMeta({required this.id, this.videoPath});

  Map<String, dynamic> toJson() => {
    'id': id,
    'videoPath': videoPath,
  };

  factory VideoMeta.fromJson(Map<String, dynamic> json) => VideoMeta(
    id: json['id'],
    videoPath: json['videoPath'],
  );
}

/// Audio Meta Model
class AudioMeta {
  final String id;
  final String? audioPath;
  AudioMeta({required this.id, this.audioPath});

  Map<String, dynamic> toJson() => {
    'id': id,
    'audioPath': audioPath,
  };

  factory AudioMeta.fromJson(Map<String, dynamic> json) => AudioMeta(
    id: json['id'],
    audioPath: json['audioPath'],
  );
}