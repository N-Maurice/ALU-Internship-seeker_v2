import 'package:alu_internship_seeker_ii/core/utilities/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('accepts any valid email domain', () {
      expect(Validators.email('j.doe@gmail.com'), isNull);
    });

    test('rejects a malformed email', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('rejects an empty value', () {
      expect(Validators.email(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('rejects passwords shorter than 8 characters', () {
      expect(Validators.password('short'), isNotNull);
    });

    test('accepts an 8+ character password', () {
      expect(Validators.password('longenoughpw'), isNull);
    });
  });

  group('Validators.fullName', () {
    test('rejects a single character', () {
      expect(Validators.fullName('J'), isNotNull);
    });

    test('accepts a real name', () {
      expect(Validators.fullName('Amina Hassan'), isNull);
    });
  });
}
