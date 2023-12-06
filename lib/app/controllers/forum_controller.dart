import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uforuxpi3/app/controllers/app_user_controller.dart';
import 'package:uforuxpi3/app/models/forum.dart';
import 'package:uuid/uuid.dart';

import 'package:uforuxpi3/app/models/app_user.dart';
import 'package:uforuxpi3/core/structures/pair.dart';
import 'package:uforuxpi3/app/models/comment.dart';
import 'package:uforuxpi3/core/utils/dprint.dart';

class ForumController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  static const uuid = Uuid();
  static const int perPage = 20;

  bool isLoading = false;
  bool hasMoreData = true;
  bool initialFetchDone = false;

  Forum forum;
  String loggedUserId;

  ForumController({
    required this.forum,
    required this.loggedUserId,
  });

  // Llamar a este metodo ni bien se inicia la clase
  Future<void> init() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('forums')
          .where('name', isEqualTo: forum.name)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final Map<String, dynamic> forumJson = doc.data();
        forumJson['id'] = doc.id;
        forum = Forum.fromJson(forumJson);
      }
    } catch (e) {
      dPrint(e);
    }
  }

  // Comments
  Map<String, dynamic> commentsToJson() {
    return forum.comments.map((key, value) => MapEntry(key, value.toJson()));
  }

  Map<String, Comment> commentsFromJson(Map<String, dynamic> json) {
    return json.map((key, value) =>
        MapEntry(key, Comment.fromJson(value as Map<String, dynamic>)));
  }

  Future<Map<String, Comment>> fetchComments() async {
    DocumentSnapshot<Map<String, dynamic>>? docSnapshot;
    QuerySnapshot<Map<String, dynamic>>? querySnapshot;

    // Si ya esta inicializado el foro con su id
    if (forum.id != null) {
      docSnapshot = await firestore.collection('forums').doc(forum.id).get();
    } else {
      querySnapshot = await firestore
          .collection('forums')
          .where('name', isEqualTo: forum.name)
          .limit(1)
          .get();
    }

    final Map<String, dynamic>? data =
        docSnapshot?.data() ?? querySnapshot?.docs.first.data();

    final Map<String, dynamic> commentsJson = data?['comments'] ?? {};

    return commentsFromJson(commentsJson);
  }

  Future<void> loadComments({bool isRefresh = false}) async {
    try {
      if (isLoading) return;

      isLoading = true;
      if (isRefresh) {
        forum.comments.clear();
        hasMoreData = true;
      }

      final int currentLength = forum.comments.length;
      final int nextFetchLimit = isRefresh ? perPage : currentLength + perPage;

      final Map<String, Comment> commentsData = await fetchComments();

      if (nextFetchLimit >= forum.comments.length) {
        forum.comments = commentsData;
        hasMoreData = false;
      } else {
        final Iterable<MapEntry<String, Comment>> entries = commentsData.entries
            .skip(currentLength)
            .take(nextFetchLimit - currentLength);

        final Map<String, Comment> newComments = Map.fromEntries(entries);
        forum.comments.addAll(newComments);
      }
    } catch (e) {
      hasMoreData = false;
      dPrint(e);
    } finally {
      isLoading = false;
      initialFetchDone = true;
    }
  }

  Future<void> updateComments() async {
    try {
      // Actualizar comentarios en firestore
      Map<String, dynamic> commentsJson = commentsToJson();

      if (forum.id != null) {
        await firestore.collection('forums').doc(forum.id).update({
          'comments': commentsJson,
        });
      } else {
        final querySnapshot = await firestore
            .collection('forums')
            .where('name', isEqualTo: forum.name)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await querySnapshot.docs.first.reference.update({
            'comments': commentsJson,
          });
        }
      }
    } catch (e) {
      dPrint(e);
    }
  }

  Future<void> updateCommentLikes(String commentId, bool isLiked) async {
    try {
      if (forum.comments.containsKey(commentId)) {
        // Actualizar likes en los comentarios
        Comment comment = forum.comments[commentId]!;
        comment.ups += isLiked ? 1 : -1;
        forum.comments[commentId] = comment;
        updateComments();

        // Actualizar likes en la coleccion user_likes
        updateUserLikes(commentId, isLiked);
      }
    } catch (e) {
      dPrint(e);
    }
  }

  // Map<String, List<Pair<String, File>>> files
  // Map de key = Type
  // value = Lista de pairs(filename, file)
  Future<void> submitComment(
    String title,
    String description,
    Map<String, List<Pair<String, File>>>? filesMap,
  ) async {
    try {
      // Solo se verifica que el title no este vacio
      // porque el comentario puede NO tener descripcion
      if (title.trim().isEmpty) return;

      final String newCommentId = uuid.v1();
      final Map<String, List<String>> attachments =
          await submitFiles(newCommentId, filesMap);

      final Comment newComment = Comment(
        id: newCommentId,
        userId: loggedUserId,
        title: title,
        description: description,
        ups: 0,
        createdAt: Timestamp.now(),
        attachments: attachments,
      );
      forum.comments[newComment.id] = newComment;

      updateComments();
    } catch (e) {
      dPrint(e);
    }
  }

  Future<void> submitSubcomment(
    Comment comment,
    Comment subcomment,
  ) async {
    if (forum.comments.containsKey(comment.id)) {
      final Comment currentComment = forum.comments[comment.id]!;

      if (currentComment.comments != null) {
        currentComment.comments?[subcomment.id] = subcomment;
      } else {
        currentComment.comments = {subcomment.id: subcomment};
      }

      forum.comments[comment.id] = currentComment;
      updateComments();
    }
  }

  // User
  Future<AppUser> fetchAppUser(String id) async {
    return (await AppUserController(uid: id).getUserData())!;
  }

  Future<void> updateUserLikes(String commentId, bool isLiked) async {
    if (isLiked) {
      await firestore.collection('user_likes').doc(loggedUserId).set({
        'liked_comments': {commentId: true}
      }, SetOptions(merge: true));
    } else {
      await firestore.collection('user_likes').doc(loggedUserId).update({
        'liked_comments.$commentId': FieldValue.delete(),
      });
    }
  }

  Future<bool> hasUserLikedComment(String commentId) async {
    try {
      final docSnapshot =
          await firestore.collection('user_likes').doc(loggedUserId).get();

      return docSnapshot.exists &&
          (docSnapshot.data()?['liked_comments'] ?? {}).containsKey(commentId);
    } catch (e) {
      dPrint(e);
      return false;
    }
  }

  // Files
  Future<String?> submitFile(
    String commentId,
    String type,
    String fileName,
    File file,
  ) async {
    final String filePath =
        'forums/${forum.id}/comments/$commentId/$type/$fileName';

    final Reference ref = storage.ref().child(filePath);
    await ref.putFile(file);

    return filePath;
  }

  Future<Map<String, List<String>>> submitFiles(
    String commentId,
    Map<String, List<Pair<String, File>>>? filesMap,
  ) async {
    Map<String, List<String>> attachments = {};

    if (filesMap != null) {
      for (var entry in filesMap.entries) {
        for (var pair in entry.value) {
          String type = entry.key;
          String? filePath =
              await submitFile(commentId, type, pair.first, pair.second);

          if (filePath != null) {
            attachments.putIfAbsent(type, () => []).add(filePath);
          }
        }
      }
    }

    return attachments;
  }

  // Images
  Future<String> fetchImageUrl(String imagePath) async {
    final Reference ref = storage.ref().child(imagePath);
    final String url = await ref.getDownloadURL();
    return url;
  }

  // No usa el metodo fetchImageUrl ya que sin usarlo es mas rapida la carga
  Future<Image> fetchImage(String imagePath) async {
    final Reference ref = storage.ref().child(imagePath);
    final String url = await ref.getDownloadURL();
    return Image.network(url);
  }

/*   Future<void> downloadFile(String firebaseFilePath) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        final url = await getImageUrl(firebaseFilePath);

        final dio = Dio();
        final dir =
            '${(await getApplicationDocumentsDirectory()).path}/Download';
        final fileName = firebaseFilePath.split('/').last;
        final mobileFilePath = '$dir/$fileName';

        await dio.download(url, mobileFilePath);
      } catch (e) {
        dPrint('Download error: $e');
      }
    } else {
      dPrint('Storage permission not granted');
    }
  }

  Future<void> downloadImage(String imagePath) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        final url = await getImageUrl(imagePath);

        final dio = Dio();
        final dir = await ExtStorage.getExternalStoragePublicDirectory(
            ExtStorage.DIRECTORY_DOWNLOADS);
        final fileName = imagePath.split('/').last;
        final filePath = '$dir/$fileName';

        await dio.download(url, filePath);
      } catch (e) {
        dPrint('Download error: $e');
      }
    } else {
      dPrint('Storage permission not granted');
    }
  } */
}
