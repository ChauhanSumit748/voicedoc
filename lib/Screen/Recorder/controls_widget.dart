import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ControlsWidget extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final bool isSaving;
  final VoidCallback onStart;
  final VoidCallback onPauseResume;
  final VoidCallback onSave;

  const ControlsWidget({
    Key? key,
    required this.isRecording,
    required this.isPaused,
    required this.isSaving,
    required this.onStart,
    required this.onPauseResume,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: isRecording && !isSaving ? onPauseResume : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPaused ? Colors.green : Colors.white,
            shape: const CircleBorder(),
            elevation: 6,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Icon(isPaused ? Icons.play_arrow : Icons.pause, size: 28, color: isPaused ? Colors.white : Colors.black87),
          ),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text('Process', style: GoogleFonts.workSans(fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}