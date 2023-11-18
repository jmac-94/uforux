import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/services/database.dart';
import 'package:uuid/uuid.dart';

import 'package:uforuxpi3/models/comment.dart';
import 'package:uforuxpi3/util/dprint.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String userId;
  // Lista de mapas con Key = comment.id y Value = comment
  Map<String, Comment> comments = {};

  final uuid = const Uuid();
  final int perPage = 20;
  bool isLoading = false;
  bool hasMoreData = true;
  bool initialFetchDone = false;

  HomeController(this.userId);

  Future<QuerySnapshot<Map<String, dynamic>>> getGeneralForum() async {
    return await _firestore
        .collection('forums')
        .where('name', isEqualTo: 'general')
        .limit(1)
        .get();
  }

  Future<void> overwriteComments(
      String forumId, Map<String, dynamic> jsonComments) async {
    try {
      await _firestore.collection('forums').doc(forumId).update({
        'comments': jsonComments,
      });

      comments = jsonComments
          .map((key, value) => MapEntry(key, Comment.fromJson(value)));
    } catch (e) {
      dPrint(e);
    }
  }

  Future<void> fetchComments({bool isRefresh = false}) async {
    if (isLoading) return;

    isLoading = true;

    // Si es una operación de refresco, reiniciar la lista de comentarios y la bandera de más datos.
    if (isRefresh) {
      comments.clear();
      hasMoreData = true;
    }

    try {
      final querySnapshot = await getGeneralForum();

      if (querySnapshot.docs.isNotEmpty) {
        final documentSnapshot = querySnapshot.docs.first;
        final data = documentSnapshot.data();
        final Map<String, dynamic> commentsData = data['comments'] ?? {};

        // Determina el rango de comentarios a obtener
        final currentLength = comments.length;
        final nextFetchLimit = isRefresh ? perPage : currentLength + perPage;

        if (nextFetchLimit >= commentsData.length) {
          comments = commentsData
              .map((key, value) => MapEntry(key, Comment.fromJson(value)));
          hasMoreData = false;
        } else {
          final Iterable<MapEntry<String, Comment>> entries = commentsData
              .entries
              .skip(currentLength)
              .take(nextFetchLimit - currentLength)
              .map((entry) =>
                  MapEntry(entry.key, Comment.fromJson(entry.value)));

          final Map<String, Comment> newComments = Map.fromEntries(entries);

          comments.addAll(newComments);
        }
      }
    } catch (e) {
      dPrint(e);
      hasMoreData = false;
    } finally {
      isLoading = false;
      // Marca que la primera carga de datos se ha completado.
      initialFetchDone = true;
    }
  }
  // Unique comment

  Future<void> fetchComment({bool isRefresh = false, String id = ''}) async {
    if (isLoading) return;

    isLoading = true;

    // Si es una operación de refresco, reiniciar la lista de comentarios y la bandera de más datos.
    if (isRefresh) {
      comments.clear();
      hasMoreData = true;
    }

    try {
      final querySnapshot = await getGeneralForum();

      if (querySnapshot.docs.isNotEmpty) {
        final documentSnapshot = querySnapshot.docs.first;
        final data = documentSnapshot.data();
        final Map<String, dynamic> commentData = data['comments'][id] ?? {};

        final Comment comment = Comment.fromJson(commentData);
        comments[comment.id] = comment;
      }
    } catch (e) {
      dPrint(e);
    } finally {
      isLoading = false;
      // Marca que la primera carga de datos se ha completado.
      initialFetchDone = true;
    }
  }

  /// Hace un submit de un comentario :3
  Future<void> submitComment(String text,
      {List<String> attachments = const []}) async {
    if (text.trim().isEmpty) return;

    try {
      final querySnapshot = await getGeneralForum();

      if (querySnapshot.docs.isNotEmpty) {
        final forumDocumentSnapshot = querySnapshot.docs.first;
        final newComment = Comment(
          id: uuid.v1(),
          userId: userId,
          text: text,
          ups: 0,
          createdAt: Timestamp.now(),
          attachments: attachments,
        );

        // Convert the new comment to JSON
        Map<String, dynamic> jsonComment = newComment.toJson();

        // Get the existing comments
        Map<String, dynamic> commentsData =
            forumDocumentSnapshot.data()['comments'] ?? {};

        commentsData[newComment.id] = jsonComment;

        await _firestore
            .collection('forums')
            .doc(forumDocumentSnapshot.id)
            .update({
          'comments': commentsData,
        });

        comments[newComment.id] = newComment;
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

  Future<void> submitSubcomment(Comment comment, Comment subcomment) async {
    try {
      final query = await getGeneralForum();

      if (query.docs.isNotEmpty) {
        final generalForum = query.docs.first;
        final generalForumData = generalForum.data();

        final String commentId = comment.id;

        final Map<String, dynamic> jsonComments =
            generalForumData['comments'] ?? {};

        final Map<String, dynamic> currentComment = jsonComments[commentId];

        if (currentComment.containsKey('comments')) {
          currentComment['comments'][subcomment.id] = subcomment.toJson();
        } else {
          currentComment['comments'] = {subcomment.id: subcomment.toJson()};
        }

        jsonComments[commentId] = currentComment;

        await overwriteComments(generalForum.id, jsonComments);
      }
    } catch (e) {
      dPrint(e);
    }
  }

  Future<AppUser> fetchAppUser(String id) async {
    final databaseService = DatabaseService(uid: id);
    final Map<String, dynamic> userJson = await databaseService.getUserData();
    return AppUser.fromJson(userJson);
  }

  Future<void> updateCommentLikes(String commentId, bool isLiked) async {
    try {
      final querySnapshot = await getGeneralForum();

      if (querySnapshot.docs.isNotEmpty) {
        final forumDocumentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> commentsData =
            forumDocumentSnapshot.data()['comments'] ?? {};

        Comment comment = Comment.fromJson(commentsData[commentId]);
        comment.ups = isLiked ? comment.ups + 1 : comment.ups - 1;
        commentsData[commentId] = comment.toJson();

        await _firestore
            .collection('forums')
            .doc(forumDocumentSnapshot.id)
            .update({
          'comments': commentsData,
        });

        comments[commentId] = comment;

        if (isLiked) {
          await _firestore.collection('user_likes').doc(userId).set({
            'liked_comments': {commentId: true}
          }, SetOptions(merge: true));
        } else {
          await _firestore.collection('user_likes').doc(userId).update({
            'liked_comments.$commentId': FieldValue.delete(),
          });
        }
      }
    } catch (e) {
      dPrint(e);
    }
  }

  Future<bool> fetchUserLikeStatus(String commentId) async {
    try {
      final docSnapshot =
          await _firestore.collection('user_likes').doc(userId).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> likedComments =
            docSnapshot.data()?['liked_comments'] ?? {};
        return likedComments.containsKey(commentId);
      }

      return false;
    } catch (e) {
      dPrint(e);
      return false;
    }
  }
}
