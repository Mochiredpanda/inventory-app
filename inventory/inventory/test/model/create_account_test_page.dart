import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/Pages/create_account_page.dart';
import 'package:inventory/Pages/welcome_page.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/rxdart.dart';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  testWidgets('CreateAccountPage UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(
      () async {
        await Firebase.initializeApp();
      },
    );
    // await tester.pumpWidget(MaterialApp(
    //   home: CreateAccountPage(),
    // ));

    /// Build our app and trigger a frame.
    await tester.pumpWidget(const CreateAccountPage());
    await tester.pumpAndSettle();

    // // Verify that the necessary widgets are present on the screen.
    // testWidgets("Enters required information to create an account",
    //     (WidgetTester) async {
    //   expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    //   expect(find.text('First name*'), findsOneWidget);
    //   expect(find.text('Last name*'), findsOneWidget);
    //   expect(find.text('Email*'), findsOneWidget);
    //   expect(find.text('Password*'), findsOneWidget);
    //   expect(find.text('Confirm Password*'), findsOneWidget);
    //   expect(find.text('Create Account'), findsOneWidget);
    // });

    // await tester.enterText(find.text('Jane'), 'Joseph');

    // Perform actions and test interactions.
    await tester.enterText(find.byKey(Key('myKey1')), 'John');
    await tester.enterText(find.byKey(Key('myKey2')), 'Doe');
    await tester.enterText(find.byKey(Key('myKey3')), 'john.doe@example.com');
    await tester.enterText(find.byKey(Key('myKey4')), 'password123');
    await tester.enterText(find.byKey(Key('myKey5')), 'password123');

    await tester.tap(find.text('Create Account'));
    await tester.pump();

    // Verify that the loading indicator appears.
    //   expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // });
  });
}
