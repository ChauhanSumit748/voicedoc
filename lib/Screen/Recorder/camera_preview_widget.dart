import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool isSaving;

  const CameraPreviewWidget({
    Key? key,
    required this.cameraController,
    required this.isSaving,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: isSaving
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : cameraController != null && cameraController!.value.isInitialized
            ? AspectRatio(
          aspectRatio: cameraController!.value.aspectRatio,
          child: CameraPreview(cameraController!),
        )
            : const Center(
          child: Icon(Icons.videocam_off, size: 70, color: Colors.white),
        ),
      ),
    );
  }
}