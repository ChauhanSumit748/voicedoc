import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalPDFPage extends StatefulWidget {
  final String? recordId;
  final String? selectedDepartment;

  const HospitalPDFPage({
    super.key,
    this.recordId,
    this.selectedDepartment,
  });

  @override
  State<HospitalPDFPage> createState() => _HospitalPDFPageState();
}

class _HospitalPDFPageState extends State<HospitalPDFPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController signerNameController = TextEditingController();
  final TextEditingController recordIdController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();

  bool agree = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.recordId != null) {
      recordIdController.text = widget.recordId!;
    }
    if (widget.selectedDepartment != null) {
      departmentController.text = widget.selectedDepartment!;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    addressController.dispose();
    mobileController.dispose();
    signerNameController.dispose();
    recordIdController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  Future<String> _uploadPdfToFirebase(
      Uint8List bytes, {
        required String fileName,
        required String patientId,
        required String patientName,
        required String department,
      }) async {
    // Storage path: hospital_forms/{fileName}
    final ref = FirebaseStorage.instance
        .ref()
        .child('hospital_forms')
        .child(fileName);

    final metadata = SettableMetadata(contentType: 'application/pdf');

    // Upload to Storage
    await ref.putData(bytes, metadata);

    // Get a download URL (depends on your Storage rules)
    final downloadUrl = await ref.getDownloadURL();

    // Optional: Save metadata to Firestore
    await FirebaseFirestore.instance.collection('hospital_forms').add({
      'patientId': patientId,
      'patientName': patientName,
      'department': department,
      'fileName': fileName,
      'storagePath': ref.fullPath,
      'downloadUrl': downloadUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hospital Form",
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  "Date: $currentDate",
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Patient Info Header
              Text(
                "Patient Information",
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 10),

              // Patient Info Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Patient ID Field
                      TextFormField(
                        controller: recordIdController,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Record ID",
                          labelStyle: GoogleFonts.workSans(),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.badge),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: GoogleFonts.workSans(),
                      ),
                      const SizedBox(height: 15),

                      // Department Field
                      TextFormField(
                        controller: departmentController,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Department",
                          labelStyle: GoogleFonts.workSans(),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.local_hospital),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: GoogleFonts.workSans(),
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: nameController,
                        validator: (value) =>
                        value!.isEmpty ? "Enter patient name" : null,
                        decoration: InputDecoration(
                          labelText: "Patient Name",
                          labelStyle: GoogleFonts.workSans(),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        style: GoogleFonts.workSans(),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                        value!.isEmpty ? "Enter patient age" : null,
                        decoration: InputDecoration(
                          labelText: "Age",
                          labelStyle: GoogleFonts.workSans(),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.cake),
                        ),
                        style: GoogleFonts.workSans(),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: addressController,
                        validator: (value) =>
                        value!.isEmpty ? "Enter address" : null,
                        decoration: InputDecoration(
                          labelText: "Address",
                          labelStyle: GoogleFonts.workSans(),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.home),
                        ),
                        style: GoogleFonts.workSans(),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                        value!.isEmpty || value.length != 10
                            ? "Enter valid 10-digit mobile number"
                            : null,
                        decoration: InputDecoration(
                          labelText: "Mobile Number",
                          labelStyle: GoogleFonts.workSans(),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        style: GoogleFonts.workSans(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Terms & Conditions
              Text(
                "Terms & Conditions",
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        "By signing this form, the patient agrees to the hospital's treatment process, billing policies, and acknowledges that they have disclosed correct information.",
                        style: GoogleFonts.workSans(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                              value: agree,
                              onChanged: (value) {
                                setState(() {
                                  agree = value ?? false;
                                });
                              }),
                          Expanded(
                            child: Text(
                              "I agree to the terms and conditions stated above.",
                              style: GoogleFonts.workSans(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Signer Name
              TextFormField(
                controller: signerNameController,
                validator: (value) =>
                value!.isEmpty ? "Enter signer name" : null,
                decoration: InputDecoration(
                  labelText: "Signer Name",
                  labelStyle: GoogleFonts.workSans(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                style: GoogleFonts.workSans(),
              ),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && agree) {
                      final pdf = pw.Document();

                      pdf.addPage(
                        pw.MultiPage(
                          pageFormat: PdfPageFormat.a4,
                          build: (pw.Context context) {
                            return [
                              // Header
                              pw.Center(
                                child: pw.Text("HOSPITAL NAME",
                                    style: pw.TextStyle(
                                        fontSize: 28,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.black)),
                              ),
                              pw.Divider(thickness: 2),
                              pw.SizedBox(height: 10),

                              // Date
                              pw.Align(
                                alignment: pw.Alignment.topRight,
                                child: pw.Text("Date: $currentDate",
                                    style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.SizedBox(height: 20),

                              // Patient Info Header
                              pw.Text(
                                "Patient Information",
                                style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black),
                              ),
                              pw.SizedBox(height: 10),

                              // Patient Info Fields
                              ...([
                                "Name: ${nameController.text}",
                                if (recordIdController.text.isNotEmpty) "Patient ID: ${recordIdController.text}",
                                "Age: ${ageController.text}",
                                "Mobile: ${mobileController.text}",
                                "Address: ${addressController.text}",
                                if (departmentController.text.isNotEmpty) "Department: ${departmentController.text}",
                              ]).map(
                                    (field) => pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(vertical: 5),
                                  child: pw.Container(
                                    padding: const pw.EdgeInsets.all(8),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(color: PdfColors.grey),
                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                                      color: PdfColors.blue50,
                                    ),
                                    child: pw.Text(field, style: const pw.TextStyle(fontSize: 14)),
                                  ),
                                ),
                              ),

                              pw.SizedBox(height: 20),

                              // Terms & Conditions
                              pw.Text(
                                "Terms & Conditions",
                                style: pw.TextStyle(
                                    fontSize: 18,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                "By signing this form, the patient agrees to all hospital rules and regulations. "
                                    "The hospital will not be liable for misinformation provided by the patient. "
                                    "Emergency procedures may be carried out if required.",
                                textAlign: pw.TextAlign.justify,
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                              pw.SizedBox(height: 10),

                              // Agree checkbox
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    width: 15,
                                    height: 15,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(color: PdfColors.black),
                                      color: agree ? PdfColors.white : PdfColors.white,
                                    ),
                                  ),
                                  pw.SizedBox(width: 8),
                                  pw.Expanded(
                                    child: pw.Text(
                                      "I agree to the terms and conditions stated above.",
                                      style: const pw.TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),

                              pw.SizedBox(height: 50),

                              // Signature box
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                                    children: [
                                      pw.Container(
                                        width: 180,
                                        height: 60,
                                        decoration: pw.BoxDecoration(
                                          border: pw.Border.all(color: PdfColors.black),
                                        ),
                                      ),
                                      pw.SizedBox(height: 5),
                                      pw.Text(
                                        "Signed by: ${signerNameController.text}",
                                        style: const pw.TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ];
                          },
                        ),
                      );

                      final Uint8List bytes = await pdf.save();

                      // Show/Print the PDF
                      await Printing.layoutPdf(
                        onLayout: (format) async => bytes,
                      );

                      // Upload to Firebase
                      try {
                        final fileName =
                            '${DateTime.now().millisecondsSinceEpoch}_${recordIdController.text.isNotEmpty ? recordIdController.text : 'unknown'}.pdf';

                        final url = await _uploadPdfToFirebase(
                          bytes,
                          fileName: fileName,
                          patientId: recordIdController.text.isNotEmpty ? recordIdController.text : 'unknown',
                          patientName: nameController.text.isNotEmpty ? nameController.text : 'unknown',
                          department: departmentController.text,
                        );

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF Firebase me save ho gaya. URL: $url')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Upload failed: $e')),
                        );
                      }
                    } else if (!agree) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "You must agree to terms & conditions to generate PDF")),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                  ),
                  label: const Text("Print & Save"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}