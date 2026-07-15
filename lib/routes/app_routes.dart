import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/screens/admin_pending_screen.dart';
import '../features/applications/screens/apply_screen.dart';
import '../features/applications/screens/applications_screen.dart';
import '../features/authentication/providers/auth_provider.dart';
import '../features/authentication/screens/forgot_password_screen.dart';
import '../features/authentication/screens/login_screen.dart';
import '../features/authentication/screens/signup_screen.dart';
import '../features/authentication/screens/verify_email_screen.dart';
import '../features/authentication/screens/welcome_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/founder/screens/applicant_management_screen.dart';
import '../features/founder/screens/applicant_profile_screen.dart';
import '../features/founder/screens/founder_dashboard_screen.dart';
import '../features/founder/screens/founder_profile_screen.dart';
import '../features/founder/screens/founder_startup_screen.dart';
import '../features/founder/screens/my_opportunities_screen.dart';
import '../features/founder/screens/opportunity_form_screen.dart';
import '../features/messaging/screens/chat_screen.dart';
import '../features/messaging/screens/conversations_screen.dart';
import '../features/onboarding/screens/founder_onboarding_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/opportunities/screens/opportunities_screen.dart';
import '../features/opportunities/screens/opportunity_detail_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/saved_opportunities_screen.dart';
import '../features/startups/screens/startup_profile_screen.dart';
import '../models/user_model.dart';
import '../shared/widgets/bottom_nav_bar.dart';

const _authRoutes = {'/welcome', '/login', '/signup', '/forgot-password'};

/// The student shell's 5 tabs — a founder landing on any of these gets
/// bounced to their own shell (defense in depth; `firestore.rules` is the
/// real boundary, this just avoids a confusing mixed-role UI state).
const _studentShellRoutes = {'/home', '/opportunities', '/applications', '/messages', '/profile'};

/// Bridges Riverpod auth/profile state into go_router's redirect logic:
/// listens to both streams and asks go_router to re-evaluate `redirect`
/// whenever either changes, without recreating the GoRouter itself (which
/// would blow away in-app navigation state).
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(authStateChangesProvider, (_, __) => notifyListeners());
    _ref.listen(currentUserProfileProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authStateChangesProvider);
    final loc = state.matchedLocation;

    // Auth state is still resolving on cold start — hold on the splash
    // route rather than bouncing to /welcome and back.
    if (authAsync.isLoading && !authAsync.hasValue) return null;

    final user = authAsync.value;
    if (user == null) {
      return _authRoutes.contains(loc) ? null : '/welcome';
    }

    if (!user.emailVerified) {
      return loc == '/verify-email' ? null : '/verify-email';
    }

    final profileAsync = _ref.read(currentUserProfileProvider);
    if (profileAsync.isLoading && !profileAsync.hasValue) return null;
    final profile = profileAsync.value;

    // Admins skip onboarding entirely and get a single screen, not a shell.
    if (profile?.role == UserRole.admin) {
      return loc == '/admin/pending' ? null : '/admin/pending';
    }

    final isFounder = profile?.role == UserRole.founder;
    final onboardingRoute = isFounder ? '/founder-onboarding' : '/onboarding';
    final onboarded = profile?.onboardingComplete ?? false;
    if (!onboarded) {
      return loc == onboardingRoute ? null : onboardingRoute;
    }

    final onAuthOrOnboardingRoute = _authRoutes.contains(loc) ||
        loc == '/onboarding' ||
        loc == '/founder-onboarding' ||
        loc == '/verify-email';
    final onWrongRoleShell =
        isFounder ? _studentShellRoutes.contains(loc) : loc.startsWith('/founder');

    if (onAuthOrOnboardingRoute || onWrongRoleShell) {
      return isFounder ? '/founder/home' : '/home';
    }
    return null;
  }
}

final _routerNotifierProvider = Provider((ref) => _RouterNotifier(ref));

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);
  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/verify-email', builder: (_, __) => const VerifyEmailScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(
        path: '/founder-onboarding',
        builder: (_, __) => const FounderOnboardingScreen(),
      ),
      GoRoute(path: '/admin/pending', builder: (_, __) => const AdminPendingScreen()),
      GoRoute(
        path: '/opportunities/:id',
        builder: (_, state) =>
            OpportunityDetailScreen(opportunityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/opportunities/:id/apply',
        builder: (_, state) => ApplyScreen(opportunityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/startups/:id',
        builder: (_, state) =>
            StartupProfileScreen(startupId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/saved',
        builder: (_, __) => const SavedOpportunitiesScreen(),
      ),
      GoRoute(
        path: '/founder/opportunities/new',
        builder: (_, __) => const OpportunityFormScreen(),
      ),
      GoRoute(
        path: '/founder/opportunities/:id/edit',
        builder: (_, state) =>
            OpportunityFormScreen(opportunityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/founder/applicants/:applicationId',
        builder: (_, state) =>
            ApplicantProfileScreen(applicationId: state.pathParameters['applicationId']!),
      ),
      GoRoute(path: '/founder/startup', builder: (_, __) => const FounderStartupScreen()),
      GoRoute(
        path: '/chat/:studentId/:startupId',
        builder: (_, state) => ChatScreen(
          studentId: state.pathParameters['studentId']!,
          startupId: state.pathParameters['startupId']!,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShellScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/opportunities', builder: (_, __) => const OpportunitiesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/applications', builder: (_, __) => const ApplicationsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/messages', builder: (_, __) => const ConversationsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => FounderShellScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/founder/home', builder: (_, __) => const FounderDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/founder/opportunities',
              builder: (_, __) => const MyOpportunitiesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/founder/applicants',
              builder: (_, state) => ApplicantManagementScreen(
                opportunityId: state.uri.queryParameters['opportunityId'],
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/founder/messages', builder: (_, __) => const ConversationsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/founder/profile', builder: (_, __) => const FounderProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});
