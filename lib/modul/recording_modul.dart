class RecordingMeta {
  String id; // Record ID (name)
  String filePath;
  int timestampMillis;
  List<String> fields;

  RecordingMeta({
    required this.id,
    required this.filePath,
    required this.timestampMillis,
    required this.fields,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'timestampMillis': timestampMillis,
    'fields': fields,
  };

  static RecordingMeta fromJson(Map<String, dynamic> j) => RecordingMeta(
    id: j['id'],
    filePath: j['filePath'],
    timestampMillis: j['timestampMillis'],
    fields: List<String>.from(j['fields'] ?? []),
  );
}
