import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uforuxpi3/app/models/app_user.dart';

class Comment {
  final String id;
  final String userId;
  AppUser? author;

  String title;
  String description;

  int ups;

  final Timestamp createdAt;
  final Map<String, List<String>> attachments;

  Map<String, Comment>? comments;

  List<String> labels;

  Comment({
    required this.id,
    required this.userId,
    this.author,
    required this.title,
    required this.description,
    required this.ups,
    required this.createdAt,
    required this.attachments,
    this.comments,
    required this.labels,
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
      'title': title,
      'description': description,
      'ups': ups,
      'createdAt': createdAt,
      'attachments': attachments,
      'labels': labels,
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

    List<String> labels = List<String>.from(json['labels']);

    return Comment(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      ups: json['ups'],
      createdAt: json['createdAt'] as Timestamp,
      attachments: attachments,
      comments: comments,
      labels: labels,
    );
  }
}
