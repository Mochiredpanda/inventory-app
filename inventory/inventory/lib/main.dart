import 'package:flutter/material.dart';
import 'package:inventory/FirebaseSettings/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'FirebaseSettings/firebase_options.dart';

const Color themeColor = Color(0xff12CDD4);
/// Main, running the app here
/// 
/// The main starting point of Avenger's inventory app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

/// MY_APP: A widget that sets up the barebones app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avenger',
      home: const Auth(),
      theme: ThemeData(
        primaryColor: themeColor,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
