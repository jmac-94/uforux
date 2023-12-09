import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uforuxpi3/app/models/app_user.dart';

class Subcomment {
  final String id;
  final String userId;
  AppUser? author;

  String text;

  int ups;

  final Timestamp createdAt;
  final Map<String, List<String>> attachments;

  List<String> labels;

  Subcomment({
    required this.id,
    required this.userId,
    this.author,
    required this.text,
    required this.ups,
    required this.createdAt,
    required this.attachments,
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
      'text': text,
      'ups': ups,
      'createdAt': createdAt,
      'attachments': attachments,
      'labels': labels,
    };

    return json;
  }

  static Subcomment fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> attachments =
        Map<String, dynamic>.from(json['attachments']).map(
      (key, value) =>
          MapEntry<String, List<String>>(key, List<String>.from(value)),
    );

    List<String> labels = List<String>.from(json['labels']);

    return Subcomment(
      id: json['id'],
      userId: json['userId'],
      text: json['text'],
      ups: json['ups'],
      createdAt: json['createdAt'] as Timestamp,
      attachments: attachments,
      labels: labels,
    );
  }
}
