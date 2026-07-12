import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/application_model.dart';
import '../../../models/opportunity_model.dart';
import '../../applications/providers/application_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../opportunities/providers/opportunity_provider.dart';

class ApplicationStats {
  const ApplicationStats({this.applied = 0, this.interviews = 0, this.offers = 0});

  final int applied;
  final int interviews;
  final int offers;
}

final applicationStatsProvider = Provider<ApplicationStats>((ref) {
  final applications = ref.watch(applicationsStreamProvider).value ?? const [];
  return ApplicationStats(
    applied: applications.length,
    interviews: applications.where((a) => a.status == ApplicationStatus.interview).length,
    offers: applications.where((a) => a.status == ApplicationStatus.accepted).length,
  );
});

class DashboardAlert {
  const DashboardAlert({required this.message, required this.time});

  final String message;
  final DateTime time;
}

/// Derived honestly from real application status changes — there is no
/// separate notifications collection in this phase, so "recent alerts" is
/// simply the most recently updated applications that have moved past
/// "submitted".
final recentAlertsProvider = Provider<List<DashboardAlert>>((ref) {
  final applications = ref.watch(applicationsStreamProvider).value ?? const [];
  final moved = applications.where((a) => a.status != ApplicationStatus.submitted).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return moved
      .take(3)
      .map((a) => DashboardAlert(
            message: '${a.opportunityTitle} at ${a.startupName} moved to ${a.status.label}',
            time: a.updatedAt,
          ))
      .toList();
});

/// Simple recommendation: opportunities that share a skill with the
/// student's profile, most recently posted first; falls back to the newest
/// open opportunities if there's no skill overlap yet.
final recommendedOpportunitiesProvider = Provider<List<OpportunityModel>>((ref) {
  final opportunities = ref.watch(opportunitiesStreamProvider).value ?? const [];
  final skills = ref.watch(currentUserProfileProvider).value?.skills ?? const [];

  final matches = skills.isEmpty
      ? <OpportunityModel>[]
      : opportunities
          .where((o) => o.requiredSkills.any(skills.contains))
          .toList();
  final rest = opportunities.where((o) => !matches.contains(o)).toList();
  return [...matches, ...rest].take(3).toList();
});
