import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/services/auth.dart';
import 'package:uforuxpi3/widgets/post_item.dart';
import 'package:uforuxpi3/util/data.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final AppUser? user;

  const Home({super.key, required this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _perPage = 20;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  DocumentSnapshot? _lastDocument;

  String userId = '';
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchComments();

    userId = widget.user!.uid;
  }

  void _fetchComments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var querySnapshot = await _firestore
          .collection('forums')
          .where('name', isEqualTo: 'general')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> data = documentSnapshot.data();
        List<dynamic> comments = data['comments'] ?? {};

        // Determine the range of comments to fetch
        final int currentLength = _comments.length;
        final int nextFetchLimit = currentLength + _perPage;
        if (nextFetchLimit >= comments.length) {
          _comments = comments.map((c) => c as Map<String, dynamic>).toList();
          _hasMoreData = false; // No more comments to load
        } else {
          List<Map<String, dynamic>> newComments = comments
              .sublist(currentLength, nextFetchLimit)
              .map((c) => c as Map<String, dynamic>)
              .toList();
          _comments.addAll(newComments);
        }
      }
    } catch (e) {
      // Handle the exception
      print(e);
      _hasMoreData = false;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submitComment(String text,
      {List<String> attachments = const []}) async {
    if (text.trim().isEmpty) return; // Don't submit empty comments.

    try {
      // Fetch the ID of the 'general' forum
      var querySnapshot = await _firestore
          .collection('forums')
          .where('name', isEqualTo: 'general')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var forumDocumentSnapshot = querySnapshot.docs.first;
        var newComment = {
          'attachments':
              attachments, // Update this as per the attachments the user adds
          'createdAt': Timestamp.now(),
          'id': DateTime.now()
              .millisecondsSinceEpoch
              .toString(), // Or any unique id generator
          'text': text,
          'ups': 0,
          'userId': userId, // Assuming you have the current user's ID here
        };

        // Add the new comment to the forum's 'comments' list
        await _firestore
            .collection('forums')
            .doc(forumDocumentSnapshot.id)
            .update({
          'comments': FieldValue.arrayUnion([newComment]),
        });

        // Update the local list of comments and refresh the UI
        setState(() {
          _comments.add(newComment);
        });
      }
    } catch (e) {
      // Handle the exception, maybe show an error message to the user
      print(e);
    }
  }

  Future<String?> _uploadFile(File file, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final result = await ref.putFile(file);
      final fileUrl = await result.ref.getDownloadURL();
      return fileUrl; // Retorna la URL del archivo subido
    } catch (e) {
      // Manejar errores aquí
      print(e);
      return null;
    }
  }

  Future<void> _selectAndUploadFile(String text) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result
          .files.single.path!); // Asumimos que se selecciona un solo archivo
      String fileName = result.files.single.name;
      // CAMBIAR ESTE FILEPATH POR FAVOR
      String filePath =
          'forums/forum_id/comments/comment_id/documents/$fileName';
      String? fileUrl = await _uploadFile(file, filePath);
      if (fileUrl != null) {
        // Llama a tu función para enviar el comentario aquí, incluyendo el archivo adjunto
        _submitComment(text, attachments: [fileUrl]);
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMoreData) {
      _fetchComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foro general'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.low_priority,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add_comment,
          color: Colors.white,
        ),
        onPressed: () {
          TextEditingController commentController = TextEditingController();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Nuevo Comentario'),
                content: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu comentario aquí',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Enviar'),
                    onPressed: () {
                      String text = commentController.text;
                      Navigator.of(context).pop(); // Close the dialog
                      _selectAndUploadFile(
                          commentController.text); // Submit the comment
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      body: ListView.separated(
        controller: _scrollController,
        itemCount: _hasMoreData ? _comments.length + 1 : _comments.length,
        itemBuilder: (context, index) {
          if (index == _comments.length) {
            return const Center(child: CircularProgressIndicator());
          }
          var comment = _comments[index];
          final created = comment['createdAt'].toDate().toString();
          // delete the hours and minutes from the date and separate un another variable
          final date =
              DateTime.parse(created).toLocal().toString().split(' ')[0];
          final hours = DateTime.parse(created)
              .toLocal()
              .toString()
              .split(' ')[1]
              .split('.')[0];
          final randomNumber = random.nextInt(1000);
          final imageUrl = 'https://picsum.photos/200/300?random=$randomNumber';
          final randomNumber2 = random.nextInt(1000);
          final imageUrl2 =
              'https://picsum.photos/200/300?random=$randomNumber2';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28.0),
                        child: GestureDetector(
                          onTap: () => showFullImage(context, imageUrl),
                          child: Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      comment['text'],
                    ),
                    const Spacer(),
                    Text(
                      hours.toString(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.network(
                  imageUrl2,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  const Icon(Icons.emoji_emotions),
                  const SizedBox(width: 10),
                  const Icon(Icons.comment),
                  const SizedBox(width: 10),
                  const Icon(Icons.local_fire_department),
                  const Spacer(),
                  Text(
                    date.toString(),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            color: Colors.black,
            height: 0.5,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

void showFullImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      var edgeInsets = const EdgeInsets.all(10);
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: edgeInsets,
        child: GestureDetector(
          onTap: () => Navigator.pop(context), // Closes the dialog on tap
          child: PhotoViewGallery.builder(
            itemCount: 1,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        ),
      );
    },
  );
}
