import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String text;
  final int ups;
  final DateTime createdAt;
  final List<String> attachments;

  Comment({
    required this.id,
    required this.userId,
    required this.text,
    required this.ups,
    required this.createdAt,
    required this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'ups': ups,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'attachments': attachments,
    };
  }

  static Comment fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      text: json['text'],
      ups: json['ups'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      attachments: (json['attachments'] as List<dynamic>)
          .map((a) => a as String)
          .toList(),
    );
  }
}
