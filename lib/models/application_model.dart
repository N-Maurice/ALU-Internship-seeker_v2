import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  submitted,
  underReview,
  interview,
  accepted,
  rejected;

  static ApplicationStatus fromString(String? value) =>
      ApplicationStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ApplicationStatus.submitted,
      );

  String get label => switch (this) {
        ApplicationStatus.submitted => 'New',
        ApplicationStatus.underReview => 'Reviewing',
        ApplicationStatus.interview => 'Interviewed',
        ApplicationStatus.accepted => 'Accepted',
        ApplicationStatus.rejected => 'Rejected',
      };
}

class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    this.status = ApplicationStatus.submitted,
    this.cvUrl,
    this.portfolioUrl,
    required this.appliedAt,
    required this.updatedAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentId;
  final ApplicationStatus status;
  final String? cvUrl;
  final String? portfolioUrl;
  final DateTime appliedAt;
  final DateTime updatedAt;

  factory ApplicationModel.fromMap(String id, Map<String, dynamic> map) =>
      ApplicationModel(
        id: id,
        opportunityId: map['opportunityId'] as String? ?? '',
        opportunityTitle: map['opportunityTitle'] as String? ?? '',
        startupId: map['startupId'] as String? ?? '',
        startupName: map['startupName'] as String? ?? '',
        studentId: map['studentId'] as String? ?? '',
        status: ApplicationStatus.fromString(map['status'] as String?),
        cvUrl: map['cvUrl'] as String?,
        portfolioUrl: map['portfolioUrl'] as String?,
        appliedAt: (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'opportunityId': opportunityId,
        'opportunityTitle': opportunityTitle,
        'startupId': startupId,
        'startupName': startupName,
        'studentId': studentId,
        'status': status.name,
        'cvUrl': cvUrl,
        'portfolioUrl': portfolioUrl,
        'appliedAt': Timestamp.fromDate(appliedAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
