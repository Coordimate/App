import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/components/login_text_field.dart';
import 'package:coordimate/components/square_tile.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/pages/login_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final String pathEmail = 'lib/images/email.png';
  final String pathLock = 'lib/images/lock.png';
  final String pathPerson = 'lib/images/person.png';
  final String backgroundImage = 'lib/images/circles2.png';

  void registerUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      if (passwordController.text == confirmPasswordController.text) {

      }
    }
  }

  void _goToLogInPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
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
                heightFactor: 0.8, // Adjust this value to crop from the top
                child: Image.asset(
                  backgroundImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 30),
            //
            const Text(
                "Create Account",
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                )
            ),

            const SizedBox(height: 20),

            LoginTextField(
              controller: usernameController,
              hintText: "Name",
              label: "Name",
              obscureText: false,
              icon: pathPerson,
            ),

            const SizedBox(height: 15),

            LoginTextField(
              controller: emailController,
              hintText: "E-mail",
              label: "E-mail",
              obscureText: false,
              icon: pathEmail,
            ),

            const SizedBox(height: 15),

            LoginTextField(
              controller: passwordController,
              hintText: "Password",
              label: "Password",
              obscureText: true,
              icon: pathLock,
            ),

            const SizedBox(height: 15),

            LoginTextField(
              controller: confirmPasswordController,
              hintText: "Confirm Password",
              label: "Confirm Password",
              obscureText: true,
              icon: pathLock,
            ),

            const SizedBox(height: 20),

            LoginButton(
                onTap: registerUser,
                text: "Register"
            ),

            const SizedBox(height: 30),

            const Row (
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
                    "Already have an account?",
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
                text: "Log In",
                onTap: _goToLogInPage
            ),

          ],
        ),
      ),
    );
  }
}