/// Firestore collection names, kept centralized so a rename is a one-line change.
abstract final class FirestoreCollections {
  static const users = 'users';
  static const opportunities = 'opportunities';
  static const applications = 'applications';
  static const startups = 'startups';
}

/// Spacing scale used across the design system (multiples of 4).
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadius {
  static const sm = 5.0;
  static const md = 8.0;
  static const lg = 12.0;
}

/// Domains allowed to sign up as students, matching the PDF's ALU email requirement.
const kAllowedEmailDomains = ['alustudent.com', 'alueducation.com', 'alueducation.org'];

const kGraduationYears = [2024, 2025, 2026, 2027, 2028, 2029];
