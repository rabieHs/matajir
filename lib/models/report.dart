class Report {
  final String id;
  final String reporterId;
  final String? reportedStoreId;
  final String? reportedUserId;
  final String reason;
  final String? description;
  final String status; // 'pending', 'reviewed', 'resolved', 'dismissed'
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for display purposes
  final String? reporterName;
  final String? reporterEmail;
  final String? reportedStoreName;
  final String? reportedUserName;
  final String? reportedUserEmail;
  final String? reviewedByName;

  Report({
    required this.id,
    required this.reporterId,
    this.reportedStoreId,
    this.reportedUserId,
    required this.reason,
    this.description,
    this.status = 'pending',
    this.reviewedBy,
    this.reviewedAt,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
    this.reporterName,
    this.reporterEmail,
    this.reportedStoreName,
    this.reportedUserName,
    this.reportedUserEmail,
    this.reviewedByName,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      reporterId: json['reporter_id'],
      reportedStoreId: json['reported_store_id'],
      reportedUserId: json['reported_user_id'],
      reason: json['reason'],
      description: json['description'],
      status: json['status'] ?? 'pending',
      reviewedBy: json['reviewed_by'],
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      reporterName: json['reporter_name'],
      reporterEmail: json['reporter_email'],
      reportedStoreName: json['reported_store_name'],
      reportedUserName: json['reported_user_name'],
      reportedUserEmail: json['reported_user_email'],
      reviewedByName: json['reviewed_by_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reported_store_id': reportedStoreId,
      'reported_user_id': reportedUserId,
      'reason': reason,
      'description': description,
      'status': status,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? reporterId,
    String? reportedStoreId,
    String? reportedUserId,
    String? reason,
    String? description,
    String? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? reporterName,
    String? reporterEmail,
    String? reportedStoreName,
    String? reportedUserName,
    String? reportedUserEmail,
    String? reviewedByName,
  }) {
    return Report(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reportedStoreId: reportedStoreId ?? this.reportedStoreId,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reporterName: reporterName ?? this.reporterName,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      reportedStoreName: reportedStoreName ?? this.reportedStoreName,
      reportedUserName: reportedUserName ?? this.reportedUserName,
      reportedUserEmail: reportedUserEmail ?? this.reportedUserEmail,
      reviewedByName: reviewedByName ?? this.reviewedByName,
    );
  }

  bool get isPending => status == 'pending';
  bool get isReviewed => status == 'reviewed';
  bool get isResolved => status == 'resolved';
  bool get isDismissed => status == 'dismissed';

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'reviewed':
        return 'Under Review';
      case 'resolved':
        return 'Resolved';
      case 'dismissed':
        return 'Dismissed';
      default:
        return 'Unknown';
    }
  }
}
