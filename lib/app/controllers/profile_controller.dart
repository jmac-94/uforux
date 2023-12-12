import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/models/comment.dart';
import 'package:forux/app/models/subcomment.dart';
import 'package:forux/core/utils/dprint.dart';
import 'package:uuid/uuid.dart';

class ProfileController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  AppUser loggedUser;

  static const uuid = Uuid();
  static const int perPage = 20;

  bool isLoading = false;
  bool hasMoreData = true;
  bool initialFetchDone = false;

  ProfileController({
    required this.loggedUser,
  });

  Map<String, Comment> commentsFromJson(Map<String, dynamic> json) {
    return json.map((key, value) =>
        MapEntry(key, Comment.fromJson(value as Map<String, dynamic>)));
  }

  Future<Map<String, Comment>> fetchComments() async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await firestore.collection('students').doc(loggedUser.id).get();

    final Map<String, dynamic>? data = docSnapshot.data();

    final Map<String, dynamic> commentsJson = data?['comments'] ?? {};

    return commentsFromJson(commentsJson);
  }

  Future<void> loadComments({bool isRefresh = false}) async {
    try {
      if (isLoading) return;

      isLoading = true;
      if (isRefresh) {
        loggedUser.comments!.clear();
        hasMoreData = true;
      }

      final int currentLength = loggedUser.comments!.length;
      final int nextFetchLimit = isRefresh ? perPage : currentLength + perPage;

      final Map<String, Comment> commentsData = await fetchComments();

      if (nextFetchLimit >= loggedUser.comments!.length) {
        loggedUser.comments = commentsData;
        hasMoreData = false;
      } else {
        final Iterable<MapEntry<String, Comment>> entries = commentsData.entries
            .skip(currentLength)
            .take(nextFetchLimit - currentLength);

        final Map<String, Comment> newComments = Map.fromEntries(entries);
        loggedUser.comments!.addAll(newComments);
      }
    } catch (e) {
      hasMoreData = false;
      dPrint(e);
    } finally {
      isLoading = false;
      initialFetchDone = true;
    }
  }

  Future<bool> hasUserLikedComment(String commentId) async {
    try {
      final docSnapshot =
          await firestore.collection('user_likes').doc(loggedUser.id).get();

      return docSnapshot.exists &&
          (docSnapshot.data()?['liked_comments'] ?? {}).containsKey(commentId);
    } catch (e) {
      dPrint(e);
      return false;
    }
  }

  // Comments
  Map<String, dynamic> commentsToJson() {
    return loggedUser.comments!
        .map((key, value) => MapEntry(key, value.toJson()));
  }

  Future<void> updateComments() async {
    try {
      // Actualizar comentarios en firestore
      Map<String, dynamic> commentsJson = commentsToJson();

      await firestore.collection('students').doc(loggedUser.id).update({
        'comments': commentsJson,
      });
    } catch (e) {
      dPrint(e);
    }
  }

  Future<void> submitSubcomment(
    Comment comment,
    Subcomment subcomment,
  ) async {
    if (loggedUser.comments!.containsKey(comment.id)) {
      final Comment currentComment = loggedUser.comments![comment.id]!;

      if (currentComment.subcomments != null) {
        currentComment.subcomments?[subcomment.id] = subcomment;
      } else {
        currentComment.subcomments = {subcomment.id: subcomment};
      }

      loggedUser.comments![comment.id] = currentComment;
      updateComments();
    }
  }

  Future<void> updateUserLikes(String commentId, bool isLiked) async {
    if (isLiked) {
      await firestore.collection('user_likes').doc(loggedUser.id).set({
        'liked_comments': {commentId: true}
      }, SetOptions(merge: true));
    } else {
      await firestore.collection('user_likes').doc(loggedUser.id).update({
        'liked_comments.$commentId': FieldValue.delete(),
      });
    }
  }

  Future<void> updateCommentLikes(String commentId, bool isLiked) async {
    try {
      if (loggedUser.comments!.containsKey(commentId)) {
        // Actualizar likes en los comentarios
        Comment comment = loggedUser.comments![commentId]!;
        comment.ups = max(0, comment.ups + (isLiked ? 1 : -1));
        loggedUser.comments![commentId] = comment;
        updateComments();

        // Actualizar likes en la coleccion user_likes
        updateUserLikes(commentId, isLiked);
      }
    } catch (e) {
      dPrint(e);
    }
  }
}
