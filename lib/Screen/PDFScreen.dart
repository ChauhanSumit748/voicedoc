import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class HospitalPDFPage extends StatefulWidget {
  const HospitalPDFPage({super.key});

  @override
  State<HospitalPDFPage> createState() => _HospitalPDFPageState();
}

class _HospitalPDFPageState extends State<HospitalPDFPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController signerNameController = TextEditingController();

  String? selectedDepartment;
  bool agree = false;

  final _formKey = GlobalKey<FormState>();

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
                        controller: idController,
                        validator: (value) =>
                            value!.isEmpty ? "Enter patient ID" : null,
                        decoration: InputDecoration(
                          labelText: "Patient ID",
                          labelStyle: GoogleFonts.workSans(),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.badge),
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
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedDepartment,
                        validator: (value) =>
                            value == null ? "Select department" : null,
                        decoration: InputDecoration(
                          labelText: "Department",
                          labelStyle: GoogleFonts.workSans(),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.local_hospital),
                        ),
                        style: GoogleFonts.workSans(color: Colors.black),
                        items: [
                          'General OPD',
                          "Oncology",
                          'Cardiology',
                          "Neurology",
                          "Ophthalmology",
                          "Pediatrics",
                          'Dermatology',
                          "Nephrology",
                          "Gastroenterology",
                          "General Surgery",
                          "Emergency Medicine",
                          "Discharge Summary",
                          "OT Notes",
                          "Default"
                        ]
                            .map((dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(
                                    dept,
                                    style: GoogleFonts.workSans(),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value;
                          });
                        },
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

                              // Patient Info Fields (Single column)
                              ...[
                                "Name: ${nameController.text}",
                                "Patient ID: ${idController.text}",
                                "Age: ${ageController.text}",
                                "Mobile: ${mobileController.text}",
                                "Address: ${addressController.text}",
                                "Department: $selectedDepartment",
                              ].map(
                                (field) => pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 5),
                                  child: pw.Container(
                                    padding: const pw.EdgeInsets.all(8),
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.grey),
                                      borderRadius: const pw.BorderRadius.all(
                                          pw.Radius.circular(5)),
                                      color: PdfColors.blue50,
                                    ),
                                    child: pw.Text(field,
                                        style:
                                            const pw.TextStyle(fontSize: 14)),
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
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: agree
                                        ? pw.Center(
                                            child: pw.Text(
                                              "",
                                              style: pw.TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      pw.FontWeight.bold),
                                            ),
                                          )
                                        : pw.Container(),
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
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.center,
                                    children: [
                                      pw.Container(
                                        width: 180,
                                        height: 60,
                                        decoration: pw.BoxDecoration(
                                          border: pw.Border.all(
                                              color: PdfColors.black),
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

                      await Printing.layoutPdf(
                        onLayout: (format) async => pdf.save(),
                      );
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
                    foregroundColor: Colors.white, // Text color white
                    backgroundColor:
                        Colors.blue, // Button background color blue
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
