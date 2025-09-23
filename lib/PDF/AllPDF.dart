import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voicedoc/PDF/pdf_view_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AllPdfSaveScreen extends StatefulWidget {
  const AllPdfSaveScreen({super.key});

  @override
  State<AllPdfSaveScreen> createState() => _AllPdfSaveScreenState();
}

class _AllPdfSaveScreenState extends State<AllPdfSaveScreen> {
  String searchQuery = "";

  Future<void> _deletePdf(String docId, String downloadUrl) async {
    try {
      await FirebaseFirestore.instance.collection('hospital_forms').doc(docId).delete();
      if (downloadUrl.isNotEmpty) {
        final ref = FirebaseStorage.instance.refFromURL(downloadUrl);
        await ref.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete PDF: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "All Saved PDFs",
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            fontSize: 22,
           ),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search by Patient Name or ID",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // PDF List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('hospital_forms')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading PDFs"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final patientName =
                  (data['patientName'] ?? '').toString().toLowerCase();
                  final patientId =
                  (data['patientId'] ?? '').toString().toLowerCase();
                  return patientName.contains(searchQuery) ||
                      patientId.contains(searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No PDFs found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final patientName = data['patientName'] ?? 'Unknown';
                    final patientId = data['patientId'] ?? 'Unknown';
                    final department = data['department'] ?? 'N/A';
                    final downloadUrl = data['downloadUrl'] ?? '';
                    final createdAt =
                    (data['createdAt'] as Timestamp?)?.toDate();

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.picture_as_pdf,
                              color: Colors.red, size: 36),
                        ),
                        title: Text(
                          patientName,
                          style: GoogleFonts.workSans(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("ID: $patientId",
                                style: GoogleFonts.workSans(fontSize: 13)),
                            Text("Dept: $department",
                                style: GoogleFonts.workSans(fontSize: 13)),
                            if (createdAt != null)
                              Text(
                                "Saved on: ${createdAt.day}-${createdAt.month}-${createdAt.year}",
                                style: GoogleFonts.workSans(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Delete Button
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    elevation: 20,
                                    backgroundColor: Colors.white,
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context).size.height * 0.5,
                                            minWidth: MediaQuery.of(context).size.width * 0.7,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Top Icon
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.red[100],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.delete_forever,
                                                  size: 40,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              const SizedBox(height: 16),

                                              // Title
                                              Text(
                                                "Delete PDF?",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 12),

                                              // Description
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  "Are you sure you want to permanently delete this PDF? This action cannot be undone.",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(height: 24),

                                              // Buttons
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.grey[300],
                                                        foregroundColor: Colors.black87,
                                                        elevation: 4,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(15),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                                      ),
                                                      child: Text(
                                                        "Cancel",
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        _deletePdf(doc.id, downloadUrl);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red[600],
                                                        foregroundColor: Colors.white,
                                                        elevation: 6,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(15),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                                      ),
                                                      child: Text(
                                                        "Delete",
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete,
                                    color: Colors.red, size: 22),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.blueAccent, size: 20),
                          ],
                        ),
                        onTap: () {
                          if (downloadUrl.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfViewScreen(
                                  pdfUrl: downloadUrl,
                                  title: patientName,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
