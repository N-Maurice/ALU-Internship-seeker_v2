import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  founder,
  admin;

  static UserRole fromString(String? value) => UserRole.values.firstWhere(
        (r) => r.name == value,
        orElse: () => UserRole.student,
      );
}

class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.role = UserRole.student,
    this.program,
    this.graduationYear,
    this.skills = const [],
    this.portfolioLinks = const [],
    this.interests = const [],
    this.savedOpportunityIds = const [],
    this.onboardingComplete = false,
    this.photoUrl,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final String? program;
  final int? graduationYear;
  final List<String> skills;
  final List<String> portfolioLinks;
  final List<String> interests;
  final List<String> savedOpportunityIds;
  final bool onboardingComplete;
  final String? photoUrl;
  final DateTime createdAt;

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) => UserModel(
        uid: uid,
        email: map['email'] as String? ?? '',
        fullName: map['fullName'] as String? ?? '',
        role: UserRole.fromString(map['role'] as String?),
        program: map['program'] as String?,
        graduationYear: map['graduationYear'] as int?,
        skills: List<String>.from(map['skills'] as List? ?? const []),
        portfolioLinks:
            List<String>.from(map['portfolioLinks'] as List? ?? const []),
        interests: List<String>.from(map['interests'] as List? ?? const []),
        savedOpportunityIds:
            List<String>.from(map['savedOpportunityIds'] as List? ?? const []),
        onboardingComplete: map['onboardingComplete'] as bool? ?? false,
        photoUrl: map['photoUrl'] as String?,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'email': email,
        'fullName': fullName,
        'role': role.name,
        'program': program,
        'graduationYear': graduationYear,
        'skills': skills,
        'portfolioLinks': portfolioLinks,
        'interests': interests,
        'savedOpportunityIds': savedOpportunityIds,
        'onboardingComplete': onboardingComplete,
        'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? fullName,
    String? program,
    int? graduationYear,
    List<String>? skills,
    List<String>? portfolioLinks,
    List<String>? interests,
    List<String>? savedOpportunityIds,
    bool? onboardingComplete,
    String? photoUrl,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        fullName: fullName ?? this.fullName,
        role: role,
        program: program ?? this.program,
        graduationYear: graduationYear ?? this.graduationYear,
        skills: skills ?? this.skills,
        portfolioLinks: portfolioLinks ?? this.portfolioLinks,
        interests: interests ?? this.interests,
        savedOpportunityIds: savedOpportunityIds ?? this.savedOpportunityIds,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
      );
}
