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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Mis Documentos PDF',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Container(
          height: 160,
          child: ListView.builder(
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
          ),
        ),
      ],
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

class CourseSchedule extends StatefulWidget {
  const CourseSchedule({super.key});

  @override
  _CourseScheduleState createState() => _CourseScheduleState();
}

class _CourseScheduleState extends State<CourseSchedule>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _cycles = [
    'CICLO 1',
    'CICLO 2',
    'CICLO 3',
    // Agrega todos los ciclos aquí
  ];

  Map<String, List<Course>> coursesPerCycle = {
    'CICLO 1': [
      Course('Programación I', 4),
      Course('Cálculo de una Variable', 4),
      Course('Comunicación Oral y Escrita', 2),
      Course('Introducción a mecanica', 2),
    ],
    'CICLO 2': [
      Course('Programación II', 4),
      Course('Cálculo de varias variables', 4),
      Course('Introducción a la Ingeniería de Sistemas', 2),
    ],
    'CICLO 3': [
      Course('Programación III', 3),
      Course('Matematica I', 4),
      Course('Arquitecuta de computadoras', 4),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _cycles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints.expand(
            height: 30,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: _cycles.map((cycle) => Tab(text: cycle)).toList(),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _cycles.map((cycle) {
              final courses = coursesPerCycle[cycle] ?? [];
              return ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return ListTile(
                    title: Text(course.name),
                    trailing: Text('${course.credits} CRD'),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class Course {
  String name;
  int credits;

  Course(this.name, this.credits);
}
