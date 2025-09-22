import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "About",
            style: GoogleFonts.workSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          )),
      body:
      SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Main App Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              shadowColor: Colors.indigoAccent.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "VoiceDoc",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Version: 1.0.0",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "VoiceDoc is a user-friendly audio recording and management app designed to help you capture, organize, and playback your recordings effortlessly. Whether you're a student, professional, or someone who likes to keep voice notes, VoiceDoc makes it simple and efficient.",
                      style: GoogleFonts.workSans(fontSize: 16, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Key Features:",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "• Record high-quality audio with a single tap.\n"
                          "• Save recordings with custom names for easy identification.\n"
                          "• Play, pause, or delete recordings directly within the app.\n"
                          "• Search and sort recordings for quick access.\n"
                          "• Backup recordings locally to ensure data safety.\n"
                          "• Simple and modern interface for seamless user experience.",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Perfect For:",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "• Students: Record lectures and notes.\n"
                          "• Professionals: Capture meetings, interviews, and ideas.\n"
                          "• Personal use: Keep voice journals or reminders.",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Thank you for choosing VoiceDoc! We continuously strive to improve your audio recording experience.",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
