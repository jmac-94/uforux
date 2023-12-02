import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/services/database.dart';
import 'package:uforuxpi3/structures/pair.dart';
import 'package:uuid/uuid.dart';

import 'package:uforuxpi3/models/comment.dart';
import 'package:uforuxpi3/util/dprint.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String userId;
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
      initialFetchDone = true;
    }
  }

  Future<void> fetchComment({bool isRefresh = false, String id = ''}) async {
    if (isLoading) return;

    isLoading = true;

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
      initialFetchDone = true;
    }
  }

  // Map<String, List<Pair<String, File>>> files
  // Map de key = Type
  // value = Lista de pairs(filename, file)
  Future<void> submitComment(
      String text, Map<String, List<Pair<String, File>>>? filesMap) async {
    try {
      if (text.trim().isEmpty) return;

      final querySnapshot = await getGeneralForum();

      if (querySnapshot.docs.isNotEmpty) {
        final forumDocumentSnapshot = querySnapshot.docs.first;

        final String commentId = uuid.v1();

        final Map<String, List<String>> attachments =
            await submitFiles(commentId, filesMap);

        final newComment = Comment(
          id: commentId,
          userId: userId,
          text: text,
          ups: 0,
          createdAt: Timestamp.now(),
          attachments: attachments,
        );

        Map<String, dynamic> jsonComment = newComment.toJson();

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

  // Map<String, List<Pair<String, File>>> files
  // Map de key = Type
  // value = Lista de pairs(filename, file)
  Future<Map<String, List<String>>> submitFiles(
      String commentId, Map<String, List<Pair<String, File>>>? filesMap) async {
    try {
      Map<String, List<String>> attachments = {};

      if (filesMap != null) {
        for (var entry in filesMap.entries) {
          for (var pair in entry.value) {
            String type = entry.key;
            String? filePath =
                await submitFile(commentId, type, pair.first, pair.second);

            if (filePath != null) {
              if (attachments.containsKey(entry.key)) {
                attachments[type]!.add(filePath);
              } else {
                attachments[type] = [filePath];
              }
            }
          }
        }
      }

      return attachments;
    } catch (e) {
      dPrint(e);
      return {};
    }
  }

  Future<String?> submitFile(
      String commentId, String type, String fileName, File file) async {
    try {
      final querySnapshot = await getGeneralForum();
      final documentSnapshot = querySnapshot.docs.first;
      final String forumId = documentSnapshot.id;

      String filePath = 'forums/$forumId/comments/$commentId/$type/$fileName';

      final ref = _storage.ref().child(filePath);
      await ref.putFile(file);

      return filePath;
    } catch (e) {
      dPrint(e);
      return null;
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

  Future<Image> getImage(String imagePath) async {
    final ref = _storage.ref().child(imagePath);
    final url = await ref.getDownloadURL();
    return Image.network(url);
  }

  Future<String> getImageUrl(String imagePath) async {
    final ref = _storage.ref().child(imagePath);
    final url = await ref.getDownloadURL();
    return url;
  }

  // Future<void> downloadFile(String firebaseFilePath) async {
  //   final status = await Permission.storage.request();

  //   if (status.isGranted) {
  //     try {
  //       final url = await getImageUrl(firebaseFilePath);

  //       final dio = Dio();
  //       final dir =
  //           '${(await getApplicationDocumentsDirectory()).path}/Download';
  //       final fileName = firebaseFilePath.split('/').last;
  //       final mobileFilePath = '$dir/$fileName';

  //       await dio.download(url, mobileFilePath);
  //     } catch (e) {
  //       dPrint('Download error: $e');
  //     }
  //   } else {
  //     dPrint('Storage permission not granted');
  //   }
  // }

  // Future<void> downloadImage(String imagePath) async {
  //   final status = await Permission.storage.request();

  //   if (status.isGranted) {
  //     try {
  //       final url = await getImageUrl(imagePath);

  //       final dio = Dio();
  //       final dir = await ExtStorage.getExternalStoragePublicDirectory(
  //           ExtStorage.DIRECTORY_DOWNLOADS);
  //       final fileName = imagePath.split('/').last;
  //       final filePath = '$dir/$fileName';

  //       await dio.download(url, filePath);
  //     } catch (e) {
  //       dPrint('Download error: $e');
  //     }
  //   } else {
  //     dPrint('Storage permission not granted');
  //   }
  // }
}
