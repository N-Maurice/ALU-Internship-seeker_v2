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

/// A startup's public profile, owned by exactly one founder (`ownerUid`).
/// Read by students on every opportunity's detail page; written by the
/// owning founder (everything except `verificationStatus`) and by admins
/// (`verificationStatus` only) — see `firestore.rules` for the actual
/// enforcement of that split.
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

  Map<String, dynamic> toMap() => {
        'name': name,
        'industry': industry,
        'description': description,
        'logoUrl': logoUrl,
        'verificationStatus': verificationStatus.name,
        'ownerUid': ownerUid,
      };

  StartupModel copyWith({
    String? name,
    String? industry,
    String? description,
    String? logoUrl,
    VerificationStatus? verificationStatus,
  }) =>
      StartupModel(
        id: id,
        name: name ?? this.name,
        industry: industry ?? this.industry,
        description: description ?? this.description,
        logoUrl: logoUrl ?? this.logoUrl,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        ownerUid: ownerUid,
      );

  bool get isVerified => verificationStatus == VerificationStatus.verified;
}
