import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voicedoc/PDF/pdf_view_screen.dart';

class AllPdfSaveScreen extends StatefulWidget {
  const AllPdfSaveScreen({super.key});

  @override
  State<AllPdfSaveScreen> createState() => _AllPdfSaveScreenState();
}

class _AllPdfSaveScreenState extends State<AllPdfSaveScreen> {
  String searchQuery = "";

   Future<void> deletePdf(String docId, String pdfUrl) async {
    try {
      // Delete from Storage
      final ref = FirebaseStorage.instance.refFromURL(pdfUrl);
      await ref.delete();

       await FirebaseFirestore.instance
          .collection('hospital_forms')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Saved PDFs",
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search by Patient ID or Name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // List of PDFs
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

                // Filter based on searchQuery
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
                  return const Center(child: Text("No PDFs found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
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

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: const Icon(Icons.picture_as_pdf,
                            color: Colors.red, size: 40),
                        title: Text(
                          patientName,
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ID: $patientId",
                                style: GoogleFonts.workSans(fontSize: 13)),
                            Text("Dept: $department",
                                style: GoogleFonts.workSans(fontSize: 13)),
                            if (createdAt != null)
                              Text(
                                "Saved on: ${createdAt.day}-${createdAt.month}-${createdAt.year}",
                                style: GoogleFonts.workSans(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Confirm before deleting
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Delete PDF"),
                                    content: const Text(
                                        "Are you sure you want to delete this PDF?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          deletePdf(doc.id, downloadUrl);
                                          Navigator.of(ctx).pop();
                                        },
                                        child: const Text(
                                          "Delete",
                                          style:
                                          TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.blue),
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
