class User {
  final String name;

  const User({required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(name: json['name'] as String? ?? '');
  }
}
