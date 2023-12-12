class AppUser {
  final String id;
  final String? username;
  final String? degree;
  final String? aboutMe;
  final String? entrySemester;
  final double? score;
  final bool? assesor;
  final List<String>? followedForums;

  AppUser(
      {required this.id,
      this.username,
      this.degree,
      this.aboutMe,
      this.entrySemester,
      this.score,
      this.assesor,
      this.followedForums});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'degree': degree,
      'aboutMe': aboutMe,
      'entrySemester': entrySemester,
      'score': score,
      'assesor': assesor,
      'followedForums': followedForums,
    };
  }

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
        id: json['id'],
        username: json['username'],
        degree: json['degree'],
        aboutMe: json['aboutMe'],
        entrySemester: json['entrySemester'],
        score: json['score'],
        assesor: json['assesor'],
        followedForums: List<String>.from(
            json['followedForums'].map((item) => item.toString())));
  }
}
