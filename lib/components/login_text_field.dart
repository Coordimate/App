import 'package:coordimate/components/colors.dart';
import 'package:flutter/material.dart';

class LoginTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String label;
  final String icon;
  final TextInputType keyboardType;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.label,
    required this.icon,
    required this.keyboardType,
  });

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${widget.label}';
          }
          return null;
        },
        onSaved: (value) => widget.controller.text = value!,
        style: const TextStyle(
          fontSize: 22,
          color: darkBlue,
        ),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: alphaDarkBlue,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: darkBlue,
            ),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: alphaDarkBlue),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              widget.icon,
              height: 26,
              width: 26,
            ),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
            onPressed: () {
              setState(() {_obscureText = !_obscureText;});
            },
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: alphaDarkBlue,
            ),
          )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
        ),
      ),
    );
  }
}
