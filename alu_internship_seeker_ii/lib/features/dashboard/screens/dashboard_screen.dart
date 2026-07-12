import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../shared/widgets/section_card.dart';
import '../../authentication/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/recent_alerts.dart';
import '../widgets/recommended_opportunities.dart';
import '../widgets/upcoming_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    final stats = ref.watch(applicationStatsProvider);
    final alerts = ref.watch(recentAlertsProvider);
    final recommended = ref.watch(recommendedOpportunitiesProvider);
    final nameParts = (profile?.fullName ?? '').trim().split(' ');
    final firstName = nameParts.first.isNotEmpty ? nameParts.first : 'there';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALU Venture Connect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications are coming in a future update.')),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Hello, $firstName',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Welcome back to the ALU career hub.',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Application Status',
              trailing: TextButton(
                onPressed: () => context.go('/applications'),
                child: const Text('View All  →'),
              ),
              child: Row(
                children: [
                  _StatTile('${stats.applied}', 'APPLIED'),
                  _StatTile('${stats.interviews}', 'INTERVIEWS', highlighted: true),
                  _StatTile('${stats.offers}', 'OFFERS', accent: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(title: 'Recent Alerts', child: RecentAlerts(alerts: alerts)),
            const SizedBox(height: 20),
            const SectionCard(title: 'Upcoming', child: UpcomingWidget()),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Recommended Opportunities',
              child: RecommendedOpportunities(opportunities: recommended),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.value, this.label, {this.highlighted = false, this.accent = false});

  final String value;
  final String label;
  final bool highlighted;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: highlighted ? AppColors.navy : Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: highlighted ? Colors.white : (accent ? AppColors.red : AppColors.textPrimary),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1,
                color: highlighted ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
