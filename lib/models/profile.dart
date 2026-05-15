class Profile {
  final String id;
  final String fullName;
  final String? studentNumber;
  final String? email;
  final String role;
  final DateTime? createdAt;

  Profile({
    required this.id,
    required this.fullName,
    this.studentNumber,
    this.email,
    required this.role,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  bool get isStudent => role == 'student';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      studentNumber: json['student_number'],
      email: json['email'],
      role: json['role'] ?? 'student',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'student_number': studentNumber,
      'role': role,
    };
  }

  Profile copyWith({
    String? fullName,
    String? studentNumber,
    String? role,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      studentNumber: studentNumber ?? this.studentNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}