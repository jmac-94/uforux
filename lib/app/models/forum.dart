import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forux/app/models/comment.dart';

class Forum {
  String? id;
  String? name;
  String? description;
  Timestamp? createdAt;
  Map<String, Comment> comments;

  Forum({
    this.id,
    this.name,
    this.description,
    this.createdAt,
    required this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'comments': comments.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  static Forum fromJson(Map<String, dynamic> json) {
    return Forum(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'] as Timestamp,
      comments: (json['comments'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Comment.fromJson(value)),
      ),
    );
  }
}
