import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkMode {
  remote,
  hybrid,
  onSite;

  static WorkMode fromString(String? value) => WorkMode.values.firstWhere(
        (w) => w.name == value,
        orElse: () => WorkMode.remote,
      );

  String get label => switch (this) {
        WorkMode.remote => 'Remote',
        WorkMode.hybrid => 'Hybrid',
        WorkMode.onSite => 'On-site',
      };
}

enum OpportunityStatus {
  open,
  closed;

  static OpportunityStatus fromString(String? value) =>
      OpportunityStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => OpportunityStatus.open,
      );
}

class OpportunityModel {
  const OpportunityModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    this.startupLogoUrl,
    required this.title,
    required this.description,
    this.category = '',
    this.requiredSkills = const [],
    required this.duration,
    required this.location,
    this.workMode = WorkMode.remote,
    this.deadline,
    required this.postedAt,
    this.status = OpportunityStatus.open,
  });

  final String id;
  final String startupId;
  final String startupName;
  final String? startupLogoUrl;
  final String title;
  final String description;
  final String category;
  final List<String> requiredSkills;
  final String duration;
  final String location;
  final WorkMode workMode;
  final DateTime? deadline;
  final DateTime postedAt;
  final OpportunityStatus status;

  factory OpportunityModel.fromMap(String id, Map<String, dynamic> map) =>
      OpportunityModel(
        id: id,
        startupId: map['startupId'] as String? ?? '',
        startupName: map['startupName'] as String? ?? '',
        startupLogoUrl: map['startupLogoUrl'] as String?,
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        category: map['category'] as String? ?? '',
        requiredSkills:
            List<String>.from(map['requiredSkills'] as List? ?? const []),
        duration: map['duration'] as String? ?? '',
        location: map['location'] as String? ?? '',
        workMode: WorkMode.fromString(map['workMode'] as String?),
        deadline: (map['deadline'] as Timestamp?)?.toDate(),
        postedAt: (map['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: OpportunityStatus.fromString(map['status'] as String?),
      );

  Map<String, dynamic> toMap() => {
        'startupId': startupId,
        'startupName': startupName,
        'startupLogoUrl': startupLogoUrl,
        'title': title,
        'description': description,
        'category': category,
        'requiredSkills': requiredSkills,
        'duration': duration,
        'location': location,
        'workMode': workMode.name,
        'deadline': deadline == null ? null : Timestamp.fromDate(deadline!),
        'postedAt': Timestamp.fromDate(postedAt),
        'status': status.name,
      };

  bool get isOpen => status == OpportunityStatus.open;
}
