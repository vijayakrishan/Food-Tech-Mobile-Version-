class AuthResponse {
  final String token;
  final String type;
  final int? id;
  final String username;
  final String email;
  final String role;

  AuthResponse({
    required this.token,
    this.type = 'Bearer',
    this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      type: json['type'] as String? ?? 'Bearer',
      id: json['id'] as int?,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'ROLE_PRODUCER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
      'id': id,
      'username': username,
      'email': email,
      'role': role,
    };
  }

  bool get isProducer => role == 'ROLE_PRODUCER';
  bool get isTechnologist => role == 'ROLE_TECHNOLOGIST';
  bool get isAdmin => role == 'ROLE_ADMIN';

  String get displayRole {
    switch (role) {
      case 'ROLE_ADMIN':
        return 'Administrator';
      case 'ROLE_TECHNOLOGIST':
        return 'Food Technologist';
      case 'ROLE_PRODUCER':
      default:
        return 'Food Producer';
    }
  }
}
