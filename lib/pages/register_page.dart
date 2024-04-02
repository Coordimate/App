import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/components/login_text_field.dart';
import 'package:coordimate/screens/home_screen.dart';
import 'package:coordimate/components/square_tile.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/divider.dart';
import 'package:coordimate/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/data/storage.dart';
import 'package:coordimate/components/alert_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
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

  final _formKey = GlobalKey<FormState>();

  void registerUser() async {
    if (_formKey.currentState!.validate() == false) {
      return ;
    }
    // isEmpty is checked in the form validation
    if (passwordController.text.isNotEmpty && emailController.text.isNotEmpty && usernameController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty) {
      if (passwordController.text == confirmPasswordController.text) {
        final registrationOK = await registerUserStorage(
            passwordController.text,
            emailController.text,
            usernameController.text
        );

        if (mounted) {
          if (registrationOK) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomeScreen(key: UniqueKey()),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const CustomAlertDialog(
                  title: "Registration Failed",
                  content: "Please check your credentials",
                );
              },
            );
          }
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlertDialog(
              title: "Registration Failed",
              content: "Please check passwords match",
            );
          },
        );
        print("Passwords do not match");
      }
    } else {
      print("Please fill all fields");
    }
  }

  void _goToLogInPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
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
            //     heightFactor: 0.8, // Adjust this value to crop from the top
            //     child: Image.asset(
            //       backgroundImage,
            //       fit: BoxFit.cover,
            //       width: double.infinity,
            //     ),
            //   ),
            // ),

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

            Form(
              key: _formKey,
              child: Column(
                children: [
                  LoginTextField(
                    controller: usernameController,
                    hintText: "Name",
                    label: "name",
                    obscureText: false,
                    icon: pathPerson,
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 15),

                  LoginTextField(
                    controller: emailController,
                    hintText: "E-mail",
                    label: "e-mail",
                    obscureText: false,
                    icon: pathEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 15),

                  LoginTextField(
                    controller: passwordController,
                    hintText: "Password",
                    label: "password",
                    obscureText: true,
                    icon: pathLock,
                    keyboardType: TextInputType.visiblePassword,
                  ),

                  const SizedBox(height: 15),

                  LoginTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    label: "password",
                    obscureText: true,
                    icon: pathLock,
                    keyboardType: TextInputType.visiblePassword,
                  ),

                  const SizedBox(height: 20),

                  LoginButton(
                      onTap: registerUser,
                      text: "Register"
                  ),
                ],
              ),
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

            const CustomDivider(text: "Already have an account?"),

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