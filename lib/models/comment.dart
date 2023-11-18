import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  String text;
  int ups;
  final Timestamp createdAt;
  final Map<String, List<String>> attachments;
  Map<String, Comment>? comments;

  Comment({
    required this.id,
    required this.userId,
    required this.text,
    required this.ups,
    required this.createdAt,
    required this.attachments,
    this.comments,
  });

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
    Map<String, List<String>> attachments = {};

    if (json['attachments'] != null) {
      Map<String, dynamic> attachmentsJson = json['attachments'];
      attachmentsJson.forEach((key, value) {
        attachments[key] = List<String>.from(value);
      });
    }

    if (json.containsKey('comments')) {
      final Map<String, dynamic> jsonComments = json['comments'];

      final Map<String, Comment> c = jsonComments
          .map((key, value) => MapEntry(key, Comment.fromJson(value)));

      return Comment(
        id: json['id'],
        userId: json['userId'],
        text: json['text'],
        ups: json['ups'],
        createdAt: json['createdAt'] as Timestamp,
        attachments: attachments,
        comments: c,
      );
    }

    return Comment(
      id: json['id'],
      userId: json['userId'],
      text: json['text'],
      ups: json['ups'],
      createdAt: json['createdAt'] as Timestamp,
      attachments: attachments,
    );
  }
}
