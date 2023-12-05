import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uforuxpi3/app/models/app_user.dart';

class Comment {
  final String id;
  final String userId;
  AppUser? author;
  String text;
  int ups;
  final Timestamp createdAt;
  final Map<String, List<String>> attachments;
  Map<String, Comment>? comments;

  Comment({
    required this.id,
    required this.userId,
    this.author,
    required this.text,
    required this.ups,
    required this.createdAt,
    required this.attachments,
    this.comments,
  });

  bool hasDocuments() {
    return attachments['documents']?.isNotEmpty ?? false;
  }

  bool hasImages() {
    return attachments['images']?.isNotEmpty ?? false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'userId': userId,
      'text': text,
      'ups': ups,
      'createdAt': createdAt,
      'attachments': attachments,
    };

    if (comments != null) {
      json['comments'] =
          comments?.map((key, value) => MapEntry(key, value.toJson()));
    }

    return json;
  }

  static Comment fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> attachments =
        (json['attachments'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );

    Map<String, Comment>? comments;
    if (json.containsKey('comments')) {
      comments = (json['comments'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Comment.fromJson(value)),
      );
    }

    return Comment(
      id: json['id'],
      userId: json['userId'],
      text: json['text'],
      ups: json['ups'],
      createdAt: json['createdAt'] as Timestamp,
      attachments: attachments,
      comments: comments,
    );
  }
}
