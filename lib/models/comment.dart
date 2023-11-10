import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uforuxpi3/util/dprint.dart';

class Comment {
  final String id;
  final String userId;
  final String text;
  final int ups;
  final Timestamp createdAt;
  final List<String> attachments;
  List<Comment>? comments;

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
    if (comments == null) {
      return {
        'id': id,
        'userId': userId,
        'text': text,
        'ups': ups,
        'createdAt': createdAt,
        'attachments': attachments,
      };
    }

    return {
      'id': id,
      'userId': userId,
      'text': text,
      'ups': ups,
      'createdAt': createdAt,
      'attachments': attachments,
      'comments': comments,
    };
  }

  static Comment fromJson(Map<String, dynamic> json) {
    if (json.containsKey('comments')) {
      dynamic c = (json['comments'] as List<dynamic>)
          .map((a) => Comment.fromJson(a))
          .toList();

      return Comment(
        id: json['id'],
        userId: json['userId'],
        text: json['text'],
        ups: json['ups'],
        createdAt: json['createdAt'] as Timestamp,
        attachments: (json['attachments'] as List<dynamic>)
            .map((a) => a as String)
            .toList(),
        comments: c,
      );
    }

    return Comment(
      id: json['id'],
      userId: json['userId'],
      text: json['text'],
      ups: json['ups'],
      createdAt: json['createdAt'] as Timestamp,
      attachments: (json['attachments'] as List<dynamic>)
          .map((a) => a as String)
          .toList(),
    );
  }

  void addSubcomment(Comment subcomment) {
    if (comments != null) {
      comments?.add(subcomment);
    } else {
      comments = [subcomment];
    }
  }
}
