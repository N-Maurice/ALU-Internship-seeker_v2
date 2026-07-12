enum VerificationStatus {
  pending,
  verified,
  rejected;

  static VerificationStatus fromString(String? value) =>
      VerificationStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => VerificationStatus.pending,
      );

  String get label => switch (this) {
        VerificationStatus.pending => 'Pending',
        VerificationStatus.verified => 'ALU Approved',
        VerificationStatus.rejected => 'Rejected',
      };
}

/// Read-only in the student-facing phase — startups are managed by founders
/// in a later phase, but students need to view a startup's public profile.
class StartupModel {
  const StartupModel({
    required this.id,
    required this.name,
    required this.industry,
    required this.description,
    this.logoUrl,
    this.verificationStatus = VerificationStatus.pending,
    this.ownerUid,
  });

  final String id;
  final String name;
  final String industry;
  final String description;
  final String? logoUrl;
  final VerificationStatus verificationStatus;
  final String? ownerUid;

  factory StartupModel.fromMap(String id, Map<String, dynamic> map) => StartupModel(
        id: id,
        name: map['name'] as String? ?? '',
        industry: map['industry'] as String? ?? '',
        description: map['description'] as String? ?? '',
        logoUrl: map['logoUrl'] as String?,
        verificationStatus:
            VerificationStatus.fromString(map['verificationStatus'] as String?),
        ownerUid: map['ownerUid'] as String?,
      );

  bool get isVerified => verificationStatus == VerificationStatus.verified;
}
