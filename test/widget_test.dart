// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_easy/features/BusTracking/bustracking.dart';
import 'package:ride_easy/features/HomePage/home.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:ride_easy/main.dart';

void main() {
  // setUpAll(() async {
  //   TestWidgetsFlutterBinding.ensureInitialized();
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // });

  testWidgets('Test AppBar widgets and Logout functionality', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('Hello, User'), findsOneWidget); // Check default user name
    expect(find.byIcon(Icons.location_on), findsOneWidget); // Check location icon
    expect(find.byType(CircleAvatar), findsOneWidget); // Check profile picture

    // Test PopupMenuButton
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Test GridView buttons and navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    // Test that buttons are present
    expect(find.text('Bus Tracking'), findsOneWidget);
    expect(find.text('Bus Schedule'), findsOneWidget);
    expect(find.text('Ticket Booking'), findsOneWidget);
    expect(find.text('Bus Seat Reserve'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('FeedBack'), findsOneWidget);

    // Test navigation
    await tester.tap(find.text('Bus Tracking'));
    await tester.pumpAndSettle();
    expect(find.byType(BusTrackingPage), findsOneWidget);
  });

}
