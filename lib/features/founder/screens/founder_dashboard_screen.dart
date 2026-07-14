import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../models/opportunity_model.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/founder_top_bar.dart';
import '../../../shared/widgets/section_card.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../applications/providers/application_provider.dart';
import '../../opportunities/providers/opportunity_provider.dart';
import '../../startups/providers/startup_provider.dart';
import '../widgets/verification_banner.dart';

class FounderDashboardScreen extends ConsumerWidget {
  const FounderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    final startup = ref.watch(myStartupProvider).value;
    final opportunities = ref.watch(myOpportunitiesProvider).value ?? const [];
    final applicants = ref.watch(applicantsForStartupProvider).value ?? const [];
    final isVerified = startup?.isVerified ?? false;
    final firstName = (profile?.fullName ?? '').trim().split(' ').firstOrNullSafe;

    void postOpportunity() {
      if (isVerified) {
        context.push('/founder/opportunities/new');
      } else {
        context.showSnack('Your startup must be approved before you can post.',
            isError: true);
      }
    }

    return Scaffold(
      appBar: const FounderTopBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: postOpportunity,
        backgroundColor: isVerified ? AppColors.navy : AppColors.textMuted,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Welcome back, ${firstName.isEmpty ? 'there' : firstName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Here is what is happening with your ventures today.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: '+ Post New Opportunity',
              onPressed: isVerified ? postOpportunity : null,
            ),
            if (!isVerified && startup != null) ...[
              const SizedBox(height: 16),
              VerificationBanner(status: startup.verificationStatus),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.campaign_outlined,
                    label: 'TOTAL OPPORTUNITIES',
                    value: '${opportunities.length}',
                    caption: 'Live across all sectors',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_outline,
                    label: 'ACTIVE APPLICATIONS',
                    value: '${applicants.length}',
                    caption: 'Across your ventures',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.mark_chat_unread_outlined,
                    label: 'NEW MESSAGES',
                    value: '0',
                    caption: 'Pending responses',
                    valueColor: AppColors.red,
                    onTap: () =>
                        context.showSnack('Messaging is coming in a future update.'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'My Opportunities',
              trailing: TextButton(
                onPressed: () => context.push('/founder/opportunities'),
                child: const Text('View All  →'),
              ),
              child: opportunities.isEmpty
                  ? const Text(
                      'Nothing posted yet — opportunities you create will show up here.',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < opportunities.length && i < 3; i++) ...[
                          if (i > 0) const Divider(),
                          _DashboardOpportunityRow(opportunity: opportunities[i]),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Talent Pool Insights',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Discover top candidates from the ALU ecosystem matching your needs.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: 'Browse Talent Pool',
                    variant: ButtonVariant.outlined,
                    onPressed: () => context.showSnack(
                        'Talent pool browsing is coming in a future update.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Resource Center',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Access guides on hiring best practices, ALU internship timelines, and legal templates.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Browse Library',
                          variant: ButtonVariant.outlined,
                          onPressed: () => context
                              .showSnack('Resource library is coming in a future update.'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () => context
                              .showSnack('Founder FAQs are coming in a future update.'),
                          child: const Text('Founder FAQs'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on List<String> {
  String get firstOrNullSafe => isNotEmpty && first.isNotEmpty ? first : '';
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.valueColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, size: 18, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    caption,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardOpportunityRow extends StatelessWidget {
  const _DashboardOpportunityRow({required this.opportunity});

  final OpportunityModel opportunity;

  Color get _pillColor => switch (opportunity.status) {
        OpportunityStatus.open => AppColors.success,
        OpportunityStatus.draft => AppColors.textSecondary,
        OpportunityStatus.closed => AppColors.error,
      };

  String get _pillLabel => switch (opportunity.status) {
        OpportunityStatus.open => 'ACTIVE',
        OpportunityStatus.draft => 'DRAFT',
        OpportunityStatus.closed => 'CLOSED',
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/founder/applicants?opportunityId=${opportunity.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opportunity.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '${opportunity.workMode.label} · ${opportunity.location}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(_pillLabel),
              backgroundColor: _pillColor.withValues(alpha: 0.12),
              labelStyle:
                  TextStyle(color: _pillColor, fontSize: 11, fontWeight: FontWeight.w700),
              visualDensity: VisualDensity.compact,
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    );
  }
}
