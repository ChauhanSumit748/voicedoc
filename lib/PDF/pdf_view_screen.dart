import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class PdfViewScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  /// Load PDF from Firebase downloadUrl
  Future<Uint8List> _loadPdfFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("Failed to load PDF");
    }
  }

  /// Save PDF temporarily for sharing
  Future<void> _sharePdf(Uint8List pdfBytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$fileName.pdf').writeAsBytes(pdfBytes);
    await Share.shareXFiles([XFile(file.path)], text: "Here is your PDF: $fileName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Uint8List>(
        future: _loadPdfFromUrl(widget.pdfUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Error loading PDF: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("PDF not found"));
          }

          final pdfBytes = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: PdfPreview(
                  build: (format) async => pdfBytes,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  allowSharing: false,
                  allowPrinting: false,
                  actions: const [],
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Print button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          await Printing.layoutPdf(
                            onLayout: (format) async => pdfBytes,
                          );
                        },
                        icon: const Icon(Icons.print, size: 20, color: Colors.white),
                        label: Text("Print",
                            style: GoogleFonts.workSans(fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Share button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          try {
                            await _sharePdf(pdfBytes, widget.title);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Share failed: $e")));
                          }
                        },
                        icon: const Icon(Icons.share, size: 20, color: Colors.white),
                        label: Text("Share",
                            style: GoogleFonts.workSans(fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Download button
                   ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
