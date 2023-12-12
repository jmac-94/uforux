import 'package:awesome_icons/awesome_icons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Wikipedia extends StatelessWidget {
  Wikipedia({super.key});

  final List<Document> documents = [
    Document(
      title: "Blue-sky printing",
      url: "https://www.princexml.com/howcome/2016/samples/magic8/index.pdf",
    ),
    Document(
      title: "A Concise Dictionary of Old Iceland",
      url: "https://css4.pub/2015/icelandic/dictionary.pdf",
    ),
    Document(
      title: "USENIX Paper",
      url: "https://css4.pub/2015/usenix/example.pdf",
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
                      PdfViewScreen(url: documents[index].url),
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
  String url;

  Document({required this.title, required this.url});
}

class PdfViewScreen extends StatelessWidget {
  final String url;

  const PdfViewScreen({super.key, required this.url});

  Future<void> downloadPdf(
      String url, String fileName, BuildContext context) async {
    try {
      var dio = Dio();
      var dir = await getApplicationDocumentsDirectory();
      var filePath = "${dir.path}/$fileName";
      await dio.download(url, filePath);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Descargado en $filePath')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: const Text("Vista previa del PDF"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () =>
                downloadPdf(url, 'nombre_del_archivo.pdf', context),
          ),
        ],
      ),
      body: SfPdfViewer.network(url),
    );
  }
}
