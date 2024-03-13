import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final String label;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText, // for hiding password
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500]),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}

 // The  LoginTextField  widget is a stateless widget that takes a  label  parameter. This parameter is used to set the label of the  TextField  widget.
 // The  TextField  widget is wrapped in a  Padding  widget to add some padding around the  TextField .
 // The  TextField  widget has a  decoration  property that takes an  InputDecoration  widget. The  InputDecoration  widget is used to customize the appearance of the  TextField .
 // The  InputDecoration  widget has two properties:  enabledBorder  and  focusedBorder . The  enabledBorder  property is used to set the border color of the  TextField  when it is not focused. The  focusedBorder  property is used to set the border color of the  TextField  when it is focused.
 // The  labelText  property of the  InputDecoration  widget is used to set the label of the  TextField .
 // The  LoginTextField  widget is used in the  LoginPage  widget to create the username and password  TextField  widgets.
 // The  LoginPage  widget is used in the  MyApp  widget to create the login page.
 // The  MyApp  widget is the root widget of the application.