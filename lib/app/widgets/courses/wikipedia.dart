import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Wikipedia extends StatelessWidget {
  Wikipedia({super.key});

  final List<Document> documents = [
    Document(
      title: "FLutter cheat sheet PDF",
      filePath: "assets/flutter-cheat-sheet.pdf",
    ),
    Document(
      title: "Remozaiento de cabina",
      filePath: "assets/Remozamiento_de_Cabina.pdf",
    ),
    Document(
      title: "Examen Laboratorio 2022-2",
      filePath: "assets/EL2_2022_2.pdf",
    ),
    // Agrega más documentos aquí
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Row(
            children: [
              Icon(
                FontAwesomeIcons.filePdf,
                color: Colors.blueAccent[700],
              ),
              const SizedBox(width: 10),
              Text(documents[index].title),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PdfViewScreen(filePath: documents[index].filePath),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class Document {
  String title;
  String filePath;

  Document({required this.title, required this.filePath});
}

class PdfViewScreen extends StatelessWidget {
  final String filePath;

  const PdfViewScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: const Text("PDF Viewer"),
      ),
      body: SfPdfViewer.asset(filePath),
    );
  }
}
