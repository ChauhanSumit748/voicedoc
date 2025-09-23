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
  Future<Uint8List> _loadPdfFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("Failed to load PDF");
    }
  }

  Future<void> _sharePdf(Uint8List pdfBytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$fileName.pdf').writeAsBytes(pdfBytes);
    await Share.shareXFiles([XFile(file.path)], text: "Here is your PDF: $fileName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 6,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            fontSize: 22,
           ),
        ),
      ),
      body: FutureBuilder<Uint8List>(
        future: _loadPdfFromUrl(widget.pdfUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading PDF: ${snapshot.error}",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "PDF not found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final pdfBytes = snapshot.data!;

          return Column(
            children: [
              // PDF Preview Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: PdfPreview(
                    build: (format) async => pdfBytes,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    allowPrinting: false,
                    allowSharing: false,
                    actions: const [],
                  ),
                ),
              ),

              // Action Buttons (Print + Share only)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Print Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Printing.layoutPdf(
                            onLayout: (format) async => pdfBytes,
                          );
                        },
                        icon: const Icon(Icons.print, color: Colors.white),
                        label: Text(
                          "Print",
                          style: GoogleFonts.workSans(fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Share Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await _sharePdf(pdfBytes, widget.title);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Share failed: $e")),
                            );
                          }
                        },
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: Text(
                          "Share",
                          style: GoogleFonts.workSans(fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ),
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
