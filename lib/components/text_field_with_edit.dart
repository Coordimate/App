import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class EditableTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int? maxLines;
  final Function(String) onChanged;
  final double fontSize;
  final double padding;

  const EditableTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.fontSize = kDefaultFontSize,
    this.padding = 24.0,
    this.maxLines,
  });

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.controller,
        textAlign: TextAlign.center,
        readOnly: isEditing == false,
        focusNode: widget.focusNode,
        maxLines: widget.maxLines,
        keyboardType: TextInputType.text,
        style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.bold, color: darkBlue),
        onSubmitted: (value) {
          setState(() { isEditing = false; });
          widget.onChanged(value);
        },
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: isEditing
              ? const UnderlineInputBorder(borderSide: BorderSide(color: darkBlue))
              : InputBorder.none,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() { isEditing = !isEditing; });
              if (isEditing) {
                widget.focusNode.requestFocus();
              } else if (!isEditing) {
                widget.onChanged(widget.controller.text);
              }
            },
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: darkBlue,
              size: widget.fontSize - 4,
            ),
          ),
          contentPadding: EdgeInsets.only(left: widget.fontSize + widget.padding),
        ),
    );
  }
}