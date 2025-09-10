import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voicedoc/modul/recording_modul.dart';
import 'package:flutter/scheduler.dart' as scheduler;

class RecorderScreen extends StatefulWidget {
  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  final _record = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  String _timerText = '00:00';
  Duration _recordDuration = Duration.zero;
  Duration _elapsedBeforePause = Duration.zero;
  String _recordId = '';
  String _selectedDefault = 'Default';

  List<String> _defaultOptions = [
    'General OPD',
    "Oncology",
    'Cardiology',
    "Neurology",
    "Ophthalmology",
    "Pediatrics",
    'Dermatology',
    "Nephrology",
    "Gastroenterology",
    "General Surgery",
    "Emergency Medicine",
    "Discharge Summary",
    "OT Notes",
    "Default"
  ];

  Map<String, List<String>> _departmentFields = {};
  List<RecordingMeta> _saved = [];
  late final scheduler.Ticker _ticker;
  String? _tempFilePath;

  @override
  void initState() {
    super.initState();
    _initDepartmentFields();
    _loadSaved();
    _ticker = scheduler.Ticker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_isRecording && !_isPaused) {
      setState(() {
        _recordDuration = _elapsedBeforePause + elapsed;
        _timerText =
        '${_twoDigits(_recordDuration.inMinutes)}:${_twoDigits(_recordDuration.inSeconds % 60)}';
      });
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _initDepartmentFields() async {
    final prefs = await SharedPreferences.getInstance();
    for (var dept in _defaultOptions) {
      final saved = prefs.getStringList('fields_$dept');
      _departmentFields[dept] = saved ??
          (dept == "Default"
              ? ['Chief Complaints', 'Allergy', 'Past Medical History']
              : []);
    }
    setState(() {});
  }

  Future<void> _saveDepartmentFields(String dept) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('fields_$dept', _departmentFields[dept] ?? []);
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('recordings_v1');
    if (s != null) {
      final list = jsonDecode(s) as List<dynamic>;
      setState(() {
        _saved = list
            .map((e) => RecordingMeta.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
    }
  }

  Future<void> _saveMetaList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _saved.map((e) => e.toJson()).toList();
    await prefs.setString('recordings_v1', jsonEncode(jsonList));
  }

  Future<String> _getFilePath(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$name.m4a';
    return '${dir.path}/$fileName';
  }

  Future<void> _startRecord() async {
    final hasPerm = await Permission.microphone.request().isGranted;
    if (!hasPerm) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Mic permission denied')));
      return;
    }
    if (_recordId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Record ID (name)')));
      return;
    }

    _tempFilePath ??= await _getFilePath(_recordId.replaceAll(' ', '_'));

    try {
      await _record.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _tempFilePath!,
      );
      setState(() {
        _isRecording = true;
        _isPaused = false;
        _recordDuration = Duration.zero;
        _elapsedBeforePause = Duration.zero;
        _timerText = '00:00';
      });
      _ticker.start();
    } catch (e) {
      debugPrint('start error: $e');
    }
  }

  Future<void> _pauseResumeRecording() async {
    if (!_isRecording) return;

    if (!_isPaused) {
      await _record.pause();
      _ticker.stop();
      _elapsedBeforePause = _recordDuration;
    } else {
      await _record.resume();
      _ticker.start();
    }

    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _saveRecording() async {
    if (!_isRecording && _tempFilePath == null) return;

    if (_isRecording) {
      _ticker.stop();
      await _record.stop();
    }

    final meta = RecordingMeta(
      id: _recordId.trim(),
      filePath: _tempFilePath!,
      timestampMillis: DateTime.now().millisecondsSinceEpoch,
      fields: [_selectedDefault, ...(_departmentFields[_selectedDefault] ?? [])],
    );

    setState(() {
      _saved.insert(0, meta);
      _isRecording = false;
      _isPaused = false;
      _tempFilePath = null;
      _elapsedBeforePause = Duration.zero;
      _recordDuration = Duration.zero;
      _timerText = '00:00';
    });

    await _saveMetaList();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording saved successfully')));
  }

  void _openAddMoreDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Add More Field',
              style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration:
            const InputDecoration(hintText: 'Field name e.g. Diagnosis'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () {
                  final v = controller.text.trim();
                  if (v.isNotEmpty) {
                    setState(() {
                      final fields = _departmentFields[_selectedDefault] ?? [];
                      if (!fields.contains(v)) {
                        fields.add(v);
                        _departmentFields[_selectedDefault] = fields;
                      }
                    });
                    _saveDepartmentFields(_selectedDefault);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.workSans(fontSize: 14, color: Colors.white);

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.mic, size: 70, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  _timerText,
                  style: GoogleFonts.workSans(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                Wrap(
                  spacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed:
                      _isRecording && !_isPaused ? null : _startRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: const CircleBorder(),
                        elevation: 6,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Icon(Icons.fiber_manual_record,
                            size: 28, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isRecording ? _pauseResumeRecording : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _isPaused ? Colors.green : Colors.white,
                        shape: const CircleBorder(),
                        elevation: 6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Icon(
                            _isPaused ? Icons.play_arrow : Icons.pause,
                            size: 28,
                            color: _isPaused ? Colors.white : Colors.black87),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _saveRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8.0),
                        child: Text(
                          'Process',
                          style: GoogleFonts.workSans(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                Text(
                  'Please let everyone know that you\'re recording',
                  style: bodyStyle.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 20),

                TextField(
                  onChanged: (v) => setState(() => _recordId = v),
                  style: GoogleFonts.workSans(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter Record ID',
                    hintStyle: GoogleFonts.workSans(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedDefault,
                          items: _defaultOptions
                              .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: GoogleFonts.workSans()),
                          ))
                              .toList(),
                          onChanged: (v) => setState(
                                  () => _selectedDefault = v ?? _selectedDefault),
                          decoration: const InputDecoration(
                            labelText: "Select Department",
                            prefixIcon: Icon(Icons.local_hospital),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                  child: Text("Fields for $_selectedDefault")),
                              const Divider(),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: (_departmentFields[_selectedDefault] ?? [])
                                    .map((f) => Chip(
                                  label: Text(f,
                                      style: GoogleFonts.workSans()),
                                  deleteIconColor: Colors.red,
                                  onDeleted: () {
                                    setState(() {
                                      _departmentFields[_selectedDefault]
                                          ?.remove(f);
                                    });
                                    _saveDepartmentFields(_selectedDefault);
                                  },
                                ))
                                    .toList(),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _openAddMoreDialog,
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: Colors.deepPurple,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Text('Add More',
                                      style: GoogleFonts.workSans(
                                          color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
