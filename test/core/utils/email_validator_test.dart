import 'package:campustrade/core/utils/email_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValidEmail', () {
    group('Happy Path', () {
      test('should return true for valid studentID@lamduan.mfu.ac.th email', () {
        // Standard valid student ID email should pass.
        expect(isValidEmail('6631501001@lamduan.mfu.ac.th'), isTrue);
      });

      test('should return true for another valid numeric student ID', () {
        // Another numeric student ID with required domain should pass.
        expect(isValidEmail('6512345678@lamduan.mfu.ac.th'), isTrue);
      });
    });

    group('Edge Cases', () {
      test('should return false for empty string', () {
        // Empty input cannot be a valid email.
        expect(isValidEmail(''), isFalse);
      });

      test('should throw TypeError for null input passed dynamically', () {
        // Null cannot be assigned to a non-nullable String parameter.
        expect(() => isValidEmail(null as dynamic), throwsA(isA<TypeError>()));
      });

      test('should return false for very short string', () {
        // Boundary-like short text should not match required full format.
        expect(isValidEmail('a'), isFalse);
      });

      test('should return false for email with trailing space', () {
        // Extra trailing whitespace breaks strict format validation.
        expect(isValidEmail('6631501001@lamduan.mfu.ac.th '), isFalse);
      });

      test('should return false for email with leading space', () {
        // Leading whitespace makes input invalid for strict matching.
        expect(isValidEmail(' 6631501001@lamduan.mfu.ac.th'), isFalse);
      });
    });

    group('Invalid Formats', () {
      test('should return false for input without @', () {
        // Missing @ symbol is not a valid email structure.
        expect(isValidEmail('6631501001lamduan.mfu.ac.th'), isFalse);
      });

      test('should return false for mfu domain without lamduan subdomain', () {
        // Business rule: only lamduan.mfu.ac.th is allowed.
        expect(isValidEmail('6631501001@mfu.ac.th'), isFalse);
      });

      test('should return false for gmail domain', () {
        // Business rule: non-university domains must fail.
        expect(isValidEmail('6631501001@gmail.com'), isFalse);
      });

      test('should return false for yahoo domain', () {
        // Business rule: non-university domains must fail.
        expect(isValidEmail('6631501001@yahoo.com'), isFalse);
      });

      test('should return false for empty local part @lamduan.mfu.ac.th', () {
        // Local part is required before @ in a valid email.
        expect(isValidEmail('@lamduan.mfu.ac.th'), isFalse);
      });

      test('should return false for non-numeric local part', () {
        // Local part must be a numeric student ID.
        expect(isValidEmail('student@lamduan.mfu.ac.th'), isFalse);
      });

      test('should return false for mixed local part letters and numbers', () {
        // Student ID format does not allow letters.
        expect(isValidEmail('66A1501001@lamduan.mfu.ac.th'), isFalse);
      });

      test('should return false for malformed domain user@.ac.th', () {
        // Incorrect domain structure should fail full pattern check.
        expect(isValidEmail('6631501001@.ac.th'), isFalse);
      });
    });

    group('Negative / Sad Path and Error Handling', () {
      test('should return false for uppercase domain due to strict match', () {
        // Function is case-sensitive, so uppercase domain does not pass.
        expect(isValidEmail('6631501001@LAMDUAN.MFU.AC.TH'), isFalse);
      });

      test('should return false for unexpected symbols after valid domain', () {
        // Unexpected trailing characters should fail exact suffix validation.
        expect(
          isValidEmail('6631501001@lamduan.mfu.ac.th.invalid'),
          isFalse,
        );
      });

      test('should return false for boundary case with one-digit student ID', () {
        // Boundary value: ID must be exactly 10 digits.
        expect(isValidEmail('1@lamduan.mfu.ac.th'), isFalse);
      });

      test('should return false for boundary case with 9-digit student ID', () {
        // Boundary below required length should fail.
        expect(isValidEmail('123456789@lamduan.mfu.ac.th'), isFalse);
      });

      test('should return false for boundary case with 11-digit student ID', () {
        // Boundary above required length should fail.
        expect(isValidEmail('12345678901@lamduan.mfu.ac.th'), isFalse);
      });
    });
  });
}