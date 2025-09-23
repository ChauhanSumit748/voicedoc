// lib/modul/recording_modul.dart

class RecordingMeta {
  final String id;
  final String? filePath;
  final String? videoPath;
  final int timestampMillis;
  final List<String> fields;
  bool pdfGenerated;

  RecordingMeta({
    required this.id,
    this.filePath,
    this.videoPath,
    required this.timestampMillis,
    required this.fields,
    this.pdfGenerated = false,
  });

  factory RecordingMeta.fromJson(Map<String, dynamic> json) {
    return RecordingMeta(
      id: json['id'] as String,
      filePath: json['filePath'] as String?,
      videoPath: json['videoPath'] as String?,
      timestampMillis: (json['timestampMillis'] is int)
          ? json['timestampMillis'] as int
          : int.tryParse('${json['timestampMillis']}') ?? 0,
      fields: (json['fields'] != null)
          ? List<String>.from(json['fields'] as List<dynamic>)
          : <String>[],
      pdfGenerated: json['pdfGenerated'] == null
          ? false
          : (json['pdfGenerated'] is bool
          ? json['pdfGenerated'] as bool
          : (json['pdfGenerated'].toString().toLowerCase() == 'true')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'videoPath': videoPath,
      'timestampMillis': timestampMillis,
      'fields': fields,
      'pdfGenerated': pdfGenerated,
    };
  }

  @override
  String toString() {
    return 'RecordingMeta(id: $id, filePath: $filePath, videoPath: $videoPath, timestamp: $timestampMillis, fields: $fields, pdfGenerated: $pdfGenerated)';
  }
}