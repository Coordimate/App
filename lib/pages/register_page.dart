import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/components/login_text_field.dart';
import 'package:coordimate/screens/home_screen.dart';
import 'package:coordimate/components/external_service_tile.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/divider.dart';
import 'package:coordimate/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/components/alert_dialog.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/widget_keys.dart';

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
        final registrationOK = await AppState.authController.register(
            emailController.text,
            usernameController.text,
            AuthType.email,
            password : passwordController.text
        );

        if (mounted) {
          if (registrationOK) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeScreen(key: UniqueKey()),),
                  (route) => false,
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const CustomAlertDialog(
                  key: alertDialogKey,
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
              key: alertDialogKey,
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        const Text(
                                "Create Account",
                                style: TextStyle(
                                  color: darkBlue,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                )
                            ),

                        const SizedBox(height: 16),

                        Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: LoginTextField(
                                    key: usernameFieldKey,
                                    controller: usernameController,
                                    hintText: "Name",
                                    label: "name",
                                    obscureText: false,
                                    icon: pathPerson,
                                    keyboardType: TextInputType.name,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: LoginTextField(
                                    key: emailFieldKey,
                                    controller: emailController,
                                    hintText: "E-mail",
                                    label: "e-mail",
                                    obscureText: false,
                                    icon: pathEmail,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: LoginTextField(
                                    key: passwordFieldKey,
                                    controller: passwordController,
                                    hintText: "Password",
                                    label: "password",
                                    obscureText: true,
                                    icon: pathLock,
                                    keyboardType: TextInputType.visiblePassword,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: LoginTextField(
                                    key: confirmPasswordFieldKey,
                                    controller: confirmPasswordController,
                                    hintText: "Confirm Password",
                                    label: "password",
                                    obscureText: true,
                                    icon: pathLock,
                                    keyboardType: TextInputType.visiblePassword,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                LoginButton(
                                    key: registerButtonKey,
                                    onTap: registerUser,
                                    text: "Register"
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        const Row (
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SquareTile(
                              key: googleTileKey,
                              imagePath: 'lib/images/google.png',
                              authType: AuthType.google
                            ),

                            SizedBox(width: 48),

                            SquareTile(
                              key: facebookTileKey,
                              imagePath: 'lib/images/facebook.png',
                              authType: AuthType.facebook
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const CustomDivider(text: "Already have an account?"),

                        const SizedBox(height: 16),

                        LoginEmptyButton(
                            key: loginButtonKey,
                            text: "Log In",
                            onTap: _goToLogInPage
                        ),
                      ],
                    ),
            ),
          ),
      ),
    );
  }
}
