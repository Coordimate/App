import 'package:flutter/material.dart';
// import 'pages/login_page.dart';
// import 'pages/start_page.dart';
import 'pages/register_page.dart';
import 'pages/groups_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'OpenSans'),
        home: GroupsPage());
  }
}
*/
import 'package:flutter/material.dart';
import 'pages/groups_page.dart'; // Import only the groups page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'OpenSans'),
      home: GroupsPage(), // Set the groups page as the home page
    );
  }
}
