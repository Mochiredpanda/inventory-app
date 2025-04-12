import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/Pages/welcome_page.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/rxdart.dart';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
// Mock sign in with email and password
  late MockUser tUser;

  setUp(
    () {
      tUser = MockUser(
        isAnonymous: false,
        email: 'bob@thebuilder.com',
        displayName: 'Bob Builder',
      );
    },
  );

  group('Returns a mocked user after sign in', () {
    test('sign in with email and password', () async {
      final email = 'some@email.com';
      final password = 'some!password';
      final auth = MockFirebaseAuth();
      final result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = result.user!;
      expect(user.email, email);
      final providerData = user.providerData;
      expect(providerData.length, 1);
      expect(providerData.first.providerId, 'password');
      expect(providerData.first.email, 'some@email.com');
      expect(providerData.first.uid, user.uid);

      expect(auth.authStateChanges(), emitsInOrder([null, isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([null, isA<User>()]));
      expect(user.isAnonymous, isFalse);
      expect(user.emailVerified, isTrue);
    });

    testWidgets('Test accessibility', (WidgetTester tester) async {
      // Accessibility
      expect(tester, meetsGuideline(textContrastGuideline));
      expect(tester, meetsGuideline(androidTapTargetGuideline));
      expect(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
