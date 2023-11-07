import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uforuxpi3/models/comment.dart';
import 'package:uforuxpi3/util/dprint.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final int perPage = 20;
  bool isLoading = false;
  bool hasMoreData = true;
  bool initialFetchDone = false;
  List<Comment> comments = [];
  String userId;

  HomeController(this.userId);

  Future<void> fetchComments({bool isRefresh = false}) async {
    if (isLoading) return;

    isLoading = true;

    // Si es una operación de refresco, reiniciar la lista de comentarios y la bandera de más datos.
    if (isRefresh) {
      comments.clear();
      hasMoreData = true;
    }

    try {
      final querySnapshot = await _firestore
          .collection('forums')
          .where('name', isEqualTo: 'general')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentSnapshot = querySnapshot.docs.first;
        // ignore: unnecessary_cast
        final data = documentSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> commentsData = data['comments'] ?? [];

        // Determina el rango de comentarios a obtener
        final currentLength = comments.length;
        final nextFetchLimit = isRefresh ? perPage : currentLength + perPage;

        if (nextFetchLimit >= commentsData.length) {
          comments = commentsData.map((c) => Comment.fromJson(c)).toList();
          hasMoreData = false;
        } else {
          final List<Comment> newComments = commentsData
              .sublist(currentLength, nextFetchLimit)
              .map((c) => Comment.fromJson(c))
              .toList();
          comments.addAll(newComments);
        }
      }
    } catch (e) {
      dPrint(e);
      hasMoreData = false;
    } finally {
      isLoading = false;
      initialFetchDone =
          true; // Marca que la primera carga de datos se ha completado.
    }
  }

  Future<void> submitComment(String text,
      {List<String> attachments = const []}) async {
    if (text.trim().isEmpty) return;

    try {
      final querySnapshot = await _firestore
          .collection('forums')
          .where('name', isEqualTo: 'general')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final forumDocumentSnapshot = querySnapshot.docs.first;
        final newComment = Comment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          text: text,
          ups: 0,
          createdAt: Timestamp.now().toDate(),
          attachments: attachments,
        );

        await _firestore
            .collection('forums')
            .doc(forumDocumentSnapshot.id)
            .update({
          'comments': FieldValue.arrayUnion([newComment.toJson()]),
        });

        comments.add(newComment);
      }
    } catch (e) {
      dPrint(e);
    }
  }

  Future<String?> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.putFile(file);
      final fileUrl = await result.ref.getDownloadURL();
      return fileUrl;
    } catch (e) {
      dPrint(e);
      return null;
    }
  }

  Future<void> selectAndUploadFile(String text) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // Asumimos que se selecciona un solo archivo
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      // CAMBIAR ESTE FILEPATH POR FAVOR
      String filePath =
          'forums/forum_id/comments/comment_id/documents/$fileName';
      String? fileUrl = await uploadFile(file, filePath);
      if (fileUrl != null) {
        submitComment(text, attachments: [fileUrl]);
      }
    }
  }
}
