import 'package:alu_internship_seeker_ii/models/application_model.dart';
import 'package:alu_internship_seeker_ii/models/opportunity_model.dart';
import 'package:alu_internship_seeker_ii/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    test('round-trips through toMap/fromMap', () {
      final user = UserModel(
        uid: 'u1',
        email: 'a@alustudent.com',
        fullName: 'Amina Hassan',
        role: UserRole.student,
        skills: const ['Flutter', 'Figma'],
        onboardingComplete: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final restored = UserModel.fromMap('u1', user.toMap());

      expect(restored.uid, 'u1');
      expect(restored.fullName, 'Amina Hassan');
      expect(restored.role, UserRole.student);
      expect(restored.skills, ['Flutter', 'Figma']);
      expect(restored.onboardingComplete, isTrue);
    });

    test('copyWith only changes the given fields', () {
      final user = UserModel(
        uid: 'u1',
        email: 'a@alustudent.com',
        fullName: 'Amina Hassan',
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = user.copyWith(skills: ['SQL']);

      expect(updated.skills, ['SQL']);
      expect(updated.fullName, 'Amina Hassan');
      expect(updated.uid, 'u1');
    });
  });

  group('OpportunityModel', () {
    test('round-trips through toMap/fromMap', () {
      final opportunity = OpportunityModel(
        id: 'o1',
        startupId: 's1',
        startupName: 'Nexus Analytics',
        postedByUid: 'founder1',
        title: 'Product Design Fellow',
        description: 'Bridge user needs and technical feasibility.',
        requiredSkills: const ['Figma', 'User Research'],
        duration: '6 Months',
        location: 'Kigali, Rwanda',
        workMode: WorkMode.hybrid,
        postedAt: DateTime(2026, 1, 1),
      );

      final restored = OpportunityModel.fromMap('o1', opportunity.toMap());

      expect(restored.title, 'Product Design Fellow');
      expect(restored.workMode, WorkMode.hybrid);
      expect(restored.requiredSkills, ['Figma', 'User Research']);
      expect(restored.isOpen, isTrue);
    });
  });

  group('ApplicationModel', () {
    test('round-trips through toMap/fromMap', () {
      final now = DateTime(2026, 1, 1);
      final application = ApplicationModel(
        id: 'a1',
        opportunityId: 'o1',
        opportunityTitle: 'Product Design Fellow',
        startupId: 's1',
        startupName: 'Nexus Analytics',
        studentId: 'u1',
        status: ApplicationStatus.interview,
        appliedAt: now,
        updatedAt: now,
      );

      final restored = ApplicationModel.fromMap('a1', application.toMap());

      expect(restored.status, ApplicationStatus.interview);
      expect(restored.status.label, 'Interview');
      expect(restored.opportunityTitle, 'Product Design Fellow');
    });
  });
}
