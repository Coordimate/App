import 'package:coordimate/components/divider.dart';
import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/components/login_text_field.dart';
import 'package:coordimate/screens/home_screen.dart';
import 'package:coordimate/components/external_service_tile.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/pages/register_page.dart';
import 'package:coordimate/app_state.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/components/alert_dialog.dart';
import 'package:coordimate/widget_keys.dart';

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

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> signUserIn() async {
    if (_formKey.currentState!.validate() == false) {
      return;
    }
    setState(() {_isLoading = true;});
    if (passwordController.text.isNotEmpty && emailController.text.isNotEmpty) {
      final signInOK = await AppState.authController.signIn(
          emailController.text, AuthType.email, password : passwordController.text);

      if (mounted) {
        if (signInOK) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomeScreen(key: UniqueKey()),
            ),
            (route) => false,
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              _isLoading = false;
              return const CustomAlertDialog(
                key: alertDialogKey,
                title: 'Sign In Failed',
                content: 'The email or password is incorrect.',
              );
            },
          );
        }
      }
    }
    setState(() {_isLoading = false;});
  }

  void _goToRegisterPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        
              const Text("Welcome Back",
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                )
              ),
        
              const SizedBox(height: 24),
        
              Form(
                key: _formKey,
                child: Column(
                  children: [
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
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 24),
                    LoginButton(
                      key: loginButtonKey,
                      onTap: _isLoading ? null : signUserIn,
                      text: "Log In"
                    ),
                  ],
                ),
              ),
        
              const SizedBox(height: 24),
        
              const Row(
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
        
              const CustomDivider(text: "Do not have an account?"),
        
              const SizedBox(height: 16),
        
              LoginEmptyButton(
                key: registerButtonKey,
                text: "Register",
                onTap: _goToRegisterPage
              ),
            ],
          ),
        ),
      ),
    );
  }
}
