import 'package:forux/app/models/comment.dart';

class AppUser {
  final String id;
  String? username;
  String? name;
  String? degree;
  String? aboutMe;
  String? entrySemester;
  double? score;
  bool? assesor;
  Map<String, Comment>? comments;
  List<String>? followedForums;

  AppUser({
    required this.id,
    this.username,
    this.name,
    this.degree,
    this.aboutMe,
    this.entrySemester,
    this.score,
    this.assesor,
    this.comments,
    this.followedForums,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'degree': degree,
      'aboutMe': aboutMe,
      'entrySemester': entrySemester,
      'score': score,
      'assesor': assesor,
      'comments': _commentsToJson(),
      'followedForums': followedForums,
    };
  }

  Map<String, dynamic> _commentsToJson() {
    if (comments == null) {
      return {};
    }

    return comments!.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
  }

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
        id: json['id'],
        username: json['username'],
        name: json['name'],
        degree: json['degree'],
        aboutMe: json['aboutMe'],
        entrySemester: json['entrySemester'],
        score: json['score'],
        assesor: json['assesor'],
        comments: _commentsFromJson(json['comments']),
        followedForums: _followedForumsFromJson(json['followedForums']));
  }

  static Map<String, Comment> _commentsFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return {};
    }

    return json.map(
      (key, value) => MapEntry(key, Comment.fromJson(value)),
    );
  }

  static List<String> _followedForumsFromJson(List<dynamic>? json) {
    if (json == null) {
      return [];
    }

    return json.map((item) => item.toString()).toList();
  }
}
