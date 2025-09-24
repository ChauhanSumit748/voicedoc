import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'all_audio_screen.dart';
import 'all_video_screen.dart';

/// Media Tab Screen
class MediaTabScreen extends StatefulWidget {
  const MediaTabScreen({super.key});

  @override
  State<MediaTabScreen> createState() => _MediaTabScreenState();
}

class _MediaTabScreenState extends State<MediaTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Media",
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
           ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.workSans(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(
              text: "Video",
              icon: Icon(Icons.video_library, color: Colors.white),
            ),
            Tab(
              text: "Audio",
              icon: Icon(Icons.audiotrack, color: Colors.white),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AllVideoScreen(),
          AllAudioScreen(),
        ],
      ),
    );
  }
}