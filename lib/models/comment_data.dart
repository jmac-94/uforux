
import 'package:uforuxpi3/models/comment.dart';

class CommentData {
  final Comment comment;
  final String realTime;
  final String profilePhoto;
  final String image;
  final bool hasImage;

  CommentData({
    required this.comment,
    required this.realTime,
    required this.profilePhoto,
    required this.image,
    required this.hasImage,
  });
}