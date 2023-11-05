class Forum {
  final String name;
  final String description;
  final DateTime createdAt;
  final List<Map<String, dynamic>> comments;

  Forum({
    required this.name,
    required this.description,
    required this.createdAt,
    required this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'comments': comments,
    };
  }

  static Forum fromJson(Map<String, dynamic> json) {
    return Forum(
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      comments: (json['comments'] as List<dynamic>)
          .map((c) => c as Map<String, dynamic>)
          .toList(),
    );
  }
}
