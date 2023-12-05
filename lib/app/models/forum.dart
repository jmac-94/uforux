import 'package:uforuxpi3/app/models/comment.dart';

class Forum {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final Map<String, Comment> comments;

  Forum({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'comments': comments.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  static Forum fromJson(Map<String, dynamic> json) {
    return Forum(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      comments: (json['comments'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Comment.fromJson(value)),
      ),
    );
  }
}
