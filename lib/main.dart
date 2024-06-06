import 'package:http/http.dart' as http;
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/keys.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static AuthorizationController authCon = AuthorizationController(plainClient: http.Client());

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'OpenSans'),
        home: const StartPage());
  }
}
