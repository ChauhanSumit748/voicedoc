// import 'dart:convert';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:voicedoc/modul/recording_modul.dart';
// import 'package:flutter/scheduler.dart' as scheduler;
// import 'PDFScreen.dart';
//
// class RecorderScreen extends StatefulWidget {
//   @override
//   State<RecorderScreen> createState() => _RecorderScreenState();
// }
//
// class _RecorderScreenState extends State<RecorderScreen> {
//   final _record = AudioRecorder();
//   bool _isRecording = false;
//   bool _isPaused = false;
//   String _timerText = '00:00';
//   Duration _recordDuration = Duration.zero;
//   Duration _elapsedBeforePause = Duration.zero;
//   String _recordId = '';
//   String _selectedDefault = 'Default';
//
//   List<String> _defaultOptions = [
//     'General OPD',
//     "Oncology",
//     'Cardiology',
//     "Neurology",
//     "Ophthalmology",
//     "Pediatrics",
//     'Dermatology',
//     "Nephrology",
//     "Gastroenterology",
//     "General Surgery",
//     "Emergency Medicine",
//     "Discharge Summary",
//     "OT Notes",
//     "Default"
//   ];
//
//   Map<String, List<String>> _departmentFields = {};
//   List<RecordingMeta> _saved = [];
//   scheduler.Ticker? _ticker;
//   String? _tempFilePath;
//   // We'll change this to a nullable type so it's null initially
//   CameraController? _cameraController;
//   // We'll also change this to a nullable type
//   List<CameraDescription>? _cameras;
//
//   @override
//   void initState() {
//     super.initState();
//     _initDepartmentFields();
//     _loadSaved();
//     _ticker = scheduler.Ticker(_onTick);
//     _initializeCamera();
//   }
//
//   Future<void> _initializeCamera() async {
//     // We now declare _cameras without 'late'
//     _cameras = await availableCameras();
//     if (_cameras != null && _cameras!.isNotEmpty) {
//       _cameraController = CameraController(
//         _cameras!.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
//         ResolutionPreset.medium,
//       );
//
//       try {
//         await _cameraController!.initialize();
//         if (mounted) {
//           setState(() {});
//         }
//       } on CameraException catch (e) {
//         debugPrint('Camera initialization error: $e');
//         // Handle case where camera initialization fails
//         _cameraController = null;
//         if (mounted) {
//           setState(() {});
//         }
//       }
//     } else {
//       debugPrint('No cameras available on this device.');
//       _cameraController = null;
//       if (mounted) {
//         setState(() {});
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _ticker?.dispose();
//     // Use the null-aware operator '?' to safely call dispose
//     _cameraController?.dispose();
//     super.dispose();
//   }
//
//   void _onTick(Duration elapsed) {
//     if (_isRecording && !_isPaused) {
//       setState(() {
//         _recordDuration = _elapsedBeforePause + elapsed;
//         _timerText =
//         '${_twoDigits(_recordDuration.inMinutes)}:${_twoDigits(_recordDuration.inSeconds % 60)}';
//       });
//     }
//   }
//
//   String _twoDigits(int n) => n.toString().padLeft(2, '0');
//
//   void _initDepartmentFields() async {
//     final prefs = await SharedPreferences.getInstance();
//     for (var dept in _defaultOptions) {
//       final saved = prefs.getStringList('fields_$dept');
//       _departmentFields[dept] = saved ??
//           (dept == "Default"
//               ? ['Chief Complaints', 'Allergy', 'Past Medical History']
//               : []);
//     }
//     setState(() {});
//   }
//
//   Future<void> _saveDepartmentFields(String dept) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('fields_$dept', _departmentFields[dept] ?? []);
//   }
//
//   Future<void> _loadSaved() async {
//     final prefs = await SharedPreferences.getInstance();
//     final s = prefs.getString('recordings_v1');
//     if (s != null) {
//       final list = jsonDecode(s) as List<dynamic>;
//       setState(() {
//         _saved = list
//             .map((e) => RecordingMeta.fromJson(Map<String, dynamic>.from(e)))
//             .toList();
//       });
//     }
//   }
//
//   Future<void> _saveMetaList() async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonList = _saved.map((e) => e.toJson()).toList();
//     await prefs.setString('recordings_v1', jsonEncode(jsonList));
//   }
//
//   Future<String> _getFilePath(String name) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final fileName = '${DateTime.now().millisecondsSinceEpoch}_$name.m4a';
//     return '${dir.path}/$fileName';
//   }
//
//   Future<void> _startRecord() async {
//     final hasMicPerm = await Permission.microphone.request().isGranted;
//     final hasCamPerm = await Permission.camera.request().isGranted;
//
//     if (!hasMicPerm || !hasCamPerm) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Permissions denied')));
//       return;
//     }
//     if (_recordId.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter Record ID (name)')));
//       return;
//     }
//
//     _tempFilePath ??= await _getFilePath(_recordId.replaceAll(' ', '_'));
//
//     try {
//       await _record.start(
//         RecordConfig(
//           encoder: AudioEncoder.aacLc,
//           bitRate: 128000,
//           sampleRate: 44100,
//         ),
//         path: _tempFilePath!,
//       );
//       // Safely check if the controller exists and is initialized
//       if (_cameraController != null && _cameraController!.value.isInitialized) {
//         await _cameraController!.startVideoRecording();
//       }
//
//       setState(() {
//         _isRecording = true;
//         _isPaused = false;
//         _recordDuration = Duration.zero;
//         _elapsedBeforePause = Duration.zero;
//         _timerText = '00:00';
//       });
//       _ticker?.start();
//     } catch (e) {
//       debugPrint('start error: $e');
//     }
//   }
//
//   Future<void> _pauseResumeRecording() async {
//     if (!_isRecording) return;
//
//     if (!_isPaused) {
//       await _record.pause();
//       // Safely pause video recording
//       if (_cameraController != null && _cameraController!.value.isInitialized) {
//         await _cameraController!.pauseVideoRecording();
//       }
//       _ticker?.stop();
//       _elapsedBeforePause = _recordDuration;
//     } else {
//       await _record.resume();
//       // Safely resume video recording
//       if (_cameraController != null && _cameraController!.value.isInitialized) {
//         await _cameraController!.resumeVideoRecording();
//       }
//       _ticker?.start();
//     }
//
//     setState(() {
//       _isPaused = !_isPaused;
//     });
//   }
//
//   Future<void> _saveRecording() async {
//     if (!_isRecording && _tempFilePath == null) return;
//
//     if (_isRecording) {
//       _ticker?.stop();
//       final audioPath = await _record.stop();
//       // Safely stop video recording
//       final videoFile = (_cameraController != null && _cameraController!.value.isInitialized)
//           ? await _cameraController!.stopVideoRecording()
//           : null;
//       final videoPath = videoFile?.path;
//
//       final meta = RecordingMeta(
//         id: _recordId.trim(),
//         filePath: audioPath!,
//         videoPath: videoPath,
//         timestampMillis: DateTime.now().millisecondsSinceEpoch,
//         fields: [_selectedDefault, ...(_departmentFields[_selectedDefault] ?? [])],
//         pdfGenerated: false,
//       );
//
//       setState(() {
//         _saved.insert(0, meta);
//         _isRecording = false;
//         _isPaused = false;
//         _tempFilePath = null;
//         _elapsedBeforePause = Duration.zero;
//         _recordDuration = Duration.zero;
//         _timerText = '00:00';
//       });
//
//       await _saveMetaList();
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recording saved successfully')));
//     }
//   }
//
//   void _openAddMoreDialog() {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: Text('Add More Field',
//               style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
//           content: TextField(
//             controller: controller,
//             decoration:
//             const InputDecoration(hintText: 'Field name e.g. Diagnosis'),
//           ),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel')),
//             ElevatedButton(
//                 onPressed: () {
//                   final v = controller.text.trim();
//                   if (v.isNotEmpty) {
//                     setState(() {
//                       final fields = _departmentFields[_selectedDefault] ?? [];
//                       if (!fields.contains(v)) {
//                         fields.add(v);
//                         _departmentFields[_selectedDefault] = fields;
//                       }
//                     });
//                     _saveDepartmentFields(_selectedDefault);
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: const Text('Add')),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bodyStyle = GoogleFonts.workSans(fontSize: 14, color: Colors.white);
//
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [
//               Color(0xFF3F51B5),
//               Color(0xFF5C6BC0),
//               Color(0xFF7986CB),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 12,
//               offset: Offset(0, 6),
//             ),
//           ],
//         ),
//         margin: const EdgeInsets.all(12),
//         padding: const EdgeInsets.all(18),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // The correct check is to see if the controller is not null
//                 // AND if it is initialized before trying to use it.
//                 if (_cameraController != null && _cameraController!.value.isInitialized)
//                   Container(
//                     height: 150, // Adjust height as needed
//                     width: 150,
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: AspectRatio(
//                         aspectRatio: _cameraController!.value.aspectRatio,
//                         child: CameraPreview(_cameraController!),
//                       ),
//                     ),
//                   )
//                 else
//                   Container(
//                     height: 150,
//                     width: 150,
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Center(
//                       child: CircularProgressIndicator(color: Colors.white),
//                     ),
//                   ),
//
//                 const SizedBox(height: 20),
//                 const Icon(Icons.mic, size: 70, color: Colors.white),
//                 const SizedBox(height: 8),
//                 Text(
//                   _timerText,
//                   style: GoogleFonts.workSans(
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 Wrap(
//                   spacing: 12,
//                   alignment: WrapAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed:
//                       _isRecording && !_isPaused ? null : _startRecord,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.redAccent,
//                         shape: const CircleBorder(),
//                         elevation: 6,
//                       ),
//                       child: const Padding(
//                         padding: EdgeInsets.all(18.0),
//                         child: Icon(Icons.fiber_manual_record,
//                             size: 28, color: Colors.white),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: _isRecording ? _pauseResumeRecording : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                         _isPaused ? Colors.green : Colors.white,
//                         shape: const CircleBorder(),
//                         elevation: 6,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(18.0),
//                         child: Icon(
//                             _isPaused ? Icons.play_arrow : Icons.pause,
//                             size: 28,
//                             color: _isPaused ? Colors.white : Colors.black87),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: _saveRecording,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16)),
//                         elevation: 6,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20.0, vertical: 8.0),
//                         child: Text(
//                           'Process',
//                           style: GoogleFonts.workSans(
//                               fontSize: 16, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                     (_saved.isNotEmpty && !_saved.first.pdfGenerated)
//                         ? Colors.redAccent
//                         : Colors.grey,
//                     foregroundColor: Colors.white,
//                   ),
//                   icon:
//                   const Icon(Icons.picture_as_pdf, color: Colors.white),
//                   label: Text("PDF",
//                       style: GoogleFonts.workSans(color: Colors.white)),
//                   onPressed: (_saved.isNotEmpty &&
//                       !_saved.first.pdfGenerated)
//                       ? () async {
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => HospitalPDFPage(
//                             recordId: _recordId.trim().isNotEmpty ? _recordId.trim() : null,
//                             selectedDepartment: _selectedDefault != 'Default' ? _selectedDefault : null,
//                           )),
//                     );
//                     setState(() {
//                       _saved.first.pdfGenerated = true;
//                     });
//                     await _saveMetaList();
//                   }
//                       : null,
//                 ),
//
//                 const SizedBox(height: 30),
//                 Text(
//                   'Please let everyone know that you\'re recording',
//                   style: bodyStyle.copyWith(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 20),
//
//                 TextField(
//                   onChanged: (v) => setState(() => _recordId = v),
//                   style: GoogleFonts.workSans(),
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     hintText: 'Enter Patient ID',
//                     hintStyle: GoogleFonts.workSans(),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 Card(
//                   elevation: 6,
//                   color: Colors.white,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24)),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 18.0, horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         DropdownButtonFormField<String>(
//                           value: _selectedDefault,
//                           items: _defaultOptions
//                               .map((e) => DropdownMenuItem(
//                             value: e,
//                             child: Text(e,
//                                 style: GoogleFonts.workSans()),
//                           ))
//                               .toList(),
//                           onChanged: (v) => setState(
//                                   () => _selectedDefault = v ?? _selectedDefault),
//                           decoration: const InputDecoration(
//                             labelText: "Select Department",
//                             prefixIcon: Icon(Icons.local_hospital),
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.black54, width: 1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Center(
//                                   child:
//                                   Text("Fields for $_selectedDefault")),
//                               const Divider(),
//                               const SizedBox(height: 8),
//                               Wrap(
//                                 spacing: 8,
//                                 runSpacing: 6,
//                                 children: (_departmentFields[_selectedDefault] ??
//                                     [])
//                                     .map((f) => Chip(
//                                   label: Text(f,
//                                       style: GoogleFonts.workSans()),
//                                   deleteIconColor: Colors.red,
//                                   onDeleted: () {
//                                     setState(() {
//                                       _departmentFields[
//                                       _selectedDefault]
//                                           ?.remove(f);
//                                     });
//                                     _saveDepartmentFields(
//                                         _selectedDefault);
//                                   },
//                                 ))
//                                     .toList(),
//                               ),
//                               const SizedBox(height: 14),
//                               ElevatedButton(
//                                 onPressed: _openAddMoreDialog,
//                                 style: ElevatedButton.styleFrom(
//                                   shape: const StadiumBorder(),
//                                   backgroundColor: Colors.deepPurple,
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 20.0),
//                                   child: Text('Add More',
//                                       style: GoogleFonts.workSans(
//                                           color: Colors.white)),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }





// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
//
// import '../VideoPlayer.dart';
//
// /// Video Meta Model
// class VideoMeta {
//   final String id;
//   final String? videoPath;
//   VideoMeta({required this.id, this.videoPath});
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'videoPath': videoPath,
//   };
//
//   factory VideoMeta.fromJson(Map<String, dynamic> json) => VideoMeta(
//     id: json['id'],
//     videoPath: json['videoPath'],
//   );
// }
//
// /// Audio Meta Model
// class AudioMeta {
//   final String id;
//   final String? audioPath;
//   AudioMeta({required this.id, this.audioPath});
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'audioPath': audioPath,
//   };
//
//   factory AudioMeta.fromJson(Map<String, dynamic> json) => AudioMeta(
//     id: json['id'],
//     audioPath: json['audioPath'],
//   );
// }
//
// /// Video Thumbnail Widget
// class VideoThumbnailWidget extends StatefulWidget {
//   final String videoPath;
//   const VideoThumbnailWidget({super.key, required this.videoPath});
//
//   @override
//   _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
// }
//
// class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
//   String? _thumbnailPath;
//
//   @override
//   void initState() {
//     super.initState();
//     _generateThumbnail();
//   }
//
//   Future<void> _generateThumbnail() async {
//     final tempDir = await getTemporaryDirectory();
//     final thumbnailPath = await VideoThumbnail.thumbnailFile(
//       video: widget.videoPath,
//       thumbnailPath: tempDir.path,
//       imageFormat: ImageFormat.JPEG,
//       quality: 75,
//     );
//     if (mounted) {
//       setState(() {
//         _thumbnailPath = thumbnailPath;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_thumbnailPath != null) {
//       return Image.file(
//         File(_thumbnailPath!),
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: double.infinity,
//       );
//     } else {
//       return const Center(child: CircularProgressIndicator());
//     }
//   }
// }
//
// /// All Video Screen
// class AllVideoScreen extends StatefulWidget {
//   const AllVideoScreen({super.key});
//
//   @override
//   State<AllVideoScreen> createState() => _AllVideoScreenState();
// }
//
// class _AllVideoScreenState extends State<AllVideoScreen> {
//   List<VideoMeta> _allVideos = [];
//   bool _isLoading = true;
//   String? _loadingMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadVideos();
//   }
//
//   Future<void> _loadVideos() async {
//     setState(() {
//       _isLoading = true;
//       _loadingMessage = 'Loading videos...';
//     });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final localData = prefs.getString('videos_v1');
//       List<VideoMeta> localVideos = [];
//       if (localData != null) {
//         final list = jsonDecode(localData) as List<dynamic>;
//         localVideos = list
//             .map((e) => VideoMeta.fromJson(Map<String, dynamic>.from(e)))
//             .toList();
//       }
//
//       final storageRef = FirebaseStorage.instance.ref().child('videos');
//       final listResult = await storageRef.listAll();
//       final newVideoMetas = <VideoMeta>[];
//
//       for (var ref in listResult.items) {
//         final videoId = ref.name;
//         final localVideo = localVideos.firstWhere(
//               (v) => v.id == videoId,
//           orElse: () => VideoMeta(id: videoId),
//         );
//
//         if (localVideo.videoPath != null &&
//             await File(localVideo.videoPath!).exists()) {
//           newVideoMetas.add(localVideo);
//         } else {
//           setState(() {
//             _loadingMessage = 'Downloading $videoId...';
//           });
//           final appDocDir = await getApplicationDocumentsDirectory();
//           final localFile = File('${appDocDir.path}/$videoId');
//           try {
//             await ref.writeToFile(localFile);
//             newVideoMetas
//                 .add(VideoMeta(id: videoId, videoPath: localFile.path));
//           } on FirebaseException catch (e) {
//             debugPrint('Error downloading video: $e');
//             newVideoMetas.add(VideoMeta(id: videoId));
//           }
//         }
//       }
//
//       setState(() {
//         _allVideos = newVideoMetas;
//         _isLoading = false;
//       });
//
//       final encoded =
//       jsonEncode(_allVideos.map((e) => e.toJson()).toList());
//       await prefs.setString('videos_v1', encoded);
//     } catch (e) {
//       debugPrint('Failed to load videos: $e');
//       setState(() {
//         _isLoading = false;
//         _loadingMessage = 'Failed to load videos.';
//       });
//     }
//   }
//
//   void _playVideo(VideoMeta meta) {
//     if (meta.videoPath == null) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Video file not found locally.',
//             style: GoogleFonts.workSans()),
//       ));
//       return;
//     }
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VideoPlayerScreen(videoPath: meta.videoPath!),
//       ),
//     );
//   }
//
//   Widget _buildGridItem(BuildContext context, VideoMeta meta, int index) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           if (meta.videoPath != null)
//             GestureDetector(
//               onTap: () => _playVideo(meta),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: VideoThumbnailWidget(videoPath: meta.videoPath!),
//               ),
//             ),
//           Positioned(
//             bottom: 8,
//             left: 8,
//             right: 8,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.6),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 meta.id,
//                 style: GoogleFonts.workSans(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text(_loadingMessage ?? 'Loading...',
//                 style: GoogleFonts.workSans()),
//           ],
//         ),
//       );
//     } else if (_allVideos.isEmpty) {
//       return Center(
//         child: Text(
//           'No videos found.',
//           style: GoogleFonts.workSans(fontSize: 16, color: Colors.grey),
//         ),
//       );
//     } else {
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: GridView.builder(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//           ),
//           itemCount: _allVideos.length,
//           itemBuilder: (context, index) {
//             return _buildGridItem(context, _allVideos[index], index);
//           },
//         ),
//       );
//     }
//   }
// }
//
// /// ---------------------------
// /// All Audio Screen (Updated with playback)
// /// ---------------------------
// class AllAudioScreen extends StatefulWidget {
//   const AllAudioScreen({super.key});
//
//   @override
//   State<AllAudioScreen> createState() => _AllAudioScreenState();
// }
//
// class _AllAudioScreenState extends State<AllAudioScreen> {
//   List<AudioMeta> _allAudios = [];
//   bool _isLoading = true;
//   final AudioPlayer _player = AudioPlayer();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAudios();
//   }
//
//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadAudios() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final localData = prefs.getString('audios_v1');
//       List<AudioMeta> localAudios = [];
//       if (localData != null) {
//         final list = jsonDecode(localData) as List<dynamic>;
//         localAudios = list
//             .map((e) => AudioMeta.fromJson(Map<String, dynamic>.from(e)))
//             .toList();
//       }
//
//       final storageRef = FirebaseStorage.instance.ref().child('recordings');
//       final listResult = await storageRef.listAll();
//       final newAudioMetas = <AudioMeta>[];
//
//       for (var ref in listResult.items) {
//         final audioId = ref.name;
//         final localAudio = localAudios.firstWhere(
//               (a) => a.id == audioId,
//           orElse: () => AudioMeta(id: audioId),
//         );
//
//         if (localAudio.audioPath != null &&
//             await File(localAudio.audioPath!).exists()) {
//           newAudioMetas.add(localAudio);
//         } else {
//           final appDocDir = await getApplicationDocumentsDirectory();
//           final localFile = File('${appDocDir.path}/$audioId');
//           try {
//             await ref.writeToFile(localFile);
//             newAudioMetas.add(AudioMeta(id: audioId, audioPath: localFile.path));
//           } on FirebaseException catch (e) {
//             debugPrint('Error downloading audio: $e');
//             newAudioMetas.add(AudioMeta(id: audioId));
//           }
//         }
//       }
//
//       setState(() {
//         _allAudios = newAudioMetas;
//         _isLoading = false;
//       });
//
//       final encoded = jsonEncode(_allAudios.map((e) => e.toJson()).toList());
//       await prefs.setString('audios_v1', encoded);
//     } catch (e) {
//       debugPrint('Failed to load audios: $e');
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _playAudio(String path) async {
//     try {
//       await _player.setFilePath(path);
//       _player.play();
//     } catch (e) {
//       debugPrint('Error playing audio: $e');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Failed to play audio")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (_allAudios.isEmpty) {
//       return Center(
//         child: Text(
//           'No audios found in recordings.',
//           style: GoogleFonts.workSans(fontSize: 16, color: Colors.grey),
//         ),
//       );
//     } else {
//       return ListView.builder(
//         itemCount: _allAudios.length,
//         itemBuilder: (context, index) {
//           final meta = _allAudios[index];
//           return ListTile(
//             leading: const Icon(Icons.audiotrack, color: Colors.blue),
//             title: Text(meta.id,
//                 style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
//             subtitle: Text(meta.audioPath ?? 'Not downloaded',
//                 style: GoogleFonts.workSans()),
//             onTap: () {
//               if (meta.audioPath != null) {
//                 _playAudio(meta.audioPath!);
//               }
//             },
//           );
//         },
//       );
//     }
//   }
// }
//
// /// Media Tab Screen
// class MediaTabScreen extends StatefulWidget {
//   const MediaTabScreen({super.key});
//
//   @override
//   State<MediaTabScreen> createState() => _MediaTabScreenState();
// }
//
// class _MediaTabScreenState extends State<MediaTabScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Media",
//           style: GoogleFonts.workSans(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue[800],
//         foregroundColor: Colors.white,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           labelStyle: GoogleFonts.workSans(
//             fontWeight: FontWeight.w600,
//           ),
//           tabs: const [
//             Tab(
//               text: "Video",
//               icon: Icon(Icons.video_library, color: Colors.white),
//             ),
//             Tab(
//               text: "Audio",
//               icon: Icon(Icons.audiotrack, color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: const [
//           AllVideoScreen(),
//           AllAudioScreen(),
//         ],
//       ),
//     );
//   }
// }
