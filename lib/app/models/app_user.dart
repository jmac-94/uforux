class AppUser {
  final String id;
  final String? username;
  final String? degree;
  final String? entrySemester;
  final double? score;
  final bool? assesor;
  final List<String>? subscribedForums;

  AppUser(
      {required this.id,
      this.username,
      this.degree,
      this.entrySemester,
      this.score,
      this.assesor,
      this.subscribedForums});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'degree': degree,
      'entrySemester': entrySemester,
      'score': score,
      'assesor': assesor,
      'subscribedForums': subscribedForums,
    };
  }

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
        id: json['id'],
        username: json['username'],
        degree: json['degree'],
        entrySemester: json['entrySemester'],
        score: json['score'],
        assesor: json['assesor'],
        subscribedForums: json['subscribedForums']);
  }
}
