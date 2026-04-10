import 'package:campustrade/features/login/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets(
      'shows password required when email is filled and login is tapped',
      (tester) async {
    // Render the widget in isolation.
    await pumpLogin(tester);

    // Enter only email, matching the classroom example flow.
    await tester.enterText(
      find.byKey(const Key('email_input')),
      'test@test.com',
    );

    // Tap by key for reliability instead of guessing button text.
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    // Verify expected validation message appears.
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows email required when login is tapped with empty form',
      (tester) async {
    // Render login component.
    await pumpLogin(tester);

    // Submit without filling any field.
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    // Email validator should trigger.
    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('shows invalid email format for malformed email', (tester) async {
    // Render login component.
    await pumpLogin(tester);

    // Enter malformed email and a password to isolate email validation.
    await tester.enterText(find.byKey(const Key('email_input')), 'invalid-email');
    await tester.enterText(find.byKey(const Key('password_input')), 'password123');

    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    // Ensure malformed email is rejected.
    expect(find.text('Invalid email format'), findsOneWidget);
  });

  testWidgets('sad path: shows password required for whitespace-only password',
      (tester) async {
    // Sad path: user enters only spaces as password.
    await pumpLogin(tester);

    await tester.enterText(
      find.byKey(const Key('email_input')),
      'test@test.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_input')),
      '   ',
    );

    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets(
      'sad path: shows password required for zero-width invisible password',
      (tester) async {
    // Sad path: password contains only invisible Unicode chars.
    await pumpLogin(tester);

    await tester.enterText(
      find.byKey(const Key('email_input')),
      'test@test.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_input')),
      '\u200B\u200B',
    );

    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('sad path: rejects overly long email boundary input',
      (tester) async {
    // Sad path boundary: email length exceeds common max length (254).
    await pumpLogin(tester);

    final tooLongEmail = '${'a' * 249}@x.com';
    await tester.enterText(
      find.byKey(const Key('email_input')),
      tooLongEmail,
    );
    await tester.enterText(
      find.byKey(const Key('password_input')),
      'password123',
    );

    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.text('Invalid email format'), findsOneWidget);
  });
}
