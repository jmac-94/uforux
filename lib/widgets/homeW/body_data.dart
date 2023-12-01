import 'package:flutter/material.dart';
import 'package:uforuxpi3/controllers/home_controller.dart';
import 'package:uforuxpi3/models/comment.dart';

class BodyData extends StatelessWidget {
  final String image;
  final bool hasImage;
  final String text;
  final Comment comment;
  final HomeController homeController;

  const BodyData(
      {super.key,
      required this.image,
      required this.hasImage,
      required this.text,
      required this.comment,
      required this.homeController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        hasImage
            ? Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 20,
                  ),
                  child: Text(
                    comment.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            : const SizedBox(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(12),
          ),
          child: hasImage
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 8.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FutureBuilder<String>(
                      future: homeController.getImageUrl(image),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Image.network(
                            snapshot.data!,
                            height: 250,
                            width: 270,
                            fit: BoxFit.cover,
                          );
                        }
                      },
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      comment.text,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ),
        const SizedBox(
          height: 30,
        ),
        if (false) //comment.attachments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comment.attachments.values
                    .expand((fileList) => fileList)
                    .map((filePath) {
                  String fileName = filePath.split('/').last;
                  return Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            fileName,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download_rounded),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmación de descarga'),
                                content: const Text(
                                    '¿Deseas continuar con la descarga?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Confirmar'),
                                    onPressed: () async {
                                      // await homeController
                                      //     .downloadFile(filePath);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
