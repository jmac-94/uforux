import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/models/subcomment.dart';

class Comment {
  final String id;
  final String userId;
  AppUser? author;

  String title;
  String description;

  int ups;

  final Timestamp createdAt;
  final Map<String, List<String>> attachments;

  Map<String, Subcomment>? subcomments;

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
    this.subcomments,
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

    if (subcomments != null) {
      json['subcomments'] =
          subcomments?.map((key, value) => MapEntry(key, value.toJson()));
    }

    return json;
  }

  static Comment fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> attachments =
        (json['attachments'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );

    Map<String, Subcomment>? subcomments;
    if (json.containsKey('subcomments')) {
      subcomments = (json['subcomments'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Subcomment.fromJson(value)),
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
      subcomments: subcomments,
      labels: labels,
    );
  }
}
