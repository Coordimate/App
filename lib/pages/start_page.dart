import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/square_tile.dart';
import 'package:coordimate/screens/home_screen.dart';
import 'package:coordimate/pages/login_page.dart';
import 'package:coordimate/pages/register_page.dart';
import 'package:coordimate/data/storage.dart';
import 'package:coordimate/api_client.dart';
import 'package:coordimate/keys.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final String backgroundImage = 'lib/images/circles.png';

  @override
  void initState() {
    super.initState();
    _checkStoredToken();
  }

  void _checkStoredToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");
    String? refreshToken = prefs.getString("refresh_token");
    if (accessToken != null && refreshToken != null) {
      await storage.write(key: 'access_token', value: accessToken);
      await storage.write(key: 'refresh_token', value: refreshToken);
    }
    final response = await client.get(Uri.parse('$apiUrl/me'));
    if (response.statusCode == 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(key: UniqueKey())),
        );
      });
    }
  }

  void _goToLogInPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _goToRegisterPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // circles background
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1, // Adjust this value to crop from the top
                child: Image.asset(
                  backgroundImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 70),

            const Text(
                "Coordimate",
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                )
            ),

            const SizedBox(height: 30),

            LoginButton(
                onTap: _goToLogInPage,
                text: "Log In"
            ),

            const SizedBox(height: 30),

            LoginButton(
                text: "Register",
                onTap: _goToRegisterPage
            ),

            const SizedBox(height: 50),

            const Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareTile(imagePath: 'lib/images/google.png'),

                SizedBox(width: 50),

                SquareTile(imagePath: 'lib/images/facebook.png'),
              ],
            ),

          ],
        ),
      ),
    );
  }
}