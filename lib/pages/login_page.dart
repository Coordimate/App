import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/components/login_text_field.dart';
import 'package:coordimate/components/square_tile.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/pages/meetings_page.dart';
import 'package:coordimate/data/storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final String pathEmail = 'lib/images/email.png';
  final String pathLock = 'lib/images/lock.png';
  final String backgroundImage = 'lib/images/circles.png';

  void signUserIn() async {
    if (passwordController.text.isNotEmpty && emailController.text.isNotEmpty) {
      final signInOK = await signUserInStorage(
          passwordController.text, emailController.text);

      if (signInOK) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MeetingsPage(),
          ),
        );
      }
    }
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // circles background
            // ClipRect(
            //   child: Align(
            //     alignment: Alignment.bottomCenter,
            //     heightFactor: 0.7, // Adjust this value to crop from the top
            //     child: Image.asset(
            //       backgroundImage,
            //       fit: BoxFit.cover,
            //       width: double.infinity,
            //     ),
            //   ),
            // ),

            const SizedBox(height: 30),

            const Text("Welcome Back",
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                )),

            const SizedBox(height: 30),

            LoginTextField(
              controller: emailController,
              hintText: "E-mail",
              label: "E-mail",
              obscureText: false,
              icon: pathEmail,
            ),

            const SizedBox(height: 25),

            LoginTextField(
              controller: passwordController,
              hintText: "Password",
              label: "Password",
              obscureText: true,
              icon: pathLock,
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: mediumBlue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            LoginButton(onTap: signUserIn, text: "Log In"),

            const SizedBox(height: 30),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareTile(imagePath: 'lib/images/google.png'),
                SizedBox(width: 50),
                SquareTile(imagePath: 'lib/images/facebook.png'),
              ],
            ),

            const SizedBox(height: 20),

            const Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: darkBlue,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: darkBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            LoginEmptyButton(
                text: "Register",
                onTap: _goToRegisterPage
            ),

          ],
        ),
      ),
    );
  }
}
