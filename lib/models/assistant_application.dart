class AssistantApplication {
  final String id;
  final String userId;
  final int currentYear;
  final String module1Level;
  final String module1Name;
  final String? module2Level;
  final String? module2Name;
  final bool eligibilityConfirmed;
  final String? documentUrl;
  final String status;
  final DateTime createdAt;

  AssistantApplication({
    required this.id,
    required this.userId,
    required this.currentYear,
    required this.module1Level,
    required this.module1Name,
    this.module2Level,
    this.module2Name,
    required this.eligibilityConfirmed,
    this.documentUrl,
    required this.status,
    required this.createdAt,
  });

  factory AssistantApplication.fromJson(Map<String, dynamic> json) {
    return AssistantApplication(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      currentYear: json['current_year'],
      module1Level: json['module1_level'] ?? '',
      module1Name: json['module1_name'] ?? '',
      module2Level: json['module2_level'],
      module2Name: json['module2_name'],
      eligibilityConfirmed: json['eligibility_confirmed'] ?? false,
      documentUrl: json['document_url'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}