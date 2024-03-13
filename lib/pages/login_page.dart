import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/components/login_text_field.dart';
import 'package:coordimate/components/square_tile.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 50),

              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 50),

              const Text(
                  "Welcome back you've been missed",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                  )
              ),

              const SizedBox(height: 50),

              LoginTextField(
                controller: usernameController,
                hintText: "Enter your username",
                label: "Username",
                obscureText: false
              ),

              const SizedBox(height: 20),

              LoginTextField(
                controller: passwordController,
                hintText: "Enter your password",
                label: "Password",
                obscureText: true
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
                        color: Colors.blue,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              LoginButton(
                onTap: signUserIn,
                  text: "Login"
              ),

              const SizedBox(height: 50),

              Row(
                children: [
                  Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                        "Or continue with",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                        ),
                    ),
                  ),
                  Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              Row (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareTile(imagePath: 'lib/images/google.png'),

                  const SizedBox(width: 50),

                  SquareTile(imagePath: 'lib/images/facebook.png'),
                ],
              )


            ],
          ),
        ),
      ),
    );
  }
}