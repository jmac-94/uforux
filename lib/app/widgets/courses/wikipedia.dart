import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Wikipedia extends StatelessWidget {
  const Wikipedia({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 10.0,
          ),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
        ),
        SfPdfViewer.asset('assets/flutter-cheat-sheet.pdf'),
      ],
    );
  }
}
